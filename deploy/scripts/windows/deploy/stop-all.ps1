# ==========================================
# E-commerce Microservices - Stop Services Script
# Version: v3.0 (Unified Architecture)
# ==========================================

# ==========================================
# 标准配置区域 (手动修改配置)
# ==========================================

# 项目基础配置
$ProjectConfig = @{
    Name = "E-commerce Microservices"
    Version = "1.0.0"
    Network = @{
        Name = "ecommerce-network"
        Subnet = "172.20.0.0/16"
        Gateway = "172.20.0.1"
    }
    ComposeFiles = @{
        Infrastructure = "docker-compose.infra.yml"
        Applications = "docker-compose.apps.yml"
        ComposeDir = "..\..\..\docker-compose"
    }
}

# 服务配置
$Services = @{
    Infrastructure = @(
        @{ Name = "mysql"; Port = 3306; DisplayName = "MySQL Database" },
        @{ Name = "redis"; Port = 6379; DisplayName = "Redis Cache" },
        @{ Name = "nacos"; Port = 18848; DisplayName = "Nacos Registry" },
        @{ Name = "rocketmq"; Ports = @(9876, 10909, 10911); DisplayName = "RocketMQ" }
    )
    Applications = @(
        @{ Name = "api-gateway"; Port = 28080; DisplayName = "API Gateway" },
        @{ Name = "user-service"; Port = 28081; DisplayName = "User Service" },
        @{ Name = "product-service"; Port = 28082; DisplayName = "Product Service" },
        @{ Name = "trade-service"; Port = 28083; DisplayName = "Trade Service" }
    )
}

# 环境要求配置
$EnvironmentConfig = @{
    MinMemoryGB = 4
    MinDiskGB = 10
    RequiredPorts = @(3306, 6379, 18848, 9876, 10909, 10911, 18080, 28080, 28081, 28082, 28083)
}

# 目录配置
$DirectoryConfig = @{
    DataRoot = "data"
    ConfigRoot = "config"
    LogsRoot = "logs"
    SubDirs = @("mysql", "redis", "nacos", "rocketmq", "user-service", "product-service", "trade-service", "api-gateway")
}

# UI配置
$UI = @{
    Colors = @{
        Header = "Cyan"
        Success = "Green"
        Warning = "Yellow"
        Error = "Red"
        Info = "White"
        Gray = "Gray"
    }
    Separators = @{
        Main = "=========================================="
        Sub = "------------------------------------------"
    }
}

# ==========================================
# 脚本参数
# ==========================================

# 手动解析参数
$Target = "all"
$Force = $false
$StatusOnly = $false
$Help = $false

foreach ($arg in $args) {
    switch ($arg.ToLower()) {
        "all" { $Target = "all" }
        "infra" { $Target = "infra" }
        "apps" { $Target = "apps" }
        "mysql" { $Target = "mysql" }
        "redis" { $Target = "redis" }
        "nacos" { $Target = "nacos" }
        "rocketmq" { $Target = "rocketmq" }
        "api-gateway" { $Target = "api-gateway" }
        "user-service" { $Target = "user-service" }
        "product-service" { $Target = "product-service" }
        "trade-service" { $Target = "trade-service" }
        "-force" { $Force = $true }
        "-statusonly" { $StatusOnly = $true }
        "-help" { $Help = $true }
        "-h" { $Help = $true }
        default {
            if ($arg -notlike "-*") {
                $Target = $arg
            }
        }
    }
}

# ==========================================
# 公共函数区域 (标准函数库)
# ==========================================

function Write-ScriptHeader {
    param([string]$Title, [string]$Subtitle = "")

    Write-Host ""
    Write-Host $UI.Separators.Main -ForegroundColor $UI.Colors.Header
    Write-Host "   $Title" -ForegroundColor $UI.Colors.Header
    if ($Subtitle) {
        Write-Host "   $Subtitle" -ForegroundColor $UI.Colors.Gray
    }
    Write-Host $UI.Separators.Main -ForegroundColor $UI.Colors.Header
    Write-Host ""
}

function Write-StepHeader {
    param([int]$Step, [int]$Total, [string]$Title)

    Write-Host $UI.Separators.Main -ForegroundColor $UI.Colors.Warning
    Write-Host "[Step $Step/$Total] $Title" -ForegroundColor $UI.Colors.Warning
    Write-Host $UI.Separators.Main -ForegroundColor $UI.Colors.Warning
}

function Write-Success {
    param([string]$Message)
    Write-Host "SUCCESS: $Message" -ForegroundColor $UI.Colors.Success
}

function Write-Error {
    param([string]$Message)
    Write-Host "ERROR: $Message" -ForegroundColor $UI.Colors.Error
}

function Write-Warning {
    param([string]$Message)
    Write-Host "WARNING: $Message" -ForegroundColor $UI.Colors.Warning
}

function Write-Info {
    param([string]$Message)
    Write-Host "INFO: $Message" -ForegroundColor $UI.Colors.Info
}

function Write-Detail {
    param([string]$Message)
    Write-Host "  $Message" -ForegroundColor $UI.Colors.Gray
}

function Show-Help {
    param(
        [string]$ScriptName,
        [string]$Description,
        [array]$Targets,
        [array]$Options,
        [array]$Examples
    )

    Write-Host "Usage: .\$ScriptName [target] [options]" -ForegroundColor $UI.Colors.Info
    Write-Host ""
    Write-Host $Description -ForegroundColor $UI.Colors.Info
    Write-Host ""

    if ($Targets) {
        Write-Host "Targets:" -ForegroundColor $UI.Colors.Info
        foreach ($target in $Targets) {
            Write-Host $target -ForegroundColor $UI.Colors.Gray
        }
        Write-Host ""
    }

    if ($Options) {
        Write-Host "Options:" -ForegroundColor $UI.Colors.Info
        foreach ($option in $Options) {
            Write-Host $option -ForegroundColor $UI.Colors.Gray
        }
        Write-Host ""
    }

    if ($Examples) {
        Write-Host "Examples:" -ForegroundColor $UI.Colors.Info
        foreach ($example in $Examples) {
            Write-Host $example -ForegroundColor $UI.Colors.Gray
        }
        Write-Host ""
    }
}

function Test-DockerEnvironment {
    # 检查Docker是否安装
    $dockerCmd = Get-Command docker -ErrorAction SilentlyContinue
    if (-not $dockerCmd) {
        Write-Error "Docker is not installed or not in PATH"
        Write-Info "Please install Docker Desktop from: https://www.docker.com/products/docker-desktop"
        return $false
    }

    # 检查Docker是否运行
    try {
        $dockerInfo = docker info 2>&1
        if ($LASTEXITCODE -ne 0) {
            Write-Error "Docker Desktop is not running"
            Write-Info "Please start Docker Desktop"
            return $false
        }
        Write-Success "Docker environment is ready"
        return $true
    } catch {
        Write-Error "Failed to check Docker status: $($_.Exception.Message)"
        return $false
    }
}

function Get-ServiceList {
    param([string]$Category = "all")

    switch ($Category) {
        "infra" {
            return $Services.Infrastructure | ForEach-Object { $_.Name }
        }
        "apps" {
            return $Services.Applications | ForEach-Object { $_.Name }
        }
        default {
            $infraServices = $Services.Infrastructure | ForEach-Object { $_.Name }
            $appServices = $Services.Applications | ForEach-Object { $_.Name }
            return @($infraServices) + @($appServices)
        }
    }
}

function Get-ServiceInfo {
    param([string]$ServiceName)

    $service = $Services.Infrastructure | Where-Object { $_.Name -eq $ServiceName }
    if (-not $service) {
        $service = $Services.Applications | Where-Object { $_.Name -eq $ServiceName }
    }

    return $service
}

function Get-ComposeFilePath {
    param([string]$ComposeType)

    # 获取脚本所在目录 - 使用PSScriptRoot变量更可靠
    $scriptDir = $PSScriptRoot
    if (-not $scriptDir) {
        $scriptDir = Split-Path -Parent $PSCommandPath
    }
    Write-Detail "Script directory: $scriptDir"

    # 计算compose文件路径
    $composeDir = Join-Path $scriptDir $ProjectConfig.ComposeFiles.ComposeDir
    Write-Detail "Compose directory: $composeDir"

    # 转换为绝对路径
    $composeDir = [System.IO.Path]::GetFullPath($composeDir)
    Write-Detail "Resolved compose directory: $composeDir"

    if ($ComposeType -eq "infra") {
        $composeFile = Join-Path $composeDir $ProjectConfig.ComposeFiles.Infrastructure
    } elseif ($ComposeType -eq "apps") {
        $composeFile = Join-Path $composeDir $ProjectConfig.ComposeFiles.Applications
    } else {
        throw "Unknown compose type: $ComposeType"
    }

    Write-Detail "Compose file: $composeFile"
    return $composeFile
}

function Invoke-DockerCompose {
    param(
        [string]$Action,
        [string]$Service,
        [string]$ComposeType
    )

    try {
        $composeFile = Get-ComposeFilePath -ComposeType $ComposeType

        if (-not (Test-Path $composeFile)) {
            Write-Warning "Compose file not found: $composeFile"
            return $true  # 继续执行
        }

        # 获取compose目录
        $composeDir = Split-Path $composeFile
        $composeFileName = Split-Path $composeFile -Leaf

        $cmd = @("docker", "compose", "-f", $composeFileName, $Action)
        if ($Service) {
            $cmd += $Service
        }

        Write-Info "Command: docker compose -f $composeFileName $Action $Service"
        Write-Detail "Working directory: $composeDir"

        # 切换到compose目录
        Push-Location $composeDir
        & cmd /c "$($cmd -join ' ')" 2>&1
        $exitCode = $LASTEXITCODE
        Pop-Location

        return $exitCode -eq 0
    } catch {
        Write-Error "Command execution failed: $($_.Exception.Message)"
        return $false
    }
}

function Show-ServiceStatus {
    Write-Info "Checking service status..."

    try {
        $containers = docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" 2>&1
        if ($containers) {
            Write-Host $containers -ForegroundColor $UI.Colors.Info

            # 统计容器数量
            $containerLines = $containers -split "`n" | Where-Object { $_ -match "^\w" }
            $containerCount = $containerLines.Count - 1  # 减去表头

            if ($containerCount -gt 0) {
                Write-Info "Total running containers: $containerCount"
            }
        } else {
            Write-Warning "No containers are currently running"
        }
    } catch {
        Write-Error "Failed to get container status"
    }
}

# ==========================================
# 专用功能函数
# ==========================================

function Stop-SingleService {
    param([string]$ServiceName)

    $serviceInfo = Get-ServiceInfo -ServiceName $ServiceName
    if (-not $serviceInfo) {
        Write-Error "Unknown service: $ServiceName"
        return $false
    }

    Write-Info "Stopping $($serviceInfo.DisplayName)..."

    # 确定服务属于哪个compose文件
    $composeType = "apps"
    if ($serviceInfo -in $Services.Infrastructure) {
        $composeType = "infra"
    }

    $success = Invoke-DockerCompose -Action "stop" -Service $ServiceName -ComposeType $composeType

    if ($success) {
        Write-Success "$($serviceInfo.DisplayName) stopped successfully"
        return $true
    } else {
        Write-Warning "Warning occurred while stopping $($serviceInfo.DisplayName)"
        return $true  # 继续执行，不因警告停止
    }
}

function Stop-ServicesByCategory {
    param([string]$Category)

    Write-Info "Stopping $Category services..."

    if ($Category -eq "infra") {
        # 停止基础设施服务
        $composeFile = Join-Path $ProjectConfig.ComposeFiles.ComposeDir $ProjectConfig.ComposeFiles.Infrastructure
        if (-not (Test-Path $composeFile)) {
            Write-Warning "Infrastructure compose file not found: $composeFile"
            return $true  # 继续执行
        }

        Write-Info "Using compose file: $composeFile"
        $success = Invoke-DockerCompose -Action "down" -ComposeType "infra"

        if ($success) {
            Write-Success "Infrastructure services stopped successfully"
            return $true
        } else {
            Write-Warning "Warning occurred while stopping infrastructure services"
            return $true  # 继续执行
        }
    }
    elseif ($Category -eq "apps") {
        # 停止应用服务
        $composeFile = Join-Path $ProjectConfig.ComposeFiles.ComposeDir $ProjectConfig.ComposeFiles.Applications
        if (-not (Test-Path $composeFile)) {
            Write-Warning "Applications compose file not found: $composeFile"
            return $true  # 继续执行
        }

        Write-Info "Using compose file: $composeFile"
        $success = Invoke-DockerCompose -Action "down" -ComposeType "apps"

        if ($success) {
            Write-Success "Application services stopped successfully"
            return $true
        } else {
            Write-Warning "Warning occurred while stopping application services"
            return $true  # 继续执行
        }
    } else {
        Write-Error "Unknown category: $Category"
        return $false
    }
}

function Stop-AllProjectContainers {
    Write-Info "Stopping all project-related containers..."

    try {
        # 获取所有项目相关的容器
        $projectContainers = docker ps -q --filter "name=$($ProjectConfig.Network.Name)" 2>&1

        if ($projectContainers) {
            Write-Detail "Found project containers, stopping..."
            docker stop $projectContainers 2>$null
            docker rm $projectContainers 2>$null
            Write-Success "All project containers stopped"
            return $true
        } else {
            Write-Warning "No project-related containers found"
            return $true
        }
    } catch {
        Write-Warning "Some containers may still be running"
        Write-Info "You can manually stop them with: docker stop \$(docker ps -q --filter name='$($ProjectConfig.Network.Name)')"
        return $false
    }
}

function Show-RemainingContainers {
    Write-Info "Checking for remaining containers..."

    try {
        $allContainers = docker ps --format "table {{.Names}}\t{{.Status}}" 2>&1
        if ($allContainers -and $allContainers -match "^\w") {
            $containerLines = $allContainers -split "`n" | Where-Object { $_ -match "^\w" }
            $containerCount = $containerLines.Count - 1

            if ($containerCount -gt 0) {
                Write-Warning "There are still $containerCount containers running"
                Write-Host $allContainers -ForegroundColor $UI.Colors.Info
                Write-Info "To stop all containers, use:"
                Write-Detail "docker stop `$`(docker ps -q`)"
            } else {
                Write-Success "All project-related services have been stopped"
            }
        } else {
            Write-Success "All project-related services have been stopped"
        }
    } catch {
        Write-Warning "Could not check remaining containers"
    }
}

# ==========================================
# 主程序逻辑
# ==========================================

# 参数验证
$validTargets = @("all", "infra", "apps") + (Get-ServiceList)
if ($Target -notin $validTargets) {
    Write-Error "Invalid target '$Target'. Valid targets: $($validTargets -join ', ')"
    Write-Info "Use -Help to see available options"
    Read-Host "Press Enter to exit"
    exit 1
}

# 处理帮助参数 - 移到最前面
if ($Help -or $h) {
    $targetList = @(
        "all              Stop all services (default)",
        "infra             Stop infrastructure services only",
        "apps              Stop application services only"
    )
    foreach ($service in Get-ServiceList) {
        $targetList += "                  Stop $service service only"
    }

    Show-Help -ScriptName "stop-all.ps1" -Description "Stop project services" -Targets $targetList -Options @(
        "-Force            Skip confirmation prompt",
        "-StatusOnly       Show status only, don't stop services",
        "-Help, -h         Show this help message"
    ) -Examples @(
        ".\stop-all.ps1               # Stop all services",
        ".\stop-all.ps1 infra         # Stop infrastructure only",
        ".\stop-all.ps1 mysql         # Stop MySQL only",
        ".\stop-all.ps1 apps -Force   # Force stop applications"
    )
    Read-Host "Press Enter to exit"
    exit 0
}

# 显示脚本头部
Write-ScriptHeader -Title "$($ProjectConfig.Name) - Stop Services" -Subtitle "Version: v3.0"

# 执行停止逻辑
if ($StatusOnly) {
    Show-ServiceStatus
} else {
    # 确认操作（除非使用了Force参数）
    if (-not $Force) {
        Write-Warning "This will stop all project-related services."
        $confirmation = Read-Host "Are you sure you want to continue? (y/N)"
        if ($confirmation -notmatch "^[Yy]") {
            Write-Info "Operation cancelled by user"
            Read-Host "Press Enter to exit"
            exit 0
        }
    }

    Write-Info "Stopping services with target: $Target"
    Write-Host ""

    # 检查Docker环境
    if (-not (Test-DockerEnvironment)) {
        Write-Error "Docker environment check failed"
        Read-Host "Press Enter to exit"
        exit 1
    }

    $allSuccess = $true

    switch ($Target) {
        "all" {
            # 先尝试通过compose文件停止服务
            Write-StepHeader 1 2 "Stopping Services via Compose Files"
            $composeSuccess = $true
            $composeSuccess = $composeSuccess -and (Stop-ServicesByCategory -Category "apps")
            $composeSuccess = $composeSuccess -and (Stop-ServicesByCategory -Category "infra")

            # 然后停止所有剩余的项目容器
            Write-StepHeader 2 2 "Stopping Remaining Containers"
            $containerSuccess = Stop-AllProjectContainers
            $allSuccess = $composeSuccess -and $containerSuccess
        }
        "infra" {
            $allSuccess = Stop-ServicesByCategory -Category "infra"
        }
        "apps" {
            $allSuccess = Stop-ServicesByCategory -Category "apps"
        }
        default {
            # 单个服务
            $allSuccess = Stop-SingleService -ServiceName $Target
        }
    }

    # 显示完成信息
    Write-Host ""
    Write-ScriptHeader -Title "Stop Complete!"

    if ($allSuccess) {
        Write-Success "All services stopped successfully"
    } else {
        Write-Warning "Some services may not have stopped properly"
        Write-Info "Check the output above for details"
    }

    # 显示剩余容器状态
    Write-Host ""
    Show-RemainingContainers

    Write-Host ""
    Write-Info "Next steps you can take:"
    Write-Detail "1. Run '.\start-all.ps1' to start services again"
    Write-Detail "2. Run '.\start-all.ps1 infra' to start infrastructure only"
    Write-Detail "3. Run '.\start-all.ps1 -StatusOnly' to check current status"
}

Write-Host ""
Read-Host "Press Enter to exit"