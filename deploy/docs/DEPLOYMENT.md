# 🚀 部署文档

## 🎯 部署概述

本文档提供电商微服务项目的快速部署指南，涵盖Windows开发环境和Linux生产环境的关键部署流程。

## 📋 部署前准备

### 系统要求
- **CPU**: 4核心以上
- **内存**: 8GB RAM以上
- **磁盘**: 50GB可用空间以上
- **操作系统**: Windows 10/11 或 Ubuntu 18.04+/CentOS 7+

### 必要软件
- **Windows**: Docker Desktop + Git
- **Linux**: 所有必要软件通过init.sh脚本自动安装

### 端口规划
| 服务类型 | Windows端口 | Linux端口 | 说明 |
|----------|-------------|-----------|------|
| MySQL | 3306 | 3306 | 数据库服务 |
| Redis | 6379 | 6379 | 缓存服务 |
| Nacos | 18848 | 8848 | 注册中心 |
| API Gateway | 28080 | 28080 | 统一API入口 |
| User Service | 28081 | 28081 | 用户服务 |
| Product Service | 28082 | 28082 | 商品服务 |
| Trade Service | 28083 | 28083 | 交易服务 |

## 🏗️ 项目结构概览
```
ecommerce-microservices-learning/
├── backend/                    # 后端微服务
├── frontend/                   # 前端应用
├── deploy/                     # 部署配置
│   ├── scripts/                # 部署脚本
│   ├── docker-compose/         # Docker编排
│   └── docs/                   # 部署文档
├── data/                       # 数据持久化目录（运行时创建）
├── config/                     # 配置文件目录（运行时创建）
└── logs/                       # 日志目录（运行时创建）
```

## 🎯 Windows快速部署

### 步骤1：环境初始化

**方法1：使用PowerShell脚本（推荐）**
```powershell
# 1. 克隆项目
git clone <repository-url>
cd ecommerce-microservices-learning

# 2. 进入部署脚本目录
cd deploy\scripts\windows\deploy

# 3. 执行环境初始化脚本（PowerShell版本）
.\init.ps1

# 注意：如果遇到执行策略限制，请使用：
powershell.exe -ExecutionPolicy Bypass -File ".\init.ps1"
```

**方法2：使用批处理脚本（兼容）**
```cmd
# 1. 克隆项目
git clone <repository-url>
cd ecommerce-microservices-learning

# 2. 以管理员身份运行初始化
cd deploy\scripts\windows\deploy
init.bat
```

### 步骤2：构建镜像
```cmd
cd deploy\scripts\windows\images
build-images.bat
```

### 步骤3：启动服务
```cmd
cd deploy\scripts\windows\deploy
start-all.ps1

# 或者使用PowerShell
powershell.exe -ExecutionPolicy Bypass -File ".\start-all.ps1"
```

### 步骤4：验证部署
- **API网关**: http://localhost:28080
- **Nacos控制台**: http://localhost:18848/nacos
- **健康检查**: http://localhost:28080/actuator/health

## 🐧 Linux快速部署

### 步骤1：环境初始化
```bash
# 1. 克隆项目
git clone <repository-url>
cd ecommerce-microservices-learning

# 2. 运行初始化脚本（自动安装Docker等）
sudo ./deploy/scripts/linux/deploy/init.sh
```

### 步骤2：导入镜像（生产环境）
```bash
# 如果有离线镜像文件
sudo ./deploy/scripts/linux/images/import-images.sh
```

### 步骤3：启动服务
```bash
sudo ./deploy/scripts/linux/deploy/start-all.sh
```

### 步骤4：验证部署
- **API网关**: http://localhost:28080
- **Nacos控制台**: http://localhost:8848/nacos
- **健康检查**: http://localhost:28080/actuator/health

## 🏭 生产环境配置

### 环境变量配置
创建 `.env` 文件：
```bash
# 数据库配置
MYSQL_ROOT_PASSWORD=your_secure_password
MYSQL_DATABASE=ecommerce_prod

# 应用配置
SPRING_PROFILES_ACTIVE=prod

# 镜像仓库配置
IMAGE_TAG=v1.0.0
```

### 生产环境部署流程
```bash
# 1. 环境初始化
sudo ./deploy/scripts/linux/deploy/init.sh -i

# 2. 导入生产镜像
sudo ./deploy/scripts/linux/images/import-images.sh -f images/ecommerce-prod-images.tar

# 3. 启动服务
sudo ./deploy/scripts/linux/deploy/start-all.sh
```

## 🔧 关键配置说明

### 目录结构
初始化脚本会创建以下目录结构：
```
data/              # 数据持久化
├─ mysql/         # MySQL数据
├─ redis/         # Redis数据
├─ nacos/         # Nacos数据
└─ rocketmq/      # RocketMQ数据

config/           # 配置文件
├─ mysql/         # MySQL配置
├─ redis/         # Redis配置
├─ nacos/         # Nacos配置
└─ [各服务配置]/   # 应用服务配置

logs/             # 日志文件
├─ infra/         # 基础设施日志
└─ [各服务日志]/  # 应用服务日志
```

### Docker网络
- **网络名称**: ecommerce-network
- **子网范围**: 172.20.0.0/16
- **网关**: 172.20.0.1

## 🔄 常用操作

### 服务管理
```bash
# Windows
start-all.ps1                   # 启动所有服务
start-all.ps1 mysql             # 启动MySQL服务
start-all.ps1 infra             # 启动基础设施
start-all.ps1 apps -force       # 强制重启应用服务
start-all.ps1 -statusOnly       # 查看服务状态
stop-all.ps1                    # 停止所有服务
stop-all.ps1 apps -force        # 停止应用服务
stop-all.ps1 mysql              # 停止MySQL服务

# Linux
sudo ./deploy/scripts/linux/deploy/stop-all.sh    # 停止服务
sudo ./deploy/scripts/linux/deploy/start-all.sh   # 启动服务
```

**底层原理**：
- **启动命令**：`docker compose -f docker-compose.yml up -d`
- **停止命令**：`docker compose -f docker-compose.yml down`
- **状态检查**：`docker ps --format "table {{.Names}}\t{{.Status}}"`
- **健康检查**：`docker inspect --format='{{.State.Health.Status}}' <container>`

### 镜像管理
```bash
# 构建镜像
build-images.bat -s user-service

# 导出镜像
export-images.bat -s user-service

# 导入镜像
import-images.bat -f custom.tar
```

**底层原理**：
- **构建命令**：`docker build -t ecommerce/user-service:latest ./user-service`
- **导出命令**：`docker save -o user-service.tar ecommerce/user-service:latest`
- **导入命令**：`docker load -i user-service.tar`
- **查看镜像**：`docker images | grep ecommerce`

### 状态检查
```bash
# 查看运行中的容器
docker ps

# 查看服务日志
docker logs -f [container-name]

# 检查服务健康状态
curl http://localhost:28080/actuator/health
```

**底层原理**：
- **容器列表**：`docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"`
- **实时日志**：`docker logs -f --tail=100 [container-name]`
- **健康检查**：`curl -s http://localhost:28080/actuator/health | jq`
- **资源监控**：`docker stats --no-stream [container-name]`

## 🎯 部署验证清单

### 基础验证
- [ ] Docker服务正常运行
- [ ] 所有容器已启动
- [ ] 端口无冲突

### 服务验证
- [ ] API网关健康检查通过
- [ ] 各微服务健康检查通过
- [ ] Nacos注册中心正常
- [ ] MySQL和Redis连接正常

### 功能验证
- [ ] 用户注册登录功能
- [ ] 商品浏览功能
- [ ] 购物车功能
- [ ] 订单创建功能

## 🚨 重要提醒

⚠️ **配置修改后必须执行完整重启**：
```bash
docker-compose down
docker-compose up -d
```
❌ **不要使用** `docker-compose restart`（配置不会生效）

详细故障处理请参考：[故障排查文档](TROUBLESHOOTING.md)

---

**文档版本**: v3.0 (精简版)
**最后更新**: 2025-10-20