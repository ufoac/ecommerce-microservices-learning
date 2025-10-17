# 电商微服务Docker开发环境

## 环境说明

本Docker Compose配置为电商微服务项目提供完整的开发环境，包含以下中间件服务：

- **MySQL 8.0.40** - 主数据库
- **Redis 7.0** - 缓存服务
- **Nacos 2.5.1** - 服务注册发现和配置中心
- **RocketMQ 5.3.2** - 消息队列
- **Seata 2.0.0** - 分布式事务协调器

## 快速启动

### Windows用户

```cmd
# 进入Docker目录
cd deploy/docker-compose

# 启动所有服务
start.bat

# 或手动启动
docker-compose up -d
```

### Linux/Mac用户

```bash
# 进入Docker目录
cd deploy/docker-compose

# 给脚本执行权限
chmod +x start.sh check-services.sh

# 启动所有服务
./start.sh

# 检查服务状态
./check-services.sh
```

## 服务访问地址

| 服务 | 地址 | 用户名/密码 | 说明 |
|------|------|-------------|------|
| Nacos控制台 | http://localhost:8848/nacos | nacos/nacos | 服务注册和配置管理 |
| MySQL数据库 | localhost:3306 | root/root123456 | 主数据库 |
| Redis缓存 | localhost:6379 | - | 缓存服务 |
| RocketMQ控制台 | http://localhost:8081 | - | 消息队列管理 |
| Seata控制台 | http://localhost:7091 | - | 分布式事务管理 |

## 环境变量配置

环境变量配置文件 `.env` 包含以下配置：

```bash
# 数据库配置
MYSQL_ROOT_PASSWORD=root123456
MYSQL_DATABASE=ecommerce

# Redis配置
REDIS_PASSWORD=redis123456

# Nacos配置
NACOS_USERNAME=nacos
NACOS_PASSWORD=nacos123

# RocketMQ配置
ROCKETMQ_NAMESRV_ADDR=127.0.0.1:9876
```

## 微服务连接配置

各微服务的 `application.yml` 已配置为支持环境变量，可以自动连接Docker环境中的服务：

```yaml
spring:
  cloud:
    nacos:
      discovery:
        server-addr: ${NACOS_SERVER_ADDR:localhost:8848}
        username: ${NACOS_USERNAME:nacos}
        password: ${NACOS_PASSWORD:nacos}

  datasource:
    url: jdbc:mysql://${DB_HOST:localhost}:${DB_PORT:3306}/${DB_NAME:ecommerce}
    username: ${DB_USERNAME:root}
    password: ${DB_PASSWORD:root123456}

  data:
    redis:
      host: ${REDIS_HOST:localhost}
      port: ${REDIS_PORT:6379}
      password: ${REDIS_PASSWORD:}

  rocketmq:
    name-server: ${ROCKETMQ_NAMESERVER_ADDR:localhost:9876}
```

## 常用命令

```bash
# 启动所有服务
docker-compose up -d

# 停止所有服务
docker-compose down

# 重启指定服务
docker-compose restart nacos

# 查看服务状态
docker-compose ps

# 查看服务日志
docker-compose logs -f nacos
docker-compose logs -f mysql

# 进入MySQL容器
docker-compose exec mysql mysql -uroot -proot123456

# 进入Redis容器
docker-compose exec redis redis-cli

# 清理所有数据（谨慎使用）
docker-compose down -v
```

## 数据库初始化

MySQL容器启动时会自动执行以下初始化脚本：

1. `config/mysql/init/01-nacos.sql` - Nacos配置数据库
2. `config/mysql/init/02-ecommerce.sql` - 电商业务数据库

包含的表结构：
- 用户相关：user, role, user_role
- 商品相关：category, product
- 交易相关：cart, `order`, order_item

## 故障排查

### Nacos启动失败

1. 检查MySQL是否正常运行：`docker-compose ps mysql`
2. 查看Nacos日志：`docker-compose logs nacos`
3. 确认数据库连接是否正常

### MySQL连接失败

1. 检查端口占用：`netstat -an | grep 3306`
2. 重启MySQL服务：`docker-compose restart mysql`
3. 查看MySQL日志：`docker-compose logs mysql`

### 端口冲突

如果遇到端口冲突，可以修改 `docker-compose.yml` 中的端口映射：

```yaml
ports:
  - "3307:3306"  # 将MySQL端口改为3307
```

## 性能优化建议

### 开发环境配置

- MySQL内存限制：1GB
- Redis内存限制：256MB
- Nacos内存限制：512MB

### 生产环境调整

```yaml
services:
  mysql:
    environment:
      - MYSQL_INNODB_BUFFER_POOL_SIZE=2G
  redis:
    sysctls:
      - net.core.somaxconn=65535
```

## 日志管理

日志文件位置：
- Nacos日志：`logs/nacos/`
- MySQL日志：Docker容器内部
- Redis日志：Docker容器内部
- RocketMQ日志：Docker卷 `rocketmq-*logs`

查看实时日志：
```bash
docker-compose logs -f [service-name]
```

## 下一步

启动Docker环境后，可以：

1. 启动微服务应用
2. 访问Nacos控制台查看服务注册情况
3. 使用数据库客户端连接MySQL
4. 开始第一阶段的微服务开发

## 注意事项

1. 确保Docker Desktop或Docker Engine已启动
2. Windows用户建议使用Docker Desktop的WSL2后端
3. 首次启动需要下载镜像，时间较长
4. 停机后重启可能会丢失数据，重要数据请备份