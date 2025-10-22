# 项目上下文 - AI助手协作指南

## 项目基本信息

| 项目信息 | 详情 |
|---------|------|
| **项目名称** | ecommerce-microservices-learning |
| **项目类型** | 电商交易领域微服务学习项目 |
| **核心目标** | 掌握企业级微服务架构和DDD实践 |

## 当前实施阶段

### 已完成 - 第零阶段
- Maven多模块项目结构搭建
- Docker开发环境完整配置
- 所有微服务基础框架创建
- 基础设施服务验证通过
- 前端Vue 3.4项目初始化
- Windows PowerShell脚本系统v2.1
- AI文档体系优化完成（精简至4个核心文档）

### 下一步计划 - 第一阶段
**高优先级任务**：
- 为各服务添加Nacos客户端依赖和配置
- 实现服务注册发现机制
- 配置网关动态路由规则
- 实现服务间Feign客户端调用

## 技术架构概览

### 微服务架构

| 服务 | 端口 | 核心职责 |
|------|------|----------|
| api-gateway | 28080 | 统一入口、认证授权、流量治理 |
| user-service | 28081 | 用户管理、身份认证、权限控制 |
| product-service | 28082 | 商品管理、库存控制、搜索服务 |
| trade-service | 28083 | 交易核心、订单处理、支付集成 |

### 技术栈版本
- **Spring Boot**: 3.2.x | **Spring Cloud**: 2023.0.x | **Spring Cloud Alibaba**: 2023.0.x
- **JDK**: 21 | **Vue**: 3.4 | **Nacos**: 2.x
- **MySQL**: 8.x | **Redis**: 7.x | **RocketMQ**: 5.x

## 工程结构

### 项目结构
```
ecommerce-microservices-learning/
├── frontend/                # Vue 3 前端应用
├── backend/                 # Spring Boot 微服务集群
│   ├── common/              # 通用组件模块
│   ├── api-gateway/         # API 网关服务
│   ├── user-service/        # 用户管理微服务
│   ├── product-service/     # 商品管理微服务
│   └── trade-service/       # 交易核心微服务
├── deploy/                  # 部署配置和脚本
├── docs/                    # 项目文档
│   └── ai/                  # AI助手专用文档
├── infrastructure/          # 基础设施配置
├── README.md                # 项目说明文档
└── CLAUDE.md                # AI助手项目记忆文件
```

### DDD四层架构标准
- **interfaces** - 接口层（REST API、DTO）
- **application** - 应用层（业务流程编排）
- **domain** - 领域层（核心业务逻辑）
- **infrastructure** - 基础设施层（技术实现）

## AI文档导航

### 标准工作流程
了解项目状态 → 检查经验教训 → 选择工作方法 → 遵循技术约束 → 应用开发模式

### AI专用文档

| 文档 | 主要功能 | 优先级 |
|------|----------|--------|
| **[AI工作流程](docs/ai/workflow.md)** | 任务处理、开发模式、质量标准 | 高 |
| **[设计约束](docs/ai/constraints.md)** | 架构约束、编码规范、技术边界 | 高 |
| **[故障排查](docs/ai/troubleshooting.md)** | 项目配置、经验教训、快速排查 | 高 |
| **[AI文档导航](docs/ai/README.md)** | AI文档体系使用指导 | 中 |

### 文档使用原则
- **CLAUDE.md**：项目级上下文，首先阅读
- **workflow.md**：选择工作方法和开发模式
- **constraints.md**：遵循技术约束和规范
- **troubleshooting.md**：遇到环境或工程问题时查阅

## 重要经验教训

### 关键运维经验
- **Docker健康检查失败**：必须使用`docker inspect`检查具体原因，不要猜测
- **配置修改后**：必须重新创建容器才能生效，restart无效
- **Windows端口问题**：检查系统动态端口范围，避免与49152-65535冲突
- **脚本编写**：Windows环境优先PowerShell，避免bat脚本
- **中文字符处理**：脚本中使用UTF-8 BOM头 + 开头插入`chcp 65001 | Out-Null`

### 项目特有约束
- **Common模块限制**：只能包含DTO、常量、异常、工具类，不能有Web依赖
- **Maven构建顺序**：必须先构建common模块，再构建具体服务
- **服务密码信息**：存储在`deploy/docker-compose/.env`文件中

## PowerShell脚本工具集
开发环境便利脚本的目录位置 `deploy\scripts\windows` 

### 核心脚本
- **build-images.ps1** - 构建脚本
- **export-images.ps1** - 镜像导出脚本
- **push-images.ps1** - 镜像推送脚本

### 快速启停
- **init.ps1** - 环境检测、初始化网络和目录脚本
- **start-all.ps1** - 一键启动所有容器
- **stop-all.ps1** - 一键停止所有容器


## 业务需求与计划

### 核心业务场景
- **[业务需求文档](docs/需求.md)** - 6个核心业务场景详细说明
  - 用户注册登录与权限管理
  - 商品信息管理与库存控制
  - 购物车与订单处理流程
  - 支付集成与交易状态管理
  - 搜索功能与商品推荐
  - 用户评价与反馈系统

### 实施路线图
- **[开发计划文档](docs/开发计划.md)** - 22步完整实施计划
  - 第零阶段：基础设施搭建（已完成）
  - 第一阶段：微服务技术骨架
  - 第二阶段：认证技术链路
  - 第三阶段：数据层技术验证
  - 第四阶段：服务间通信验证
  - 第五阶段：业务场景实现

### 项目文档
- **[项目说明](README.md)** - 项目整体介绍和快速开始指南

## 文档体系分工

### AI专用文档 (docs/ai/)
- 工作流程与开发模式
- 设计约束与编码规范
- 项目配置与经验教训
- AI文档使用导航

### 业务文档 (docs/)
- 业务需求与场景说明
- 开发计划与实施路线
- 项目整体介绍

### 部署配置 (deploy/)
- Docker容器编排配置
- PowerShell/Linux脚本工具
- 基础设施配置文件

---

**文档版本**: v5.0 (AI文档体系优化版)
**最后更新**: 2025-10-22
**维护者**: Claude AI Assistant
**核心更新**: AI文档体系优化，精简至4个核心文档，提升使用效率