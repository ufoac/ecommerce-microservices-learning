# 📋 脚本使用文档

## 🎯 文档说明

本文档详细说明电商微服务项目的所有命令行脚本的作用、参数和使用场景。

## 📁 脚本目录结构

```
deploy/
├── scripts/
│   ├── windows/           # Windows环境脚本
│   │   ├── images/        # 镜像管理脚本
│   │   │   ├── build-images.bat
│   │   │   ├── export-images.bat
│   │   │   ├── import-images.bat
│   │   │   └── push-images.bat
│   │   └── deploy/        # 服务部署脚本
│   │       ├── init.ps1    # PowerShell版本（推荐）
│   │       ├── init.bat    # 批处理版本（兼容）
│   │       ├── start-all.bat
│   │       └── stop-all.bat
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

### init.bat - Windows环境初始化（批处理版本 - 兼容）

**作用**：Windows环境下检查Docker环境、创建网络、初始化项目目录结构和配置文件

**语法**：
```bash
init.bat [选项]
```

**参数**：
- `-a`：执行所有阶段（默认）
- `-c`：只执行环境检查
- `-i`：只执行初始化（网络和目录）
- `--help, -h`：显示帮助信息

**使用场景**：
```bash
# 首次部署推荐
init.bat

# 只检查环境
init.bat -c

# 只初始化网络和目录
init.bat -i

# 查看帮助
init.bat --help
```

**说明**：此版本为兼容性保留，建议使用PowerShell版本以获得更好的体验

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

## 🏗️ 镜像管理脚本

### build-images.bat - 构建镜像
**语法**：`build-images.bat [选项]`
**参数**：
- `--service, -s <服务名>`：构建指定服务
- `--help, -h`：显示帮助信息

**可用服务**：user-service、product-service、trade-service、api-gateway

**使用场景**：
```bash
build-images.bat                    # 构建所有服务
build-images.bat -s user-service    # 只构建用户服务
```

### export-images.bat - 导出镜像
**语法**：`export-images.bat [选项]`
**参数**：
- `--service, -s <服务名>`：导出指定服务
- `--file, -f <文件名>`：自定义导出文件名
- `--help, -h`：显示帮助信息

**使用场景**：
```bash
export-images.bat                           # 导出所有服务
export-images.bat -s user-service           # 只导出用户服务
export-images.bat -f custom.tar             # 自定义文件名
```

### import-images.bat - 导入镜像
**语法**：`import-images.bat [选项]`
**参数**：
- `--file, -f <文件路径>`：指定镜像文件路径
- `--help, -h`：显示帮助信息

**使用场景**：
```bash
import-images.bat                              # 自动导入最新文件
import-images.bat -f "images\ecommerce.tar"    # 导入指定文件
```

### push-images.bat - 推送镜像
**语法**：`push-images.bat [选项]`
**参数**：
- `--service, -s <服务名>`：推送指定服务
- `--registry, -r <仓库地址>`：镜像仓库地址
- `--namespace, -n <命名空间>`：命名空间
- `--tag, -t <标签>`：镜像标签
- `--help, -h`：显示帮助信息

**使用场景**：
```bash
push-images.bat                           # 推送所有服务
push-images.bat -s user-service           # 只推送用户服务
push-images.bat -t v1.0.0                 # 推送指定版本
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

**文档版本**: v3.1 (增强版)
**最后更新**: 2025-10-20