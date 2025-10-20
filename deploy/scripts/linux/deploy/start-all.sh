#!/bin/bash

# ===================================
# 电商微服务项目 - Linux一键启动所有服务
# 版本: v1.0
# 作用: 按顺序启动基础设施和应用服务
# 支持: CentOS, Ubuntu, 其他主流发行版
# ===================================

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 输出函数
print_header() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}   电商微服务项目 - 一键启动所有服务${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${BLUE}[信息] $1${NC}"
}

print_step() {
    echo -e "${CYAN}[步骤] $1${NC}"
}

# 获取脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$(dirname "$(dirname "$SCRIPT_DIR")")")"
COMPOSE_DIR="$PROJECT_ROOT/deploy/docker-compose"

# 检查是否以root权限运行
check_root_permission() {
    if [ "$EUID" -ne 0 ]; then
        print_warning "建议使用root权限运行此脚本"
        print_info "如果遇到权限问题，请使用: sudo $0"
        read -p "是否继续运行？(y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
}

# 检查Docker环境
check_docker_environment() {
    print_step "Docker环境状态检查"

    # 检查Docker命令
    if ! command -v docker >/dev/null 2>&1; then
        print_error "Docker未安装"
        print_info "请先运行 ../init/check-environment.sh 安装Docker"
        exit 1
    fi

    # 检查Docker服务
    if ! docker info >/dev/null 2>&1; then
        print_error "Docker未运行"
        print_info "请启动Docker服务: sudo systemctl start docker"
        exit 1
    fi

    # 检查Docker Compose
    if ! command -v docker-compose >/dev/null 2>&1 && ! docker compose version >/dev/null 2>&1; then
        print_error "Docker Compose未安装"
        print_info "请先运行 ../init/check-environment.sh 安装Docker Compose"
        exit 1
    fi

    # 检查Docker权限
    if ! docker ps >/dev/null 2>&1; then
        print_warning "当前用户可能没有Docker权限"
        print_info "尝试使用sudo运行Docker命令"
    fi

    print_success "Docker环境检查通过"
}

# 检查网络
check_network() {
    print_step "Docker网络状态检查"

    if docker network inspect ecommerce-network >/dev/null 2>&1; then
        print_success "Docker网络 'ecommerce-network' 已存在"
    else
        print_warning "Docker网络 'ecommerce-network' 不存在"
        print_info "建议先运行 ../init/init-network.sh 创建网络"
        read -p "是否现在创建网络？(y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            if [ -f "$SCRIPT_DIR/../init/init-network.sh" ]; then
                "$SCRIPT_DIR/../init/init-network.sh"
                print_success "网络创建完成"
            else
                print_error "网络创建脚本不存在"
                exit 1
            fi
        else
            print_warning "跳过网络创建，服务启动可能失败"
        fi
    fi
}

# 检查配置文件
check_compose_files() {
    print_step "配置文件检查"

    local compose_files=("docker-compose.infra.yml" "docker-compose.apps.yml")
    local missing_files=0

    for file in "${compose_files[@]}"; do
        if [ -f "$COMPOSE_DIR/$file" ]; then
            print_success "$file 存在"
        else
            print_error "$file 不存在"
            missing_files=$((missing_files + 1))
        fi
    done

    if [ $missing_files -gt 0 ]; then
        print_error "发现 $missing_files 个配置文件缺失"
        print_info "请确保项目文件完整"
        exit 1
    else
        print_success "所有配置文件检查通过"
    fi
}

# 确定Docker Compose命令
get_docker_compose_cmd() {
    if command -v docker-compose >/dev/null 2>&1; then
        echo "docker-compose"
    else
        echo "docker compose"
    fi
}

# 启动基础设施服务
start_infrastructure() {
    print_step "启动基础设施服务"
    echo "正在启动：MySQL, Redis, Nacos, RocketMQ"
    echo

    cd "$COMPOSE_DIR" || exit 1

    local compose_cmd=$(get_docker_compose_cmd)

    if $compose_cmd -f docker-compose.infra.yml up -d; then
        print_success "基础设施服务启动命令已执行"
    else
        print_error "基础设施服务启动失败"
        exit 1
    fi

    # 等待基础设施服务就绪
    wait_infrastructure_ready
}

# 等待基础设施服务就绪
wait_infrastructure_ready() {
    print_info "等待基础设施服务健康检查..."

    local max_wait=120
    local wait_count=0
    local services=("mysql" "redis" "nacos" "rocketmq-nameserver" "rocketmq-broker")

    while [ $wait_count -lt $max_wait ]; do
        local healthy_count=0

        for service in "${services[@]}"; do
            if docker ps --filter "name=$service" --filter "status=running" --filter "health=healthy" --format "{{.Names}}" | grep -q "$service"; then
                healthy_count=$((healthy_count + 1))
            fi
        done

        printf "进度: %d/5 个服务健康 [%d/%d秒]\n" $healthy_count $wait_count $max_wait

        if [ $healthy_count -eq 5 ]; then
            print_success "所有基础设施服务已就绪"
            return 0
        fi

        if [ $wait_count -ge $max_wait ]; then
            print_warning "等待超时，部分服务可能未完全就绪"
            break
        fi

        sleep 2
        wait_count=$((wait_count + 2))
    done

    # 显示当前状态
    echo
    print_info "当前基础设施服务状态:"
    docker ps --filter "name=mysql\|redis\|nacos\|rocketmq" --format "table {{.Names}}\t{{.Status}}"
    echo
}

# 启动应用服务
start_applications() {
    print_step "启动应用服务"
    echo "正在启动：API Gateway, User Service, Product Service, Trade Service"
    echo

    cd "$COMPOSE_DIR" || exit 1

    local compose_cmd=$(get_docker_compose_cmd)

    if $compose_cmd -f docker-compose.apps.yml up -d; then
        print_success "应用服务启动命令已执行"
    else
        print_error "应用服务启动失败"
        exit 1
    fi

    # 等待应用服务就绪
    wait_applications_ready
}

# 等待应用服务就绪
wait_applications_ready() {
    print_info "等待应用服务健康检查..."

    local max_wait=60
    local wait_count=0
    local services=("api-gateway" "user-service" "product-service" "trade-service")

    while [ $wait_count -lt $max_wait ]; do
        local healthy_count=0

        for service in "${services[@]}"; do
            if docker ps --filter "name=$service" --filter "status=running" --filter "health=healthy" --format "{{.Names}}" | grep -q "$service"; then
                healthy_count=$((healthy_count + 1))
            fi
        done

        printf "进度: %d/4 个服务健康 [%d/%d秒]\n" $healthy_count $wait_count $max_wait

        if [ $healthy_count -eq 4 ]; then
            print_success "所有应用服务已就绪"
            return 0
        fi

        if [ $wait_count -ge $max_wait ]; then
            print_warning "等待超时，部分服务可能未完全就绪"
            break
        fi

        sleep 2
        wait_count=$((wait_count + 2))
    done

    # 显示当前状态
    echo
    print_info "当前应用服务状态:"
    docker ps --filter "name=api-gateway\|user-service\|product-service\|trade-service" --format "table {{.Names}}\t{{.Status}}"
    echo
}

# 显示最终状态
show_final_status() {
    print_step "启动完成状态总览"

    echo "📊 服务状态总览："
    echo
    docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep -E "(mysql|redis|nacos|rocketmq|api-gateway|user-service|product-service|trade-service|CONTAINER)" || true
    echo

    echo "🌐 访问地址："
    echo
    echo "基础设施服务："
    echo "- MySQL数据库:     localhost:3306"
    echo "- Redis缓存:      localhost:6379"
    echo "- Nacos控制台:    http://localhost:8848/nacos (nacos/nacos)"
    echo "- RocketMQ控制台: http://localhost:18080"
    echo
    echo "应用服务："
    echo "- API网关:        http://localhost:28080"
    echo "- 用户服务:       http://localhost:28081"
    echo "- 商品服务:       http://localhost:28082"
    echo "- 交易服务:       http://localhost:28083"
    echo
    echo "健康检查端点："
    echo "- API网关:        http://localhost:28080/actuator/health"
    echo "- 用户服务:       http://localhost:28081/actuator/health"
    echo "- 商品服务:       http://localhost:28082/actuator/health"
    echo "- 交易服务:       http://localhost:28083/actuator/health"
    echo

    echo "🛠️  常用操作："
    echo "- show-status.sh  - 查看详细服务状态"
    echo "- stop-all.sh     - 停止所有服务"
    echo "- restart-all.sh  - 重启所有服务"
    echo "- list-images.sh  - 查看镜像列表"
    echo
}

# 主函数
main() {
    print_header
    check_root_permission
    check_docker_environment
    check_network
    check_compose_files

    # 分阶段启动
    start_infrastructure
    start_applications
    show_final_status

    print_success "🎉 所有服务启动完成！"
}

# 处理命令行参数
case "${1:-}" in
    --help|-h)
        echo "用法: $0 [选项]"
        echo
        echo "选项:"
        echo "  --help, -h          显示此帮助信息"
        echo "  --infra-only        只启动基础设施服务"
        echo "  --apps-only         只启动应用服务"
        echo "  --no-wait           启动服务但不等待健康检查"
        echo "  --force             强制重新创建容器"
        echo
        echo "示例:"
        echo "  $0                  # 启动所有服务"
        echo "  $0 --infra-only     # 只启动基础设施"
        echo "  $0 --apps-only      # 只启动应用服务"
        echo "  $0 --force          # 强制重新创建并启动"
        exit 0
        ;;
    --infra-only)
        print_header
        check_root_permission
        check_docker_environment
        check_network
        check_compose_files
        start_infrastructure
        print_success "基础设施服务启动完成！"
        exit 0
        ;;
    --apps-only)
        print_header
        check_root_permission
        check_docker_environment
        check_compose_files
        start_applications
        print_success "应用服务启动完成！"
        exit 0
        ;;
    --no-wait)
        print_header
        check_root_permission
        check_docker_environment
        check_network
        check_compose_files

        cd "$COMPOSE_DIR" || exit 1
        local compose_cmd=$(get_docker_compose_cmd)

        print_step "启动基础设施服务"
        $compose_cmd -f docker-compose.infra.yml up -d

        print_step "启动应用服务"
        $compose_cmd -f docker-compose.apps.yml up -d

        print_success "服务启动完成（未等待健康检查）"
        print_info "请运行 show-status.sh 查看服务状态"
        exit 0
        ;;
    --force)
        print_header
        check_root_permission
        check_docker_environment
        check_network
        check_compose_files

        cd "$COMPOSE_DIR" || exit 1
        local compose_cmd=$(get_docker_compose_cmd)

        print_step "强制重新创建并启动所有服务"
        $compose_cmd -f docker-compose.infra.yml down
        $compose_cmd -f docker-compose.apps.yml down
        $compose_cmd -f docker-compose.infra.yml up -d --force-recreate
        $compose_cmd -f docker-compose.apps.yml up -d --force-recreate

        print_success "服务强制重新创建完成"
        print_info "请运行 show-status.sh 查看服务状态"
        exit 0
        ;;
esac

# 执行主函数
main "$@"