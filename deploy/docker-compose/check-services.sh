#!/bin/bash

echo "=========================================="
echo "  电商微服务健康检查脚本"
echo "  E-commerce Microservices Health Check"
echo "=========================================="

# 检查基础服务状态
check_service() {
    local service_name=$1
    local port=$2
    local description=$3

    echo -n "检查 $description ($service_name:$port)... "

    if nc -z localhost $port 2>/dev/null; then
        echo "✅ 运行正常"
        return 0
    else
        echo "❌ 无法连接"
        return 1
    fi
}

# HTTP服务检查
check_http_service() {
    local service_name=$1
    local port=$2
    local path=$3
    local description=$4

    echo -n "检查 $description (http://localhost:$port$path)... "

    if curl -s -f "http://localhost:$port$path" > /dev/null 2>&1; then
        echo "✅ 运行正常"
        return 0
    else
        echo "❌ 无法访问"
        return 1
    fi
}

echo "开始检查基础服务..."

# TCP端口服务检查
check_service "mysql" "3306" "MySQL数据库"
check_service "redis" "6379" "Redis缓存"
check_service "nacos" "8848" "Nacos注册中心"
check_service "rocketmq-nameserver" "9876" "RocketMQ NameServer"
check_service "seata-server" "7091" "Seata分布式事务"

echo ""
echo "检查HTTP服务端点..."

# HTTP服务检查
check_http_service "nacos" "8848" "/nacos" "Nacos控制台"
check_http_service "rocketmq-console" "8081" "/" "RocketMQ控制台"
check_http_service "seata-server" "7091" "/" "Seata控制台"

echo ""
echo "=========================================="
echo "健康检查完成"
echo "=========================================="

# 显示Docker容器状态
echo ""
echo "Docker容器状态："
docker-compose ps

echo ""
echo "提示："
echo "- 如果服务无法连接，请使用 'docker-compose logs [服务名]' 查看日志"
echo "- 如果Nacos启动失败，请检查MySQL是否正常运行"
echo "- 建议等待1-2分钟后重新运行此脚本"