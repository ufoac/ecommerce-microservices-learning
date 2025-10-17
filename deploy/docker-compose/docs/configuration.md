# 配置说明文档

## 环境变量配置

### 核心配置

#### 时区和语言设置
```bash
# 时区配置（所有容器统一）
TIMEZONE=Asia/Shanghai

# 语言设置
LANG=zh_CN.UTF-8
LC_ALL=zh_CN.UTF-8
```

#### 项目基础配置
```bash
# Docker Compose 项目名称
COMPOSE_PROJECT_NAME=ecommerce

# 环境标识
ENVIRONMENT=dev
```

### 数据库配置

#### MySQL 配置
```bash
# 版本和基础配置
MYSQL_VERSION=8.0
MYSQL_DATABASE=ecommerce
MYSQL_CHARSET=utf8mb4
MYSQL_COLLATION=utf8mb4_unicode_ci

# 认证配置
MYSQL_ROOT_PASSWORD=root_123456
MYSQL_USER=ecommerce
MYSQL_PASSWORD=ecommerce_123456

# 连接配置
MYSQL_PORT=3306
MYSQL_HOST=mysql

# 性能配置
MYSQL_INNODB_BUFFER_POOL_SIZE=1G
MYSQL_MAX_CONNECTIONS=1000
MYSQL_QUERY_CACHE_SIZE=64M

# 日志配置
MYSQL_LOG_QUERIES=false
MYSQL_SLOW_QUERY_LOG=true
MYSQL_LONG_QUERY_TIME=2
```

#### Redis 配置
```bash
# 版本和基础配置
REDIS_VERSION=7.0-alpine
REDIS_PORT=6379
REDIS_HOST=redis

# 认证配置
REDIS_PASSWORD=redis_123456

# 内存配置
REDIS_MAXMEMORY=512mb
REDIS_MAXMEMORY_POLICY=allkeys-lru

# 持久化配置
REDIS_SAVE_INTERVAL="900 1 300 10 60 10000"
REDIS_APPENDONLY=yes
REDIS_APPENDFSYNC=everysec

# 日志配置
REDIS_LOGLEVEL=notice
```

### 服务注册与配置中心

#### Nacos 配置
```bash
# 版本和端口配置
NACOS_VERSION=v2.5.1
NACOS_SERVER_PORT=8848
NACOS_CLIENT_PORT=9848

# 数据库配置
NACOS_DATASOURCE_PLATFORM=mysql
NACOS_MYSQL_SERVICE_HOST=mysql
NACOS_MYSQL_SERVICE_DB_NAME=nacos
NACOS_MYSQL_SERVICE_USER=root
NACOS_MYSQL_SERVICE_PASSWORD=root_123456

# 认证配置
NACOS_AUTH_ENABLE=true
NACOS_AUTH_TOKEN=SecretKey012345678901234567890123456789012345678901234567890123456789

# 集群配置
NACOS_CLUSTER_MODE=standalone

# 日志配置
NACOS_LOG_LEVEL=INFO
```

### 消息队列配置

#### RocketMQ 配置
```bash
# 版本配置
ROCKETMQ_VERSION=5.3.2

# NameServer 配置
ROCKETMQ_NAMESRV_PORT=9876
ROCKETMQ_NAMESRV_HOST=rocketmq-nameserver

# Broker 配置
ROCKETMQ_BROKER_PORT=10911
ROCKETMQ_BROKER_HOST=rocketmq-broker
ROCKETMQ_BROKER_CLUSTER=DefaultCluster
ROCKETMQ_BROKER_NAME=broker-a

# 控制台配置
ROCKETMQ_CONSOLE_PORT=8081
ROCKETMQ_CONSOLE_USER=admin
ROCKETMQ_CONSOLE_PASSWORD=admin123

# 存储配置
ROCKETMQ_BROKER_STORE_PATH_ROOT_DIR=/data/rocketmq/store
ROCKETMQ_BROKER_STORE_PATH_COMMITLOG=/data/rocketmq/store/commitlog
ROCKETMQ_BROKER_STORE_PATH_CONSUMEQUEUE=/data/rocketmq/store/consumequeue
ROCKETMQ_BROKER_STORE_PATH_INDEX=/data/rocketmq/store/index
```

### 分布式事务配置

#### Seata 配置
```bash
# 版本和端口配置
SEATA_VERSION=2.0.0
SEATA_SERVER_PORT=7091
SEATA_GRPC_PORT=7092

# 存储配置
SEATA_STORE_MODE=db
SEATA_DB_DRIVER=mysql
SEATA_DB_URL=jdbc:mysql://mysql:3306/seata?useUnicode=true&characterEncoding=utf8&connectTimeout=1000&socketTimeout=3000&autoReconnect=true&useSSL=false
SEATA_DB_USER=root
SEATA_DB_PASSWORD=root_123456

# 事务组配置
SEATA_TX_SERVICE_GROUP=default_tx_group
SEATA_VGROUP_MAPPING=default_tx_group
```

### 应用服务配置

#### API 网关配置
```bash
# 端口配置
GATEWAY_PORT=8080
GATEWAY_GRPC_PORT=5005

# JVM 配置
GATEWAY_JAVA_OPTS="-Xms512m -Xmx1024m -XX:+UseG1GC -XX:MaxGCPauseMillis=200"

# Spring 配置
SPRING_PROFILES_ACTIVE=dev
GATEWAY_LOG_LEVEL=INFO

# 路由配置
GATEWAY_DISCOVERY_SERVER_ADDR=nacos:8848
GATEWAY_NACOS_NAMESPACE=public
GATEWAY_NACOS_GROUP=DEFAULT_GROUP

# 限流配置
GATEWAY_RATE_LIMIT_ENABLED=true
GATEWAY_RATE_LIMIT_REQUESTS_PER_SECOND=100
```

#### 用户服务配置
```bash
# 端口配置
USER_SERVICE_PORT=8081
USER_SERVICE_GRPC_PORT=5006

# JVM 配置
USER_SERVICE_JAVA_OPTS="-Xms512m -Xmx1024m -XX:+UseG1GC"

# 数据库配置
USER_SERVICE_DB_HOST=mysql
USER_SERVICE_DB_PORT=3306
USER_SERVICE_DB_NAME=ecommerce_user
USER_SERVICE_DB_USERNAME=ecommerce
USER_SERVICE_DB_PASSWORD=ecommerce_123456

# Redis 配置
USER_SERVICE_REDIS_HOST=redis
USER_SERVICE_REDIS_PORT=6379
USER_SERVICE_REDIS_PASSWORD=redis_123456
```

#### 商品服务配置
```bash
# 端口配置
PRODUCT_SERVICE_PORT=8082
PRODUCT_SERVICE_GRPC_PORT=5007

# JVM 配置（商品服务需要更多内存）
PRODUCT_SERVICE_JAVA_OPTS="-Xms512m -Xmx1536m -XX:+UseG1GC"

# 数据库配置
PRODUCT_SERVICE_DB_HOST=mysql
PRODUCT_SERVICE_DB_PORT=3306
PRODUCT_SERVICE_DB_NAME=ecommerce_product
PRODUCT_SERVICE_DB_USERNAME=ecommerce
PRODUCT_SERVICE_DB_PASSWORD=ecommerce_123456

# 缓存配置
PRODUCT_SERVICE_CACHE_TTL=300
PRODUCT_SERVICE_CACHE_MAX_SIZE=1000
```

#### 交易服务配置
```bash
# 端口配置
TRADE_SERVICE_PORT=8083
TRADE_SERVICE_GRPC_PORT=5008

# JVM 配置
TRADE_SERVICE_JAVA_OPTS="-Xms512m -Xmx1536m -XX:+UseG1GC"

# 数据库配置
TRADE_SERVICE_DB_HOST=mysql
TRADE_SERVICE_DB_PORT=3306
TRADE_SERVICE_DB_NAME=ecommerce_trade
TRADE_SERVICE_DB_USERNAME=ecommerce
TRADE_SERVICE_DB_PASSWORD=ecommerce_123456

# RocketMQ 配置
TRADE_SERVICE_ROCKETMQ_NAME_SERVER=rocketmq-nameserver:9876
TRADE_SERVICE_ROCKETMQ_PRODUCER_GROUP=trade_producer_group
TRADE_SERVICE_ROCKETMQ_CONSUMER_GROUP=trade_consumer_group
```

### 健康检查配置

```bash
# 通用健康检查配置
HEALTHCHECK_INTERVAL=30
HEALTHCHECK_TIMEOUT=10
HEALTHCHECK_RETRIES=3
HEALTHCHECK_START_PERIOD=60

# 健康检查端点
HEALTH_CHECK_ENDPOINT=/actuator/health
LIVENESS_PROBE_PATH=/actuator/health/liveness
READINESS_PROBE_PATH=/actuator/health/readiness
```

### 日志配置

```bash
# 日志级别配置
LOGGING_LEVEL_ROOT=INFO
LOGGING_LEVEL_COM_ECOMMERCE=INFO
LOGGING_LEVEL_ORG_SPRINGFRAMEWORK=WARN
LOGGING_LEVEL_COM_ALIBABA=WARN

# 日志文件配置
LOGGING_FILE_NAME=ecommerce.log
LOGGING_FILE_MAX_SIZE=100MB
LOGGING_FILE_MAX_HISTORY=30

# 日志格式配置
LOGGING_PATTERN_CONSOLE="%d{yyyy-MM-dd HH:mm:ss} [%thread] %-5level %logger{36} - %msg%n"
LOGGING_PATTERN_FILE="%d{yyyy-MM-dd HH:mm:ss} [%thread] %-5level %logger{36} - %msg%n"
```

### 监控配置

```bash
# Actuator 配置
MANAGEMENT_ENDPOINTS_WEB_EXPOSURE_INCLUDE=health,info,metrics,prometheus
MANAGEMENT_ENDPOINT_HEALTH_SHOW_DETAILS=always
MANAGEMENT_METRICS_EXPORT_PROMETHEUS_ENABLED=true

# 监控端口
MANAGEMENT_SERVER_PORT=9090

# 链路追踪配置
SLEUTH_TRACE_ID_128=true
SLEUTH_SAMPLER_PROBABILITY=1.0
ZIPKIN_BASE_URL=http://zipkin:9411
```

## Docker Compose 配置详解

### 网络配置

```yaml
networks:
  ecommerce-frontend:
    driver: bridge
    name: ecommerce-frontend-network

  ecommerce-backend:
    driver: bridge
    name: ecommerce-backend-network
    internal: true

  ecommerce-data:
    driver: bridge
    name: ecommerce-data-network
    internal: true
```

### 数据卷配置

```yaml
volumes:
  mysql-data:
    driver: local
    name: ecommerce-mysql-data

  redis-data:
    driver: local
    name: ecommerce-redis-data

  rocketmq-logs:
    driver: local
    name: ecommerce-rocketmq-logs

  rocketmq-store:
    driver: local
    name: ecommerce-rocketmq-store
```

### 服务依赖配置

```yaml
# 示例：用户服务依赖配置
user-service:
  depends_on:
    mysql:
      condition: service_healthy
    redis:
      condition: service_healthy
    nacos:
      condition: service_healthy
  restart: unless-stopped
```

### 资源限制配置

```yaml
# 示例：生产环境资源配置
services:
  mysql:
    deploy:
      resources:
        limits:
          memory: 4G
          cpus: '2.0'
        reservations:
          memory: 2G
          cpus: '1.0'

  api-gateway:
    deploy:
      resources:
        limits:
          memory: 2G
          cpus: '1.0'
        reservations:
          memory: 1G
          cpus: '0.5'
```

## 配置文件模板

### 开发环境 (.env.dev)

```bash
# 开发环境配置
ENVIRONMENT=dev
SPRING_PROFILES_ACTIVE=dev

# 调试配置
DEBUG=true
JAVA_DEBUG_OPTS="-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=5005"

# 日志配置
LOGGING_LEVEL_COM_ECOMMERCE=DEBUG

# 热重载配置
RELOAD_ENABLED=true
```

### 测试环境 (.env.test)

```bash
# 测试环境配置
ENVIRONMENT=test
SPRING_PROFILES_ACTIVE=test

# 数据库配置（测试数据库）
MYSQL_DATABASE=ecommerce_test

# 缓存配置
REDIS_MAXMEMORY=256mb

# 日志配置
LOGGING_LEVEL_COM_ECOMMERCE=INFO
```

### 生产环境 (.env.prod)

```bash
# 生产环境配置
ENVIRONMENT=prod
SPRING_PROFILES_ACTIVE=prod

# 安全配置
DEBUG=false
JAVA_DEBUG_OPTS=""

# 性能配置
HEALTHCHECK_INTERVAL=60
HEALTHCHECK_START_PERIOD=120

# 资源配置
MYSQL_INNODB_BUFFER_POOL_SIZE=2G
REDIS_MAXMEMORY=2gb
```

## 配置验证

### 环境变量验证脚本

```bash
#!/bin/bash
# validate-config.sh

# 检查必需的环境变量
required_vars=(
    "MYSQL_ROOT_PASSWORD"
    "MYSQL_PASSWORD"
    "REDIS_PASSWORD"
    "NACOS_AUTH_TOKEN"
)

for var in "${required_vars[@]}"; do
    if [[ -z "${!var}" ]]; then
        echo "错误: 环境变量 $var 未设置"
        exit 1
    fi
done

# 检查端口冲突
ports=("3306" "6379" "8848" "8080" "8081" "8082" "8083")
for port in "${ports[@]}"; do
    if lsof -i :$port >/dev/null 2>&1; then
        echo "警告: 端口 $port 已被占用"
    fi
done

echo "配置验证通过"
```

### 服务连通性测试

```bash
#!/bin/bash
# test-connectivity.sh

# 测试数据库连接
docker-compose exec -T mysql mysql -u root -p$MYSQL_ROOT_PASSWORD -e "SELECT 1"

# 测试 Redis 连接
docker-compose exec -T redis redis-cli -a $REDIS_PASSWORD ping

# 测试 Nacos 连接
curl -f http://localhost:${NACOS_SERVER_PORT:-8848}/nacos/v1/ns/instance/list?serviceName=test

echo "连通性测试通过"
```

## 配置最佳实践

### 1. 安全性
- 使用强密码
- 定期更换密钥
- 禁用不必要的调试功能
- 使用内部网络通信

### 2. 性能优化
- 根据硬件配置调整 JVM 参数
- 合理设置数据库连接池大小
- 配置适当的缓存策略
- 监控资源使用情况

### 3. 可维护性
- 使用有意义的环境变量名
- 添加详细的注释
- 分类组织配置项
- 版本控制配置文件

### 4. 可扩展性
- 使用环境变量支持多环境部署
- 设计灵活的服务发现机制
- 支持水平扩展的配置
- 预留监控和日志接口

---

**最后更新**: 2024-12-17
**版本**: v1.0.0
**维护者**: 电商微服务团队