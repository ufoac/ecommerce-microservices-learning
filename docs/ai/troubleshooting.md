# AI 项目上下文增强包

## 核心经验教训

1. Docker健康检查失败：必须使用 `docker inspect` 检查具体原因，不要猜测
2. 配置修改后：必须重新创建容器才能生效，docker-compose restart无效
3. Windows端口问题：检查系统动态端口范围，避免与49152-65535冲突
4. Windows脚本：优先使用PowerShell，避免bat脚本。
5. 镜像拉取：国内环境拉取不下来，可设置镜像网站。还是拉取不下来，可到[渡渡鸟镜像同步网站](https://docker.aityp.com/) 上搜索同类镜像。

## 项目关键配置信息

### 密码和认证信息
- **存储位置**：`deploy/docker-compose/.env`（从.env.example复制）
- **MySQL密码**：root123456（开发环境）
- **Redis密码**：redis123456
- **Nacos用户名密码**：nacos/nacos
- **RocketMQ**：无认证（开发环境）

### 端口配置
- **API网关**：28080（外部访问）→ 8080（容器内部）
- **用户服务**：28081 → 8081
- **商品服务**：28082 → 8082
- **交易服务**：28083 → 8083
- **Nacos控制台**：18848 → 8848
- **RocketMQ控制台**：18080 → 8081

### Docker关键命令
```bash
# 容器健康检查
docker inspect <container_name> | grep -A 10 -B 5 "Health"

# 强制重新创建容器（配置变更后必须）
docker-compose down
docker-compose up -d --force-recreate

# 清理Docker资源
docker system prune -f
```

### Windows端口排查
```powershell
# 检查动态端口范围
netsh int ipv4 show dynamicport tcp

# 检查端口占用
netstat -ano | findstr ":28080"

# 测试端口连通性
Test-NetConnection -ComputerName localhost -Port 28080
```

### 环境特定问题

#### Maven构建
- **依赖冲突**：使用dependencyManagement统一版本
- **强制更新**：mvn clean install -U
- **依赖分析**：mvn dependency:tree
- **关键依赖**：所有后端服务都依赖common模块，必须先在common目录执行`mvn clean install`安装到本地仓库，其他服务才能编译成功
- **构建顺序**：先构建common模块，再构建具体服务

#### Nacos服务注册
- **检查URL**：http://localhost:18848/nacos/v1/ns/instance/list?serviceName=user-service
- **配置URL**：http://localhost:18848/nacos/v1/cs/configs?dataId=user-service.yml&group=DEFAULT_GROUP
- **服务配置**：namespace=public, group=DEFAULT_GROUP

#### 数据库连接
- **MySQL版本**：8.0
- **字符集**：utf8mb4_unicode_ci
- **连接URL**：jdbc:mysql://localhost:3306/ecommerce?useSSL=false&serverTimezone=UTC

#### PowerShell脚本规范
- 所有变量名、函数名必须使用英文 。避免中文字符，特别是路径和变量
- 如果一定要用中文（比如注释/输出结果），须采用UTF-8编码 + BOM头。脚本开头`chcp 65001 | Out-Null`
- 使用 `$LASTEXITCODE` 检查命令执行结果

### 常见配置路径
- **环境变量**：deploy/docker-compose/.env
- **Docker Compose**：deploy/docker-compose/compose/
- **应用配置**：backend/{service}/src/main/resources/application.yml
- **数据库脚本**：infrastructure/database/

### JVM配置
```bash
# 标准最小配置（所有服务）
-Xms512m -Xmx1024m -XX:+UseG1GC
```

### 调试端口配置（开发环境）
- API网关：5005
- 用户服务：5006
- 商品服务：5007
- 交易服务：5008

---

**使用原则**：遇到问题时，首先检查这里的项目特定信息，然后再进行通用性排查。这些信息是AI无法从代码结构中推断的关键工程上下文。