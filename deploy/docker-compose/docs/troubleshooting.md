# 故障排除指南

## 快速诊断

### 首先检查事项

当遇到问题时，请按以下顺序进行快速诊断：

```bash
# 1. 检查所有服务状态
make status

# 2. 执行健康检查
make health

# 3. 查看错误日志
make logs-errors

# 4. 检查系统资源
make du
```

### 常用诊断命令

```bash
# 查看容器状态
docker ps -a

# 查看容器资源使用
docker stats

# 查看网络连接
docker network ls

# 查看数据卷
docker volume ls
```

## 启动问题

### 问题1：Docker Compose 无法启动

**症状**：
```
ERROR: Couldn't connect to Docker daemon at http+docker://localhost
```

**解决方案**：
```bash
# 检查 Docker 服务状态
sudo systemctl status docker

# 启动 Docker 服务
sudo systemctl start docker

# 设置 Docker 开机自启
sudo systemctl enable docker

# 检查用户权限
sudo usermod -aG docker $USER
# 注销并重新登录
```

### 问题2：端口冲突

**症状**：
```
ERROR: for mysql  Cannot start service mysql: driver failed programming external connectivity
```

**解决方案**：
```bash
# 查看端口占用
netstat -tlnp | grep :3306
# 或
lsof -i :3306

# 修改环境变量中的端口配置
vim .env
# 修改：MYSQL_PORT=3307

# 重新启动服务
make restart
```

### 问题3：内存不足

**症状**：
```
Container killed due to memory limit
```

**解决方案**：
```bash
# 查看内存使用情况
free -h
docker stats

# 调整 JVM 参数
vim .env
# 修改：JAVA_OPTS="-Xms512m -Xmx768m"

# 增加交换空间
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
```

### 问题4：环境变量未设置

**症状**：
```
ERROR: Missing required environment variable: MYSQL_ROOT_PASSWORD
```

**解决方案**：
```bash
# 检查环境变量文件
ls -la .env*

# 从模板复制配置
cp .env.example .env

# 编辑配置文件
vim .env

# 验证配置
make check-env
```

## 服务连接问题

### 问题1：服务间无法通信

**症状**：
```java
Could not connect to mysql:3306
```

**解决方案**：
```bash
# 检查网络连通性
docker-compose exec api-gateway ping mysql

# 检查 DNS 解析
docker-compose exec api-gateway nslookup mysql

# 检查防火墙设置
sudo ufw status

# 重建网络
docker-compose down
docker network prune
docker-compose up -d
```

### 问题2：数据库连接失败

**症状**：
```
Access denied for user 'ecommerce'@'%''
```

**解决方案**：
```bash
# 检查数据库服务状态
make health SERVICE=mysql

# 进入数据库容器
make shell SERVICE=mysql

# 登录数据库检查用户
mysql -u root -p
SHOW DATABASES;
SELECT User, Host FROM mysql.user;

# 重置用户密码
ALTER USER 'ecommerce'@'%' IDENTIFIED BY 'new_password';
FLUSH PRIVILEGES;
```

### 问题3：Redis 连接失败

**症状**：
```
Redis connection failed: NOAUTH Authentication required
```

**解决方案**：
```bash
# 检查 Redis 服务状态
make health SERVICE=redis

# 测试 Redis 连接
docker-compose exec redis redis-cli -a $REDIS_PASSWORD ping

# 检查 Redis 配置
docker-compose exec redis redis-cli -a $REDIS_PASSWORD CONFIG GET requirepass

# 重置 Redis 密码
docker-compose exec redis redis-cli CONFIG SET requirepass new_password
```

## 服务注册问题

### 问题1：Nacos 服务注册失败

**症状**：
```
Failed to register service to nacos
```

**解决方案**：
```bash
# 检查 Nacos 服务状态
make health SERVICE=nacos

# 检查 Nacos 配置
curl http://localhost:8848/nacos/v1/ns/instance/list?serviceName=nacos

# 查看应用日志
make logs SERVICE=api-gateway | grep nacos

# 检查网络配置
docker-compose exec api-gateway ping nacos

# 重启 Nacos 服务
docker-compose restart nacos
```

### 问题2：服务发现失败

**症状**：
```
No instances available for user-service
```

**解决方案**：
```bash
# 检查服务注册状态
curl "http://localhost:8848/nacos/v1/ns/instance/list?serviceName=user-service"

# 检查服务健康状态
make health-detailed

# 重启应用服务
docker-compose restart user-service

# 清理 Nacos 缓存
curl -X DELETE "http://localhost:8848/nacos/v1/ns/instance?serviceName=user-service&ip=172.18.0.1&port=8081"
```

## 数据持久化问题

### 问题1：数据丢失

**症状**：
重启容器后数据丢失

**解决方案**：
```bash
# 检查数据卷状态
docker volume ls | grep mysql

# 检查数据卷挂载
docker volume inspect ecommerce-mysql-data

# 备份现有数据
docker exec mysql mysqldump -u root -p --all-databases > backup.sql

# 重建数据卷
docker-compose down -v
docker-compose up -d

# 恢复数据
docker exec -i mysql mysql -u root -p < backup.sql
```

### 问题2：磁盘空间不足

**症状**：
```
No space left on device
```

**解决方案**：
```bash
# 检查磁盘使用情况
df -h
docker system df

# 清理 Docker 资源
docker system prune -a

# 清理日志文件
sudo journalctl --vacuum-time=7d

# 清理应用日志
make clean

# 扩展磁盘空间
# 根据实际情况扩展磁盘分区
```

### 问题3：数据卷权限问题

**症状**：
```
Permission denied while accessing data directory
```

**解决方案**：
```bash
# 检查数据卷权限
ls -la data/mysql/

# 修改权限
sudo chown -R 999:999 data/mysql/
sudo chown -R 999:999 data/redis/

# 重新启动容器
docker-compose restart mysql redis
```

## 性能问题

### 问题1：服务响应缓慢

**症状**：
API 响应时间超过 10 秒

**解决方案**：
```bash
# 检查资源使用情况
docker stats

# 检查数据库性能
docker-compose exec mysql mysql -u root -p -e "SHOW PROCESSLIST;"

# 检查慢查询日志
docker-compose logs mysql | grep "Slow query"

# 优化数据库索引
# 根据慢查询日志添加适当的索引

# 调整 JVM 参数
vim .env
# 修改：JAVA_OPTS="-Xms1g -Xmx2g -XX:+UseG1GC"
```

### 问题2：内存泄漏

**症状**：
容器内存使用持续增长

**解决方案**：
```bash
# 监控内存使用
docker stats --no-stream

# 生成内存转储
docker-compose exec api-gateway jcmd <PID> GC.run_finalization
docker-compose exec api-gateway jcmd <PID> VM.gc

# 分析内存使用
docker-compose exec api-gateway jmap -histo <PID>

# 调整内存参数
# 增加 MaxMetaspaceSize
# 使用 G1GC 垃圾收集器
```

### 问题3：CPU 使用率过高

**症状**：
CPU 使用率持续超过 80%

**解决方案**：
```bash
# 检查 CPU 使用情况
top
docker stats

# 检查线程状态
docker-compose exec api-gateway top -H

# 分析线程转储
docker-compose exec api-gateway jstack <PID>

# 优化代码
# 检查是否有死循环或阻塞操作
```

## 网络问题

### 问题1：外部无法访问服务

**症状**：
浏览器无法打开 http://localhost:8080

**解决方案**：
```bash
# 检查端口映射
docker-compose ps

# 检查防火墙设置
sudo ufw status
sudo ufw allow 8080

# 检查服务绑定地址
curl http://127.0.0.1:8080/actuator/health

# 检查网络配置
ip route show
```

### 问题2：DNS 解析失败

**症状**：
无法通过服务名访问其他容器

**解决方案**：
```bash
# 检查 DNS 配置
docker-compose exec api-gateway cat /etc/resolv.conf

# 测试 DNS 解析
docker-compose exec api-gateway nslookup mysql

# 重启 Docker 服务
sudo systemctl restart docker

# 使用 IP 地址临时解决
# 在配置中使用容器 IP 地址
```

## 日志问题

### 问题1：日志文件过大

**症状**：
磁盘空间被日志文件占满

**解决方案**：
```bash
# 检查日志文件大小
du -sh data/logs/*

# 清理旧日志
find data/logs -name "*.log" -mtime +7 -delete

# 配置日志轮转
# 在 docker-compose.yml 中添加 logging 配置

# 启用日志压缩
# 配置应用的日志框架进行日志压缩
```

### 问题2：关键日志丢失

**症状**：
无法找到错误的详细信息

**解决方案**：
```bash
# 调整日志级别
vim .env
# 修改：LOGGING_LEVEL_COM_ECOMMERCE=DEBUG

# 重启服务
docker-compose restart <service_name>

# 实时查看日志
make logs-follow SERVICE=<service_name>

# 导出日志
docker-compose logs <service_name> > service.log
```

## 监控告警

### 设置监控脚本

```bash
#!/bin/bash
# monitor.sh

# 检查服务健康状态
health_check() {
    local service=$1
    local url=$2

    if curl -f -s $url > /dev/null; then
        echo "✅ $service is healthy"
    else
        echo "❌ $service is unhealthy"
        # 发送告警通知
        send_alert "$service is unhealthy"
    fi
}

# 检查资源使用
resource_check() {
    local service=$1
    local memory_limit=$2
    local cpu_limit=$3

    local stats=$(docker stats --no-stream --format "table {{.CPUPerc}}\t{{.MemUsage}}" $service)
    # 解析并检查是否超过限制
}

# 发送告警
send_alert() {
    local message=$1
    # 发送邮件、短信或钉钉通知
    echo $message | mail -s "Service Alert" admin@example.com
}

# 主监控循环
while true; do
    health_check "api-gateway" "http://localhost:8080/actuator/health"
    health_check "user-service" "http://localhost:8081/actuator/health"
    resource_check "mysql" "4G" "200%"
    sleep 60
done
```

## 数据恢复

### MySQL 数据恢复

```bash
# 停止 MySQL 服务
docker-compose stop mysql

# 备份当前数据
docker cp mysql:/var/lib/mysql /backup/mysql_$(date +%Y%m%d_%H%M%S)

# 恢复数据
docker cp /backup/mysql_backup mysql:/var/lib/mysql/
docker-compose start mysql

# 验证数据恢复
docker-compose exec mysql mysql -u root -p -e "SHOW DATABASES;"
```

### Redis 数据恢复

```bash
# 停止 Redis 服务
docker-compose stop redis

# 恢复 RDB 文件
docker cp /backup/dump.rdb redis:/data/

# 启动 Redis 服务
docker-compose start redis

# 验证数据恢复
docker-compose exec redis redis-cli keys "*"
```

## 联系支持

当遇到无法解决的问题时，请按以下步骤操作：

### 1. 收集诊断信息

```bash
# 生成诊断报告
make info > system_info.txt
make status > service_status.txt
make health-detailed > health_report.txt
make logs-errors > error_logs.txt

# 打包诊断信息
tar czf troubleshooting_$(date +%Y%m%d_%H%M%S).tar.gz *.txt data/logs/
```

### 2. 检查已知问题

- 查看项目的 GitHub Issues
- 搜索相关错误信息
- 查看本文档的常见问题

### 3. 提交问题报告

请在问题报告中包含：
- 详细的问题描述
- 复现步骤
- 环境信息（操作系统、Docker版本等）
- 相关日志和配置文件
- 已尝试的解决方案

---

**最后更新**: 2024-12-17
**版本**: v1.0.0
**维护者**: 电商微服务团队