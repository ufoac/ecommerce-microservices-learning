#!/bin/bash

echo "=========================================="
echo "  微服务连接测试脚本"
echo "  Microservices Connection Test"
echo "=========================================="

# 设置环境变量
export NACOS_SERVER_ADDR=localhost:8848
export DB_HOST=localhost
export DB_PORT=3306
export DB_NAME=ecommerce
export DB_USERNAME=root
export DB_PASSWORD=root123456
export REDIS_HOST=localhost
export REDIS_PORT=6379
export ROCKETMQ_NAMESERVER_ADDR=localhost:9876

echo "测试环境变量："
echo "NACOS_SERVER_ADDR: $NACOS_SERVER_ADDR"
echo "DB_HOST: $DB_HOST:$DB_PORT"
echo "REDIS_HOST: $REDIS_HOST:$REDIS_PORT"
echo ""

# 检查Nacos是否可访问
echo "检查Nacos连接..."
if curl -s -f "http://localhost:8848/nacos" > /dev/null 2>&1; then
    echo "✅ Nacos控制台可访问"
else
    echo "❌ Nacos控制台无法访问，请先启动Docker环境"
    exit 1
fi

# 测试各个微服务启动
echo ""
echo "开始测试微服务启动..."

test_microservice() {
    local service_name=$1
    local service_path=$2
    local port=$3
    local description=$4

    echo -n "启动 $service_name ($description)... "

    cd "$service_path"

    # 后台启动服务
    mvn spring-boot:run -q > /dev/null 2>&1 &
    local pid=$!

    # 等待服务启动
    echo -n "等待启动 "
    for i in {1..30}; do
        if curl -s -f "http://localhost:$port/actuator/health" > /dev/null 2>&1; then
            echo "✅ 启动成功"
            echo "   健康检查: http://localhost:$port/actuator/health"

            # 检查服务注册
            sleep 2
            if curl -s "http://localhost:8848/nacos/v1/ns/instance/list?serviceName=$service_name" | grep -q "$service_name"; then
                echo "   ✅ 已成功注册到Nacos"
            else
                echo "   ⚠️  可能未注册到Nacos"
            fi

            # 停止服务
            kill $pid 2>/dev/null
            return 0
        fi
        echo -n "."
        sleep 2
    done

    echo "❌ 启动超时"
    kill $pid 2>/dev/null
    return 1
}

# 进入后端项目目录
cd "$(dirname "$0")/../.."

# 测试各个微服务
echo ""
test_microservice "api-gateway" "backend/api-gateway" "8080" "API网关"
test_microservice "user-service" "backend/user-service" "8081" "用户服务"
test_microservice "product-service" "backend/product-service" "8082" "商品服务"
test_microservice "trade-service" "backend/trade-service" "8083" "交易服务"

echo ""
echo "=========================================="
echo "测试完成"
echo "=========================================="

echo ""
echo "Nacos服务列表："
curl -s "http://localhost:8848/nacos/v1/ns/service/list?pageNo=1&pageSize=20" | jq -r '.doms[]' 2>/dev/null || echo "请手动访问: http://localhost:8848/nacos"

echo ""
echo "提示："
echo "- 如果服务启动失败，请检查application.yml配置"
echo "- 使用 'docker-compose logs -f nacos' 查看Nacos日志"
echo "- 确保所有依赖服务（MySQL、Redis）已启动"