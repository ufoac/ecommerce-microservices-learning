# 开发与测试分身协作工作流程

## 工作流程图

```
开发窗口 ──[完成功能]──> 通知测试窗口 ──[拉取代码]──> 测试窗口
   ↑                                                      ↓
   │                                                      │
   └──────[反馈问题]───────[测试报告]──────────────────────┘
```

## 详细协作步骤

### 1. 开发窗口工作流程

#### 步骤1: 功能开发
```bash
# 开发窗口操作
git checkout -b feature/new-function
# 编写代码...
git add .
git commit -m "feat: 实现XX功能"
git push origin feature/new-function
```

#### 步骤2: 自测通知
```bash
# 通知测试分身
echo "【开发通知】已完成用户注册功能实现，请进行测试验证
功能点: 用户注册API
分支: feature/user-register
提交: $(git log -1 --oneline)
时间: $(date)"
```

#### 步骤3: 标记待测试
在项目根目录创建标记文件:
```bash
echo "user-register-api" > .claude/pending-tests.txt
echo "$(date): 用户注册API待测试" >> .claude/test-log.txt
```

### 2. 测试窗口工作流程

#### 步骤1: 检查待测试任务
```bash
# 检查是否有新的测试任务
if [ -f .claude/pending-tests.txt ]; then
    echo "发现新的测试任务:"
    cat .claude/pending-tests.txt
fi
```

#### 步骤2: 同步代码
```bash
# 拉取最新代码
git fetch origin
git checkout feature/user-register
git pull origin feature/user-register
```

#### 步骤3: 执行测试
```bash
# 启动服务进行测试
./scripts/start-services.sh
./scripts/run-tests.sh user-register
```

#### 步骤4: 生成测试报告
```bash
# 生成测试报告
./scripts/generate-test-report.sh user-register
```

### 3. 通信机制

#### 3.1 文件系统通信
```
.claude/
├── pending-tests.txt      # 待测试任务列表
├── test-results.txt       # 测试结果记录
├── dev-notifications.txt  # 开发通知
└── issues.txt            # 问题记录
```

#### 3.2 状态标记
```bash
# 开发窗口标记
echo "IN_PROGRESS" > .claude/dev-status.txt
echo "COMPLETED" > .claude/dev-status.txt

# 测试窗口标记
echo "TESTING" > .claude/test-status.txt
echo "PASSED" > .claude/test-status.txt
echo "FAILED" > .claude/test-status.txt
```

### 4. 标准化通知格式

#### 4.1 开发完成通知格式
```
【开发完成通知】
功能模块: [模块名称]
功能描述: [简要描述]
技术要点: [关键技术点]
测试重点: [需要重点测试的内容]
相关文件: [修改的文件列表]
分支名称: [git分支]
提交信息: [commit message]
完成时间: [时间]
注意事项: [测试注意事项]
```

#### 4.2 测试结果通知格式
```
【测试结果报告】
测试功能: [功能名称]
测试时间: [测试时间]
测试结果: PASS/FAIL
测试详情:
  ✓ API接口测试: 通过/失败
  ✓ 业务逻辑测试: 通过/失败
  ✓ 数据一致性测试: 通过/失败
  ✓ 性能基础测试: 通过/失败
问题描述: [如有问题]
复现步骤: [问题复现步骤]
建议修复: [修复建议]
```

### 5. 问题处理流程

#### 5.1 问题发现
```bash
# 测试窗口发现问题
echo "$(date): [ISSUE] 用户注册API返回500错误" >> .claude/issues.txt
echo "FAILED" > .claude/test-status.txt
```

#### 5.2 问题通知
```bash
# 通知开发窗口
echo "【测试发现问题】
功能: 用户注册API
问题: 500错误
时间: $(date)
详情: 查看.claude/issues.txt
请及时修复并重新测试"
```

#### 5.3 问题修复验证
```bash
# 开发窗口修复后
git commit -m "fix: 修复用户注册API 500错误"
echo "【修复通知】用户注册API问题已修复，请重新测试"

# 测试窗口重新测试
./scripts/run-tests.sh user-register --regression
```

### 6. 自动化脚本

#### 6.1 检查脚本 (check-status.sh)
```bash
#!/bin/bash
echo "=== 当前项目状态 ==="
echo "开发状态: $(cat .claude/dev-status.txt 2>/dev/null || echo 'UNKNOWN')"
echo "测试状态: $(cat .claude/test-status.txt 2>/dev/null || echo 'UNKNOWN')"
echo "待测试任务: $(cat .claude/pending-tests.txt 2>/dev/null || echo '无')"
echo "最近问题: $(tail -1 .claude/issues.txt 2>/dev/null || echo '无')"
```

#### 6.2 同步脚本 (sync-workspace.sh)
```bash
#!/bin/bash
echo "=== 同步工作空间 ==="
git fetch origin
echo "最新提交:"
git log --oneline -5
echo "当前分支:"
git branch
echo "待测试任务:"
if [ -f .claude/pending-tests.txt ]; then
    cat .claude/pending-tests.txt
else
    echo "无"
fi
```

### 7. 工作时间安排

#### 7.1 开发时段
- **主要开发**: 09:00-12:00, 14:00-17:00
- **代码提交**: 12:00, 17:30
- **自测通知**: 提交后立即通知

#### 7.2 测试时段
- **功能测试**: 10:00-12:00, 15:00-17:00
- **回归测试**: 17:30-18:00
- **测试报告**: 测试完成后30分钟内

### 8. 质量保证

#### 8.1 代码质量检查点
- 代码提交前: 开发自测
- 测试开始前: 代码同步
- 测试完成后: 结果验证
- 问题修复后: 回归测试

#### 8.2 测试覆盖要求
- API接口: 100%覆盖
- 业务逻辑: 主要场景覆盖
- 异常处理: 关键场景覆盖
- 性能测试: 基础性能验证

### 9. 文档维护

#### 9.1 测试文档
- 测试用例更新
- 测试结果记录
- 问题解决方案
- 最佳实践总结

#### 9.2 开发文档
- API接口文档
- 技术设计文档
- 部署配置文档
- 故障排查文档

这个工作流程确保了开发和测试分身之间的高效协作，通过标准化的通知格式和自动化脚本减少沟通成本，提高开发效率。