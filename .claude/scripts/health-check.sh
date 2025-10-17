#!/bin/bash

# 微服务健康检查脚本
# 用于检查所有电商微服务的健康状态

echo "=== 电商微服务健康检查 ==="
echo "检查时间: $(date)"
echo ""

# 服务端口配置
GATEWAY_PORT=8080
AUTH_PORT=8081
USER_PORT=8082
PRODUCT_PORT=8083
ORDER_PORT=8084
CART_PORT=8085

# 服务URL配置
GATEWAY_URL="http://localhost:${GATEWAY_PORT}"
AUTH_URL="http://localhost:${AUTH_PORT}"
USER_URL="http://localhost:${USER_PORT}"
PRODUCT_URL="http://localhost:${PRODUCT_PORT}"
ORDER_URL="http://localhost:${ORDER_PORT}"
CART_URL="http://localhost:${CART_PORT}"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 检查函数
check_service() {
    local service_name=$1
    local url=$2
    local port=$3

    echo -n "检查 $service_name (端口: $port)... "

    # 检查端口是否被占用
    if netstat -tuln | grep -q ":$port "; then
        # 端口被占用，检查健康状态
        if curl -s -f "${url}/actuator/health" > /dev/null 2>&1; then
            echo -e "${GREEN}✓ 健康运行${NC}"
            return 0
        else
            echo -e "${YELLOW}⚠ 服务运行但健康检查失败${NC}"
            return 1
        fi
    else
        echo -e "${RED}✗ 服务未启动${NC}"
        return 2
    fi
}

# 检查依赖服务
check_dependencies() {
    echo ""
    echo "=== 检查依赖服务 ==="

    # 检查MySQL
    echo -n "检查 MySQL... "
    if command -v mysql > /dev/null 2>&1; then
        if mysql -h localhost -u root -e "SELECT 1;" > /dev/null 2>&1; then
            echo -e "${GREEN}✓ 连接正常${NC}"
        else
            echo -e "${RED}✗ 连接失败${NC}"
        fi
    else
        echo -e "${YELLOW}⚠ MySQL客户端未安装${NC}"
    fi

    # 检查Redis
    echo -n "检查 Redis... "
    if command -v redis-cli > /dev/null 2>&1; then
        if redis-cli ping > /dev/null 2>&1; then
            echo -e "${GREEN}✓ 连接正常${NC}"
        else
            echo -e "${RED}✗ 连接失败${NC}"
        fi
    else
        echo -e "${YELLOW}⚠ Redis客户端未安装${NC}"
    fi

    # 检查Nacos
    echo -n "检查 Nacos... "
    if curl -s -f "http://localhost:8848/nacos/" > /dev/null 2>&1; then
        echo -e "${GREEN}✓ 运行正常${NC}"
    else
        echo -e "${RED}✗ 未启动或不可访问${NC}"
    fi
}

# 检查服务注册状态
check_service_registration() {
    echo ""
    echo "=== 检查服务注册状态 ==="

    services=("gateway-service" "auth-service" "user-service" "product-service" "order-service" "cart-service")

    for service in "${services[@]}"; do
        echo -n "检查 $service 注册状态... "
        if curl -s "http://localhost:8848/nacos/v1/ns/instance/list?serviceName=${service}" | grep -q '"instanceId"'; then
            echo -e "${GREEN}✓ 已注册${NC}"
        else
            echo -e "${RED}✗ 未注册${NC}"
        fi
    done
}

# 网关路由检查
check_gateway_routes() {
    echo ""
    echo "=== 检查网关路由 ==="

    routes=("/api/auth/**" "/api/user/**" "/api/product/**" "/api/order/**" "/api/cart/**")

    for route in "${routes[@]}"; do
        echo -n "检查路由 $route... "
        if curl -s -f "${GATEWAY_URL}/actuator/gateway/routes" | grep -q "$route"; then
            echo -e "${GREEN}✓ 路由存在${NC}"
        else
            echo -e "${RED}✗ 路由不存在${NC}"
        fi
    done
}

# 生成健康检查报告
generate_report() {
    echo ""
    echo "=== 健康检查报告 ==="
    echo "生成时间: $(date)"
    echo "检查结果: $1"

    if [ "$1" = "ALL_GOOD" ]; then
        echo -e "${GREEN}✓ 所有服务运行正常${NC}"
    else
        echo -e "${YELLOW}⚠ 发现问题，请检查上述服务状态${NC}"
    fi

    # 保存报告到文件
    {
        echo "健康检查报告"
        echo "时间: $(date)"
        echo "结果: $1"
        echo "详细日志请查看上述输出"
    } > .claude/health-report-$(date +%Y%m%d-%H%M%S).txt
}

# 主检查逻辑
main() {
    local failed_services=0

    # 检查各个微服务
    check_service "网关服务" "$GATEWAY_URL" "$GATEWAY_PORT" || ((failed_services++))
    check_service "认证服务" "$AUTH_URL" "$AUTH_PORT" || ((failed_services++))
    check_service "用户服务" "$USER_URL" "$USER_PORT" || ((failed_services++))
    check_service "商品服务" "$PRODUCT_URL" "$PRODUCT_PORT" || ((failed_services++))
    check_service "订单服务" "$ORDER_URL" "$ORDER_PORT" || ((failed_services++))
    check_service "购物车服务" "$CART_URL" "$CART_PORT" || ((failed_services++))

    # 检查依赖服务
    check_dependencies

    # 检查服务注册
    check_service_registration

    # 检查网关路由
    check_gateway_routes

    # 生成报告
    if [ $failed_services -eq 0 ]; then
        generate_report "ALL_GOOD"
        exit 0
    else
        generate_report "SOME_SERVICES_FAILED"
        exit 1
    fi
}

# 显示帮助信息
show_help() {
    echo "用法: $0 [选项]"
    echo ""
    echo "选项:"
    echo "  -h, --help     显示帮助信息"
    echo "  -q, --quiet    静默模式，只显示结果"
    echo "  -s, --service  检查指定服务"
    echo ""
    echo "示例:"
    echo "  $0                    # 检查所有服务"
    echo "  $0 -s gateway        # 只检查网关服务"
    echo "  $0 -q                # 静默模式检查"
}

# 解析命令行参数
case "$1" in
    -h|--help)
        show_help
        exit 0
        ;;
    -q|--quiet)
        main > /dev/null 2>&1
        exit $?
        ;;
    -s|--service)
        if [ -z "$2" ]; then
            echo "错误: 请指定要检查的服务名称"
            show_help
            exit 1
        fi
        case "$2" in
            gateway)
                check_service "网关服务" "$GATEWAY_URL" "$GATEWAY_PORT"
                ;;
            auth)
                check_service "认证服务" "$AUTH_URL" "$AUTH_PORT"
                ;;
            user)
                check_service "用户服务" "$USER_URL" "$USER_PORT"
                ;;
            product)
                check_service "商品服务" "$PRODUCT_URL" "$PRODUCT_PORT"
                ;;
            order)
                check_service "订单服务" "$ORDER_URL" "$ORDER_PORT"
                ;;
            cart)
                check_service "购物车服务" "$CART_URL" "$CART_PORT"
                ;;
            *)
                echo "错误: 未知服务 '$2'"
                show_help
                exit 1
                ;;
        esac
        exit $?
        ;;
    "")
        main
        ;;
    *)
        echo "错误: 未知参数 '$1'"
        show_help
        exit 1
        ;;
esac