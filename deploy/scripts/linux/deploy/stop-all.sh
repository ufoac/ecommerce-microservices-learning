#!/bin/bash

# ===================================
# 电商微服务项目 - Linux停止所有服务
# 版本: v1.0
# 作用: 停止所有Docker Compose服务
# ===================================

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_header() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}   电商微服务项目 - 停止所有服务${NC}"
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

# 获取脚本目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMPOSE_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")/docker-compose"

# 检查Docker
if ! command -v docker >/dev/null 2>&1; then
    print_error "Docker未安装"
    exit 1
fi

# 显示当前状态
echo "当前运行的容器："
docker ps --format "table {{.Names}}\t{{.Status}}" | grep -E "(mysql|redis|nacos|rocketmq|api-gateway|user-service|product-service|trade-service|CONTAINER)" || true
echo

# 确认停止
read -p "确认停止所有服务？(y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "操作已取消"
    exit 0
fi

cd "$COMPOSE_DIR" || exit 1

# 确定Docker Compose命令
if command -v docker-compose >/dev/null 2>&1; then
    COMPOSE_CMD="docker-compose"
else
    COMPOSE_CMD="docker compose"
fi

# 停止应用服务
echo "正在停止应用服务..."
$COMPOSE_CMD -f docker-compose.apps.yml down

# 停止基础设施服务
echo "正在停止基础设施服务..."
$COMPOSE_CMD -f docker-compose.infra.yml down

# 检查结果
echo
echo "========================================="
echo "              🛑 停止完成！"
echo "========================================="

RUNNING_CONTAINERS=$(docker ps -q | wc -l)
if [ $RUNNING_CONTAINERS -gt 0 ]; then
    echo "⚠️  仍有 $RUNNING_CONTAINERS 个容器在运行"
    docker ps --format "table {{.Names}}\t{{.Status}}"
else
    print_success "所有项目相关服务已停止"
fi

echo
echo "🚀 接下来您可以："
echo "- start-all.sh     - 重新启动所有服务"
echo "- import-images.sh - 导入新镜像"
echo "- check-environment.sh - 重新检查环境"