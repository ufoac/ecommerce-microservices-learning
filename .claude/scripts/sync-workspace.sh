#!/bin/bash

# 工作空间同步脚本
# 用于同步开发和测试分身的工作状态

set -e

# 配置
PROJECT_ROOT="$(pwd)"
CLAUDE_DIR="$PROJECT_ROOT/.claude"
PENDING_TESTS_FILE="$CLAUDE_DIR/pending-tests.txt"
TEST_STATUS_FILE="$CLAUDE_DIR/test-status.txt"
DEV_STATUS_FILE="$CLAUDE_DIR/dev-status.txt"
ISSUES_FILE="$CLAUDE_DIR/issues.txt"
SYNC_LOG="$CLAUDE_DIR/sync-log.txt"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 日志函数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [INFO] $1" >> "$SYNC_LOG"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [SUCCESS] $1" >> "$SYNC_LOG"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [WARNING] $1" >> "$SYNC_LOG"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [ERROR] $1" >> "$SYNC_LOG"
}

# 创建必要的目录和文件
init_workspace() {
    log_info "初始化工作空间..."

    mkdir -p "$CLAUDE_DIR"
    mkdir -p "$CLAUDE_DIR/scripts"
    mkdir -p "$CLAUDE_DIR/reports"
    mkdir -p "$CLAUDE_DIR/logs"

    # 创建状态文件（如果不存在）
    touch "$PENDING_TESTS_FILE"
    touch "$TEST_STATUS_FILE"
    touch "$DEV_STATUS_FILE"
    touch "$ISSUES_FILE"
    touch "$SYNC_LOG"

    log_success "工作空间初始化完成"
}

# 检查Git状态
check_git_status() {
    log_info "检查Git状态..."

    # 检查是否在Git仓库中
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        log_error "当前目录不是Git仓库"
        return 1
    fi

    # 检查是否有未提交的更改
    if [ -n "$(git status --porcelain)" ]; then
        log_warning "发现未提交的更改:"
        git status --short
        return 1
    else
        log_success "工作目录干净，无未提交更改"
    fi

    return 0
}

# 同步远程代码
sync_remote_code() {
    log_info "同步远程代码..."

    # 获取远程更新
    if git fetch origin; then
        log_success "成功获取远程更新"
    else
        log_error "获取远程更新失败"
        return 1
    fi

    # 显示最新提交
    log_info "最新5次提交:"
    git log --oneline -5

    # 检查当前分支状态
    local current_branch=$(git branch --show-current)
    local behind_commits=$(git rev-list --count HEAD..origin/"$current_branch" 2>/dev/null || echo "0")

    if [ "$behind_commits" -gt 0 ]; then
        log_warning "当前分支落后远程 $behind_commits 个提交"
        echo "建议执行: git pull origin $current_branch"
    else
        log_success "当前分支与远程同步"
    fi
}

# 检查待测试任务
check_pending_tests() {
    log_info "检查待测试任务..."

    if [ -s "$PENDING_TESTS_FILE" ]; then
        log_warning "发现待测试任务:"
        cat "$PENDING_TESTS_FILE"
        return 1
    else
        log_success "无待测试任务"
    fi
}

# 检查测试状态
check_test_status() {
    log_info "检查测试状态..."

    if [ -f "$TEST_STATUS_FILE" ] && [ -s "$TEST_STATUS_FILE" ]; then
        local status=$(cat "$TEST_STATUS_FILE")
        case $status in
            "TESTING")
                log_warning "测试正在进行中..."
                ;;
            "PASSED")
                log_success "上次测试通过"
                ;;
            "FAILED")
                log_warning "上次测试失败"
                ;;
            *)
                log_info "测试状态: $status"
                ;;
        esac
    else
        log_info "无测试状态记录"
    fi
}

# 检查开发状态
check_dev_status() {
    log_info "检查开发状态..."

    if [ -f "$DEV_STATUS_FILE" ] && [ -s "$DEV_STATUS_FILE" ]; then
        local status=$(cat "$DEV_STATUS_FILE")
        case $status in
            "IN_PROGRESS")
                log_warning "开发正在进行中..."
                ;;
            "COMPLETED")
                log_success "开发已完成"
                ;;
            "BLOCKED")
                log_warning "开发被阻塞"
                ;;
            *)
                log_info "开发状态: $status"
                ;;
        esac
    else
        log_info "无开发状态记录"
    fi
}

# 检查问题记录
check_issues() {
    log_info "检查问题记录..."

    if [ -s "$ISSUES_FILE" ]; then
        log_warning "发现未解决的问题:"
        tail -5 "$ISSUES_FILE"
        return 1
    else
        log_success "无未解决问题"
    fi
}

# 检查服务状态
check_services_status() {
    log_info "检查服务状态..."

    if [ -f "$CLAUDE_DIR/scripts/health-check.sh" ]; then
        if bash "$CLAUDE_DIR/scripts/health-check.sh" -q; then
            log_success "所有服务运行正常"
        else
            log_warning "部分服务状态异常，建议执行健康检查"
        fi
    else
        log_warning "健康检查脚本不存在"
    fi
}

# 生成同步报告
generate_sync_report() {
    log_info "生成同步报告..."

    local report_file="$CLAUDE_DIR/reports/sync-report-$(date +%Y%m%d-%H%M%S).txt"

    {
        echo "=== 工作空间同步报告 ==="
        echo "同步时间: $(date)"
        echo "项目目录: $PROJECT_ROOT"
        echo "当前分支: $(git branch --show-current 2>/dev/null || echo 'Unknown')"
        echo ""

        echo "=== Git状态 ==="
        if [ -n "$(git status --porcelain 2>/dev/null)" ]; then
            echo "状态: 有未提交的更改"
            git status --short
        else
            echo "状态: 工作目录干净"
        fi
        echo ""

        echo "=== 开发状态 ==="
        if [ -f "$DEV_STATUS_FILE" ] && [ -s "$DEV_STATUS_FILE" ]; then
            echo "状态: $(cat "$DEV_STATUS_FILE")"
        else
            echo "状态: 未知"
        fi
        echo ""

        echo "=== 测试状态 ==="
        if [ -f "$TEST_STATUS_FILE" ] && [ -s "$TEST_STATUS_FILE" ]; then
            echo "状态: $(cat "$TEST_STATUS_FILE")"
        else
            echo "状态: 未知"
        fi
        echo ""

        echo "=== 待测试任务 ==="
        if [ -s "$PENDING_TESTS_FILE" ]; then
            cat "$PENDING_TESTS_FILE"
        else
            echo "无"
        fi
        echo ""

        echo "=== 问题记录 ==="
        if [ -s "$ISSUES_FILE" ]; then
            tail -3 "$ISSUES_FILE"
        else
            echo "无"
        fi
        echo ""

        echo "=== 最新提交 ==="
        git log --oneline -3 2>/dev/null || echo "无法获取提交信息"

    } > "$report_file"

    log_success "同步报告已保存到: $report_file"
}

# 清理旧文件
cleanup_old_files() {
    log_info "清理旧文件..."

    # 清理超过7天的报告
    find "$CLAUDE_DIR/reports" -name "*.txt" -type f -mtime +7 -delete 2>/dev/null || true

    # 清理超过30天的日志
    find "$CLAUDE_DIR/logs" -name "*.log" -type f -mtime +30 -delete 2>/dev/null || true

    # 限制同步日志大小
    if [ -f "$SYNC_LOG" ] && [ $(stat -f%z "$SYNC_LOG" 2>/dev/null || stat -c%s "$SYNC_LOG" 2>/dev/null || echo 0) -gt 1048576 ]; then
        tail -1000 "$SYNC_LOG" > "$SYNC_LOG.tmp" && mv "$SYNC_LOG.tmp" "$SYNC_LOG"
    fi

    log_success "旧文件清理完成"
}

# 显示工作状态概览
show_status_overview() {
    echo -e "\n${BLUE}=== 工作状态概览 ===${NC}"

    # Git状态
    if [ -n "$(git status --porcelain 2>/dev/null)" ]; then
        echo -e "Git状态: ${YELLOW}有未提交更改${NC}"
    else
        echo -e "Git状态: ${GREEN}工作目录干净${NC}"
    fi

    # 开发状态
    if [ -f "$DEV_STATUS_FILE" ] && [ -s "$DEV_STATUS_FILE" ]; then
        local dev_status=$(cat "$DEV_STATUS_FILE")
        case $dev_status in
            "COMPLETED")
                echo -e "开发状态: ${GREEN}已完成${NC}"
                ;;
            "IN_PROGRESS")
                echo -e "开发状态: ${YELLOW}进行中${NC}"
                ;;
            *)
                echo -e "开发状态: $dev_status"
                ;;
        esac
    else
        echo -e "开发状态: ${YELLOW}未知${NC}"
    fi

    # 测试状态
    if [ -f "$TEST_STATUS_FILE" ] && [ -s "$TEST_STATUS_FILE" ]; then
        local test_status=$(cat "$TEST_STATUS_FILE")
        case $test_status in
            "PASSED")
                echo -e "测试状态: ${GREEN}通过${NC}"
                ;;
            "FAILED")
                echo -e "测试状态: ${RED}失败${NC}"
                ;;
            "TESTING")
                echo -e "测试状态: ${YELLOW}测试中${NC}"
                ;;
            *)
                echo -e "测试状态: $test_status"
                ;;
        esac
    else
        echo -e "测试状态: ${YELLOW}未知${NC}"
    fi

    # 待测试任务
    if [ -s "$PENDING_TESTS_FILE" ]; then
        local pending_count=$(wc -l < "$PENDING_TESTS_FILE")
        echo -e "待测试任务: ${YELLOW}$pending_count 个${NC}"
    else
        echo -e "待测试任务: ${GREEN}无${NC}"
    fi

    # 问题记录
    if [ -s "$ISSUES_FILE" ]; then
        local issue_count=$(wc -l < "$ISSUES_FILE")
        echo -e "未解决问题: ${RED}$issue_count 个${NC}"
    else
        echo -e "未解决问题: ${GREEN}无${NC}"
    fi
}

# 显示帮助信息
show_help() {
    echo "用法: $0 [选项]"
    echo ""
    echo "选项:"
    echo "  -h, --help              显示帮助信息"
    echo "  -i, --init              初始化工作空间"
    echo "  -s, --status            显示状态概览"
    echo "  -g, --git               仅检查Git状态"
    echo "  -c, --cleanup           清理旧文件"
    echo "  -q, --quiet             静默模式"
    echo "  --no-git                跳过Git检查"
    echo "  --no-services           跳过服务状态检查"
    echo ""
    echo "示例:"
    echo "  $0                      # 完整同步"
    echo "  $0 -s                   # 仅显示状态"
    echo "  $0 -i                   # 初始化工作空间"
    echo "  $0 --no-git             # 跳过Git检查的同步"
}

# 主函数
main() {
    local init_only=false
    local status_only=false
    local git_only=false
    local cleanup_only=false
    local quiet_mode=false
    local skip_git=false
    local skip_services=false

    # 解析命令行参数
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -i|--init)
                init_only=true
                shift
                ;;
            -s|--status)
                status_only=true
                shift
                ;;
            -g|--git)
                git_only=true
                shift
                ;;
            -c|--cleanup)
                cleanup_only=true
                shift
                ;;
            -q|--quiet)
                quiet_mode=true
                shift
                ;;
            --no-git)
                skip_git=true
                shift
                ;;
            --no-services)
                skip_services=true
                shift
                ;;
            *)
                echo "错误: 未知参数 '$1'"
                show_help
                exit 1
                ;;
        esac
    done

    # 初始化工作空间
    init_workspace

    # 根据选项执行相应操作
    if [ "$init_only" = true ]; then
        exit 0
    fi

    if [ "$status_only" = true ]; then
        show_status_overview
        exit 0
    fi

    if [ "$git_only" = true ]; then
        check_git_status
        exit $?
    fi

    if [ "$cleanup_only" = true ]; then
        cleanup_old_files
        exit 0
    fi

    # 完整同步流程
    if [ "$quiet_mode" != true ]; then
        log_info "开始工作空间同步..."
    fi

    local sync_failed=false

    # Git状态检查
    if [ "$skip_git" != true ]; then
        if ! check_git_status; then
            sync_failed=true
        fi
        sync_remote_code
    fi

    # 检查各种状态
    check_dev_status
    check_test_status
    check_pending_tests
    check_issues

    # 服务状态检查
    if [ "$skip_services" != true ]; then
        check_services_status
    fi

    # 生成报告
    generate_sync_report

    # 清理旧文件
    cleanup_old_files

    # 显示状态概览
    if [ "$quiet_mode" != true ]; then
        show_status_overview
    fi

    if [ "$sync_failed" = true ]; then
        log_warning "同步过程中发现问题，请查看上述信息"
        exit 1
    else
        log_success "工作空间同步完成"
        exit 0
    fi
}

# 执行主函数
main "$@"