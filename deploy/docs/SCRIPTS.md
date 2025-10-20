# 📋 脚本使用文档

## 🎯 文档说明

本文档详细说明电商微服务项目的所有命令行脚本的作用、参数和使用场景。

## 📁 脚本目录结构

```
deploy/
├── scripts/
│   ├── windows/           # Windows环境脚本
│   │   ├── images/        # 镜像管理脚本 (v2.1)
│   │   │   ├── build-images.ps1    # 智能构建脚本 ✨
│   │   │   ├── export-images.ps1   # 镜像导出脚本 ✨
│   │   │   └── push-images.ps1     # 镜像推送脚本 ✨
│   │   └── deploy/        # 服务部署脚本
│   │       ├── init.ps1    # PowerShell版本（推荐）
│   │       ├── start-all.ps1
│   │       └── stop-all.ps1
│   └── linux/             # Linux环境脚本
│       ├── images/        # 镜像管理脚本
│       │   ├── import-images.sh
│       │   └── list-images.sh
│       └── deploy/        # 服务部署脚本
│           ├── init.sh
│           ├── start-all.sh
│           └── stop-all.sh
```

## 🚀 环境初始化脚本

### init.ps1 - Windows环境初始化（PowerShell版本 - 推荐）

**作用**：Windows环境下检查Docker环境、创建网络、初始化项目目录结构和配置文件

**优势**：
- 更好的错误处理和调试能力
- 彩色输出，提升用户体验
- 更详细的错误信息
- 更强的异常处理机制

**语法**：
```powershell
.\init.ps1 [参数]
```

**参数**：
- `all`：执行所有阶段（默认）
- `check`：只执行环境检查
- `init`：只执行初始化（网络和目录）
- `-Help, -h`：显示帮助信息

**底层命令原理**：
```powershell
# 环境检查底层命令
docker --version                    # 检查Docker是否安装
docker info                         # 检查Docker是否运行
docker compose version              # 检查Docker Compose是否可用
Test-NetConnection -ComputerName localhost -Port 3306  # 检查端口占用

# 网络创建底层命令
docker network create --driver bridge --subnet=172.20.0.0/16 --gateway=172.20.0.1 ecommerce-network

# 目录创建底层命令
New-Item -ItemType Directory -Path "data" -Force
New-Item -ItemType Directory -Path "data\mysql" -Force

# 系统资源检查底层命令
Get-WmiObject -Class Win32_ComputerSystem      # 获取内存信息
Get-WmiObject -Class Win32_LogicalDisk         # 获取磁盘信息
```

**使用场景**：
```powershell
# 首次部署推荐
.\init.ps1

# 只检查环境
.\init.ps1 check

# 只初始化网络和目录
.\init.ps1 init

# 查看帮助
.\init.ps1 -Help
```

**执行策略**：如果遇到执行策略限制，请使用：
```powershell
powershell.exe -ExecutionPolicy Bypass -File ".\init.ps1"
```

**技术原理**：
1. **Docker环境检查**：通过调用Docker CLI命令验证环境状态
2. **网络创建**：使用Docker网络API创建自定义bridge网络
3. **目录结构初始化**：通过PowerShell文件系统API创建项目目录
4. **端口检查**：使用TCP套接字验证端口可用性


### init.sh - Linux环境初始化

**作用**：Linux环境下自动检查并安装Docker、创建网络、初始化项目目录结构和配置文件

**语法**：
```bash
sudo ./init.sh [选项]
```

**参数**：
- `-a`：执行所有阶段（默认）
- `-c`：只执行环境检查
- `-i`：只执行初始化（网络和目录）
- `--help, -h`：显示帮助信息

**使用场景**：
```bash
# 首次部署推荐
sudo ./init.sh

# 只检查环境
sudo ./init.sh -c

# 只初始化网络和目录
sudo ./init.sh -i

# 查看帮助
./init.sh --help
```

**支持的Linux发行版**：
- Ubuntu 18.04+ / Debian 9+
- CentOS 7+ / RHEL 7+

## 🏗️ 镜像管理脚本 (v2.2 参数优化版本)

### build-images.ps1 - 强制构建脚本 ⭐

**版本**：v2.3 (简化强制构建版本)
**作用**：强制构建Docker镜像，执行完整的Maven清理和构建流程

**核心特性**：
- 🚀 **强制重建**：每次执行完整的Maven clean package和Docker build
- 📦 **简单流程**：Maven构建 → Docker构建 → 镜像标记
- 🎯 **简化参数**：直观的参数设计，易于使用
- 🎨 **友好输出**：标准化彩色输出，详细的构建进度
- 🔧 **服务别名**：支持简短服务名（user → user-service）

**语法**：
```powershell
.\build-images.ps1 [target] [tag] [options]
```

**参数**：
- `target`：构建目标（默认：all）
  - `all` - 构建所有服务
  - `user` - 构建用户服务
  - `product` - 构建商品服务
  - `trade` - 构建交易服务
  - `gateway` - 构建网关服务
- `tag`：镜像标签（默认：latest）
- `-h`：显示帮助信息

**使用场景**：
```powershell
# 构建所有服务（推荐）
.\build-images.ps1

# 构建指定服务
.\build-images.ps1 user

# 构建指定服务并打标签
.\build-images.ps1 user v1.0.0

# 构建多个服务
.\build-images.ps1 user,product

# 构建所有服务并打标签
.\build-images.ps1 all production

# 查看帮助
.\build-images.ps1 -h
```

**构建流程**：
1. **环境检查**：验证Maven、Docker环境和项目目录
2. **Maven构建**：执行 `mvn clean package -DskipTests`
3. **Docker构建**：基于构建结果创建Docker镜像
4. **结果汇总**：显示构建状态和后续操作建议

**配置管理**：
```powershell
# 项目配置（脚本开头）
$ProjectConfig = @{
    Name = "ecommerce"
    Version = "2.1"
    Services = @("user-service", "product-service", "trade-service", "api-gateway")
    JarVersion = "1.0.0"
    ImagePrefix = "ecommerce"
}

# 构建配置
$BuildConfig = @{
    MavenCommand = "mvn clean package -DskipTests"
    MonitoredFiles = @("pom.xml", "src/**", "Dockerfile", "common/**")
}
```

**技术原理**：
1. **文件变更检测**：使用 `.build-timestamp.json` 记录构建时间，监控 `pom.xml`、`src/**`、`Dockerfile`、`common/**` 变更
2. **智能决策**：根据文件变更和JAR存在状态决定是否需要构建
3. **分层构建**：先Maven构建JAR，再Docker构建镜像
4. **增量优化**：避免不必要的重复构建，提升开发效率

### export-images.ps1 - 镜像导出脚本 ⭐

**版本**：v2.2 (参数优化版本)
**作用**：导出Docker镜像为tar文件，支持灵活的选择和命名

**核心特性**：
- 🎯 **灵活选择**：支持单个/多个服务导出，支持基础设施镜像
- 📁 **智能命名**：根据导出内容自动生成文件名
- 📋 **详细信息**：自动生成包含镜像信息的详细文档
- 🎨 **友好界面**：标准化输出，清晰的操作反馈
- 🎯 **简化参数**：位置参数，更直观的使用方式

**语法**：
```powershell
.\export-images.ps1 [target] [outputdir] [options]
```

**参数**：
- `target`：导出目标（默认：all）
  - `all` - 导出所有应用服务
  - `user` - 导出用户服务
  - `product` - 导出商品服务
  - `trade` - 导出交易服务
  - `gateway` - 导出网关服务
  - `user,product` - 导出多个服务（逗号分隔）
- `outputdir`：输出目录（默认：./images）
- `-i`：包含基础设施镜像
- `-h`：显示帮助信息

**使用场景**：
```powershell
# 导出所有应用服务
.\export-images.ps1

# 导出指定服务
.\export-images.ps1 user

# 导出多个服务
.\export-images.ps1 user,product

# 包含基础设施镜像
.\export-images.ps1 -i

# 导出所有服务包括基础设施
.\export-images.ps1 all -i

# 自定义输出目录
.\export-images.ps1 user D:\backup

# 导出服务到自定义目录并包含基础设施
.\export-images.ps1 product D:\backup -i

# 查看帮助
.\export-images.ps1 -h
```

**智能文件命名规则**：
- 所有服务 + 基础设施：`ecommerce-full-export-20251020-233338.tar`
- 仅应用服务：`ecommerce-app-services-20251020-233338.tar`
- 仅基础设施：`ecommerce-infrastructure-20251020-233338.tar`
- 单个服务：`ecommerce-user-service-20251020-233338.tar`
- 选择服务：`ecommerce-selected-services-20251020-233338.tar`

**基础设施镜像**：
- `mysql:8.0` - 数据库
- `redis:7.2` - 缓存
- `nacos/nacos-server:v2.3.0` - 注册中心
- `apache/rocketmq:5.1.4` - 消息队列
- `nginx:latest` - 网关

**技术原理**：
1. **镜像验证**：使用 `docker images --format` 验证镜像存在性
2. **批量导出**：使用 `docker save -o` 导出多个镜像到单个tar文件
3. **信息生成**：自动创建包含镜像详细信息的txt文件
4. **目录管理**：自动创建输出目录，处理路径问题

### push-images.ps1 - 镜像推送脚本 ⭐

**版本**：v2.2 (参数优化版本)
**作用**：标记并推送Docker镜像到远程仓库，支持多种仓库配置

**核心特性**：
- 🏷️ **灵活标记**：支持自定义仓库、命名空间、标签
- 📤 **三步骤流程**：环境检查 → 镜像检查 → 执行推送
- 🔄 **自动清理**：推送后自动清理本地临时标记
- 📊 **详细反馈**：完整的推送状态和后续操作指导
- 🎯 **简化参数**：位置参数，更直观的配置方式

**语法**：
```powershell
.\push-images.ps1 [target] [registry] [namespace] [tag] [options]
```

**参数**：
- `target`：推送目标（默认：all）
  - `all` - 推送所有应用服务
  - `user` - 推送用户服务
  - `product` - 推送商品服务
  - `trade` - 推送交易服务
  - `gateway` - 推送网关服务
  - `user,product` - 推送多个服务（逗号分隔）
- `registry`：仓库地址（默认：registry.cn-hangzhou.aliyuncs.com）
- `namespace`：命名空间（默认：ecommerce）
- `tag`：镜像标签（默认：latest）
- `-h`：显示帮助信息

**使用场景**：
```powershell
# 推送所有服务到默认仓库
.\push-images.ps1

# 推送指定服务
.\push-images.ps1 user

# 推送多个服务
.\push-images.ps1 user,product

# 推送到Docker Hub
.\push-images.ps1 all docker.io myproject

# 推送指定版本到Docker Hub
.\push-images.ps1 user docker.io myproject v1.0.0

# 推送到私有仓库
.\push-images.ps1 all registry.example.com myorg production

# 推送指定服务到自定义仓库
.\push-images.ps1 product registry.example.com org dev

# 查看帮助
.\push-images.ps1 -h
```

**默认配置**：
```powershell
$DockerConfig = @{
    DefaultRegistry = "registry.cn-hangzhou.aliyuncs.com"
    DefaultNamespace = "ecommerce"
    DefaultTag = "latest"
}
```

**默认配置**：
```powershell
$DockerConfig = @{
    DefaultRegistry = "registry.cn-hangzhou.aliyuncs.com"
    DefaultNamespace = "ecommerce"
    DefaultTag = "latest"
}
```

**推送流程**：
1. **环境检查**：验证Docker环境和网络连接
2. **镜像检查**：确认本地镜像存在性
3. **镜像标记**：标记为远程仓库格式
4. **执行推送**：推送到远程仓库
5. **清理标记**：删除本地临时标记
6. **结果汇总**：显示推送状态和拉取命令

**拉取命令示例**：
```bash
# Linux环境下拉取推送的镜像
docker pull registry.cn-hangzhou.aliyuncs.com/ecommerce/user-service:latest
docker pull registry.cn-hangzhou.aliyuncs.com/ecommerce/product-service:latest
```

### import-images.sh - Linux导入镜像

**语法**：`import-images.sh [选项]`
**参数**：
- `--list`：列出可用的镜像文件
- `--verify-only`：仅验证镜像文件，不导入
- `--help, -h`：显示帮助信息

**使用场景**：
```bash
sudo ./import-images.sh                    # 自动导入
sudo ./import-images.sh --list             # 列出文件
sudo ./import-images.sh --verify-only      # 验证文件
```

### list-images.sh - 查看镜像信息

**语法**：`list-images.sh [选项]`
**参数**：
- `--detailed`：显示详细信息
- `--check-jar`：只检查JAR文件状态
- `--exported`：只显示导出的镜像文件
- `--refresh`：刷新Docker镜像缓存
- `--help, -h`：显示帮助信息

**使用场景**：
```bash
./list-images.sh                          # 基本信息
./list-images.sh --detailed               # 详细信息
./list-images.sh --check-jar              # 检查JAR状态
```

## 🔧 服务管理脚本

### start-all.ps1 - Windows启动服务（PowerShell版本）

**语法**：`start-all.ps1 [target] [options]`

**参数**：
- `target`：启动目标（默认：all）
  - `all` - 启动所有服务
  - `infra` - 仅启动基础设施服务
  - `apps` - 仅启动应用服务
  - `mysql`、`redis`、`nacos`、`rocketmq` - 单个基础设施服务
  - `api-gateway`、`user-service`、`product-service`、`trade-service` - 单个应用服务
- `-noWait`：跳过健康检查等待
- `-force`：强制重新创建容器
- `-statusOnly`：仅显示状态，不启动服务
- `-help, -h`：显示帮助信息

**底层命令原理**：
```powershell
# Docker环境检查底层命令
docker --version                    # 检查Docker是否安装
docker info                         # 检查Docker运行状态

# 网络检查底层命令
docker network inspect ecommerce-network  # 检查网络是否存在
docker network create --driver bridge --subnet=172.20.0.0/16 --gateway=172.20.0.1 ecommerce-network

# 服务启动底层命令
docker compose -f docker-compose.infra.yml up -d            # 启动基础设施
docker compose -f docker-compose.apps.yml up -d             # 启动应用服务
docker compose -f docker-compose.infra.yml up -d mysql     # 启动单个服务

# 健康检查底层命令
docker ps --filter "name=mysql" --filter "status=running" --filter "health=healthy" --format "{{.Names}}"
docker inspect --format='{{.State.Health.Status}}' mysql   # 检查容器健康状态

# 状态查看底层命令
docker ps --format "table {{.Names}}`t{{.Status}}`t{{.Ports}}"  # 查看运行状态
```

**使用场景**：
```powershell
# 启动所有服务
start-all.ps1

# 仅启动基础设施
start-all.ps1 infra

# 启动单个服务（MySQL）
start-all.ps1 mysql -noWait

# 强制重启应用服务
start-all.ps1 apps -force

# 查看服务状态
start-all.ps1 -statusOnly
```

**技术原理**：
1. **分层启动策略**：先启动基础设施（MySQL、Redis、Nacos、RocketMQ），再启动应用服务
2. **健康检查机制**：通过Docker Health Check API等待服务就绪
3. **网络隔离**：使用自定义Docker网络确保服务间通信安全
4. **依赖管理**：基础设施就绪后才启动依赖它的应用服务
5. **错误恢复**：提供详细的启动日志和故障诊断信息

### stop-all.ps1 - Windows停止服务（PowerShell版本）

**语法**：`stop-all.ps1 [target] [options]`

**参数**：
- `target`：停止目标（默认：all）
  - `all` - 停止所有服务
  - `infra` - 仅停止基础设施服务
  - `apps` - 仅停止应用服务
  - `mysql`、`redis`、`nacos`、`rocketmq` - 单个基础设施服务
  - `api-gateway`、`user-service`、`product-service`、`trade-service` - 单个应用服务
- `-force`：跳过确认提示
- `-statusOnly`：仅显示状态，不停止服务
- `-help, -h`：显示帮助信息

**底层命令原理**：
```powershell
# Docker环境检查底层命令
docker --version                    # 检查Docker是否安装

# 服务停止底层命令
docker compose -f docker-compose.apps.yml down           # 停止应用服务
docker compose -f docker-compose.infra.yml down         # 停止基础设施
docker compose -f docker-compose.infra.yml down mysql   # 停止单个服务

# 状态检查底层命令
docker ps -q                          # 获取运行中容器ID列表
docker ps --format "table {{.Names}}`t{{.Status}}`t{{.Ports}}"  # 查看运行状态
docker inspect --format='{{.Name}}' <container_id>       # 检查容器详细信息

# 强制停止所有容器底层命令
docker stop $(docker ps -q)           # 停止所有运行中的容器
docker rm $(docker ps -aq)            # 删除所有容器
```

**使用场景**：
```powershell
# 停止所有服务
stop-all.ps1

# 仅停止应用服务
stop-all.ps1 apps

# 停止单个服务（MySQL）
stop-all.ps1 mysql -force

# 查看服务状态
stop-all.ps1 -statusOnly
```

**技术原理**：
1. **安全停止策略**：默认先停止应用服务，再停止基础设施，避免数据不一致
2. **依赖关系处理**：按照服务依赖关系顺序停止，确保优雅关闭
3. **状态验证**：停止后检查容器状态，确认服务已完全关闭
4. **清理机制**：自动清理停止的容器，释放系统资源
5. **故障诊断**：提供详细的停止日志和剩余状态检查

### start-all.sh - Linux启动服务
**语法**：`sudo ./start-all.sh [选项]`
**参数**：
- `--infra-only`：只启动基础设施服务
- `--apps-only`：只启动应用服务
- `--no-wait`：启动服务但不等待健康检查
- `--force`：强制重新创建容器
- `--help, -h`：显示帮助信息

**使用场景**：
```bash
sudo ./start-all.sh                       # 启动所有服务
sudo ./start-all.sh --infra-only          # 只启动基础设施
sudo ./start-all.sh --force               # 强制重新创建
```

### stop-all.sh - Linux停止服务
**语法**：`sudo ./stop-all.sh`

## 📌 使用说明

### 权限要求
- **Windows脚本**：建议以管理员身份运行
- **Linux脚本**：建议使用sudo运行

### 脚本位置
- Windows：`deploy/scripts/windows/`
- Linux：`deploy/scripts/linux/`

### 脚本版本信息
- **镜像管理脚本**：v2.2/v2.3 (优化版本)
  - **build-images.ps1**: v2.3 (简化强制构建) - 去除智能检测，直接强制构建
  - **export-images.ps1**: v2.2 (参数优化版本) - 简化参数，支持位置参数
  - **push-images.ps1**: v2.2 (参数优化版本) - 简化参数，支持位置参数
  - 简化的参数设计，提升易用性
  - 支持位置参数和短选项开关
  - 服务名称别名支持（user → user-service）
  - 统一配置管理，便于修改和维护
  - 标准化输出格式和错误处理
  - 完整的帮助文档和使用示例

### 脚本亮点
**v2.2/v2.3版本主要改进**：
- **简化构建**：build-images.ps1直接强制构建，无需复杂的智能检测
- **位置参数**：`build-images.ps1 user v1.0` 代替复杂的参数组合
- **服务别名**：`user` 代替 `user-service`，`product` 代替 `product-service`
- **短选项开关**：`-i` 代替 `-includeinfra`，`-h` 代替 `-help`
- **直观语法**：`export-images.ps1 user D:\backup -i` 代替复杂的参数组合
- **强制构建**：每次执行完整的Maven clean package，确保一致性

### 底层技术栈
**Docker核心技术**：
```bash
# Docker网络管理
docker network ls                      # 列出所有网络
docker network inspect <network_name>  # 检查网络详情
docker network create <options> <name> # 创建自定义网络

# Docker容器管理
docker ps                              # 查看运行中的容器
docker ps -a                           # 查看所有容器
docker logs <container_name>           # 查看容器日志
docker inspect <container_name>        # 检查容器详细信息

# Docker Compose管理
docker compose -f <file> up -d         # 后台启动服务
docker compose -f <file> down           # 停止并删除服务
docker compose -f <file> logs           # 查看服务日志
docker compose -f <file> ps             # 查看服务状态
```

**PowerShell核心技术**：
```powershell
# 系统信息获取
Get-WmiObject -Class Win32_ComputerSystem    # 获取系统信息
Get-WmiObject -Class Win32_LogicalDisk       # 获取磁盘信息
Get-Command docker                           # 检查命令是否存在

# 网络连接测试
Test-NetConnection -ComputerName localhost -Port 3306  # 测试端口连通性

# 文件系统操作
New-Item -ItemType Directory -Path <path> -Force      # 创建目录
Test-Path <path>                                    # 检查路径是否存在
Set-Location <path>                                  # 切换工作目录

# 进程控制
Start-Process powershell -ArgumentList <args>         # 启动新进程
Read-Host "Prompt"                                  # 用户输入
```

### 故障排查命令
```bash
# Docker问题排查
docker version                           # 检查Docker版本
docker system info                       # 查看Docker系统信息
docker system df                         # 查看磁盘使用情况
docker system prune -f                   # 清理未使用的资源

# 网络问题排查
docker network inspect ecommerce-network  # 检查项目网络
ping 172.20.0.1                         # 测试网关连通性
nslookup mysql                          # 测试DNS解析

# 容器问题排查
docker logs mysql                       # 查看MySQL日志
docker exec -it mysql bash              # 进入容器调试
docker stats                            # 查看容器资源使用
```

## 🎓 技术原理深度解析

### Docker容器编排原理
**Docker Compose工作流程**：
1. **解析YAML文件**：读取服务定义、网络配置、卷映射
2. **创建网络**：根据配置创建Docker网络（如ecommerce-network）
3. **启动依赖服务**：按照depends_on顺序启动基础设施服务
4. **健康检查等待**：通过Health Check机制等待服务就绪
5. **启动应用服务**：基础设施就绪后启动业务服务

**网络通信原理**：
```bash
# 自定义网络创建
docker network create --driver bridge --subnet=172.20.0.0/16 ecommerce-network

# 容器网络配置
# 每个容器获得两个IP地址：
# - 172.20.0.x (内部网络IP，用于容器间通信)
# - 127.0.0.1 (本地映射，用于主机访问)

# DNS解析机制
# 容器名称自动解析为内部IP
# 如: mysql -> 172.20.0.2
```

### PowerShell脚本设计原理
**错误处理机制**：
```powershell
try {
    $result = docker ps 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "SUCCESS: Docker is running" -ForegroundColor Green
    }
} catch {
    Write-Host "ERROR: Docker check failed" -ForegroundColor Red
    Write-Host "Error details: $($_.Exception.Message)" -ForegroundColor Red
}
```

**参数验证原理**：
```powershell
[ValidateSet("all", "infra", "apps", "mysql")]
[string]$target = "all"
```

**健康检查实现**：
```powershell
function Test-ServiceHealth {
    param($serviceName, $timeoutSeconds = 30)
    $maxWait = $timeoutSeconds
    $waitCount = 0

    while ($waitCount -lt $maxWait) {
        $healthyServices = docker ps --filter "name=$serviceName" --filter "status=running" --filter "health=healthy" --format "{{.Names}}" 2>$null
        if ($healthyServices -like "*$serviceName*") {
            return $true
        }
        Start-Sleep -Seconds 2
        $waitCount += 2
    }
    return $false
}
```

### 微服务启动顺序原理
**依赖关系图**：
```
基础设施层 (优先启动)
├── MySQL (3306) - 数据持久化
├── Redis (6379) - 缓存服务
├── Nacos (8848->18848) - 服务注册发现
└── RocketMQ (9876/10909/10911) - 消息队列

应用服务层 (依赖基础设施)
├── API Gateway (28080) - 请求路由
├── User Service (28081) - 用户管理
├── Product Service (28082) - 商品管理
└── Trade Service (28083) - 交易管理
```

**启动策略**：
1. **基础设施检查**：验证Docker环境和网络
2. **分层启动**：先启动所有基础设施服务
3. **健康等待**：等待基础设施服务健康检查通过
4. **应用启动**：启动依赖基础设施的应用服务
5. **状态验证**：最终验证所有服务状态

### 故障恢复机制
**自动重试原理**：
```powershell
# 网络创建失败时的恢复
if ($LASTEXITCODE -ne 0) {
    $choice = Read-Host "Create network now? (Y/N)"
    if ($choice -eq "Y") {
        docker network create --driver bridge --subnet=172.20.0.0/16 --gateway=172.20.0.1 ecommerce-network
    }
}
```

**状态一致性检查**：
```powershell
# 启动后验证所有服务状态
docker ps --format "table {{.Names}}`t{{.Status}}`t{{.Ports}}" | Where-Object { $_ -notmatch "CONTAINER" }
```

---

**文档版本**: v4.4 (v2.3简化构建版)
**最后更新**: 2025-10-21
**脚本版本**: PowerShell镜像管理脚本 v2.2/v2.3 (优化版本)