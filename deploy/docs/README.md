# 📚 部署文档中心

## 🎯 文档概述

本文档中心提供电商微服务项目的完整部署指南和脚本使用说明，涵盖Windows开发环境和Linux生产环境的部署方案。

## 📋 文档结构

### 📜 [SCRIPTS.md](./SCRIPTS.md) - 脚本使用手册
**目的**：提供所有部署脚本的详细使用说明

**内容包括**：
- 环境初始化脚本（init.ps1/init.bat/init.sh）
- 镜像管理脚本（build/export/import/push）
- 服务管理脚本（start/stop）
- 脚本参数、语法和使用场景

**适用人群**：开发者、运维人员

**使用场景**：
```bash
# PowerShell版本（推荐）
.\init.ps1 -Help
.\init.ps1 check

# 环境初始化底层命令
docker network create --driver bridge --subnet=172.20.0.0/16 ecommerce-network
New-Item -ItemType Directory -Path "data" -Force

# 服务管理底层命令
docker compose -f docker-compose.infra.yml up -d
docker compose -f docker-compose.apps.yml up -d
docker compose -f docker-compose.infra.yml down mysql

# 健康检查底层命令
docker ps --filter "name=mysql" --filter "health=healthy"
docker inspect --format='{{.State.Health.Status}}' mysql

# 构建特定服务镜像
build-images.bat -s user-service

# 启动所有服务
start-all.ps1
```

---

### 🚀 [DEPLOYMENT.md](./DEPLOYMENT.md) - 部署指南
**目的**：提供完整的项目部署流程和关键配置说明

**内容包括**：
- Windows开发环境快速部署
- Linux生产环境部署流程
- 关键配置说明
- 部署验证方法

**适用人群**：部署工程师、运维人员

**部署流程概览**：
```bash
# Windows快速部署
1. .\init.ps1                 # 环境初始化（PowerShell版本）
   或 init.bat                 # 环境初始化（批处理版本）
2. build-images.bat            # 构建镜像
3. start-all.bat               # 启动服务
4. 验证部署                    # 访问验证

# Linux生产部署
1. sudo ./init.sh              # 环境初始化（自动安装Docker）
2. sudo ./import-images.sh     # 导入镜像
3. sudo ./start-all.sh         # 启动服务
4. 验证部署                    # 访问验证
```

---

### 🔧 [TROUBLESHOOTING.md](./TROUBLESHOOTING.md) - 故障排查指南
**目的**：提供实战问题诊断和解决方案

**内容包括**：
- 🚨 **重要实战错误案例**（必须避免的典型错误）
- 🔍 **高频实战问题**（Docker、服务、应用层面）
- 🛠️ **快速诊断工具**（一键健康检查脚本）
- 🚨 **应急处理流程**（服务快速恢复）

**适用人群**：所有项目参与人员

**核心错误案例**：
```bash
# ❌ 错误：配置修改后使用restart
docker-compose restart    # 配置不会生效

# ✅ 正确：配置修改后完整重启
docker-compose down
docker-compose up -d
```

---

## 🏗️ 整体部署思路

### 设计理念
1. **环境分离**：Windows开发环境 + Linux生产环境
2. **脚本自动化**：减少手动操作，降低错误率
3. **配置标准化**：统一的配置管理和部署流程
4. **问题预防**：通过文档避免常见错误

### 技术栈
- **容器化**：Docker + Docker Compose
- **微服务**：Spring Boot + Spring Cloud
- **基础设施**：MySQL + Redis + Nacos + RocketMQ
- **部署工具**：自动化脚本 + 配置模板

### 部署架构
```
开发环境 (Windows)          生产环境 (Linux)
├─ Docker Desktop          ├─ Docker Engine
├─ 自动化脚本              ├─ 自动化脚本
├─ 本地镜像构建            ├─ 离线镜像导入
└─ 快速启动验证            └─ 生产配置优化
```

## 🎯 使用指南

### 📍 首次部署
1. **阅读[部署指南](./DEPLOYMENT.md)**，了解完整部署流程
2. **参考[脚本手册](./SCRIPTS.md)**，学习脚本使用方法
3. **准备环境**：检查系统要求和必要软件
4. **执行部署**：按照指南步骤进行部署
5. **验证结果**：确认所有服务正常运行

### 🔧 问题排查
1. **查看[故障排查](./TROUBLESHOOTING.md)**，定位问题类型
2. **使用诊断工具**：运行一键健康检查脚本
3. **参考解决方案**：按照文档步骤解决问题
4. **预防措施**：学习避免常见错误的方法

### 📚 日常维护
1. **服务管理**：使用start/stop脚本管理服务
2. **镜像管理**：使用build/export/import管理镜像
3. **监控检查**：定期运行健康检查脚本
4. **配置更新**：注意配置修改后的正确重启方式

## 🚨 重要提醒

### ⚠️ 关键注意事项
1. **配置修改后必须执行完整重启**：
   ```bash
   docker-compose down
   docker-compose up -d
   ```
   ❌ **不要使用** `docker-compose restart`

2. **脚本权限要求**：
   - Windows：以管理员身份运行
   - Linux：使用sudo运行

3. **端口冲突检查**：
   - Windows 8848端口容易冲突
   - 使用init脚本自动检查端口状态

### 🔧 推荐最佳实践
1. **部署前准备**：运行init脚本检查环境
2. **分步验证**：每个阶段后验证服务状态
3. **日志监控**：定期检查容器和应用日志
4. **备份策略**：重要配置和数据定期备份

## 📞 获取帮助

### 🆘 问题分类处理
- **脚本使用问题** → 查看[SCRIPTS.md](./SCRIPTS.md)
- **部署流程问题** → 查看[DEPLOYMENT.md](./DEPLOYMENT.md)
- **运行时故障** → 查看[TROUBLESHOOTING.md](./TROUBLESHOOTING.md)

### 📋 反馈信息
遇到问题时，请收集以下信息：
- 操作系统和版本
- Docker版本
- 执行的命令和错误信息
- 相关日志输出

---

## 📊 文档信息

| 文档 | 版本 | 状态 | 维护日期 |
|------|------|------|----------|
| README.md | v1.0 | ✅ 最新 | 2025-10-20 |
| SCRIPTS.md | v3.0 | ✅ 最新 | 2025-10-20 |
| DEPLOYMENT.md | v3.0 | ✅ 最新 | 2025-10-20 |
| TROUBLESHOOTING.md | v4.0 | ✅ 最新 | 2025-10-20 |

---

**项目**: 电商微服务学习项目
**维护团队**: 电商微服务项目组
**最后更新**: 2025-10-20

💡 **提示**: 建议按照 README → DEPLOYMENT → SCRIPTS → TROUBLESHOOTING 的顺序阅读文档