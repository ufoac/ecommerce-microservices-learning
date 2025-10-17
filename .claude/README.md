# 电商微服务项目 - Claude 分身协作配置

## 概述

本项目配置了完善的开发和测试分身协作机制，支持"一个窗口写代码，一个窗口测试"的高效工作模式。

## 配置文件说明

### 核心配置
- `test-persona.md` - 测试分身角色配置
- `workflow.md` - 开发与测试协作工作流程
- `communicate.md` - 分身间通信机制
- `README.md` - 本文件，配置说明

### 脚本工具
- `scripts/health-check.sh` - 微服务健康检查脚本
- `scripts/api-test.sh` - API接口测试脚本
- `scripts/sync-workspace.sh` - 工作空间同步脚本

## 快速开始

### 1. 初始化测试分身

在新窗口中启动 Claude 并加载测试分身配置：

```bash
cd D:\test\learn\backend
claude
```

然后输入以下初始化指令：

```
你好，我是这个电商项目的测试分身。请根据 .claude/test-persona.md 配置文件加载我的角色配置。我负责：
1. 功能测试验证
2. 服务状态监控
3. API接口测试
4. 问题发现和反馈

项目技术栈：JDK 21 + Spring Boot 3.3.5 + Vue 3.4 + Element Plus
微服务架构：gateway(8080) + auth(8081) + user(8082) + product(8083) + order(8084) + cart(8085)

请开始我们的测试协作工作。
```

### 2. 开发分身设置

在原开发窗口中设置开发模式：

```bash
echo "IN_PROGRESS" > .claude/dev-status.txt
```

### 3. 基本工作流程

#### 开发窗口（写代码）
```bash
# 1. 开发功能
git checkout -b feature/new-function
# 编写代码...

# 2. 提交代码
git add .
git commit -m "feat: 实现XX功能"
git push origin feature/new-function

# 3. 通知测试
echo "COMPLETED" > .claude/dev-status.txt
echo "$(date): [FEATURE] XX功能" >> .claude/pending-tests.txt
```

#### 测试窗口（测试）
```bash
# 1. 检查新任务
./.claude/scripts/sync-workspace.sh

# 2. 拉取最新代码
git pull origin feature/new-function

# 3. 执行测试
./.claude/scripts/health-check.sh
./.claude/scripts/api-test.sh -a

# 4. 反馈结果
echo "PASSED" > .claude/test-status.txt
```

## 脚本使用指南

### 健康检查脚本
```bash
# 检查所有服务
./.claude/scripts/health-check.sh

# 检查特定服务
./.claude/scripts/health-check.sh -s gateway

# 静默模式
./.claude/scripts/health-check.sh -q
```

### API测试脚本
```bash
# 执行所有测试
./.claude/scripts/api-test.sh -a

# 只测试认证功能
./.claude/scripts/api-test.sh -u

# 指定网关地址
./.claude/scripts/api-test.sh --url http://localhost:9090 -a
```

### 工作空间同步脚本
```bash
# 完整同步
./.claude/scripts/sync-workspace.sh

# 只显示状态
./.claude/scripts/sync-workspace.sh -s

# 初始化工作空间
./.claude/scripts/sync-workspace.sh -i
```

## 通信协议

### 开发完成通知格式
```
【开发完成通知】
时间: 2024-XX-XX XX:XX:XX
功能: [功能名称]
分支: [git分支]
提交: [commit hash]
测试重点: [测试重点]
相关文件: [相关文件列表]
```

### 测试结果通知格式
```
【测试结果报告】
时间: 2024-XX-XX XX:XX:XX
功能: [功能名称]
测试结果: PASS/FAIL
测试详情: [详细测试结果]
问题描述: [如有问题]
建议修复: [修复建议]
```

## 状态文件说明

### .claude/dev-status.txt
- `IDLE`: 空闲
- `IN_PROGRESS`: 开发中
- `COMPLETED`: 已完成
- `BLOCKED`: 被阻塞

### .claude/test-status.txt
- `IDLE`: 空闲
- `TESTING`: 测试中
- `PASSED`: 通过
- `FAILED`: 失败
- `BLOCKED`: 被阻塞

### .claude/pending-tests.txt
记录待测试的功能列表

### .claude/issues.txt
记录发现的问题和异常

## 项目结构

```
D:\test\learn\
├── .claude/
│   ├── test-persona.md          # 测试分身配置
│   ├── workflow.md              # 工作流程
│   ├── communicate.md           # 通信机制
│   ├── README.md               # 配置说明
│   ├── scripts/                # 测试脚本
│   │   ├── health-check.sh     # 健康检查
│   │   ├── api-test.sh         # API测试
│   │   └── sync-workspace.sh   # 工作空间同步
│   ├── reports/                # 测试报告
│   ├── logs/                   # 日志文件
│   ├── dev-status.txt          # 开发状态
│   ├── test-status.txt         # 测试状态
│   ├── pending-tests.txt       # 待测试任务
│   ├── issues.txt             # 问题记录
│   └── notifications.txt       # 通知消息
├── backend/                    # 后端代码
├── frontend/                   # 前端代码
├── docs/                      # 文档
└── deploy/                    # 部署配置
```

## 最佳实践

### 1. 定期同步
- 每次开发完成后立即通知测试分身
- 测试分身每小时检查一次状态更新
- 定期清理旧的通信记录

### 2. 消息规范
- 使用标准化的通知格式
- 包含详细的时间戳和描述信息
- 重要信息使用结构化格式

### 3. 错误处理
- 通信文件损坏时的恢复机制
- 网络异常时的重试策略
- 数据不一致时的修复方案

### 4. 性能优化
- 避免频繁的文件读写操作
- 使用缓存机制减少重复检查
- 定期清理日志文件

## 故障排查

### 常见问题

1. **脚本无法执行**
   ```bash
   chmod +x .claude/scripts/*.sh
   ```

2. **服务健康检查失败**
   ```bash
   # 检查服务是否启动
   netstat -tuln | grep 8080
   # 检查Docker容器
   docker ps
   ```

3. **API测试失败**
   ```bash
   # 检查网关配置
   curl http://localhost:8080/actuator/health
   # 检查服务注册
   curl http://localhost:8848/nacos/
   ```

4. **通信文件权限问题**
   ```bash
   # 检查文件权限
   ls -la .claude/
   # 修复权限
   chmod 644 .claude/*.txt
   ```

### 日志查看
```bash
# 查看同步日志
tail -f .claude/sync-log.txt

# 查看通知记录
tail -f .claude/notifications.txt

# 查看问题记录
tail -f .claude/issues.txt
```

## 进阶功能

### 1. 自动化触发
可以设置定时任务自动执行状态检查：

```bash
# 添加到 crontab
*/30 * * * * cd /path/to/project && ./.claude/scripts/sync-workspace.sh -q
```

### 2. 集成CI/CD
在CI/CD流水线中集成测试脚本：

```yaml
# GitHub Actions 示例
- name: Run API Tests
  run: |
    chmod +x .claude/scripts/*.sh
    ./.claude/scripts/api-test.sh -a
```

### 3. 监控告警
配置监控告警机制，当服务异常或测试失败时发送通知。

## 贡献指南

1. 遵循现有的代码格式和命名规范
2. 添加必要的注释和文档
3. 确保所有脚本都有适当的错误处理
4. 更新相关文档说明

## 联系方式

如有问题或建议，请通过以下方式联系：
- 项目Issues: [GitHub Issues链接]
- 文档更新: 提交PR到docs分支
- 紧急问题: 直接联系项目负责人

---

**注意**: 本配置适用于电商微服务学习项目，请根据实际项目需求调整配置参数和测试用例。