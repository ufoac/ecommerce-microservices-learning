# ==========================================
# E-commerce Microservices - Start Services Script
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
$NoWait = $false
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
        "-nowait" { $NoWait = $true }
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
        [string]$ComposeType,
        [switch]$Force
    )

    try {
        $composeFile = Get-ComposeFilePath -ComposeType $ComposeType

        if (-not (Test-Path $composeFile)) {
            Write-Error "Compose file not found: $composeFile"
            return $false
        }

        # 获取compose目录
        $composeDir = Split-Path $composeFile
        $composeFileName = Split-Path $composeFile -Leaf

        $cmd = @("docker", "compose", "-f", $composeFileName, $Action)
        if ($Service) {
            $cmd += $Service
        }
        if ($Force) {
            $cmd += "--force-recreate"
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
    param([switch]$SkipHealthCheck)

    Write-Info "Checking Docker container status..."

    try {
        # 获取所有运行的容器，优化格式
        $containers = docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" 2>&1

        if ($containers -and $containers.Trim()) {
            # 改进显示格式，确保表格正确对齐
            $containerLines = $containers -split "`n"
            foreach ($line in $containerLines) {
                if ($line.Trim()) {
                    # 使用固定宽度格式化显示
                    Write-Host $line -ForegroundColor $UI.Colors.Info
                }
            }

            # 统计容器数量
            $dataLines = $containerLines | Where-Object { $_ -match "^\w" }
            $containerCount = $dataLines.Count

            if ($containerCount -gt 0) {
                Write-Host ""
                Write-Success "Total running containers: $containerCount"

                # 显示系统资源配额
                Write-Host ""
                Write-Info "System Resource Quotas:"
                Show-ResourceQuotas

                # 健康状态统计 - 简化版本
                if (-not $SkipHealthCheck) {
                    Write-Host ""
                    Write-Info "Health Status Summary:"

                    try {
                        $allStatuses = docker ps --format "{{.Status}}" 2>&1
                        if ($allStatuses) {
                            $healthyCount = 0
                            $startingCount = 0
                            $runningCount = 0

                            foreach ($status in $allStatuses) {
                                if ($status -match "healthy") {
                                    $healthyCount++
                                } elseif ($status -match "starting|unhealthy") {
                                    $startingCount++
                                } elseif ($status -match "Up") {
                                    $runningCount++
                                }
                            }

                            if ($healthyCount -gt 0) {
                                Write-Success "  [OK] Healthy services: $healthyCount"
                            }
                            if ($startingCount -gt 0) {
                                Write-Warning "  [..] Starting services: $startingCount"
                            }
                            if ($runningCount -gt 0) {
                                Write-Info "  [>>] Running services: $runningCount"
                            }
                        } else {
                            Write-Detail "  No status information available"
                        }
                    } catch {
                        Write-Detail "  Health check failed: $($_.Exception.Message)"
                    }
                }
            }
        } else {
            Write-Warning "No containers are currently running"

            # 显示系统资源配额（即使没有容器）
            Write-Host ""
            Write-Info "System Resource Quotas:"
            Show-ResourceQuotas
        }

        # 显示资源使用情况
        Write-Host ""
        Write-Info "Current Resource Usage (CPU / Memory):"
        try {
            $stats = docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}" 2>&1
            if ($stats -and $stats.Trim()) {
                $statLines = $stats -split "`n"
                foreach ($line in $statLines) {
                    if ($line.Trim()) {
                        Write-Host $line -ForegroundColor $UI.Colors.Gray
                    }
                }
            } else {
                Write-Detail "  Resource usage data not available"
            }
        } catch {
            Write-Detail "  Resource usage not available"
        }

    } catch {
        Write-Error "Failed to get container status: $($_.Exception.Message)"
    }
}

function Show-ResourceQuotas {
    try {
        # 直接检查系统资源信息

        # 磁盘空间检查
        try {
            $disk = Get-WmiObject -Class Win32_LogicalDisk -Filter "DeviceID='C:'"
            $freeSpace = [math]::Round($disk.FreeSpace / 1GB, 2)
            $totalSpace = [math]::Round($disk.Size / 1GB, 2)
            $diskSpace = "$freeSpace GB / $totalSpace GB (Free/Total)"
            Write-Detail "  Disk Space: $diskSpace"
        } catch {
            Write-Detail "  Disk Space: Unable to get disk info"
        }

        # 内存信息检查
        try {
            $computerSystem = Get-WmiObject -Class Win32_ComputerSystem
            $totalMemoryKB = $computerSystem.TotalPhysicalMemory
            $totalMemoryGB = [math]::Round($totalMemoryKB / 1GB, 2)

            $os = Get-WmiObject -Class Win32_OperatingSystem
            $freeMemoryKB = $os.FreePhysicalMemory
            $freeMemoryGB = [math]::Round($freeMemoryKB / 1MB, 2)

            $memoryInfo = "$freeMemoryGB GB / $totalMemoryGB GB (Available/Total)"
            Write-Detail "  Memory Info: $memoryInfo"
        } catch {
            Write-Detail "  Memory Info: Unable to get memory info"
        }

        # CPU信息检查
        try {
            $cpu = Get-WmiObject -Class Win32_Processor
            $cpuCores = $cpu.NumberOfCores
            $cpuName = $cpu.Name
            Write-Detail "  CPU Info: $cpuCores cores - $cpuName"
        } catch {
            Write-Detail "  CPU Info: Unable to get CPU info"
        }

        # 网络模式
        Write-Detail "  Network Mode: Bridge (ecommerce-network)"

    } catch {
        Write-Detail "  Memory Limit: Unable to get resource info"
        Write-Detail "  CPU Limit: Unable to get resource info"
        Write-Detail "  Disk Space: Unable to get resource info"
        Write-Detail "  Network Mode: Bridge (ecommerce-network)"
    }
}

# ==========================================
# 专用功能函数
# ==========================================

function Start-SingleService {
    param([string]$ServiceName)

    $serviceInfo = Get-ServiceInfo -ServiceName $ServiceName
    if (-not $serviceInfo) {
        Write-Error "Unknown service: $ServiceName"
        return $false
    }

    Write-Info "Starting $($serviceInfo.DisplayName)..."

    # 确定服务属于哪个compose文件
    $composeType = "apps"
    if ($serviceInfo -in $Services.Infrastructure) {
        $composeType = "infra"
    }

    $composeFile = ""
    if ($composeType -eq "infra") {
        $composeFile = Join-Path $ProjectConfig.ComposeFiles.ComposeDir $ProjectConfig.ComposeFiles.Infrastructure
    } else {
        $composeFile = Join-Path $ProjectConfig.ComposeFiles.ComposeDir $ProjectConfig.ComposeFiles.Applications
    }

    if (-not (Test-Path $composeFile)) {
        Write-Error "Compose file not found: $composeFile"
        return $false
    }

    $success = Invoke-DockerCompose -Action "up -d" -Service $ServiceName -ComposeType $composeType -Force:$Force

    if ($success) {
        Write-Success "$($serviceInfo.DisplayName) started successfully"

        if (-not $NoWait -and $serviceInfo.Port) {
            Write-Info "Waiting for service to be ready..."
            Start-Sleep -Seconds 10

            # 简单的健康检查
            try {
                $testResult = Test-NetConnection -ComputerName localhost -Port $serviceInfo.Port -WarningAction SilentlyContinue
                if ($testResult.TcpTestSucceeded) {
                    Write-Success "$($serviceInfo.DisplayName) is ready on port $($serviceInfo.Port)"
                } else {
                    Write-Warning "$($serviceInfo.DisplayName) may still be starting up"
                }
            } catch {
                Write-Warning "Could not verify service status"
            }
        }

        return $true
    } else {
        Write-Error "Failed to start $($serviceInfo.DisplayName)"
        return $false
    }
}

function Start-ServicesByCategory {
    param([string]$Category)

    Write-Info "Starting $Category services..."
    Write-Info "About to call Get-ComposeFilePath for type: $Category"

    if ($Category -eq "infra") {
        # 启动基础设施服务
        Write-Info "Infrastructure compose type detected"
        $success = Invoke-DockerCompose -Action "up -d" -ComposeType "infra" -Force:$Force

        if ($success) {
            Write-Success "Infrastructure services started successfully"
            return $true
        } else {
            Write-Error "Failed to start infrastructure services"
            return $false
        }
    }
    elseif ($Category -eq "apps") {
        # 启动应用服务
        Write-Info "Applications compose type detected"
        $success = Invoke-DockerCompose -Action "up -d" -ComposeType "apps" -Force:$Force

        if ($success) {
            Write-Success "Application services started successfully"
            return $true
        } else {
            Write-Error "Failed to start application services"
            return $false
        }
    } else {
        Write-Error "Unknown category: $Category"
        return $false
    }
}

function Check-Prerequisites {
    Write-StepHeader 1 2 "Prerequisites Check"

    # 检查Docker环境
    if (-not (Test-DockerEnvironment)) {
        return $false
    }

    # 检查网络
    Write-Info "Checking Docker network..."
    try {
        $networkExists = docker network inspect $ProjectConfig.Network.Name 2>&1
        if ($LASTEXITCODE -ne 0) {
            Write-Warning "Docker network '$($ProjectConfig.Network.Name)' not found"
            Write-Info "Please run '.\init.ps1' to create the network first"
            return $false
        } else {
            Write-Success "Docker network '$($ProjectConfig.Network.Name)' is available"
        }
    } catch {
        Write-Error "Failed to check Docker network: $($_.Exception.Message)"
        return $false
    }

    return $true
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
        "all              Start all services (default)",
        "infra             Start infrastructure services only",
        "apps              Start application services only"
    )
    foreach ($service in Get-ServiceList) {
        $targetList += "                  Start $service service only"
    }

    Show-Help -ScriptName "start-all.ps1" -Description "Start project services" -Targets $targetList -Options @(
        "-NoWait           Skip health check waiting",
        "-Force            Force recreate containers",
        "-StatusOnly       Show status only, don't start",
        "-Help, -h         Show this help message"
    ) -Examples @(
        ".\start-all.ps1              # Start all services",
        ".\start-all.ps1 infra        # Start infrastructure only",
        ".\start-all.ps1 mysql        # Start MySQL only",
        ".\start-all.ps1 apps -Force  # Force start applications"
    )
    Read-Host "Press Enter to exit"
    exit 0
}

# 显示脚本头部
Write-ScriptHeader -Title "$($ProjectConfig.Name) - Start Services" -Subtitle "Version: v3.0"

# 执行启动逻辑
if ($StatusOnly) {
    Show-ServiceStatus
} else {
    Write-Info "Starting services with target: $Target"
    Write-Host ""

    # 检查先决条件
    if (-not (Check-Prerequisites)) {
        Write-Error "Prerequisites check failed"
        Read-Host "Press Enter to exit"
        exit 1
    }

    $allSuccess = $true

    switch ($Target) {
        "all" {
            $allSuccess = $allSuccess -and (Start-ServicesByCategory -Category "infra")
            $allSuccess = $allSuccess -and (Start-ServicesByCategory -Category "apps")
        }
        "infra" {
            $allSuccess = Start-ServicesByCategory -Category "infra"
        }
        "apps" {
            $allSuccess = Start-ServicesByCategory -Category "apps"
        }
        default {
            # 单个服务
            $allSuccess = Start-SingleService -ServiceName $Target
        }
    }

    # 显示完成信息
    Write-Host ""
    Write-ScriptHeader -Title "Start Complete!"

    if ($allSuccess) {
        Write-Success "All services started successfully"
        Write-Info "Service URLs:"
        foreach ($service in $Services.Applications) {
            Write-Detail "$($service.DisplayName): http://localhost:$($service.Port)"
        }
        Write-Host ""
        Write-Info "Infrastructure Services:"
        foreach ($service in $Services.Infrastructure) {
            if ($service.Port) {
                Write-Detail "$($service.DisplayName): localhost:$($service.Port)"
            } else {
                Write-Detail "$($service.DisplayName): $($service.Ports -join ', ')"
            }
        }

        # 显示当前容器状态
        Write-Host ""
        Write-StepHeader 1 1 "Current Docker Container Status"
        Show-ServiceStatus

        Write-Host ""
        Write-Info "Health Check Tips:"
        Write-Detail "- Services may take a few moments to fully initialize"
        Write-Detail "- Use '.\start-all.ps1 -StatusOnly' to check status later"
        Write-Detail "- Check individual service logs with: docker logs <container_name>"

    } else {
        Write-Warning "Some services may not have started properly"
        Write-Info "Check the output above for details"
        Write-Info "You can check service status with: .\start-all.ps1 -StatusOnly"

        # 即使启动失败，也显示当前容器状态以便调试
        Write-Host ""
        Write-Info "Current Container Status (for debugging):"
        Show-ServiceStatus
    }
}

Write-Host ""
Read-Host "Press Enter to exit"