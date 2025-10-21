# 🔧 故障排查文档

## 🎯 文档说明

本文档提供电商微服务项目部署和运行过程中的实战问题诊断和解决方案，重点突出高频问题和典型错误。

## 🚨 重要实战错误案例

### ❌ Docker Compose配置修改不生效
**典型场景**：修改了docker-compose.yml的健康检查配置后，服务状态没有更新

**错误原因**：`docker-compose restart`不会重新读取配置文件

**正确做法**：
```bash
docker-compose down
docker-compose up -d
```

**预防措施**：
- 配置变更后必须执行完整的down/up流程
- 不要使用restart命令来应用配置更改
- 重要配置变更后要验证容器状态

### ❌ init脚本路径计算错误
**典型场景**：移动脚本到不同目录后，路径计算不正确，导致目录创建失败

**错误原因**：硬编码路径或相对路径计算错误

**解决方案**：使用动态路径计算
```bash
# Linux示例
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$(dirname "$(dirname "$SCRIPT_DIR")")")"
```

**预防措施**：
- 使用dirname函数动态计算路径
- 测试脚本在不同位置的执行
- 避免硬编码绝对路径

### ❌ Windows/Linux权限问题
**典型场景**：
- Windows：容器挂载目录时权限不足
- Linux：普通用户执行docker命令被拒绝

**解决方案**：
```bash
# Windows - 设置目录权限
icacls "C:\path\to\dir" /grant Everyone:F /T

# Linux - 添加用户到docker组
sudo usermod -aG docker $USER
newgrp docker
```

**预防措施**：
- init脚本中自动设置权限
- 使用sudo运行需要权限的脚本
- 检查目录权限配置

### ❌ 端口冲突导致服务启动失败
**典型场景**：Windows 8848端口被占用，Nacos无法启动

**解决方案**：
```bash
# 查找占用端口的进程
netstat -ano | findstr :8848

# 终止进程
taskkill /PID [PID] /F

# 或修改docker-compose.yml中的端口映射
```

**预防措施**：
- 在init脚本中检查端口冲突
- 为Windows环境使用备用端口
- 记录端口分配情况

## 🔍 高频实战问题

### Docker相关问题

#### 问题1：Docker镜像拉取失败
**症状**：
```
Error response from daemon: Get https://registry-1.docker.io/v2/
```

**快速解决**：
```bash
# 配置国内镜像源
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json <<EOF
{
  "registry-mirrors": [
    "https://docker.mirrors.ustc.edu.cn",
    "https://hub-mirror.c.163.com"
  ]
}
EOF
sudo systemctl restart docker
```

#### 问题2：容器间网络不通
**症状**：容器无法互相访问，服务注册失败

**快速诊断**：
```bash
# 检查网络
docker network ls
docker network inspect ecommerce-network

# 测试连通性
docker exec [container1] ping [container2]
```

**解决方案**：
```bash
# 确保容器在同一网络
docker network connect ecommerce-network [container-name]
```

#### 问题3：容器频繁重启
**症状**：容器状态不断变化，服务不稳定

**快速诊断**：
```bash
# 查看容器状态
docker ps -a

# 查看错误日志
docker logs [container-name] --tail 50
```

**常见原因**：
- 内存不足（OOMKilled）
- 端口冲突
- 配置错误
- 依赖服务未启动

### 服务相关问题

#### 问题4：服务注册到Nacos失败
**症状**：服务列表中看不到服务，调用失败

**快速诊断**：
```bash
# 检查Nacos状态
curl http://localhost:8848/nacos/v1/ns/instance/list?serviceName=user-service

# 检查网络连通性
docker exec [service-container] ping nacos

# 查看应用日志
docker logs [service-container] | grep -i nacos
```

**解决方案**：
```yaml
# application.yml
spring:
  cloud:
    nacos:
      discovery:
        server-addr: nacos:8848
        enabled: true
```

#### 问题5：MySQL连接失败
**症状**：
```
Communications link failure
```

**快速诊断**：
```bash
# 检查MySQL状态
docker logs mysql

# 测试连接
docker exec mysql mysql -u root -p -e "SELECT 1"
```

**解决方案**：
```yaml
# application.yml
spring:
  datasource:
    url: jdbc:mysql://mysql:3306/ecommerce?useUnicode=true&characterEncoding=utf8&serverTimezone=Asia/Shanghai
    username: root
    password: ${MYSQL_ROOT_PASSWORD:123456}
```

#### 问题6：Redis连接超时
**症状**：
```
Could not get a resource from the pool
```

**快速诊断**：
```bash
# 检查Redis状态
docker exec redis redis-cli ping

# 检查连接数
docker exec redis redis-cli info clients
```

**解决方案**：
```yaml
# application.yml
spring:
  redis:
    host: redis
    port: 6379
    timeout: 3000ms
    lettuce:
      pool:
        max-active: 8
        max-idle: 8
```

### 应用相关问题

#### 问题7：内存溢出（OOM）
**症状**：
```
java.lang.OutOfMemoryError: Java heap space
```

**快速诊断**：
```bash
# 查看内存使用
docker stats [container-name]

# 生成内存dump
docker exec [container-name] jcmd [pid] GC.run_finalization
docker exec [container-name] jmap -dump:format=b,file=heap.hprof [pid]
```

**解决方案**：
```yaml
# docker-compose.yml
environment:
  JAVA_OPTS: >-
    -Xms512m -Xmx1024m
    -XX:+HeapDumpOnOutOfMemoryError
    -XX:HeapDumpPath=/app/logs/
```

#### 问题8：Feign调用超时
**症状**：
```
Read timed out executing POST
```

**快速诊断**：
```bash
# 检查目标服务状态
curl http://localhost:28082/actuator/health

# 检查网络延迟
docker exec [container1] ping [container2]
```

**解决方案**：
```yaml
# application.yml
feign:
  client:
    config:
      default:
        connectTimeout: 5000
        readTimeout: 10000
```

#### 问题9：RocketMQ消息发送失败
**症状**：
```
Send message to Broker failed
```

**快速诊断**：
```bash
# 检查RocketMQ状态
docker logs rocketmq-namesrv
docker logs rocketmq-broker

# 检查网络连接
telnet localhost 9876
```

**解决方案**：
```yaml
# application.yml
rocketmq:
  name-server: rocketmq-namesrv:9876
  producer:
    group: ecommerce-producer-group
    send-message-timeout: 3000
    retry-times-when-send-failed: 3
```

## 🛠️ 快速诊断工具

### 一键健康检查
```bash
#!/bin/bash
echo "=== Docker Status ==="
docker ps --format "table {{.Names}}\t{{.Status}}"

echo -e "\n=== Service Health ==="
for service in api-gateway:28080 user-service:28081 product-service:28082 trade-service:28083; do
    name=$(echo $service | cut -d: -f1)
    port=$(echo $service | cut -d: -f2)
    if curl -f http://localhost:$port/actuator/health > /dev/null 2>&1; then
        echo "✅ $name is healthy"
    else
        echo "❌ $name is unhealthy"
    fi
done

echo -e "\n=== System Resources ==="
echo "Memory: $(free -h | grep Mem | awk '{print $3"/"$2}')"
echo "Disk: $(df -h / | tail -1 | awk '{print $3"/"$2}')"
```

### 常用诊断命令
```bash
# Docker相关
docker ps -a                    # 查看所有容器状态
docker logs [container-name]    # 查看容器日志
docker stats                    # 查看资源使用情况

# 网络相关
docker network ls               # 查看Docker网络
docker exec [container] ping [service]  # 测试容器间连通性

# 服务健康检查
curl http://localhost:28080/actuator/health  # API网关健康状态
curl http://localhost:8848/nacos  # Nacos状态
```

## 🚨 应急处理流程

### 服务快速恢复
```bash
# 1. 检查问题
docker ps -a
docker logs [failed-container]

# 2. 重启服务
docker-compose restart [service-name]

# 3. 如果重启失败，重新创建
docker-compose up -d --force-recreate [service-name]

# 4. 验证恢复
curl http://localhost:8080/health
```

### 容器调试技巧
```bash
# 进入容器调试
docker exec -it [container-name] /bin/bash

# 复制文件
docker cp [container]:/app/logs/app.log ./app.log

# 实时查看日志
docker logs -f [container-name]
```

### Windows开发环境问题

#### 问题9：Windows PowerShell脚本中文乱码
**典型场景**：PowerShell脚本中包含中文字符时出现乱码或语法错误

**错误症状**：
```
所在位置 行:1 字符: 34
+ Write-Host "中文测试" -ForegroundColor Green
+                                  ~
字符串缺少终止符: "。
```

**根本原因**：
- PowerShell 5.1默认使用GB2312编码解析脚本
- UTF-8编码的中文在GB2312环境下显示为乱码
- 字符串解析失败导致语法错误

**✅ 终极解决方案**：
```powershell
# 1. 文件编码：UTF-8 with BOM
# 2. 脚本开头添加：
chcp 65001 | Out-Null

# 3. 标准模板：
# PowerShell中文脚本模板
chcp 65001 | Out-Null

Write-Host "中文脚本完美运行" -ForegroundColor Green
```

**实施步骤**：
1. **创建脚本** → 编写包含中文的PowerShell脚本
2. **添加BOM头** → 使用工具添加UTF-8 BOM头
3. **首行命令** → 在脚本开头添加 `chcp 65001 | Out-Null`
4. **正常执行** → `powershell.exe -File script.ps1`

**预防措施**：
- **优先选择**：英文脚本 > 中文脚本（避免编码问题）
- **开发工具**：使用支持UTF-8 BOM的编辑器
- **标准化**：所有PS1脚本遵循UTF-8 BOM + chcp标准
- **替代方案**：考虑升级到PowerShell 7+（原生UTF-8支持）

#### 问题10：bat脚本 vs PowerShell脚本选择
**建议原则**：Windows环境优先PowerShell，避免bat脚本

**PowerShell优势**：
- 更好的错误处理和异常管理
- 丰富的面向对象语法
- .NET Framework集成
- 更好的跨版本兼容性

**bat脚本限制**：
- 错误处理机制简单
- 语法老旧，功能有限
- 中文字符支持更差

#### 问题11：数据库和缓存认证失败
**典型场景**：连接MySQL或Redis时出现认证失败错误

**错误症状**：
```
mysqladmin: connect to server at 'localhost' failed
Access denied for user 'root'@'localhost' (using password: NO)
Redis: NOAUTH Authentication required
```

**解决方案**：
**认证凭据位置**：`deploy/docker-compose/.env`

```bash
# MySQL连接（使用正确密码）
docker exec mysql mysql -u root -proot123456 -e "SELECT 'Connected' as status;"

# Redis连接（使用正确密码）
docker exec redis redis-cli -a redis123456 ping

# 应用程序连接配置
MySQL用户: ecommerce
MySQL密码: ecommerce123
Redis密码: redis123456
```

**预防措施**：
- 所有认证信息统一存储在 `.env` 文件中
- 不要在代码中硬编码密码
- 定期检查和更新认证配置
- 生产环境使用更安全的密码策略

## 📋 问题排查清单

### 环境问题检查清单
- [ ] Docker服务是否正常运行？
- [ ] 所有容器是否已启动？
- [ ] 网络连接是否正常？
- [ ] 端口是否有冲突？
- [ ] 系统资源是否充足？

### 服务问题检查清单
- [ ] API网关健康检查是否通过？
- [ ] 各微服务是否注册到Nacos？
- [ ] 数据库连接是否正常？
- [ ] Redis缓存是否可访问？
- [ ] 消息队列是否正常工作？

### 应用问题检查清单
- [ ] 内存使用是否正常？
- [ ] 接口响应是否及时？
- [ ] 错误日志是否有异常？
- [ ] 配置文件是否正确？
- [ ] 依赖服务是否可用？

---

**文档版本**: v4.0 (实战版)
**最后更新**: 2025-10-20
**维护团队**: 电商微服务项目组