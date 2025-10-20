#!/bin/bash

# ===================================
# 电商微服务项目 - Linux环境初始化脚本
# 版本: v1.0
# 作用: 环境检查、网络创建、目录初始化
# 支持: CentOS, Ubuntu, 其他主流发行版
# ===================================

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 输出函数
print_header() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}   电商微服务项目 - 环境初始化${NC}"
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

# 获取脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$(dirname "$(dirname "$SCRIPT_DIR")")")"

# 解析命令行参数
ACTION="ALL"
SHOW_HELP=false

parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --help|-h)
                SHOW_HELP=true
                shift
                ;;
            -a)
                ACTION="ALL"
                shift
                ;;
            -c)
                ACTION="CHECK"
                shift
                ;;
            -i)
                ACTION="INIT"
                shift
                ;;
            *)
                print_error "未知参数: $1"
                echo "使用 --help 查看帮助信息"
                exit 1
                ;;
        esac
    done
}

parse_args "$@"

# 显示帮助信息
if [ "$SHOW_HELP" = "true" ]; then
    echo "用法: $0 [选项]"
    echo
    echo "选项:"
    echo "  -a              执行所有阶段（默认）"
    echo "  -c              只执行环境检查"
    echo "  -i              只执行初始化（网络和目录）"
    echo "  --help, -h      显示此帮助信息"
    echo
    echo "阶段说明:"
    echo "  环境检查: 检查Docker环境和系统要求，自动安装依赖"
    echo "  初始化:   创建Docker网络和项目目录结构"
    echo
    echo "示例:"
    echo "  $0              # 执行所有阶段"
    echo "  $0 -c           # 只检查环境"
    echo "  $0 -i           # 只初始化环境和目录"
    echo
    exit 0
fi

print_header
print_info "项目根目录: $PROJECT_ROOT"
print_info "脚本目录: $SCRIPT_DIR"
print_info "执行阶段: $ACTION"
echo

# 第一阶段：环境检查
if [ "$ACTION" = "ALL" ] || [ "$ACTION" = "CHECK" ]; then
    print_info "[阶段1] 环境检查"
    echo "========================================="
    echo "[检查1/6] Docker安装状态"

    if ! command -v docker &> /dev/null; then
        print_error "Docker未安装"
        print_info "开始自动安装Docker..."

        # 检测Linux发行版
        if [ -f /etc/os-release ]; then
            . /etc/os-release
            OS=$NAME
            VER=$VERSION_ID
        else
            print_error "无法检测Linux发行版"
            exit 1
        fi

        # 根据发行版安装Docker
        if [[ "$OS" == *"Ubuntu"* ]] || [[ "$OS" == *"Debian"* ]]; then
            print_info "检测到Ubuntu/Debian系统，开始安装Docker..."
            apt-get update
            apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release
            curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
            echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
            apt-get update
            apt-get install -y docker-ce docker-ce-cli containerd.io
        elif [[ "$OS" == *"CentOS"* ]] || [[ "$OS" == *"Red Hat"* ]]; then
            print_info "检测到CentOS/RHEL系统，开始安装Docker..."
            yum install -y yum-utils
            yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
            yum install -y docker-ce docker-ce-cli containerd.io
        else
            print_error "不支持的Linux发行版: $OS"
            print_info "请手动安装Docker: https://docs.docker.com/engine/install/"
            exit 1
        fi

        # 启动Docker服务
        systemctl start docker
        systemctl enable docker
        print_success "Docker安装完成"
    else
        DOCKER_VERSION=$(docker --version | awk '{print $3}' | sed 's/,//')
        print_success "Docker已安装: $DOCKER_VERSION"
    fi

    echo "[检查2/6] Docker服务运行状态"
    if ! docker info &> /dev/null; then
        print_error "Docker服务未运行"
        print_info "启动Docker服务..."
        systemctl start docker
        if docker info &> /dev/null; then
            print_success "Docker服务已启动"
        else
            print_error "Docker服务启动失败"
            exit 1
        fi
    else
        print_success "Docker服务正在运行"
    fi

    echo "[检查3/6] Docker Compose可用性"
    if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
        print_error "Docker Compose不可用"
        print_info "开始安装Docker Compose..."

        # 下载Docker Compose
        COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep 'tag_name' | cut -d\" -f4)
        curl -L "https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        chmod +x /usr/local/bin/docker-compose

        if command -v docker-compose &> /dev/null || docker compose version &> /dev/null; then
            COMPOSE_VERSION=$(docker-compose --version 2>/dev/null || docker compose version | awk '{print $3}' | sed 's/,//')
            print_success "Docker Compose安装成功: $COMPOSE_VERSION"
        else
            print_error "Docker Compose安装失败"
            exit 1
        fi
    else
        if command -v docker-compose &> /dev/null; then
            COMPOSE_VERSION=$(docker-compose --version | awk '{print $3}' | sed 's/,//')
        else
            COMPOSE_VERSION=$(docker compose version | awk '{print $3}' | sed 's/,//')
        fi
        print_success "Docker Compose可用: $COMPOSE_VERSION"
    fi

    echo "[检查4/6] 系统内存检查"
    TOTAL_MEMORY_KB=$(grep MemTotal /proc/meminfo | awk '{print $2}')
    TOTAL_MEMORY_GB=$((TOTAL_MEMORY_KB / 1024 / 1024))
    if [ $TOTAL_MEMORY_GB -ge 4 ]; then
        print_success "系统内存充足: ${TOTAL_MEMORY_GB}GB"
    else
        print_warning "系统内存较低: ${TOTAL_MEMORY_GB}GB (建议至少4GB)"
    fi

    echo "[检查5/6] 磁盘空间检查"
    FREE_SPACE_KB=$(df / | tail -1 | awk '{print $4}')
    FREE_SPACE_GB=$((FREE_SPACE_KB / 1024 / 1024))
    if [ $FREE_SPACE_GB -ge 10 ]; then
        print_success "磁盘空间充足: ${FREE_SPACE_GB}GB"
    else
        print_warning "磁盘空间较低: ${FREE_SPACE_GB}GB (建议至少10GB)"
    fi

    echo "[检查6/6] 关键端口检查"
    PORTS="3306 6379 8848 9876 28080 28081 28082 28083"
    CONFLICTS=0
    for port in $PORTS; do
        if netstat -tuln 2>/dev/null | grep -q ":$port " || ss -tuln 2>/dev/null | grep -q ":$port "; then
            print_warning "端口 $port 被占用"
            CONFLICTS=$((CONFLICTS + 1))
        else
            print_success "端口 $port 可用"
        fi
    done

    if [ $CONFLICTS -eq 0 ]; then
        print_success "所有关键端口都可用"
    else
        print_warning "发现 $CONFLICTS 个端口冲突，可能影响服务启动"
    fi

    echo
    echo "========================================="
    echo "              环境检查结果汇总"
    echo "========================================="
    if [ $CONFLICTS -eq 0 ]; then
        print_success "🎉 环境检查通过！可以开始部署项目"
    else
        print_warning "环境基本满足，但存在端口冲突"
        print_info "建议关闭占用端口的程序或修改配置"
    fi
    echo
fi

if [ "$ACTION" = "CHECK" ]; then
    exit 0
fi

# 第二阶段：初始化
if [ "$ACTION" = "ALL" ] || [ "$ACTION" = "INIT" ]; then
    print_info "[阶段2] 网络和目录初始化"
    echo "========================================="

    # 创建Docker网络
    print_info "创建Docker网络..."
    if ! docker network ls | grep -q "ecommerce-network"; then
        docker network create --driver bridge --subnet=172.20.0.0/16 --gateway=172.20.0.1 ecommerce-network
        print_success "Docker网络创建成功"
    else
        print_success "Docker网络已存在"
    fi

    # 创建目录结构
    echo
    print_info "创建项目目录结构..."

    # 主目录
    MAIN_DIRS=("data" "config" "logs")
    for dir in "${MAIN_DIRS[@]}"; do
        DIR_PATH="$PROJECT_ROOT/$dir"
        if [ ! -d "$DIR_PATH" ]; then
            print_info "创建主目录: $dir"
            mkdir -p "$DIR_PATH"
            if [ -d "$DIR_PATH" ]; then
                print_success "创建成功: $dir"
            else
                print_error "创建失败: $dir"
            fi
        else
            print_success "目录已存在: $dir"
        fi
    done

    # 创建data目录子目录
    echo
    print_info "创建data子目录（基础服务数据存储）..."
    DATA_DIRS=("mysql" "redis" "nacos" "rocketmq" "user-service" "product-service" "trade-service" "api-gateway")
    for dir in "${DATA_DIRS[@]}"; do
        DIR_PATH="$PROJECT_ROOT/data/$dir"
        if [ ! -d "$DIR_PATH" ]; then
            print_info "创建数据目录: data/$dir"
            mkdir -p "$DIR_PATH"
            if [ -d "$DIR_PATH" ]; then
                print_success "创建成功: data/$dir"
            else
                print_error "创建失败: data/$dir"
            fi
        else
            print_success "数据目录已存在: data/$dir"
        fi
    done

    # 创建config目录子目录
    echo
    print_info "创建config子目录（各服务配置文件）..."
    CONFIG_DIRS=("nginx" "mysql" "redis" "nacos" "rocketmq" "user-service" "product-service" "trade-service" "api-gateway")
    for dir in "${CONFIG_DIRS[@]}"; do
        DIR_PATH="$PROJECT_ROOT/config/$dir"
        if [ ! -d "$DIR_PATH" ]; then
            print_info "创建配置目录: config/$dir"
            mkdir -p "$DIR_PATH"
            if [ -d "$DIR_PATH" ]; then
                print_success "创建成功: config/$dir"
            else
                print_error "创建失败: config/$dir"
            fi
        else
            print_success "配置目录已存在: config/$dir"
        fi
    done

    # 创建logs目录子目录
    echo
    print_info "创建logs子目录（各服务日志文件）..."
    LOGS_DIRS=("infra" "mysql" "redis" "nacos" "rocketmq" "user-service" "product-service" "trade-service" "api-gateway")
    for dir in "${LOGS_DIRS[@]}"; do
        DIR_PATH="$PROJECT_ROOT/logs/$dir"
        if [ ! -d "$DIR_PATH" ]; then
            print_info "创建日志目录: logs/$dir"
            mkdir -p "$DIR_PATH"
            if [ -d "$DIR_PATH" ]; then
                print_success "创建成功: logs/$dir"
            else
                print_error "创建失败: logs/$dir"
            fi
        else
            print_success "日志目录已存在: logs/$dir"
        fi
    done

    # 设置目录权限
    echo
    print_info "设置目录权限..."
    print_info "设置完全访问权限，避免权限问题..."

    # Linux下使用chmod设置权限
    for dir in "${MAIN_DIRS[@]}"; do
        DIR_PATH="$PROJECT_ROOT/$dir"
        if [ -d "$DIR_PATH" ]; then
            print_info "设置目录权限: $dir"
            chmod -R 777 "$DIR_PATH" 2>/dev/null || {
                print_warning "权限设置跳过: $dir (可能需要sudo权限)"
            }
        fi
    done

    echo
    echo "========================================="
    echo "              🎉 初始化完成！"
    echo "========================================="
    echo
    echo "📁 创建的目录结构："
    echo
    echo "data/                              # 数据持久化根目录"
    echo "  ├─ mysql/                        # MySQL数据文件"
    echo "  ├─ redis/                        # Redis数据文件"
    echo "  ├─ nacos/                        # Nacos数据文件"
    echo "  └─ rocketmq/                     # RocketMQ数据文件"
    echo
    echo "config/                            # 配置文件根目录"
    echo "  ├─ mysql/                        # MySQL配置文件"
    echo "  ├─ redis/                        # Redis配置文件"
    echo "  ├─ nacos/                        # Nacos配置文件"
    echo "  ├─ rocketmq/                     # RocketMQ配置文件"
    echo "  ├─ nginx/                        # Nginx配置文件"
    echo "  ├─ user-service/                 # 用户服务配置"
    echo "  ├─ product-service/              # 商品服务配置"
    echo "  ├─ trade-service/                # 交易服务配置"
    echo "  └─ api-gateway/                  # API网关配置"
    echo
    echo "logs/                              # 日志文件根目录"
    echo "  ├─ infra/                        # 基础设施日志"
    echo "  ├─ mysql/                        # MySQL日志"
    echo "  ├─ redis/                        # Redis日志"
    echo "  ├─ nacos/                        # Nacos日志"
    echo "  ├─ rocketmq/                     # RocketMQ日志"
    echo "  ├─ user-service/                 # 用户服务日志"
    echo "  ├─ product-service/              # 商品服务日志"
    echo "  ├─ trade-service/                # 交易服务日志"
    echo "  └─ api-gateway/                  # API网关日志"
    echo
    echo "🌐 网络信息："
    echo "- 网络名称: ecommerce-network"
    echo "- 子网范围: 172.20.0.0/16"
    echo
    echo "💡 配置文件说明："
    echo "- 所有配置文件都已预留基础配置"
    echo "- 包含挂载点说明和参数调整指引"
    echo "- 可根据实际需求修改配置参数"
    echo
    echo "🔒 权限设置："
    echo "- 所有目录已设置为完全访问权限"
    echo "- 避免容器挂载和文件访问权限问题"
    echo
fi

# 显示完成信息
if [ "$ACTION" = "ALL" ]; then
    echo "🚀 接下来您可以："
    echo "1. 运行 start-all.sh 启动所有服务"
    echo "2. 运行 import-images.sh 导入镜像"
    echo "3. 运行 show-status.sh 查看服务状态"
    echo
fi

echo "========================================="
echo "操作完成！"
echo "========================================="