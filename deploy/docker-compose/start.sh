#!/bin/bash

# 电商微服务Docker环境启动脚本

echo "=========================================="
echo "  电商微服务Docker环境启动脚本"
echo "  E-commerce Microservices Docker Startup"
echo "=========================================="

# 检查Docker和Docker Compose是否安装
if ! command -v docker &> /dev/null; then
    echo "错误: Docker未安装，请先安装Docker"
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo "错误: Docker Compose未安装，请先安装Docker Compose"
    exit 1
fi

# 进入项目目录
cd "$(dirname "$0")"

# 加载环境变量
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
    echo "已加载环境变量文件"
else
    echo "警告: .env文件不存在，使用默认配置"
fi

# 创建必要的目录
echo "创建必要的日志和数据目录..."
mkdir -p logs/nacos logs/mysql logs/redis logs/rocketmq

# 启动基础中间件服务
echo "启动基础中间件服务..."
docker-compose up -d mysql redis nacos

echo "等待基础服务启动完成（30秒）..."
sleep 30

# 检查基础服务状态
echo "检查基础服务状态..."
docker-compose ps

# 启动其他服务
echo "启动消息队列和分布式事务服务..."
docker-compose up -d rocketmq-nameserver rocketmq-broker rocketmq-console seata-server

echo "等待所有服务启动完成（20秒）..."
sleep 20

# 显示所有服务状态
echo "=========================================="
echo "所有服务启动完成，状态如下："
echo "=========================================="
docker-compose ps

echo ""
echo "=========================================="
echo "服务访问地址："
echo "=========================================="
echo "Nacos控制台:     http://localhost:8848/nacos (nacos/nacos)"
echo "MySQL数据库:     localhost:3306 (root/root123456)"
echo "Redis缓存:       localhost:6379"
echo "RocketMQ控制台:  http://localhost:8081"
echo "Seata控制台:     http://localhost:7091"
echo "=========================================="

echo ""
echo "提示：使用 'docker-compose logs -f [服务名]' 查看服务日志"
echo "提示：使用 'docker-compose down' 停止所有服务"