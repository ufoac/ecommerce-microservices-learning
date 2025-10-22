# 脚本使用指南

## 镜像构建脚本

### build-images.ps1 完整参数说明
```bash
# 语法格式
build-images.ps1 -Target [target] [-tag [tag_name]]

# 支持的目标服务
-Target all          # 构建所有服务镜像
-Target user         # 构建用户服务镜像
-Target product      # 构建商品服务镜像
-Target trade        # 构建交易服务镜像
-Target gateway      # 构建网关服务镜像

# 标签参数（可选）
-tag latest          # 指定镜像标签（默认latest）
```

### 执行示例
```bash
# 构建所有服务
powershell.exe -ExecutionPolicy Bypass -File "deploy/scripts/windows/images/build-images.ps1" -Target all

# 构建单个服务
powershell.exe -ExecutionPolicy Bypass -File "deploy/scripts/windows/images/build-images.ps1" -Target user

# 构建带标签
powershell.exe -ExecutionPolicy Bypass -File "deploy/scripts/windows/images/build-images.ps1" -Target all -tag v1.0
```

## 容器管理脚本

### start-all.ps1 完整参数说明
```bash
# 语法格式
start-all.ps1 -Target [target] [-StatusOnly]

# 支持的目标
-Target all              # 启动所有服务
-Target infra            # 启动基础设施服务
-Target apps             # 启动应用服务
-Target api-gateway      # 启动网关服务
-Target user-service     # 启动用户服务
-Target product-service  # 启动商品服务
-Target trade-service    # 启动交易服务

# 状态查询参数
-StatusOnly              # 仅检查服务状态，不执行启动
```

### stop-all.ps1 完整参数说明
```bash
# 语法格式
stop-all.ps1 -Target [target]

# 支持的目标
-Target all              # 停止所有服务
-Target apps             # 停止应用服务
-Target api-gateway      # 停止网关服务
-Target user-service     # 停止用户服务
-Target product-service  # 停止商品服务
-Target trade-service    # 停止交易服务
```

### 执行示例
```bash
# 启动所有服务
powershell.exe -ExecutionPolicy Bypass -File "deploy/scripts/windows/deploy/start-all.ps1"

# 启动基础设施服务
powershell.exe -ExecutionPolicy Bypass -File "deploy/scripts/windows/deploy/start-all.ps1" -Target infra

# 启动单个服务
powershell.exe -ExecutionPolicy Bypass -File "deploy/scripts/windows/deploy/start-all.ps1" -Target user-service

# 检查服务状态
powershell.exe -ExecutionPolicy Bypass -File "deploy/scripts/windows/deploy/start-all.ps1" -StatusOnly

# 停止应用服务
powershell.exe -ExecutionPolicy Bypass -File "deploy/scripts/windows/deploy/stop-all.ps1" -Target apps
```

## 镜像管理脚本

### export-images.ps1 说明
```bash
# 导出所有镜像到文件
export-images.ps1

# 导出指定镜像
export-images.ps1 -Images ecommerce/user-service,ecommerce/api-gateway
```

### push-images.ps1 说明
```bash
# 推送所有镜像到仓库
push-images.ps1

# 推送指定镜像
push-images.ps1 -Images ecommerce/user-service,ecommerce/api-gateway
```

## 脚本执行规范

### 执行前检查
1. **确认工作目录**: 在项目根目录执行脚本
2. **检查权限**: 确保PowerShell执行策略允许脚本运行
3. **验证依赖**: 确保Docker和Maven可用

### 常见错误处理
- **权限不足**: 使用管理员权限运行PowerShell
- **路径错误**: 确保在正确目录执行脚本
- **端口冲突**: 检查端口是否被占用
- **Docker未启动**: 确保Docker服务正在运行

### 脚本输出解读
- **SUCCESS**: 操作成功完成
- **WARNING**: 存在潜在问题但不影响执行
- **ERROR**: 操作失败，需要检查错误信息
- **INFO**: 一般信息提示

---

**文档用途**: 提供详细的脚本操作说明和参数规范
**适用场景**: 需要精确控制脚本执行和参数配置
**更新原则**: 遇到新的脚本参数或使用问题时更新