#!/bin/bash

# ===================================
# 电商微服务项目 - Linux镜像导入脚本
# 版本: v1.0
# 作用: 从tar文件导入所有镜像，用于离线部署
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
    echo -e "${BLUE}   电商微服务项目 - 导入应用镜像${NC}"
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
IMPORT_DIR="$PROJECT_ROOT/deploy/images"

# 检查是否以root权限运行
check_root_permission() {
    if [ "$EUID" -ne 0 ]; then
        print_warning "建议使用root权限运行此脚本以确保Docker操作正常"
        print_info "如果遇到权限问题，请使用: sudo $0"
        read -p "是否继续运行？(y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
}

# 检查Docker环境
check_docker() {
    print_info "检查Docker环境..."

    if ! command -v docker >/dev/null 2>&1; then
        print_error "Docker未安装"
        print_info "请先运行 check-environment.sh 安装Docker"
        exit 1
    fi

    if ! docker info >/dev/null 2>&1; then
        print_error "Docker未运行或权限不足"
        print_info "请启动Docker服务: sudo systemctl start docker"
        print_info "或将当前用户添加到docker组: sudo usermod -aG docker \$USER"
        exit 1
    fi

    DOCKER_VERSION=$(docker --version | sed 's/.*version //;s/,.*//g')
    print_success "Docker环境正常: $DOCKER_VERSION"
}

# 检查导入目录
check_import_directory() {
    print_info "检查导入目录: $IMPORT_DIR"

    if [ ! -d "$IMPORT_DIR" ]; then
        print_error "导入目录不存在: $IMPORT_DIR"
        print_info "请确保项目结构完整，或手动创建目录"
        exit 1
    fi

    if [ ! -w "$IMPORT_DIR" ]; then
        print_error "导入目录不可写: $IMPORT_DIR"
        print_info "请检查目录权限"
        exit 1
    fi

    print_success "导入目录检查通过"
}

# 查找镜像文件
find_image_file() {
    print_info "查找镜像文件..."

    IMAGE_FILE=""
    LATEST_FILE=""

    # 查找所有镜像tar文件
    for file in "$IMPORT_DIR"/ecommerce-images-*.tar; do
        if [ -f "$file" ]; then
            if [ -z "$IMAGE_FILE" ]; then
                IMAGE_FILE="$file"
                LATEST_FILE="$file"
            else
                # 比较文件修改时间，选择最新的
                if [ "$file" -nt "$LATEST_FILE" ]; then
                    LATEST_FILE="$file"
                fi
            fi
        fi
    done

    if [ -z "$LATEST_FILE" ]; then
        print_error "未找到镜像文件"
        print_info "请确保在 $IMPORT_DIR 目录中有 ecommerce-images-*.tar 文件"
        print_info "或在Windows环境中运行 export-all-images.bat 导出镜像"
        exit 1
    fi

    IMAGE_FILE="$LATEST_FILE"
    FILE_SIZE=$(du -h "$IMAGE_FILE" | cut -f1)
    FILE_MOD_TIME=$(stat -c %y "$IMAGE_FILE" 2>/dev/null || stat -f %Sm "$IMAGE_FILE" 2>/dev/null)

    print_success "找到镜像文件: $(basename "$IMAGE_FILE")"
    print_info "文件大小: $FILE_SIZE"
    print_info "修改时间: $FILE_MOD_TIME"
}

# 检查版本信息文件
check_version_file() {
    local base_name=$(basename "$IMAGE_FILE" .tar)
    local version_file="$IMPORT_DIR/version-${base_name#ecommerce-images-}.txt"

    if [ -f "$version_file" ]; then
        print_info "找到版本信息文件: $(basename "$version_file")"
        print_info "版本信息内容:"
        cat "$version_file" | sed 's/^/  /'
    else
        print_warning "未找到版本信息文件"
    fi
}

# 导入镜像
import_images() {
    print_info "开始导入镜像，请稍候..."

    # 显示当前镜像列表（导入前）
    print_info "导入前当前项目镜像列表:"
    docker images ecommerce/ --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}\t{{.CreatedAt}}" 2>/dev/null || print_info "  暂无项目镜像"
    echo

    print_info "正在导入镜像文件: $IMAGE_FILE"
    print_info "这可能需要几分钟时间，请耐心等待..."

    # 使用pv显示进度（如果可用）
    if command -v pv >/dev/null 2>&1; then
        pv "$IMAGE_FILE" | docker load
    else
        docker load -i "$IMAGE_FILE"
    fi

    if [ $? -eq 0 ]; then
        print_success "镜像导入成功"
    else
        print_error "镜像导入失败"
        print_info "请检查："
        print_info "1. 镜像文件是否损坏"
        print_info "2. Docker是否有足够的存储空间"
        print_info "3. 当前用户是否有Docker权限"
        exit 1
    fi
}

# 验证导入结果
verify_import() {
    print_info "验证导入结果..."

    # 检查导入的镜像
    IMPORTED_IMAGES=$(docker images ecommerce/ --format "{{.Repository}}:{{.Tag}}" 2>/dev/null)
    IMAGE_COUNT=$(echo "$IMPORTED_IMAGES" | wc -l)

    if [ -z "$IMPORTED_IMAGES" ]; then
        print_warning "未找到导入的项目镜像"
    else
        print_success "成功导入 $IMAGE_COUNT 个镜像:"
        echo "$IMPORTED_IMAGES" | sed 's/^/  - /'
    fi

    # 检查关键镜像
    local required_images=("ecommerce/api-gateway:latest" "ecommerce/user-service:latest" "ecommerce/product-service:latest" "ecommerce/trade-service:latest")
    local missing_images=0

    for image in "${required_images[@]}"; do
        if docker images --format "{{.Repository}}:{{.Tag}}" | grep -q "^$image$"; then
            print_success "镜像 $image 导入成功"
        else
            print_warning "镜像 $image 未找到"
            missing_images=$((missing_images + 1))
        fi
    done

    if [ $missing_images -eq 0 ]; then
        print_success "所有必需镜像都已导入"
    else
        print_warning "缺少 $missing_images 个必需镜像"
    fi
}

# 显示导入结果
show_import_result() {
    echo
    echo "========================================="
    echo "              🎉 导入完成！"
    echo "========================================="

    echo "📋 当前项目镜像列表:"
    docker images ecommerce/ --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}\t{{.CreatedAt}}" 2>/dev/null || echo "  暂无镜像"
    echo

    echo "🚀 接下来您可以："
    echo "1. 运行 check-environment.sh 检查环境"
    echo "2. 运行 init-network.sh 创建网络"
    echo "3. 运行 start-all.sh 启动所有服务"
    echo

    echo "💡 提示："
    echo "- 如果是首次部署，建议运行 setup-production.sh"
    echo "- 可以运行 show-status.sh 查看服务状态"
    echo "- 镜像文件可以保留作为备份"
    echo "========================================="
}

# 清理旧镜像（可选）
cleanup_old_images() {
    read -p "是否清理旧的项目镜像？(y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_info "清理旧的项目镜像..."
        old_images=$(docker images ecommerce/ --format "{{.Repository}}:{{.Tag}}" 2>/dev/null || true)
        if [ -n "$old_images" ]; then
            echo "$old_images" | xargs -r docker rmi 2>/dev/null || true
            print_success "旧镜像清理完成"
        else
            print_info "没有找到旧镜像"
        fi
    fi
}

# 主函数
main() {
    print_header
    check_root_permission
    check_docker
    check_import_directory
    find_image_file
    check_version_file
    cleanup_old_images
    import_images
    verify_import
    show_import_result
}

# 处理命令行参数
case "${1:-}" in
    --help|-h)
        echo "用法: $0 [选项] [镜像文件路径]"
        echo
        echo "选项:"
        echo "  --help, -h        显示此帮助信息"
        echo "  --list            列出可用的镜像文件"
        echo "  --verify-only     仅验证镜像文件，不导入"
        echo
        echo "示例:"
        echo "  $0                                    # 自动查找并导入最新镜像"
        echo "  $0 /path/to/ecommerce-images.tar     # 导入指定镜像文件"
        echo "  $0 --list                            # 列出可用的镜像文件"
        exit 0
        ;;
    --list)
        print_header
        print_info "可用的镜像文件:"
        if ls "$IMPORT_DIR"/ecommerce-images-*.tar 1> /dev/null 2>&1; then
            for file in "$IMPORT_DIR"/ecommerce-images-*.tar; do
                if [ -f "$file" ]; then
                    file_size=$(du -h "$file" | cut -f1)
                    file_time=$(stat -c %y "$file" 2>/dev/null || stat -f %Sm "$file" 2>/dev/null)
                    echo "  - $(basename "$file") (${file_size}, ${file_time})"
                fi
            done
        else
            print_warning "未找到镜像文件"
        fi
        exit 0
        ;;
    --verify-only)
        print_header
        check_root_permission
        check_docker
        check_import_directory
        find_image_file
        check_version_file
        print_success "镜像文件验证完成"
        exit 0
        ;;
esac

# 如果提供了镜像文件路径参数
if [ -n "$1" ] && [ -f "$1" ]; then
    IMAGE_FILE="$1"
    print_info "使用指定的镜像文件: $1"
fi

# 执行主函数
main "$@"