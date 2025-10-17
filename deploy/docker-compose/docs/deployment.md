# 部署文档

## 环境要求

### 系统要求
- **操作系统**: Linux/macOS/Windows (支持 Docker)
- **内存**: 最低 8GB，推荐 16GB+
- **磁盘**: 最低 20GB 可用空间
- **网络**: 稳定的互联网连接

### 软件依赖
- **Docker**: 20.10+
- **Docker Compose**: 2.0+
- **Make**: 3.8+ (可选，用于便捷命令)
- **Git**: 2.30+ (用于代码管理)

## 快速部署

### 1. 克隆项目
```bash
git clone <repository-url>
cd ecommerce-project/deploy/docker-compose
```

### 2. 环境初始化
```bash
# 复制环境变量模板
cp .env.example .env

# 检查环境配置
make check-env
```

### 3. 启动服务
```bash
# 快速启动完整环境
make quick-start

# 或分步启动
make up-infra  # 启动基础设施
sleep 60      # 等待基础设施就绪
make up-apps  # 启动应用服务
```

### 4. 验证部署
```bash
# 检查服务状态
make status

# 执行健康检查
make health

# 查看服务日志
make logs-all
```

## 生产环境部署

### 1. 环境准备

#### 服务器配置
```bash
# 推荐配置
CPU: 4核心+
内存: 16GB+
磁盘: 100GB+ SSD
网络: 1Gbps+
```

#### 系统优化
```bash
# 增加文件描述符限制
echo "* soft nofile 65536" >> /etc/security/limits.conf
echo "* hard nofile 65536" >> /etc/security/limits.conf

# 优化内核参数
echo "vm.max_map_count=262144" >> /etc/sysctl.conf
sysctl -p
```

### 2. 安全配置

#### 环境变量安全
```bash
# 设置强密码
MYSQL_ROOT_PASSWORD=<strong_password>
MYSQL_PASSWORD=<strong_password>
REDIS_PASSWORD=<strong_password>

# 禁用调试端口
JAVA_OPTS="-Xms2g -Xmx4g -XX:+UseG1GC"
```

#### 网络安全
```bash
# 配置防火墙
ufw allow 22    # SSH
ufw allow 80    # HTTP
ufw allow 443   # HTTPS
ufw allow 8080  # API Gateway
ufw enable
```

### 3. 生产环境配置

#### 资源限制
```yaml
# compose/docker-compose.prod.yml
version: '3.8'
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

#### 数据持久化
```yaml
volumes:
  mysql-data:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /data/mysql

  redis-data:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /data/redis
```

### 4. 监控配置

#### 日志收集
```yaml
logging:
  driver: "json-file"
  options:
    max-size: "100m"
    max-file: "3"
    labels: "service,environment"
```

#### 健康检查
```yaml
healthcheck:
  test: ["CMD", "curl", "-f", "http://localhost:8080/actuator/health"]
  interval: 30s
  timeout: 10s
  retries: 3
  start_period: 60s
```

## 高可用部署

### 1. 数据库高可用

#### MySQL 主从复制
```yaml
# compose/docker-compose.mysql-ha.yml
services:
  mysql-master:
    environment:
      MYSQL_REPLICATION_MODE: master
      MYSQL_REPLICATION_USER: replicator
      MYSQL_REPLICATION_PASSWORD: <replication_password>

  mysql-slave:
    environment:
      MYSQL_REPLICATION_MODE: slave
      MYSQL_MASTER_HOST: mysql-master
      MYSQL_MASTER_PORT: 3306
      MYSQL_REPLICATION_USER: replicator
      MYSQL_REPLICATION_PASSWORD: <replication_password>
```

#### Redis 集群
```yaml
# compose/docker-compose.redis-cluster.yml
services:
  redis-node-1:
    command: redis-server --cluster-enabled yes --cluster-config-file nodes.conf

  redis-node-2:
    command: redis-server --cluster-enabled yes --cluster-config-file nodes.conf
```

### 2. 服务负载均衡

#### Nginx 配置
```nginx
upstream api_gateway {
    server api-gateway-1:8080;
    server api-gateway-2:8080;
    server api-gateway-3:8080;
}

server {
    listen 80;
    location / {
        proxy_pass http://api_gateway;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

## 备份策略

### 1. 数据备份

#### 自动备份脚本
```bash
#!/bin/bash
# backup.sh

BACKUP_DIR="/backup/$(date +%Y%m%d_%H%M%S)"
mkdir -p $BACKUP_DIR

# 备份 MySQL
docker exec mysql mysqldump -u root -p$MYSQL_ROOT_PASSWORD --all-databases > $BACKUP_DIR/mysql_full.sql

# 备份 Redis
docker exec redis redis-cli BGSAVE
docker cp redis:/data/dump.rdb $BACKUP_DIR/

# 压缩备份文件
tar czf $BACKUP_DIR.tar.gz $BACKUP_DIR
rm -rf $BACKUP_DIR

# 清理旧备份（保留7天）
find /backup -name "*.tar.gz" -mtime +7 -delete
```

#### 定时备份
```bash
# 添加到 crontab
0 2 * * * /path/to/backup.sh
```

### 2. 配置备份

```bash
# 备份配置文件
tar czf config_backup_$(date +%Y%m%d).tar.gz .env compose/ config/

# 备份到远程存储
aws s3 cp config_backup_$(date +%Y%m%d).tar.gz s3://backup-bucket/
```

## 故障恢复

### 1. 服务恢复

```bash
# 检查服务状态
make status

# 重启异常服务
docker-compose restart <service_name>

# 查看详细日志
make logs SERVICE=<service_name>
```

### 2. 数据恢复

```bash
# 恢复 MySQL 数据
docker exec -i mysql mysql -u root -p$MYSQL_ROOT_PASSWORD < backup.sql

# 恢复 Redis 数据
docker cp dump.rdb redis:/data/
docker-compose restart redis
```

### 3. 完整恢复

```bash
# 恢复配置
make restore-data BACKUP_DIR=backup/20231201_120000

# 重启所有服务
make restart

# 验证恢复
make health-detailed
```

## 性能优化

### 1. 数据库优化

```sql
-- MySQL 配置优化
SET GLOBAL innodb_buffer_pool_size = 2147483648;  -- 2GB
SET GLOBAL max_connections = 1000;
SET GLOBAL query_cache_size = 67108864;  -- 64MB
```

### 2. 缓存优化

```bash
# Redis 内存优化
redis-cli CONFIG SET maxmemory 1gb
redis-cli CONFIG SET maxmemory-policy allkeys-lru
```

### 3. JVM 优化

```bash
# 生产环境 JVM 参数
JAVA_OPTS="-Xms2g -Xmx4g -XX:+UseG1GC -XX:MaxGCPauseMillis=200 -XX:+UseStringDeduplication"
```

## 安全加固

### 1. 访问控制

```bash
# 限制容器权限
docker-compose.yml:
security_opt:
  - no-new-privileges:true
user: "1000:1000"
```

### 2. 网络隔离

```yaml
# 创建专用网络
networks:
  frontend:
    driver: bridge
  backend:
    driver: bridge
    internal: true
```

### 3. 密钥管理

```bash
# 使用 Docker Secrets
echo "my_secret_password" | docker secret create db_password -
```

## 故障排查

### 常见问题

1. **内存不足**
   ```bash
   # 检查内存使用
   docker stats

   # 调整 JVM 参数
   export JAVA_OPTS="-Xms1g -Xmx2g"
   ```

2. **磁盘空间不足**
   ```bash
   # 清理 Docker 资源
   docker system prune -a

   # 清理日志文件
   make clean
   ```

3. **网络连接问题**
   ```bash
   # 检查网络连通性
   docker-compose exec api-gateway ping mysql

   # 重建网络
   docker-compose down
   docker network prune
   docker-compose up -d
   ```

### 日志分析

```bash
# 查看错误日志
make logs-errors

# 分析访问日志
docker-compose logs api-gateway | grep ERROR

# 监控资源使用
docker stats --no-stream
```

## 联系支持

如遇到部署问题，请：

1. 查看本文档的故障排查部分
2. 检查项目的 Issues 页面
3. 收集相关日志和配置信息
4. 联系技术支持团队

---

**最后更新**: 2024-12-17
**版本**: v1.0.0
**维护者**: 电商微服务团队