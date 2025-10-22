# 项目目录结构详细说明

## 完整目录结构

### 根目录结构
```
ecommerce-microservices-learning/
├── backend/                 # Spring Boot 微服务源码
├── frontend/               # Vue 3 前端应用源码
├── deploy/                 # 部署配置和脚本
├── docs/                   # 项目文档
├── infrastructure/         # 基础设施配置文件
├── README.md              # 项目说明文档
└── CLAUDE.md              # AI助手项目记忆文件
```

### backend/ 目录结构
```
backend/
├── common/                # 通用组件模块
│   ├── src/main/java/     # DTO、常量、异常、工具类
│   └── pom.xml           # Maven配置
├── api-gateway/          # API网关服务
│   ├── src/main/java/    # Java源码
│   ├── src/main/resources/
│   │   └── application.yml
│   ├── Dockerfile        # Docker构建文件
│   └── pom.xml          # Maven配置
├── user-service/         # 用户管理服务
├── product-service/      # 商品管理服务
├── trade-service/        # 交易核心服务
└── pom.xml              # 父级Maven配置
```

### deploy/ 目录结构
```
deploy/
├── docker-compose/               # Docker编排配置
│   ├── .env                     # 环境变量配置
│   ├── docker-compose.infra.yml # 基础设施服务编排
│   └── docker-compose.apps.yml  # 应用服务编排
├── scripts/                     # 脚本工具（跨平台）
│   └── windows/                 # Windows脚本工具
│       ├── images/              # 镜像管理脚本
│       │   ├── build-images.ps1
│       │   ├── export-images.ps1
│       │   └── push-images.ps1
│       └── deploy/              # 部署管理脚本
│           ├── init.ps1
│           ├── start-all.ps1
│           └── stop-all.ps1
└── .env.example                 # 环境变量模板
```

### docs/ 目录结构
```
docs/
├── ai/                          # AI助手专用文档
│   ├── README.md                # AI文档使用导航
│   ├── workflow.md              # 工作流程指南
│   ├── constraints.md           # 设计约束规范
│   ├── troubleshooting.md       # 故障排查指南
│   ├── scripts-guide.md         # 脚本使用指南
│   ├── directory-structure.md   # 目录结构说明
│   └── config-mapping.md        # 配置映射说明
├── 需求.md                      # 业务需求文档
├── 开发计划.md                  # 开发实施计划
└── 其他业务文档...
```

### infrastructure/ 目录结构
```
infrastructure/
├── database/                    # 数据库相关配置
│   ├── init/                   # 数据库初始化脚本
│   └── migration/              # 数据库迁移脚本
├── nacos/                      # Nacos配置文件
├── redis/                      # Redis配置文件
└── rocketmq/                   # RocketMQ配置文件
```

## 关键文件说明

### 环境配置文件
- **deploy/docker-compose/.env**: 核心环境变量配置
  - 数据库连接信息
  - 中间件认证信息
  - 服务端口配置
  - JVM参数配置

### Docker编排文件
- **docker-compose.infra.yml**: 基础设施服务
  - MySQL、Redis、Nacos、RocketMQ
  - 网络和存储配置
- **docker-compose.apps.yml**: 应用服务
  - 业务微服务配置
  - 健康检查和依赖关系

### 脚本文件
- **build-images.ps1**: 镜像构建脚本
  - Maven编译打包
  - Docker镜像构建
- **start-all.ps1**: 服务启动脚本
  - 环境检查
  - 容器启动
  - 健康状态监控
- **stop-all.ps1**: 服务停止脚本
  - 容器停止和清理

## 目录使用规范

### 开发时的工作目录
- **本地开发**: backend/{service}/
- **容器操作**: deploy/docker-compose/
- **脚本执行**: 项目根目录

### 配置修改原则
- **服务配置**: backend/{service}/src/main/resources/
- **容器配置**: deploy/docker-compose/.env
- **编排配置**: deploy/docker-compose/*.yml

### 文件查找优先级
1. **服务特定配置**: service目录
2. **环境配置**: .env文件
3. **默认配置**: application.yml

---

**文档用途**: 提供完整的项目目录结构和文件定位指导
**适用场景**: 需要快速定位文件或理解项目组织结构
**更新原则**: 项目结构调整或新增重要文件时更新