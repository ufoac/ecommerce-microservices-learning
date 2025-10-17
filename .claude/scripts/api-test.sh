#!/bin/bash

# API测试脚本
# 用于测试电商微服务的API接口

set -e

# 配置
GATEWAY_URL="http://localhost:8080"
TEST_USER="testuser_$(date +%s)"
TEST_EMAIL="test_$(date +%s)@example.com"
TEST_PASSWORD="Test123456"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 测试结果统计
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# 存储Token
AUTH_TOKEN=""

# 测试日志函数
log_test() {
    local test_name=$1
    local result=$2
    local details=$3

    TOTAL_TESTS=$((TOTAL_TESTS + 1))

    echo -n "测试 $test_name... "

    if [ "$result" = "PASS" ]; then
        echo -e "${GREEN}✓ PASS${NC}"
        PASSED_TESTS=$((PASSED_TESTS + 1))
        [ -n "$details" ] && echo "  $details"
    else
        echo -e "${RED}✗ FAIL${NC}"
        FAILED_TESTS=$((FAILED_TESTS + 1))
        [ -n "$details" ] && echo -e "  ${RED}$details${NC}"
    fi
}

# HTTP请求函数
make_request() {
    local method=$1
    local url=$2
    local data=$3
    local headers=$4

    local cmd="curl -s -w '%{http_code}' -X $method"

    if [ -n "$data" ]; then
        cmd="$cmd -H 'Content-Type: application/json' -d '$data'"
    fi

    if [ -n "$headers" ]; then
        cmd="$cmd -H '$headers'"
    fi

    cmd="$cmd '$url'"

    local response=$(eval $cmd)
    local http_code="${response: -3}"
    local body="${response%???}"

    echo "$http_code|$body"
}

# 测试用户注册
test_user_register() {
    echo -e "\n${BLUE}=== 测试用户注册 ===${NC}"

    local data='{
        "username": "'$TEST_USER'",
        "password": "'$TEST_PASSWORD'",
        "email": "'$TEST_EMAIL'",
        "phone": "13800138000"
    }'

    local result=$(make_request "POST" "$GATEWAY_URL/api/auth/register" "$data")
    local http_code=$(echo "$result" | cut -d'|' -f1)
    local body=$(echo "$result" | cut -d'|' -f2)

    if [ "$http_code" = "200" ] || [ "$http_code" = "201" ]; then
        log_test "用户注册" "PASS" "HTTP $http_code"
        return 0
    else
        log_test "用户注册" "FAIL" "HTTP $http_code, Response: $body"
        return 1
    fi
}

# 测试用户登录
test_user_login() {
    echo -e "\n${BLUE}=== 测试用户登录 ===${NC}"

    local data='{
        "username": "'$TEST_USER'",
        "password": "'$TEST_PASSWORD'"
    }'

    local result=$(make_request "POST" "$GATEWAY_URL/api/auth/login" "$data")
    local http_code=$(echo "$result" | cut -d'|' -f1)
    local body=$(echo "$result" | cut -d'|' -f2)

    if [ "$http_code" = "200" ]; then
        # 提取token
        AUTH_TOKEN=$(echo "$body" | grep -o '"token":"[^"]*"' | cut -d'"' -f4)
        if [ -n "$AUTH_TOKEN" ]; then
            log_test "用户登录" "PASS" "HTTP $http_code, Token获取成功"
            return 0
        else
            log_test "用户登录" "FAIL" "HTTP $http_code, 但未获取到Token"
            return 1
        fi
    else
        log_test "用户登录" "FAIL" "HTTP $http_code, Response: $body"
        return 1
    fi
}

# 测试获取用户信息
test_get_user_info() {
    echo -e "\n${BLUE}=== 测试获取用户信息 ===${NC}"

    if [ -z "$AUTH_TOKEN" ]; then
        log_test "获取用户信息" "FAIL" "未找到认证Token"
        return 1
    fi

    local result=$(make_request "GET" "$GATEWAY_URL/api/user/profile" "" "Authorization: Bearer $AUTH_TOKEN")
    local http_code=$(echo "$result" | cut -d'|' -f1)
    local body=$(echo "$result" | cut -d'|' -f2)

    if [ "$http_code" = "200" ]; then
        log_test "获取用户信息" "PASS" "HTTP $http_code"
        return 0
    else
        log_test "获取用户信息" "FAIL" "HTTP $http_code, Response: $body"
        return 1
    fi
}

# 测试商品列表查询
test_product_list() {
    echo -e "\n${BLUE}=== 测试商品列表查询 ===${NC}"

    local result=$(make_request "GET" "$GATEWAY_URL/api/product/list?page=1&size=10")
    local http_code=$(echo "$result" | cut -d'|' -f1)
    local body=$(echo "$result" | cut -d'|' -f2)

    if [ "$http_code" = "200" ]; then
        # 检查返回的数据结构
        if echo "$body" | grep -q '"content"'; then
            log_test "商品列表查询" "PASS" "HTTP $http_code, 数据结构正确"
            return 0
        else
            log_test "商品列表查询" "FAIL" "HTTP $http_code, 但数据结构不正确"
            return 1
        fi
    else
        log_test "商品列表查询" "FAIL" "HTTP $http_code, Response: $body"
        return 1
    fi
}

# 测试商品详情查询
test_product_detail() {
    echo -e "\n${BLUE}=== 测试商品详情查询 ===${NC}"

    # 假设商品ID为1
    local result=$(make_request "GET" "$GATEWAY_URL/api/product/1")
    local http_code=$(echo "$result" | cut -d'|' -f1)
    local body=$(echo "$result" | cut -d'|' -f2)

    if [ "$http_code" = "200" ]; then
        if echo "$body" | grep -q '"id"'; then
            log_test "商品详情查询" "PASS" "HTTP $http_code"
            return 0
        else
            log_test "商品详情查询" "FAIL" "HTTP $http_code, 但数据结构不正确"
            return 1
        fi
    else
        log_test "商品详情查询" "FAIL" "HTTP $http_code, Response: $body"
        return 1
    fi
}

# 测试添加购物车
test_add_to_cart() {
    echo -e "\n${BLUE}=== 测试添加购物车 ===${NC}"

    if [ -z "$AUTH_TOKEN" ]; then
        log_test "添加购物车" "FAIL" "未找到认证Token"
        return 1
    fi

    local data='{
        "productId": 1,
        "quantity": 2
    }'

    local result=$(make_request "POST" "$GATEWAY_URL/api/cart/add" "$data" "Authorization: Bearer $AUTH_TOKEN")
    local http_code=$(echo "$result" | cut -d'|' -f1)
    local body=$(echo "$result" | cut -d'|' -f2)

    if [ "$http_code" = "200" ] || [ "$http_code" = "201" ]; then
        log_test "添加购物车" "PASS" "HTTP $http_code"
        return 0
    else
        log_test "添加购物车" "FAIL" "HTTP $http_code, Response: $body"
        return 1
    fi
}

# 测试查询购物车
test_get_cart() {
    echo -e "\n${BLUE}=== 测试查询购物车 ===${NC}"

    if [ -z "$AUTH_TOKEN" ]; then
        log_test "查询购物车" "FAIL" "未找到认证Token"
        return 1
    fi

    local result=$(make_request "GET" "$GATEWAY_URL/api/cart/list" "" "Authorization: Bearer $AUTH_TOKEN")
    local http_code=$(echo "$result" | cut -d'|' -f1)
    local body=$(echo "$result" | cut -d'|' -f2)

    if [ "$http_code" = "200" ]; then
        log_test "查询购物车" "PASS" "HTTP $http_code"
        return 0
    else
        log_test "查询购物车" "FAIL" "HTTP $http_code, Response: $body"
        return 1
    fi
}

# 测试认证拦截器
test_auth_interceptor() {
    echo -e "\n${BLUE}=== 测试认证拦截器 ===${NC}"

    # 不带token访问需要认证的接口
    local result=$(make_request "GET" "$GATEWAY_URL/api/user/profile")
    local http_code=$(echo "$result" | cut -d'|' -f1)

    if [ "$http_code" = "401" ] || [ "$http_code" = "403" ]; then
        log_test "认证拦截器" "PASS" "HTTP $http_code, 正确拦截未认证请求"
        return 0
    else
        log_test "认证拦截器" "FAIL" "HTTP $http_code, 未正确拦截未认证请求"
        return 1
    fi
}

# 性能测试
test_performance() {
    echo -e "\n${BLUE}=== 性能测试 ===${NC}"

    local test_url="$GATEWAY_URL/api/product/list"
    local requests=10
    local total_time=0

    echo "执行 $requests 次请求测试..."

    for i in $(seq 1 $requests); do
        local start_time=$(date +%s%N)
        local result=$(make_request "GET" "$test_url")
        local end_time=$(date +%s%N)
        local duration=$((($end_time - $start_time) / 1000000)) # 转换为毫秒
        total_time=$(($total_time + $duration))
        echo -n "."
    done

    local avg_time=$(($total_time / $requests))
    echo ""

    if [ $avg_time -lt 1000 ]; then
        log_test "性能测试" "PASS" "平均响应时间: ${avg_time}ms"
        return 0
    else
        log_test "性能测试" "FAIL" "平均响应时间过长: ${avg_time}ms"
        return 1
    fi
}

# 生成测试报告
generate_test_report() {
    echo -e "\n${BLUE}=== 测试报告 ===${NC}"
    echo "测试时间: $(date)"
    echo "总测试数: $TOTAL_TESTS"
    echo -e "通过测试: ${GREEN}$PASSED_TESTS${NC}"
    echo -e "失败测试: ${RED}$FAILED_TESTS${NC}"

    local success_rate=0
    if [ $TOTAL_TESTS -gt 0 ]; then
        success_rate=$((($PASSED_TESTS * 100) / $TOTAL_TESTS))
    fi

    echo "成功率: ${success_rate}%"

    # 保存报告到文件
    local report_file=".claude/api-test-report-$(date +%Y%m%d-%H%M%S).txt"
    {
        echo "API测试报告"
        echo "时间: $(date)"
        echo "总测试数: $TOTAL_TESTS"
        echo "通过: $PASSED_TESTS"
        echo "失败: $FAILED_TESTS"
        echo "成功率: ${success_rate}%"
        echo "测试用户: $TEST_USER"
        echo "网关地址: $GATEWAY_URL"
    } > "$report_file"

    echo "报告已保存到: $report_file"

    if [ $FAILED_TESTS -eq 0 ]; then
        return 0
    else
        return 1
    fi
}

# 显示帮助信息
show_help() {
    echo "用法: $0 [选项]"
    echo ""
    echo "选项:"
    echo "  -h, --help              显示帮助信息"
    echo "  -a, --all               执行所有测试"
    echo "  -u, --auth              只执行认证相关测试"
    echo "  -p, --product           只执行商品相关测试"
    echo "  -c, --cart              只执行购物车相关测试"
    echo "  -f, --performance       只执行性能测试"
    echo "  --url URL               指定网关URL (默认: http://localhost:8080)"
    echo ""
    echo "示例:"
    echo "  $0 -a                   # 执行所有测试"
    echo "  $0 -u                   # 只测试认证功能"
    echo "  $0 --url http://localhost:9090 -a  # 指定网关地址执行测试"
}

# 主函数
main() {
    local test_type="all"

    # 解析命令行参数
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -a|--all)
                test_type="all"
                shift
                ;;
            -u|--auth)
                test_type="auth"
                shift
                ;;
            -p|--product)
                test_type="product"
                shift
                ;;
            -c|--cart)
                test_type="cart"
                shift
                ;;
            -f|--performance)
                test_type="performance"
                shift
                ;;
            --url)
                GATEWAY_URL="$2"
                shift 2
                ;;
            *)
                echo "错误: 未知参数 '$1'"
                show_help
                exit 1
                ;;
        esac
    done

    echo -e "${BLUE}开始API测试...${NC}"
    echo "网关地址: $GATEWAY_URL"
    echo "测试时间: $(date)"
    echo ""

    # 根据测试类型执行相应测试
    case $test_type in
        "all")
            test_auth_interceptor
            test_user_register
            test_user_login
            test_get_user_info
            test_product_list
            test_product_detail
            test_add_to_cart
            test_get_cart
            test_performance
            ;;
        "auth")
            test_auth_interceptor
            test_user_register
            test_user_login
            test_get_user_info
            ;;
        "product")
            test_product_list
            test_product_detail
            ;;
        "cart")
            test_add_to_cart
            test_get_cart
            ;;
        "performance")
            test_performance
            ;;
    esac

    # 生成测试报告
    generate_test_report
}

# 执行主函数
main "$@"