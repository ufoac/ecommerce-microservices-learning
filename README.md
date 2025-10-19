# 电商微服务学习项目

## 项目概述

本项目是一个基于 JDK 21 和 Spring Boot 3.2.x 的电商交易领域微服务学习项目，采用国内中大型互联网公司主流技术栈与 DDD（领域驱动设计）架构，包含前端应用和四个核心后端微服务，严格遵循业界最佳实践。


## 技术栈

### 后端核心框架
- **JDK 21**
- **Spring Boot 3.2.x**
- **Spring Cloud 2023.x**
- **Spring Cloud Alibaba 2023.x**
- **MyBatis-Plus 3.x**

### 微服务基础设施
- **Nacos 2.x**（服务注册与发现、配置中心）
- **Spring Cloud Gateway**（API 网关）
- **RocketMQ 2.x**（消息队列）
- **OpenFeign**（服务间通信）
- **Seata 1.x**（分布式事务）

### 数据持久化
- **MySQL 8.x**
- **Redis 7.x**
- **Redisson 3.x**（分布式锁）

### 可观测性
- **Micrometer**（应用指标采集）
- **Prometheus + Grafana**（监控可视化）
- **Spring Boot Actuator**（健康检查与指标暴露）

### 前端技术
- **Vue 3.4**
- **Element Plus**（UI 组件库）
- **Nginx 1.28.0**（静态资源服务与反向代理）

## 项目结构

```
ecommerce-microservices-learning/
├── frontend/                          # Vue.js 前端单页应用
│   ├── src/                          # 前端源码目录
│   ├── public/                       # 静态资源文件
│   ├── package.json                  # 项目依赖配置
│   ├── vite.config.js               # Vite 构建配置
│   └── Dockerfile                    # 前端容器镜像构建
├── backend/                           # Spring Boot 微服务集群
│   ├── pom.xml                       # Maven 父项目管理
│   ├── common/                       # 通用工具和基础组件
│   ├── api-gateway/                  # API 网关服务
│   ├── user-service/                 # 用户管理微服务
│   ├── product-service/              # 商品管理微服务
│   └── trade-service/                # 交易核心微服务
├── deploy/                            # 多环境部署配置
│   ├── docker-compose/               # 开发环境容器编排
│   │   └── compose/                  # Docker Compose 配置文件
│   │       ├── docker-compose.yml    # 主配置文件（使用 include）
│   │       ├── docker-compose.infra.yml # 基础设施配置
│   │       └── docker-compose.apps.yml  # 应用服务配置
│   └── kubernetes/                   # 生产环境 K8s 配置（规划中）
├── infrastructure/                    # 基础设施配置
│   ├── database/                     # 数据库初始化脚本
│   ├── nginx/                        # 负载均衡配置
│   ├── seata/                        # 分布式事务配置
│   └── monitoring/                   # 监控与可观测性配置
├── docs/                             # 项目文档
│   ├── 需求.md                       # 业务需求文档
│   ├── 开发计划.md                   # 详细实施计划
│   ├── api/                         # API 接口文档（规划中）
│   ├── database/                    # 数据库设计文档（规划中）
│   └── deployment/                  # 部署运维文档（规划中）
├── README.md                         # 项目整体说明文档
├── CLAUDE.md                         # AI 助手项目记忆文件
└── .gitignore                        # Git 忽略配置
```

## 后端服务详解

### 各服务核心职责

#### api-gateway（API网关服务）
- 统一API入口与路由转发
- JWT令牌验证与权限控制
- 请求限流与熔断降级
- 访问日志与安全防护

#### user-service（用户服务）
- 用户注册、登录、认证
- 用户信息管理与权限控制
- JWT 令牌生成与验证
- 用户会话管理

#### product-service（商品服务）
- 商品分类与基本信息管理
- 商品搜索与筛选功能
- 库存管理与价格策略
- 商品缓存优化

#### trade-service（交易服务）
- 购物车与订单管理
- 交易流程与状态机
- 支付处理与资金账户
- 交易风控规则

## 服务架构

### 网关服务结构

```
backend/api-gateway/
├── src/main/java/com/cao/ecommerce/gateway/
│   ├── GatewayApplication.java        # 启动类
│   ├── config/                        # 网关配置
│   │   ├── GatewayConfig.java         # 路由配置（待实现）
│   │   ├── CorsConfig.java            # 跨域配置（待实现）
│   │   ├── RateLimitConfig.java       # 限流配置（待实现）
│   │   └── FilterConfig.java          # 过滤器配置（待实现）
│   ├── filter/                        # 网关过滤器（待实现）
│   │   ├── AuthFilter.java            # 认证过滤器
│   │   ├── RateLimitFilter.java       # 限流过滤器
│   │   ├── LoggingFilter.java         # 日志过滤器
│   │   └── GlobalExceptionFilter.java # 全局异常处理
│   └── fallback/                      # 降级处理（待实现）
│       ├── UserServiceFallback.java   # 用户服务降级
│       └── ProductServiceFallback.java# 商品服务降级
├── src/main/resources/
│   ├── application.yml                # 主配置文件
│   └── logback-spring.xml             # 日志配置
├── Dockerfile                         # 容器镜像构建文件
└── pom.xml
```

### Common 模块结构

```
backend/common/
├── pom.xml
└── src/main/java/com/cao/ecommerce/common/
    ├── annotation/                    # 注解定义（待实现）
    │   ├── Idempotent.java           # 幂等性注解
    │   └── DistributedLock.java      # 分布式锁注解
    ├── constant/                      # 常量定义（待实现）
    │   ├── CommonConstants.java      # 通用常量
    │   ├── TimeUnitConstants.java   # 时间单位常量
    │   └── TransactionConstants.java # 事务常量
    ├── exception/                     # 异常处理（待实现）
    │   ├── BaseException.java        # 基础异常
    │   ├── BizException.java         # 业务异常
    │   ├── ErrorCode.java            # 错误码定义
    │   └── SystemException.java      # 系统异常
    ├── model/                         # 通用模型（待实现）
    │   ├── PageQuery.java            # 分页查询
    │   ├── PageResult.java           # 分页结果
    │   └── Result.java               # 统一响应格式
    ├── mq/                            # 消息队列相关（待实现）
    │   ├── MessageWrapper.java       # 消息包装器
    │   ├── MqConstant.java           # 消息队列常量
    │   └── RocketMqTemplate.java     # RocketMQ 模板
    └── util/                          # 工具类（待实现）
        ├── Asserts.java              # 断言工具
        ├── DateUtils.java            # 日期工具
        ├── IdGenerator.java          # ID 生成器
        ├── JsonUtils.java            # JSON 工具
        └── MaskUtils.java            # 脱敏工具
```

### 微服务结构（以 trade-service 为例）

```
backend/trade-service/
├── src/main/java/com/cao/ecommerce/trade/
│   ├── TradeApplication.java          # 启动类
│   ├── interfaces/                    # 接口层（待实现）
│   │   ├── rest/                      # REST API 控制器
│   │   └── rpc/                       # Feign/RPC 接口
│   ├── application/                   # 应用层（待实现）
│   │   ├── service/                   # 应用服务（用例编排）
│   │   ├── event/handler/             # 事件处理器
│   │   └── scheduler/                 # 定时任务
│   ├── domain/                        # 领域层（待实现）
│   │   ├── model/                     # 领域模型（实体、值对象）
│   │   ├── service/                   # 领域服务
│   │   ├── event/                     # 领域事件
│   │   ├── repository/                # 仓库接口
│   │   └── factory/                   # 领域工厂
│   ├── infrastructure/                # 基础设施层（待实现）
│   │   ├── persistence/               # 持久化实现（MyBatis）
│   │   ├── mq/                        # 消息队列集成
│   │   │   ├── producer/              # 消息生产者
│   │   │   └── consumer/              # 消息消费者
│   │   ├── seata/                     # 分布式事务配置
│   │   ├── client/                    # 外部服务客户端（如 Feign）
│   │   ├── config/                    # Spring 配置类
│   │   └── util/                      # 服务内工具类
│   └── shared/                        # 服务内共享组件（待实现）
├── src/main/resources/
│   ├── application.yml                # 主配置文件
│   └── logback-spring.xml             # 日志配置
├── Dockerfile                         # 容器镜像构建文件
└── pom.xml
```

## 部署架构

### Docker Compose 开发环境

```
deploy/docker-compose/
├── compose/                            # Docker Compose 配置文件
│   ├── docker-compose.yml             # 主配置文件（使用 include 语法）
│   ├── docker-compose.infra.yml       # 基础设施配置（MySQL、Redis、Nacos等）
│   └── docker-compose.apps.yml        # 应用服务配置（微服务）
├── .env                                # 环境变量配置
└── logs/                               # 各中间件日志目录
```

### Kubernetes 生产环境

```
deploy/kubernetes/
├── base/                       # 基础配置
│   ├── kustomization.yaml     # Kustomize 主配置
│   ├── namespace.yaml         # 命名空间定义
│   ├── configmap.yaml         # 应用配置
│   └── secrets.yaml           # 敏感信息模板
├── services/                   # 业务服务部署
│   ├── api-gateway/           # 网关服务部署
│   │   ├── deployment.yaml
│   │   ├── service.yaml
│   │   └── hpa.yaml
│   ├── user-service/
│   │   ├── deployment.yaml
│   │   ├── service.yaml
│   │   └── hpa.yaml
│   ├── product-service/
│   │   ├── deployment.yaml
│   │   ├── service.yaml
│   │   └── hpa.yaml
│   └── trade-service/
│       ├── deployment.yaml
│       ├── service.yaml
│       └── hpa.yaml
├── middleware/                 # 中间件部署
│   ├── mysql/
│   │   ├── statefulset.yaml
│   │   ├── service.yaml
│   │   └── pvc.yaml
│   ├── redis/
│   │   ├── statefulset.yaml
│   │   ├── service.yaml
│   │   └── pvc.yaml
│   ├── rocketmq/              # RocketMQ 部署
│   │   ├── statefulset.yaml
│   │   ├── service.yaml
│   │   └── pvc.yaml
│   └── seata/                 # Seata 部署
│       ├── deployment.yaml
│       └── service.yaml
└── overlays/                   # 环境覆盖配置
    ├── development/
    │   ├── kustomization.yaml
    │   └── patch-memory.yaml
    ├── staging/
    │   ├── kustomization.yaml
    │   └── patch-replicas.yaml
    └── production/
        ├── kustomization.yaml
        ├── patch-replicas.yaml
        └── patch-resources.yaml
```

## 快速开始

### 开发环境要求
- **Git 2.30.x**
- **JDK 21+**
- **Maven 3.6.3+**
- **Node.js 18+**（前端开发）
- **Docker & Docker Compose**
- **Windows 用户需启用 WSL2** `wsl --install`

安装完通过以下命令检查
```commandline
git --version
java -version
mvn -version
node -v
npm -v
docker --version
docker-compose --version
```

### 开发环境启动

**方式一：一键启动所有服务（推荐）**
```bash
cd deploy/docker-compose
docker compose up -d
```

**方式二：分别启动服务**
```bash
# 启动基础设施
cd deploy/docker-compose
docker compose -f compose/docker-compose.infra.yml up -d

# 启动后端服务（在各自目录下）
cd backend/api-gateway && mvn spring-boot:run
cd backend/user-service && mvn spring-boot:run
cd backend/product-service && mvn spring-boot:run
cd backend/trade-service && mvn spring-boot:run

# 启动前端开发服务器
cd frontend
npm install
npm run dev
```

### 验证服务状态
```bash
# 检查网关健康状态
curl http://localhost:8080/actuator/health

# 检查业务服务健康状态（待实现网关路由配置）
curl http://localhost:8080/api/user/actuator/health
curl http://localhost:8080/api/product/actuator/health
curl http://localhost:8080/api/trade/actuator/health

# 直接访问各服务（当前阶段）
curl http://localhost:8081/actuator/health  # user-service
curl http://localhost:8082/actuator/health  # product-service
curl http://localhost:8083/actuator/health  # trade-service
```

### 生产环境部署
```bash
# 使用 Kubernetes (Kustomize)
kubectl apply -k deploy/kubernetes/overlays/production

# 或使用部署脚本
./deploy/scripts/deploy-prod.sh
```

## 访问地址

- **前端应用**: http://localhost
- **API 网关**: http://localhost:8080
- **用户服务 API**: http://localhost:8080/api/user/**
- **商品服务 API**: http://localhost:8080/api/product/**
- **交易服务 API**: http://localhost:8080/api/trade/**
- **API 文档**: http://localhost:8080/api/user/swagger-ui.html
- **监控面板 (Grafana)**: http://localhost:3000
- **RocketMQ 控制台**: http://localhost:8080
- **Seata 控制台**: http://localhost:7091

## 开发规范

### 命名规范
- **包名**: com.cao.ecommerce，各服务按功能分包（如 com.cao.ecommerce.user）
- **类名**: 遵循驼峰命名法
- **方法名**: 动词开头，驼峰命名法

### 代码提交规范
- **feat**: 新功能
- **fix**: 修复问题
- **docs**: 文档更新
- **style**: 代码格式
- **refactor**: 重构
- **test**: 测试相关
- **chore**: 构建过程或辅助工具变动

### 分支管理策略
- **main**：生产环境分支
- **develop**：集成开发分支
- **feature/**：功能开发分支
- **hotfix/**：紧急热修复分支

### API 设计规范
- 遵循 RESTful 风格
- 使用统一响应格式（通过 common/model/Result.java）
- 合理使用 HTTP 状态码（200 成功，4xx 客户端错误，5xx 服务端错误）
- 提供完整的 Swagger/OpenAPI 文档

### 数据库设计规范
- **命名**：表名/字段名用单数蛇形（如 user_order），唯一索引 uk_字段，普通索引 idx_字段  
- **基础字段**：所有业务表必须含 id（BIGINT 分布式ID）、create_time、update_time、核心业务表增加deleted（逻辑删除）  
- **数据类型**：金额用 DECIMAL(18,2)，时间用 DATETIME，字符集 utf8mb4，枚举优先 TINYINT  
- **索引**：高频查询字段建索引，遵守最左前缀，单表 ≤5 个，低区分度字段不建  
- **约束**：字段 NOT NULL，禁用外键，禁止 SELECT *，密码必须加密  
- **分表时机**：单表超 1000 万行 或 10GB 且查询明显变慢时才分，优先归档

## 技术架构特点

- **前后端分离**: Vue.js SPA + Spring Boot 微服务
- **DDD 领域驱动**: 清晰的业务边界、聚合根、领域事件
- **统一网关**: Spring Cloud Gateway 统一入口，集中治理
- **消息驱动**: RocketMQ 异步解耦，确保最终一致性
- **分布式事务**: Seata AT/TCC 模式保障数据一致性
- **云原生架构**: Docker 容器化 + Kubernetes 编排
- **高可观测性**: Micrometer + Prometheus + Grafana 全链路监控
- **弹性通信**: Nacos 服务发现 + OpenFeign + 熔断降级