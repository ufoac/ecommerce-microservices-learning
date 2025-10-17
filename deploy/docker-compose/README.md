# 电商微服务 Docker Compose 部署

这是一个基于 Docker Compose 的电商微服务系统部署方案，采用分层架构设计，支持基础设施和应用的独立管理。

## 📁 目录结构

```
deploy/docker-compose/
├── README.md                   # 本文件
├── bin/                       # Linux/macOS 管理脚本
│   ├── docker-up.sh          # 启动脚本
│   ├── docker-down.sh        # 停止脚本
│   ├── docker-logs.sh        # 日志查看脚本
│   ├── docker-health.sh      # 健康检查脚本
│   └── docker-clean.sh       # 清理脚本
└── compose/                   # 🔥 完整运行环境（配置+数据+环境变量）
    ├── .env                  # 环境变量配置（需自行创建）
    ├── .env.example          # 环境变量模板
    ├── docker-compose.yml            # 主配置文件
    ├── docker-compose.infra.yml           # 基础设施服务（简化命名）
    ├── docker-compose.apps.yml            # 应用服务（简化命名）
    ├── docker-compose.dev.yml            # 开发环境配置
    ├── config/               # 配置文件目录
    │   ├── mysql/           # MySQL 配置和初始化脚本
    │   │   └── init/
    │   │       ├── 01-nacos.sql
    │   │       └── 02-ecommerce.sql
    │   ├── redis/           # Redis 配置文件
    │   │   └── redis.conf
    │   ├── seata/           # Seata 配置文件
    │   ├── nacos/           # Nacos 配置文件
    │   └── rocketmq/        # RocketMQ 配置文件
    ├── data/                 # 数据持久化目录
    │   ├── mysql/           # MySQL 数据文件（含占位文件）
    │   │   └── .keep
    │   └── redis/           # Redis 数据文件（含占位文件）
    └── logs/                 # 日志目录（为每个服务预创建）
        ├── mysql/           # MySQL 日志
        │   └── .keep
        ├── redis/           # Redis 日志
        │   └── .keep
        ├── nacos/           # Nacos 日志
        │   └── .keep
        ├── rocketmq-nameserver/ # RocketMQ NameServer 日志
        │   └── .keep
        ├── rocketmq-broker/    # RocketMQ Broker 日志
        │   └── .keep
        ├── rocketmq-console/  # RocketMQ 控制台日志
        │   └── .keep
        ├── seata-server/     # Seata 服务日志
        │   └── .keep
        ├── api-gateway/      # API 网关日志
        │   └── .keep
        ├── user-service/     # 用户服务日志
        │   └── .keep
        ├── product-service/  # 商品服务日志
        │   └── .keep
        └── trade-service/     # 交易服务日志
            └── .keep
└── docs/                     # 文档
    ├── deployment.md         # 部署文档
    ├── configuration.md      # 配置说明
    └── troubleshooting.md    # 故障排除
```

## 🚀 快速开始

### 1. 环境准备

确保系统已安装：
- Docker 20.10+
- Docker Compose 2.0+

### 2. 初始化配置

**关键说明**：现在 `.env` 文件和 docker-compose 配置文件都在 `compose/` 目录下！

```bash
# 复制环境变量模板
cp compose/.env.example compose/.env

# 检查环境配置
./bin/docker-up.sh --check
```

### 3. 启动服务

```bash
# 启动所有服务
./bin/docker-up.sh

# 仅启动基础设施
./bin/docker-up.sh --infra

# 仅启动应用服务（基础设施必须已启动）
./bin/docker-up.sh --apps

# 开发环境启动（带调试功能）
./bin/docker-up.sh --dev
```

### 4. 验证部署

```bash
# 查看服务状态
./bin/docker-down.sh --help  # 查看所有可用命令

# 执行健康检查
./bin/docker-health.sh

# 查看服务日志
./bin/docker-logs.sh
```

## 🏗️ 基础设施服务

| 服务 | 端口 | 说明 | 健康检查 |
|------|------|------|----------|
| MySQL | 3306 | 主数据库 | ✅ |
| Redis | 6379 | 缓存服务 | ✅ |
| Nacos | 8848 | 服务注册发现 | ✅ |
| RocketMQ NameServer | 9876 | 消息队列 | ✅ |
| RocketMQ Broker | 10909/10911 | 消息队列 | ✅ |
| RocketMQ Console | 8081 | 消息队列控制台 | ✅ |
| Seata | 7091 | 分布式事务 | ✅ |

## 🔧 微服务应用

| 服务 | 端口 | 说明 | 依赖 |
|------|------|------|------|
| API Gateway | 8080 | API网关 | Nacos, Redis |
| User Service | 8081 | 用户服务 | Nacos, MySQL, Redis |
| Product Service | 8082 | 商品服务 | Nacos, MySQL, Redis |
| Trade Service | 8083 | 交易服务 | Nacos, MySQL, Redis, RocketMQ |

## 🔧 环境变量配置

### 环境变量加载机制

**重要改进**：所有运行环境相关文件都在 `compose/` 目录下，包括环境变量、配置文件和数据！

#### 加载位置和方式

1. **文件位置**: `compose/.env` 和 `compose/.env.example`
2. **Docker Compose 自动加载**: Docker Compose 在 `compose/` 目录中执行时自动加载 `.env` 文件
3. **统一管理**: 配置文件、数据卷、环境变量都在同一目录下
4. **无需显式加载**: 脚本不再需要手动加载环境变量

#### 环境变量引用语法

在 Docker Compose 文件中引用环境变量：

```yaml
# 基础引用
environment:
  MYSQL_ROOT_PASSWORD: ${MYSQL_ROOT_PASSWORD}

# 带默认值的引用
environment:
  MYSQL_ROOT_PASSWORD: ${MYSQL_ROOT_PASSWORD:-default_password}
  NACOS_SERVER_PORT: ${NACOS_SERVER_PORT:-8848}

# 在网络配置中引用
ports:
  - "${MYSQL_PORT:-3306}:3306"
  - "${REDIS_PORT:-6379}:6379"
```

#### 加载优先级

```
1. 命令行环境变量 (最高优先级)
2. compose/.env 文件中的变量
3. 系统环境变量 (最低优先级)
```

### 核心配置

#### 时区配置
所有容器统一使用上海时区：
```bash
TIMEZONE=Asia/Shanghai
```

#### 数据库配置
```bash
MYSQL_VERSION=8.0
MYSQL_ROOT_PASSWORD=root_123456
MYSQL_DATABASE=ecommerce
MYSQL_CHARSET=utf8mb4
MYSQL_COLLATION=utf8mb4_unicode_ci
```

#### 服务端口配置
```bash
GATEWAY_PORT=8080
USER_SERVICE_PORT=8081
PRODUCT_SERVICE_PORT=8082
TRADE_SERVICE_PORT=8083
NACOS_SERVER_PORT=8848
REDIS_PORT=6379
ROCKETMQ_NAMESRV_PORT=9876
```

## 🛠️ 常用命令

### 服务管理

```bash
# 启动服务
./bin/docker-up.sh              # 启动所有服务
./bin/docker-up.sh --infra      # 仅启动基础设施
./bin/docker-up.sh --apps       # 仅启动应用服务

# 停止服务
./bin/docker-down.sh            # 停止所有服务
./bin/docker-down.sh --infra    # 仅停止基础设施
./bin/docker-down.sh --apps     # 仅停止应用服务
```

### 日志查看

```bash
# 查看所有服务日志
./bin/docker-logs.sh -a

# 查看指定服务日志
./bin/docker-logs.sh mysql

# 实时跟踪日志
./bin/docker-logs.sh -f mysql

# 查看错误日志
./bin/docker-logs.sh -r
```

### 健康检查

```bash
# 基础健康检查
./bin/docker-health.sh

# 详细健康检查
./bin/docker-health.sh -d

# JSON 格式检查
./bin/docker-health.sh -j

# 持续监控
./bin/docker-health.sh -w
```

### 资源清理

```bash
# 清理容器和网络
./bin/docker-clean.sh

# 清理所有资源
./bin/docker-clean.sh -a

# 清理数据卷（会删除数据）
./bin/docker-clean.sh -v

# 预览将要清理的内容
./bin/docker-clean.sh --dry-run
```

## 🌐 服务访问地址

| 服务 | 地址 | 用户名/密码 | 说明 |
|------|------|-------------|------|
| Nacos控制台 | http://localhost:8848/nacos | nacos/nacos | 服务注册管理 |
| MySQL数据库 | localhost:3306 | root/root_123456 | 数据库连接 |
| Redis缓存 | localhost:6379 | - | 缓存连接 |
| RocketMQ控制台 | http://localhost:8081 | - | 消息队列管理 |
| Seata控制台 | http://localhost:7091 | - | 分布式事务管理 |
| API网关 | http://localhost:8080 | - | 微服务入口 |
| 用户服务 | http://localhost:8081 | - | 用户管理API |
| 商品服务 | http://localhost:8082 | - | 商品管理API |
| 交易服务 | http://localhost:8083 | - | 交易管理API |

## 🔧 故障排查

### 端口冲突
修改 `compose/.env` 文件中的端口配置：
```bash
# 例如修改MySQL端口
MYSQL_PORT=3307
```

### 服务启动失败
1. 检查服务日志：`./bin/docker-logs.sh [service-name]`
2. 检查端口占用：`netstat -an | grep [port]`
3. 检查资源使用：`docker stats`

### 环境变量问题
1. 检查 `compose/.env` 文件是否存在
2. 检查文件权限：确保可读
3. 验证环境变量格式：`KEY=VALUE`

### 配置文件问题
1. 检查 `compose/config/` 目录下的配置文件
2. 确认挂载路径正确：Docker Compose 在 `compose/` 目录中执行
3. 检查配置文件语法是否正确

## 📈 监控和日志

### 日志位置
- **所有服务**: `compose/logs/[service-name]/`
- **MySQL**: Docker容器内部 + Docker卷 `ecommerce-mysql-data`
- **Redis**: Docker容器内部 + Docker卷 `ecommerce-redis-data`
- **RocketMQ**: Docker卷 `ecommerce-rocketmq-*-logs`

### 监控指标
所有服务都暴露了健康检查端点：
```bash
curl http://localhost:8080/actuator/health
```

## 🚀 生产环境部署

生产环境建议：
1. 使用外部数据库和Redis
2. 配置资源限制
3. 启用日志收集
4. 配置监控告警
5. 使用HTTPS

## 🎯 架构优势

1. **运行环境完整**: 所有运行环境文件（配置、数据、环境变量）都在 `compose/` 目录
2. **配置集中化**: 配置文件和数据目录集中管理，避免分散
3. **挂载路径简化**: Docker Compose 在 compose 目录执行，挂载路径更简洁
4. **自动化加载**: Docker Compose 自动加载 `.env` 文件，无需手动处理
5. **跨平台一致**: Linux/macOS 目录结构和操作完全一致
6. **分层架构**: 基础设施和应用服务分离
7. **开发友好**: 支持调试和热重载
8. **运维简化**: 备份和迁移只需关注 compose 目录

这种架构既保持了Docker Compose的简洁性，又解决了企业级项目的复杂配置需求，同时避免了环境变量管理的复杂性。

---

**最后更新**: 2024-12-17
**版本**: v1.0.0
**维护者**: 电商微服务团队