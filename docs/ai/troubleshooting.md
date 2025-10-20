# 常见问题和解决方案（学习项目版）

## 🚨 重要提醒

**🔥 核心经验教训**：在进行任何故障排查前，请务必记住以下经验教训，这些都是用时间和错误换来的：

1. **健康检查失败**：不要猜测，要用 `docker inspect` 检查具体原因
2. **配置修改后**：必须重新创建容器才能生效，restart无效
3. **Windows端口问题**：要检查系统端口分配，不要试错式选择
4. **脚本编写**：Windows 环境优先 PowerShell，避免 bat 脚本
5. **中文字符**：脚本中避免中文和特殊符号，使用英文
6. **镜像拉取**：国内免费镜像源很少，华为云是有效解决方案

## 🚀 快速诊断指南

### 环境问题快速排查

#### Docker 相关问题
**问题**: 容器启动失败或健康检查失败

**⚠️ 重要教训**: 健康检查失败时，**不要猜测**，要使用 `docker inspect` 检查具体原因！

**正确排查步骤**:
```bash
# 1. 查看 Docker 容器状态
docker ps -a

# 2. 查看 Docker 容器健康检查状态和日志
docker inspect <container_name> | grep -A 10 -B 5 "Health"
docker logs <container_name> | tail -50

# 3. 检查容器网络配置
docker network ls
docker network inspect ecommerce-network

# 4. 如果修改了健康检查配置，必须重新创建容器
docker-compose down
docker-compose up -d --force-recreate
```

**常见解决方案**:
```bash
# 清理无用容器和镜像
docker system prune -f

# 重新构建镜像
docker-compose build <service_name>

# 强制重新创建容器（配置变更后必须）
docker-compose up -d --force-recreate
```

#### Windows 环境端口问题
**问题**: 端口被占用或端口冲突

**⚠️ 重要教训**: 不要试错式选择端口，要先检查系统端口分配！

**正确排查步骤**:
```powershell
# 1. 查看端口占用情况
netstat -ano | findstr ":28080"

# 2. 检查 Windows 动态端口范围（关键！）
netsh int ipv4 show dynamicport tcp

# 3. 检查端口占用进程
netstat -ano | findstr ":28080"
tasklist | findstr "<PID>"

# 4. 测试端口连通性
Test-NetConnection -ComputerName localhost -Port 28080
```

**端口选择建议**:
- Windows 动态端口范围: 49152-65535
- 建议应用端口: 10000-49000
- 本项目已用端口: 28080(网关), 28081(用户), 28082(商品), 28083(交易)

### Windows 脚本问题

#### ⚠️ 脚本编写规范
**重要教训**: Windows 环境优先使用 PowerShell，避免 bat 脚本！

#### PowerShell 脚本示例
```powershell
# ✅ 正确的 PowerShell 脚本写法
function Start-Services {
    param(
        [string]$Target = "all",
        [switch]$NoWait,
        [switch]$Force
    )

    Write-Host "Starting services..." -ForegroundColor Green

    # 检查 Docker 环境
    try {
        $dockerVersion = docker --version 2>&1
        if ($LASTEXITCODE -ne 0) {
            throw "Docker not found"
        }
        Write-Host "Docker version: $dockerVersion" -ForegroundColor Cyan
    } catch {
        Write-Host "ERROR: Docker check failed" -ForegroundColor Red
        return
    }

    # 服务启动逻辑...
}

# ✅ 调用示例
Start-Services -Target "infra" -NoWait
```

#### 脚本编写禁忌
```powershell
# ❌ 错误写法（不要使用）
function 启动服务 {  # 中文函数名
    $服务名称 = "mysql"  # 中文变量名
    Write-Host "服务启动中..."  # 可能的编码问题
}

# ❌ 避免中文字符
$配置文件路径 = "C:\配置\应用.yml"  # 中文路径可能有问题
```

### 🎯 脚本编写最佳实践

#### 关键教训
- **Windows 环境优先使用 PowerShell，避免 bat 脚本**
- **脚本中所有变量名、函数名必须使用英文**
- **避免脚本中出现中文字符，特别是变量和路径**
- **PowerShell 一次写对的概率远高于 bat 脚本**

#### 正确的脚本编写模式
```powershell
# ✅ 使用英文命名
function Start-DockerServices {
    param([string]$ServiceName = "all")

    Write-Host "Starting Docker services: $ServiceName" -ForegroundColor Green

    # 检查 Docker 环境
    $dockerStatus = docker --version 2>$null
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: Docker is not available" -ForegroundColor Red
        return $false
    }

    # 启动服务逻辑...
    return $true
}

# ✅ 使用英文变量名
$serviceName = "mysql"
$containerName = "ecommerce-mysql"
$configPath = "C:\docker\config"

# ✅ 使用英文路径（如果可能包含中文，要特别注意编码）
# 或者将配置文件放在无中文的路径下
```

## 🏗️ 构建和部署问题

### Docker 镜像拉取失败
**⚠️ 重要教训**: 国内免费镜像源很少，华为云是有效解决方案！

**解决方案**:
```bash
# 方案1: 使用华为云前缀直接拉取
docker pull repo.huaweicloud.com/library/nginx:latest
docker tag repo.huaweicloud.com/library/nginx:latest nginx:latest

# 方案2: 配置 Docker 镜像源
# 在 /etc/docker/daemon.json 中添加：
{
  "registry-mirrors": [
    "https://repo.huaweicloud.com"
  ]
}

# 方案3: 其他可用镜像源
# 阿里云: https://registry.cn-hangzhou.aliyuncs.com
# 腾讯云: https://mirror.ccs.tencentyun.com

# 重启 Docker 服务
systemctl restart docker
```

### Maven 构建问题

#### 依赖冲突解决
```xml
<!-- 在父POM中使用dependencyManagement统一版本 -->
<dependencyManagement>
    <dependencies>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-dependencies</artifactId>
            <version>${spring-boot.version}</version>
            <type>pom</type>
            <scope>import</scope>
        </dependency>
    </dependencies>
</dependencyManagement>
```

**排查命令**:
```bash
# 查看依赖树
mvn dependency:tree

# 分析依赖冲突
mvn dependency:analyze

# 强制更新依赖
mvn clean install -U
```

## 🗄️ 数据库问题

### MySQL 连接失败
**排查步骤**:
```sql
-- 检查MySQL服务状态
SHOW STATUS;

-- 检查连接数
SHOW STATUS LIKE 'Threads_connected';

-- 检查最大连接数
SHOW VARIABLES LIKE 'max_connections';
```

**配置示例**:
```yaml
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/ecommerce?useSSL=false&serverTimezone=UTC
    username: root
    password: password
    driver-class-name: com.mysql.cj.jdbc.Driver
    hikari:
      maximum-pool-size: 20
      minimum-idle: 5
      connection-timeout: 30000
      idle-timeout: 600000
      max-lifetime: 1800000
```


**连接测试**:
```bash
# Redis连接测试
redis-cli ping

# 查看Redis信息
redis-cli info
```

## 🔌 微服务通信问题

### 服务注册发现

#### Nacos 注册失败
**排查步骤**:
```bash
# 检查Nacos服务状态
curl http://localhost:18848/nacos/v1/ns/instance/list?serviceName=user-service

# 检查服务配置
curl http://localhost:18848/nacos/v1/cs/configs?dataId=user-service.yml&group=DEFAULT_GROUP
```

**服务配置示例**:
```yaml
spring:
  cloud:
    nacos:
      discovery:
        server-addr: localhost:18848
        namespace: public
        group: DEFAULT_GROUP
        weight: 1
      config:
        server-addr: localhost:18848
        file-extension: yml
        group: DEFAULT_GROUP
        namespace: public
```


## 📊 性能问题

### 数据库性能

#### 慢查询优化
**常用优化策略**:

1. **索引优化**
```sql
-- 查看慢查询
SHOW VARIABLES LIKE 'slow_query_log';
SHOW VARIABLES LIKE 'long_query_time';

-- 分析执行计划
EXPLAIN SELECT * FROM orders WHERE user_id = 123 AND status = 1;

-- 添加索引
CREATE INDEX idx_orders_user_status ON orders(user_id, status);
```

2. **查询优化**
```sql
-- 避免SELECT *
SELECT id, name, email FROM users WHERE status = 1;

-- 使用LIMIT分页
SELECT * FROM products ORDER BY create_time DESC LIMIT 20 OFFSET 0;
```

### 内存问题

#### JVM 内存配置
**学习项目适用配置**:
```bash
# 推荐的JVM参数
-Xms512m -Xmx1024m
-XX:+UseG1GC
-XX:MaxGCPauseMillis=200
-XX:+PrintGCDetails
```

**内存泄漏排查**:
```bash
# 生成堆转储
jmap -dump:format=b,file=heap.hprof <pid>

# 分析堆转储
jhat heap.hprof

# 查看GC情况
jstat -gc <pid> 1000 10
```


## 📋 标准故障排查流程

### 1. 快速定位问题
- **收集错误信息**: 获取详细的错误日志和堆栈信息
- **复现问题**: 确保能够稳定复现问题
- **缩小范围**: 确定问题发生的具体模块或功能

### 2. 系统性排查
- **检查配置**: 验证相关配置是否正确
- **检查环境**: 确认运行环境是否符合要求
- **检查依赖**: 验证依赖服务是否正常

### 3. 深入分析
- **查看日志**: 分析详细的错误日志
- **调试代码**: 在代码中添加调试信息
- **工具辅助**: 使用专业工具进行深度分析

### 4. 解决验证
- **实施方案**: 设计并实施解决方案
- **测试验证**: 确保问题解决且不引入新问题
- **文档记录**: 记录问题和解决方案

## 🚨 紧急情况处理

### 生产环境问题
- **快速回滚**: 立即回滚到上一个稳定版本
- **临时方案**: 提供临时解决方案
- **详细分析**: 在问题解决后进行详细分析

### 学习环境问题
- **环境重置**: 必要时重置整个开发环境
- **配置检查**: 仔细检查所有配置文件
- **文档参考**: 参考官方文档和社区资源

---

**文档版本**: v3.0 (整合经验教训版)
**重要提醒**: 排查前务必先记住核心经验教训
**维护策略**: 根据实际遇到的问题持续补充
**使用建议**: 按照标准流程进行排查，避免试错式解决