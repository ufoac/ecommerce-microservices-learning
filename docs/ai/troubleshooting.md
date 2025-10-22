# AI 项目上下文增强包

## 核心经验教训

1. Docker健康检查失败：必须使用 `docker inspect` 检查具体原因，不要猜测
2. 配置修改后：必须重新创建容器才能生效，docker-compose restart无效
3. 容器重建原则：`docker-compose down`再`up`，restart不能应用新配置
4. 镜像构建时机：修改应用代码或配置文件后必须重新构建镜像，否则容器使用旧镜像
5. Windows端口问题：检查系统动态端口范围，避免与49152-65535冲突
6. Windows脚本：优先使用PowerShell，避免bat脚本
7. 脚本执行识别：.ps1文件使用PowerShell执行，.sh文件使用bash执行
8. 镜像拉取：国内环境拉取不下来，可设置镜像网站。还是拉取不下来，可到[渡渡鸟镜像同步网站](https://docker.aityp.com/) 上搜索同类镜像

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

### Docker容器故障排查

#### 容器启动失败
```bash
# 检查容器状态
docker ps -a

# 查看容器日志
docker logs [container_name]

# 检查容器详细信息
docker inspect [container_name]

# 常见原因：镜像不存在、端口冲突、环境变量错误
```

#### 服务注册失败
```bash
# 检查Nacos连接
curl http://localhost:18848/nacos/v1/ns/instance/list?serviceName=[service_name]

# 检查环境变量映射
docker exec [container_name] env | grep NACOS

# 常见问题：ENV_NACOS_SERVER_ADDR配置错误、网络不通
```

#### 镜像构建问题
```bash
# 强制重新构建镜像
docker build --no-cache -t [image_name]:[tag] .

# 清理Docker缓存
docker system prune -a

# 检查镜像构建日志
docker build --progress=plain -t [image_name]:[tag] .
```

#### 网络连接问题
```bash
# 检查Docker网络
docker network ls
docker network inspect ecommerce-network

# 测试容器间连通性
docker exec [container1] ping [container2_name]

# 常见问题：服务名配置错误、网络隔离
```

### 配置映射问题排查

#### 环境变量映射错误
```bash
# 检查容器环境变量
docker exec [container_name] env | grep -E "(NACOS|DB|REDIS)"

# 常见映射错误
本地：NACOS_SERVER_ADDR=localhost:18848
容器：ENV_NACOS_SERVER_ADDR=nacos:8848

# 检查网络连通性
docker exec [container_name] ping nacos
docker exec [container_name] ping mysql
```

#### 路由配置映射错误
```bash
# 本地直连模式 - 错误的容器配置
uri: http://localhost:28081

# 容器负载均衡模式 - 正确的容器配置
uri: lb://user-service

# 检查网关路由配置
curl http://localhost:28080/actuator/gateway/routes
```

#### 应用配置不生效
```bash
# 检查应用配置文件
docker exec [container_name] cat /app/application.yml

# 验证环境变量是否正确注入
docker exec [container_name] env | grep SPRING_PROFILES_ACTIVE
```

### 脚本执行问题

#### PowerShell脚本执行失败
```bash
# 检查执行策略
Get-ExecutionPolicy

# 设置执行策略
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# 检查脚本路径
Get-ChildItem deploy/scripts/windows/ -Recurse -Name "*.ps1"
```

#### Maven构建问题
```bash
# 强制更新依赖
mvn clean install -U -DskipTests

# 检查依赖冲突
mvn dependency:tree

# 清理本地仓库
mvn dependency:purge-local-repository
```

### 常见配置路径
- **环境变量**：deploy/docker-compose/.env
- **Docker Compose**：deploy/docker-compose/
- **镜像脚本**：deploy/scripts/windows/images/
- **部署脚本**：deploy/scripts/windows/deploy/
- **应用配置**：backend/{service}/src/main/resources/application.yml
- **数据库脚本**：infrastructure/database/
- **详细目录**：[directory-structure.md](directory-structure.md)
- **脚本使用**：[scripts-guide.md](scripts-guide.md)

### 配置映射核心差异总结
- **本地验证**: 使用localhost直连，NACOS_SERVER_ADDR=localhost:18848
- **容器验证**: 使用服务名通信，ENV_NACOS_SERVER_ADDR=nacos:8848
- **路由配置**: 本地用http://localhost:port，容器用lb://service-name
- **数据库连接**: 本地localhost:3306，容器mysql:3306

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

### 服务验证正确方式
**错误方式**：单独启动jar包验证服务注册
**正确方式**：通过Docker Compose启动微服务
- ✅ `docker-compose -f docker-compose.apps.yml up -d`
- ✅ 微服务和Nacos在同一容器网络中通信

### 服务启动验证流程
1. **基础设施**：`docker-compose -f docker-compose.infra.yml up -d`
2. **微服务**：`docker-compose -f docker-compose.apps.yml up -d`
3. **代码修改后**：必须重新构建镜像 `docker-compose build`

---

**使用原则**：遇到问题时，首先检查这里的项目特定信息，然后再进行通用性排查。这些信息是AI无法从代码结构中推断的关键工程上下文。