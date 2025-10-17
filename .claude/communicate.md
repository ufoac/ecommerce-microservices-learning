# 开发与测试分身通信机制

## 通信架构

```
开发窗口 ←→ .claude/通信文件 ←→ 测试窗口
    ↑                              ↓
    └─── Git仓库 ── 共享代码 ───┘
```

## 通信文件系统

### 状态文件
```
.claude/
├── dev-status.txt           # 开发状态
├── test-status.txt          # 测试状态
├── pending-tests.txt        # 待测试任务
├── issues.txt              # 问题记录
├── notifications.txt       # 通知消息
└── communication.log       # 通信日志
```

### 状态值定义

#### 开发状态 (dev-status.txt)
- `IDLE`: 空闲状态
- `IN_PROGRESS`: 开发进行中
- `COMPLETED`: 开发完成
- `BLOCKED`: 开发阻塞
- `REVIEW`: 代码审查中

#### 测试状态 (test-status.txt)
- `IDLE`: 空闲状态
- `TESTING`: 测试进行中
- `PASSED`: 测试通过
- `FAILED`: 测试失败
- `BLOCKED`: 测试阻塞

## 通信协议

### 1. 开发完成通知

**触发条件**: 开发窗口完成功能实现

**操作流程**:
```bash
# 开发窗口执行
echo "COMPLETED" > .claude/dev-status.txt
echo "$(date): [FEATURE] 用户注册API" >> .claude/pending-tests.txt
echo "$(date): [NOTIFY] 开发完成，请测试用户注册API功能" >> .claude/notifications.txt
```

**通知格式**:
```
【开发完成通知】
时间: 2024-XX-XX XX:XX:XX
功能: 用户注册API
分支: feature/user-register
提交: abc1234 - feat: 实现用户注册功能
测试重点:
- 用户注册接口正确性
- 数据验证逻辑
- 异常处理机制
相关文件:
- auth-service/src/main/java/.../AuthController.java
- auth-service/src/main/java/.../UserService.java
- auth-service/src/test/java/.../AuthTest.java
```

### 2. 测试结果通知

**触发条件**: 测试窗口完成测试

**操作流程**:
```bash
# 测试窗口执行
echo "PASSED" > .claude/test-status.txt
echo "$(date): [RESULT] 用户注册API测试通过" >> .claude/notifications.txt
sed -i '/用户注册API/d' .claude/pending-tests.txt
```

**通知格式**:
```
【测试结果报告】
时间: 2024-XX-XX XX:XX:XX
功能: 用户注册API
测试结果: PASS
测试耗时: 15分钟
测试详情:
✓ API接口测试: PASS (响应时间: 120ms)
✓ 数据验证测试: PASS
✓ 异常处理测试: PASS
✓ 性能基础测试: PASS (并发10用户，平均响应200ms)
测试覆盖率: 85%
建议: 可以进行下一阶段开发
```

### 3. 问题发现通知

**触发条件**: 测试发现问题

**操作流程**:
```bash
# 测试窗口执行
echo "FAILED" > .claude/test-status.txt
echo "$(date): [ISSUE] 用户注册API返回500错误 - SQL异常" >> .claude/issues.txt
echo "$(date): [NOTIFY] 测试发现问题，请及时修复" >> .claude/notifications.txt
```

**问题格式**:
```
【测试发现问题】
时间: 2024-XX-XX XX:XX:XX
功能: 用户注册API
问题级别: HIGH
问题类型: 运行时异常
错误信息: SQLSyntaxErrorException: Table 'user' doesn't exist
复现步骤:
1. POST /api/auth/register
2. 请求体: {"username":"test","password":"123456","email":"test@example.com"}
3. 观察: 返回500错误
预期结果: 返回201和用户信息
实际结果: 返回500和错误信息
环境影响:
- 数据库: MySQL 8.0
- 表结构: user表不存在
建议修复:
1. 检查数据库初始化脚本
2. 确保user表创建语句正确
3. 验证数据库连接配置
```

## 自动化通信脚本

### 1. 开发通知脚本 (dev-notify.sh)

```bash
#!/bin/bash
# 开发通知脚本

notify_dev_completion() {
    local feature_name="$1"
    local branch_name="$2"
    local commit_hash="$3"
    local test_points="$4"

    echo "COMPLETED" > .claude/dev-status.txt
    echo "$(date): $feature_name" >> .claude/pending-tests.txt

    cat > .claude/last-dev-notification.txt << EOF
【开发完成通知】
时间: $(date)
功能: $feature_name
分支: $branch_name
提交: $commit_hash
测试重点:
$test_points
EOF

    echo "$(date): [NOTIFY] 开发完成 - $feature_name" >> .claude/notifications.txt
    echo "开发完成通知已发送: $feature_name"
}

# 使用示例
notify_dev_completion "用户注册API" "feature/user-register" "$(git log -1 --oneline)" "API正确性、数据验证、异常处理"
```

### 2. 测试通知脚本 (test-notify.sh)

```bash
#!/bin/bash
# 测试通知脚本

notify_test_result() {
    local feature_name="$1"
    local test_result="$2"
    local test_details="$3"
    local test_duration="$4"

    echo "$test_result" > .claude/test-status.txt

    if [ "$test_result" = "PASSED" ]; then
        sed -i "/$feature_name/d" .claude/pending-tests.txt
    fi

    cat > .claude/last-test-notification.txt << EOF
【测试结果报告】
时间: $(date)
功能: $feature_name
测试结果: $test_result
测试耗时: $test_duration
测试详情:
$test_details
EOF

    echo "$(date): [RESULT] $feature_name 测试 $test_result" >> .claude/notifications.txt
    echo "测试结果通知已发送: $feature_name - $test_result"
}

notify_issue_found() {
    local feature_name="$1"
    local issue_type="$2"
    local issue_description="$3"
    local severity="$4"

    echo "FAILED" > .claude/test-status.txt
    echo "$(date): [$severity] $feature_name - $issue_type: $issue_description" >> .claude/issues.txt

    cat > .claude/last-issue-notification.txt << EOF
【测试发现问题】
时间: $(date)
功能: $feature_name
问题级别: $severity
问题类型: $issue_type
问题描述: $issue_description
EOF

    echo "$(date): [ISSUE] $feature_name 发现问题 - $issue_type" >> .claude/notifications.txt
    echo "问题通知已发送: $feature_name - $issue_type"
}

# 使用示例
# notify_test_result "用户注册API" "PASSED" "所有测试通过" "10分钟"
# notify_issue_found "用户注册API" "SQL异常" "Table 'user' doesn't exist" "HIGH"
```

### 3. 状态检查脚本 (check-status.sh)

```bash
#!/bin/bash
# 状态检查脚本

check_notifications() {
    echo "=== 检查新通知 ==="

    if [ -f .claude/notifications.txt ]; then
        local new_notifications=$(tail -5 .claude/notifications.txt)
        if [ -n "$new_notifications" ]; then
            echo "$new_notifications"
        else
            echo "无新通知"
        fi
    else
        echo "通知文件不存在"
    fi
}

check_status() {
    echo "=== 当前状态 ==="

    echo "开发状态: $(cat .claude/dev-status.txt 2>/dev/null || echo 'UNKNOWN')"
    echo "测试状态: $(cat .claude/test-status.txt 2>/dev/null || echo 'UNKNOWN')"

    if [ -f .claude/pending-tests.txt ] && [ -s .claude/pending-tests.txt ]; then
        echo "待测试任务:"
        cat .claude/pending-tests.txt
    else
        echo "无待测试任务"
    fi

    if [ -f .claude/issues.txt ] && [ -s .claude/issues.txt ]; then
        echo "未解决问题:"
        tail -3 .claude/issues.txt
    else
        echo "无未解决问题"
    fi
}

# 主函数
case "$1" in
    "notifications")
        check_notifications
        ;;
    "status")
        check_status
        ;;
    "all")
        check_notifications
        echo ""
        check_status
        ;;
    *)
        echo "用法: $0 [notifications|status|all]"
        ;;
esac
```

## 通信最佳实践

### 1. 通知频率控制
- 开发完成通知: 功能完成后立即发送
- 测试结果通知: 测试完成后30分钟内发送
- 问题通知: 发现问题立即发送
- 状态更新: 每小时检查一次

### 2. 消息格式规范
- 使用标准化的消息格式
- 包含时间戳、功能名称、详细描述
- 重要信息使用结构化格式

### 3. 文件大小管理
- 定期清理旧的通信记录
- 限制日志文件大小
- 保留最近30天的记录

### 4. 并发处理
- 使用文件锁避免并发写入冲突
- 原子操作更新状态文件
- 备份重要的通信数据

### 5. 错误处理
- 通信文件损坏时的恢复机制
- 网络异常时的重试策略
- 数据不一致时的修复方案

## 使用示例

### 开发窗口使用流程
```bash
# 1. 开发完成
./.claude/scripts/dev-notify.sh "用户登录API" "feature/user-login" "$(git log -1 --oneline)"

# 2. 检查测试反馈
./.claude/scripts/check-status.sh notifications

# 3. 查看问题（如有）
cat .claude/last-issue-notification.txt
```

### 测试窗口使用流程
```bash
# 1. 检查新任务
./.claude/scripts/check-status.sh all

# 2. 执行测试
./.claude/scripts/api-test.sh -a

# 3. 发送测试结果
./.claude/scripts/test-notify.sh "用户登录API" "PASSED" "所有测试通过" "8分钟"
```

这个通信机制确保了开发和测试分身之间的有效协作，通过标准化的通知格式和自动化脚本减少了沟通成本，提高了开发效率。