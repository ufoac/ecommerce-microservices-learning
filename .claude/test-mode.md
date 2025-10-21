# 测试模式配置

## 🎯 使用说明

当需要执行测试任务时，可以激活测试模式获得专门的测试工具和方法。

### 激活测试模式
```
请激活测试模式，我需要执行微服务的功能测试验证。
```

## 🗂️ 关键部署文件目录

### Docker Compose配置
```
deploy/docker-compose/
├── docker-compose.yml              # 主配置文件
├── docker-compose.infra.yml        # 基础设施服务
├── docker-compose.apps.yml         # 应用服务
└── docker-compose.dev.yml          # 开发环境配置
```

### PowerShell脚本工具集 v2.3
```
deploy/scripts/windows/
├── deploy/
│   ├── init.ps1                    # 环境初始化脚本
│   ├── start-all.ps1               # 启动所有服务
│   └── stop-all.ps1                # 停止所有服务
└── images/
    ├── build-images.ps1            # 镜像构建脚本
    ├── export-images.ps1           # 镜像导出脚本
    └── push-images.ps1             # 镜像推送脚本
```

### 部署文档
```
deploy/docs/
├── DEPLOYMENT.md                   # 部署指南
├── SCRIPTS.md                      # 脚本使用说明
└── TROUBLESHOOTING.md              # 故障排查手册
```

## 🔧 测试工具集

### 1. 健康检查脚本
```powershell
# 执行所有服务健康检查
.\.claude\scripts\health-check-en.ps1

# 检查特定服务
.\.claude\scripts\health-check-en.ps1 -service gateway

# 静默模式
.\.claude\scripts\health-check-en.ps1 -quiet
```

### 2. API测试脚本 (v2.0 - English Version)
```powershell
# 执行所有API测试
.\.claude\scripts\api-test.ps1

# 测试特定模块
.\.claude\scripts\api-test.ps1 -service auth
.\.claude\scripts\api-test.ps1 -service user
.\.claude\scripts\api-test.ps1 -service product
.\.claude\scripts\api-test.ps1 -service trade

# 指定网关地址
.\.claude\scripts\api-test.ps1 -url http://localhost:28080

# 显示帮助信息
.\.claude\scripts\api-test.ps1 -help
```

### 3. 环境检查脚本
```powershell
# 快速环境检查
.\.claude\scripts\test-env.ps1
```

## 📋 测试检查清单

### 第0阶段 - 环境验证
- [ ] Docker环境完整性
- [ ] PowerShell脚本工具可用性
- [ ] 网络和端口配置
- [ ] 基础设施服务健康状态

### 第一阶段 - 微服务技术骨架
- [ ] 所有微服务启动成功 (28080-28083)
- [ ] 服务注册到Nacos (18848)
- [ ] API网关路由正确

### 第二阶段 - 认证技术链路
- [ ] JWT生成和解析
- [ ] 认证拦截器工作
- [ ] Token自动携带

### 第三阶段 - 数据层技术
- [ ] MySQL CRUD操作
- [ ] Redis缓存读写
- [ ] 数据一致性验证

### 第四阶段 - 服务间通信
- [ ] OpenFeign调用成功
- [ ] 熔断降级机制
- [ ] RocketMQ消息队列通信

### 第五阶段 - 业务场景验证
- [ ] 完整电商业务流程
- [ ] 异常场景处理
- [ ] 用户体验验证

## 🔍 服务认证信息

### 数据库和缓存认证凭据
**配置文件位置**: `deploy/docker-compose/.env`

| 服务 | 用户名 | 密码 | 连接命令 |
|------|--------|------|----------|
| **MySQL** | root | root123456 | `docker exec mysql mysql -u root -proot123456` |
| **MySQL应用** | ecommerce | ecommerce123 | 应用程序连接 |
| **Redis** | - | redis123456 | `docker exec redis redis-cli -a redis123456` |
| **Nacos** | nacos | nacos | Web界面登录 |

### 服务连接测试命令
```powershell
# MySQL连接测试
docker exec mysql mysql -u root -proot123456 -e "SELECT 'MySQL OK' as status;"

# Redis连接测试
docker exec redis redis-cli -a redis123456 ping

# Nacos API认证测试
curl -X POST "http://localhost:18848/nacos/v1/auth/users/login" `
  -H "Content-Type: application/x-www-form-urlencoded" `
  -d "username=nacos&password=nacos"
```

## 🔍 脚本状态检查

### 当前脚本状态 (2025-10-21)
- ✅ **health-check-en.ps1** - 健康检查脚本，运行正常
- ✅ **test-env.ps1** - 环境检查脚本，运行正常
- ✅ **api-test.ps1** - API测试脚本，已修复编码问题，运行正常
- ✅ **chinese-template.ps1** - 中文脚本模板，包含UTF-8 BOM

### 脚本验证命令
```powershell
# 验证所有脚本可用性
.\.claude\scripts\health-check-en.ps1 -help
.\.claude\scripts\api-test.ps1 -help
.\.claude\scripts\test-env.ps1
```

## 🚨 重要经验教训

### PowerShell脚本编码
- **优先使用英文脚本**避免编码问题
- **中文支持方案**: UTF-8 BOM + `chcp 65001 | Out-Null`
- **脚本模板**: 参考 `.claude\scripts\README.md`
- **编码检查**: 所有脚本已通过UTF-8 BOM验证

### Docker环境
- **配置修改后**: 必须重新创建容器 `docker-compose down && docker-compose up -d`
- **健康检查失败**: 使用 `docker inspect` 检查具体原因
- **Windows端口**: 检查系统端口分配，避免冲突

## 📊 测试报告

测试报告自动保存到 `.claude\reports\` 目录

---

**版本**: v2.0 (简化版)
**最后更新**: 2025-10-21
**适用**: 电商微服务学习项目