# 电商微服务学习项目

基于 JDK 21 + Spring Boot 3.2 的企业级电商微服务学习项目，采用 DDD 架构和现代化技术栈，包含完整的前后端分离实现，严格遵循业界最佳实践。

[![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.2.x-brightgreen.svg)](https://spring.io/projects/spring-boot)
[![Spring Cloud](https://img.shields.io/badge/Spring%20Cloud-2023.0.x-green.svg)](https://spring.io/projects/spring-cloud)
[![Vue.js](https://img.shields.io/badge/Vue.js-3.4-4FC08D.svg)](https://vuejs.org/)
[![Docker](https://img.shields.io/badge/Docker-28.x-2496ED.svg)](https://www.docker.com/)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

## 项目概览

### 项目特色

- 企业级架构：DDD 领域驱动设计，微服务分层架构
- 现代技术栈：Spring Boot 3.2 + JDK 21 + Vue 3.4
- 容器化部署：Docker + Docker Compose 完整配置
- 完整工具链：PowerShell/Linux 脚本，一键部署管理
- 渐进式学习：从基础设施到完整业务的 22 步实施计划
- 详细文档：完整的需求文档、API 文档、部署文档

### 项目进度

| 阶段 | 状态 | 进度 | 说明 |
|------|------|------|------|
| 第零阶段 | 已完成 | 100% | 基础设施搭建、Docker 环境、框架初始化 |
| 第一阶段 | 准备中 | 0% | 微服务技术骨架（服务注册、网关路由） |
| 第二阶段 | 待开始 | 0% | 认证技术链路（JWT 认证、权限管理） |
| 第三阶段 | 待开始 | 0% | 数据层技术验证（数据库、缓存） |
| 第四阶段 | 待开始 | 0% | 服务间通信验证（消息队列） |
| 第五阶段 | 待开始 | 0% | 业务场景实现（完整电商功能） |

## 快速开始

### 环境准备

| 工具 | 版本要求 | 说明 |
|------|---------|------|
| Git | 2.51+ | 版本控制 |
| JDK | 21+ | 推荐 Temurin OpenJDK |
| Maven | 3.9+ | 项目构建 |
| Node.js | 22+ 或 20 LTS | 前端开发 |
| Docker | 28.x | 容器化运行 |
| Docker Compose | 2.x | 服务编排 |
| Windows | - | 建议启用 WSL2 以获得更好的 Docker 体验 |

### 一键启动开发环境

#### Windows 环境（推荐）

```powershell
# 进入项目目录
cd deploy/scripts/windows/deploy

# 环境初始化（首次运行）
.\init.ps1

# 启动所有服务
.\start-all.ps1
```

#### Linux 环境

```bash
# 进入项目目录
cd deploy/scripts/linux/deploy

# 环境初始化（首次运行）
sudo ./init.sh

# 启动所有服务
sudo ./start-all.sh
```

### 服务验证

启动完成后，访问以下地址验证服务状态：

| 服务 | 地址 | 说明 |
|------|------|------|
| 前端应用 | http://localhost | Vue 3.4 应用 |
| API 网关 | http://localhost:28080 | Spring Cloud Gateway |
| Nacos 控制台 | http://localhost:18848/nacos | 用户名/密码: nacos/nacos |
| 监控面板 | http://localhost:3000 | Grafana |
| RocketMQ 控制台 | http://localhost:18080 | 消息队列管理 |

## 架构概览

### 微服务架构

采用 DDD 领域驱动设计的四层架构，服务按业务边界清晰拆分：

| 服务 | 端口 | 核心职责 |
|------|------|----------|
| api-gateway | 28080 | 统一入口、认证授权、流量治理 |
| user-service | 28081 | 用户管理、身份认证、权限控制 |
| product-service | 28082 | 商品管理、库存控制、搜索服务 |
| trade-service | 28083 | 交易核心、订单处理、支付集成 |

### 服务功能概览

- API Gateway: 统一 API 入口，处理认证、限流、路由转发
- User Service: 用户注册登录，JWT 认证，权限管理
- Product Service: 商品信息管理，库存控制，搜索筛选
- Trade Service: 购物车，订单流程，交易状态管理

### 架构特点

- DDD 领域驱动设计 - 清晰的业务边界和领域模型
- 前后端分离 - Vue 3 + Spring Boot 微服务架构
- 统一网关治理 - Spring Cloud Gateway 集中管理
- 消息驱动异步解耦 - RocketMQ 确保最终一致性
- 云原生架构 - Docker + Kubernetes 容器化部署
- 全链路可观测性 - 监控、日志、追踪一体化

## 技术栈

### 核心技术
- **后端**: JDK 21 + Spring Boot 3.2.x + Spring Cloud 2023.0.x + MyBatis-Plus
- **前端**: Vue 3.4 + Element Plus + Pinia + Vite
- **数据库**: MySQL 8.x + Redis 7.x
- **微服务**: Spring Cloud Alibaba (Nacos服务注册发现) + RocketMQ 5.x
- **容器化**: Docker + Docker Compose
- **监控**: Spring Boot Actuator + Prometheus + Grafana

## 项目结构

```
ecommerce-microservices-learning/
├── frontend/                # Vue 3 前端单页应用
│   ├── src/                 # 前端源码目录
│   │   ├── components/      # 通用组件
│   │   ├── views/           # 页面组件
│   │   ├── router/          # 路由配置
│   │   ├── stores/          # 状态管理 (Pinia)
│   │   ├── api/             # API 接口调用
│   │   └── utils/           # 工具函数
│   ├── public/              # 静态资源
│   └── package.json         # 依赖配置
├── backend/                 # Spring Boot 微服务集群
│   ├── common/              # 通用组件和工具类
│   ├── api-gateway/         # API 网关服务
│   ├── user-service/        # 用户管理微服务
│   ├── product-service/     # 商品管理微服务
│   └── trade-service/       # 交易核心微服务
├── deploy/                  # 多环境部署配置
│   ├── docker-compose/      # 开发环境容器编排
│   ├── scripts/             # 部署和管理脚本
│   └── docs/                # 部署相关文档
├── infrastructure/          # 基础设施配置
│   ├── database/           # 数据库脚本
│   ├── nginx/              # 负载均衡配置
│   └── monitoring/         # 监控配置
├── docs/                   # 项目文档
│   ├── 需求.md             # 业务需求文档
│   ├── 开发计划.md         # 实施路线图
│   ├── api/                # API 接口文档
│   ├── database/           # 数据库设计文档
│   └── deployment/         # 部署运维文档
├── README.md               # 项目整体说明文档
└── CLAUDE.md               # AI 助手项目上下文文件
```

## 开发指南

### 本地开发模式

```bash
# 1. 启动基础设施服务
docker compose -f deploy/docker-compose/compose/docker-compose.infra.yml up -d

# 2. 启动后端微服务（选择需要的服务）
cd backend/user-service && mvn spring-boot:run
cd backend/product-service && mvn spring-boot:run

# 3. 启动前端开发服务器
cd frontend && npm run dev
```

### 开发规范

项目采用企业级开发标准，包含完整的代码规范、API 设计规范和数据库设计规范。

详细开发规范、代码模板和最佳实践请查看：
- [CLAUDE.md](CLAUDE.md) - AI 助手协作指南和技术规范
- [docs/开发计划.md](docs/开发计划.md) - 完整实施计划
- [docs/需求.md](docs/需求.md) - 业务需求文档
- [deploy/docs/SCRIPTS.md](deploy/docs/SCRIPTS.md) - 脚本使用指南

### 故障排查

遇到问题？查看详细的故障排查指南：

- [deploy/docs/TROUBLESHOOTING.md](deploy/docs/TROUBLESHOOTING.md) - 常见问题和解决方案
- [deploy/docs/DEPLOYMENT.md](deploy/docs/DEPLOYMENT.md) - 部署指南

## 文档导航

### 核心文档

| 文档 | 描述 | 链接 |
|------|------|------|
| 快速开始 | 项目介绍和快速启动指南 | README.md |
| AI 协作指南 | Claude AI 助手使用规范 | CLAUDE.md |
| 业务需求 | 6 个核心业务场景详细说明 | docs/需求.md |
| 开发计划 | 22 步完整实施路线图 | docs/开发计划.md |

### 部署文档

| 文档 | 描述 | 链接 |
|------|------|------|
| 脚本使用 | Windows/Linux 脚本详细说明 | deploy/docs/SCRIPTS.md |
| 部署指南 | 完整部署流程和配置 | deploy/docs/DEPLOYMENT.md |
| 故障排查 | 常见问题和解决方案 | deploy/docs/TROUBLESHOOTING.md |

### 技术文档

| 文档 | 描述 | 链接 |
|------|------|------|
| API 文档 | REST API 接口规范 | docs/api/ |
| 数据库设计 | 数据表结构和关系 | docs/database/ |
| 架构设计 | 系统架构和技术选型 | docs/architecture/ |


## 贡献指南

### 开发流程

1. Fork 项目到个人仓库
2. 创建功能分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'feat: Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 创建 Pull Request

## 许可证

本项目基于 MIT 许可证开源 - 查看 LICENSE 文件了解详情。

## 致谢

感谢以下开源项目的支持：

- [Spring Boot](https://spring.io/projects/spring-boot) - Java 企业级开发框架
- [Spring Cloud](https://spring.io/projects/spring-cloud) - 微服务开发框架
- [Vue.js](https://vuejs.org/) - 渐进式 JavaScript 框架
- [Element Plus](https://element-plus.org/) - Vue 3 UI 组件库
- [Docker](https://www.docker.com/) - 容器化平台
- [Nacos](https://nacos.io/) - 服务发现和配置中心
- [RocketMQ](https://rocketmq.apache.org/) - 分布式消息中间件

---

<div align="center">

联系方式

如有问题或建议，欢迎通过以下方式联系：

- Email: ikent84@163.com
- Issues: [GitHub Issues](https://github.com/your-username/ecommerce-microservices-learning/issues)

如果这个项目对你有帮助，请给它一个 Star！

</div>