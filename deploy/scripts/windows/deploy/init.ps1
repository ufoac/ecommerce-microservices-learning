# ==========================================
# E-commerce Microservices - Environment Initialization Script
# Version: v4.0 (Unified Architecture)
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
$Mode = "all"
$Force = $false
$Help = $false

foreach ($arg in $args) {
    switch ($arg.ToLower()) {
        "all" { $Mode = "all" }
        "check" { $Mode = "check" }
        "init" { $Mode = "init" }
        "network" { $Mode = "network" }
        "dirs" { $Mode = "dirs" }
        "-force" { $Force = $true }
        "-help" { $Help = $true }
        "-h" { $Help = $true }
        default {
            if ($arg -notlike "-*") {
                $Mode = $arg
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

function Test-PortInUse {
    param([int]$Port)
    try {
        $connection = New-Object System.Net.Sockets.TcpClient
        $connection.Connect("localhost", $Port)
        $connection.Close()
        return $true
    }
    catch {
        return $false
    }
}

# ==========================================
# 专用功能函数
# ==========================================

function Test-SystemEnvironment {
    Write-StepHeader 1 3 "Environment Check"

    # 内存检查
    Write-Info "Checking system memory..."
    try {
        $computerSystem = Get-WmiObject -Class Win32_ComputerSystem
        $totalMemoryKB = $computerSystem.TotalPhysicalMemory
        $totalMemoryGB = [math]::Round($totalMemoryKB / 1GB, 2)

        $os = Get-WmiObject -Class Win32_OperatingSystem
        $freeMemoryKB = $os.FreePhysicalMemory
        $freeMemoryGB = [math]::Round($freeMemoryKB / 1MB, 2)

        $usedMemoryGB = $totalMemoryGB - $freeMemoryGB
        $memoryUsagePercent = [math]::Round(($usedMemoryGB / $totalMemoryGB) * 100, 1)

        Write-Detail "Total Memory: $totalMemoryGB GB"
        Write-Detail "Used Memory:  $usedMemoryGB GB ($memoryUsagePercent%)"
        Write-Detail "Free Memory:  $freeMemoryGB GB"

        if ($totalMemoryGB -ge $EnvironmentConfig.MinMemoryGB) {
            Write-Success "System has sufficient memory"
        } elseif ($totalMemoryGB -ge ($EnvironmentConfig.MinMemoryGB / 2)) {
            Write-Warning "System memory is low, but can run basic services"
        } else {
            Write-Error "System memory is insufficient (< $($EnvironmentConfig.MinMemoryGB)GB)"
            Write-Error "Please upgrade system memory for better performance"
            return $false
        }
    } catch {
        Write-Error "Failed to get memory information: $($_.Exception.Message)"
        return $false
    }

    # 磁盘空间检查
    Write-Info "Checking disk space..."
    try {
        $diskDrive = Get-WmiObject -Class Win32_LogicalDisk -Filter "DeviceID='C:'"
        $totalDiskGB = [math]::Round($diskDrive.Size / 1GB, 2)
        $freeDiskGB = [math]::Round($diskDrive.FreeSpace / 1GB, 2)
        $usedDiskGB = $totalDiskGB - $freeDiskGB
        $usagePercent = [math]::Round(($usedDiskGB / $totalDiskGB) * 100, 1)

        Write-Detail "Total Disk: $totalDiskGB GB"
        Write-Detail "Used Disk:  $usedDiskGB GB ($usagePercent%)"
        Write-Detail "Free Disk:  $freeDiskGB GB"

        if ($freeDiskGB -ge $EnvironmentConfig.MinDiskGB) {
            Write-Success "Sufficient disk space available"
        } elseif ($freeDiskGB -ge ($EnvironmentConfig.MinDiskGB / 2)) {
            Write-Warning "Limited disk space, monitor usage"
        } else {
            Write-Error "Insufficient disk space (< $($EnvironmentConfig.MinDiskGB)GB)"
            Write-Error "Please free up disk space"
            return $false
        }
    } catch {
        Write-Error "Failed to get disk information: $($_.Exception.Message)"
        return $false
    }

    # Docker环境检查
    Write-Info "Checking Docker environment..."
    return Test-DockerEnvironment
}

function Test-PortAvailability {
    Write-Info "Checking required ports..."
    $conflicts = 0

    foreach ($port in $EnvironmentConfig.RequiredPorts) {
        if (Test-PortInUse -Port $port) {
            Write-Warning "Port $port is occupied"
            $conflicts++
        } else {
            Write-Detail "Port $port is available"
        }
    }

    if ($conflicts -eq 0) {
        Write-Success "All required ports are available"
        return $true
    } else {
        Write-Warning "Found $conflicts port conflicts"
        Write-Info "Suggest closing programs occupying ports or modify configuration"
        return $true  # 继续执行，只是警告
    }
}

function Initialize-DockerNetwork {
    Write-Info "Creating Docker network..."

    try {
        $networkExists = docker network inspect $ProjectConfig.Network.Name 2>&1
        if ($LASTEXITCODE -ne 0) {
            Write-Detail "Creating network: $($ProjectConfig.Network.Name)"
            $networkResult = docker network create --driver bridge --subnet=$($ProjectConfig.Network.Subnet) --gateway=$($ProjectConfig.Network.Gateway) $ProjectConfig.Network.Name 2>&1

            if ($LASTEXITCODE -eq 0) {
                Write-Success "Docker network created successfully"
                return $true
            } else {
                Write-Error "Network creation failed: $networkResult"
                return $false
            }
        } else {
            Write-Success "Docker network already exists"
            return $true
        }
    } catch {
        Write-Error "Failed to create Docker network: $($_.Exception.Message)"
        return $false
    }
}

function Initialize-Directories {
    Write-Info "Creating directory structure..."

    $success = $true

    # 创建根目录
    $rootDirs = @($DirectoryConfig.DataRoot, $DirectoryConfig.ConfigRoot, $DirectoryConfig.LogsRoot)
    foreach ($dir in $rootDirs) {
        if (-not (Test-Path $dir)) {
            try {
                New-Item -ItemType Directory -Path $dir -Force | Out-Null
                Write-Success "Created directory: $dir"
            } catch {
                Write-Error "Failed to create directory $dir`: $($_.Exception.Message)"
                $success = $false
            }
        } else {
            Write-Detail "Directory already exists: $dir"
        }
    }

    # 创建子目录
    foreach ($rootDir in $rootDirs) {
        foreach ($subDir in $DirectoryConfig.SubDirs) {
            $fullPath = Join-Path $rootDir $subDir
            if (-not (Test-Path $fullPath)) {
                try {
                    New-Item -ItemType Directory -Path $fullPath -Force | Out-Null
                    Write-Detail "Created subdirectory: $fullPath"
                } catch {
                    Write-Warning "Failed to create subdirectory $fullPath`: $($_.Exception.Message)"
                }
            }
        }
    }

    return $success
}

function Set-DirectoryPermissions {
    Write-Info "Setting directory permissions..."

    $rootDirs = @($DirectoryConfig.DataRoot, $DirectoryConfig.ConfigRoot, $DirectoryConfig.LogsRoot)
    foreach ($dir in $rootDirs) {
        if (Test-Path $dir) {
            try {
                $acl = Get-Acl $dir
                $accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule(
                    "Everyone", "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow"
                )
                $acl.SetAccessRule($accessRule)
                Set-Acl $dir $acl
                Write-Detail "Permissions set for $dir"
            } catch {
                Write-Warning "Permission setting skipped for $dir (may need admin rights)"
            }
        }
    }
}

# ==========================================
# 主程序逻辑
# ==========================================

# 处理帮助参数 - 移到最前面
if ($Help -or $h) {
    Show-Help -ScriptName "init.ps1" -Description "Initialize project environment" -Targets @(
        "all              Execute all phases (default)",
        "check            Only check environment",
        "init             Only initialize directories",
        "network          Only create Docker network",
        "dirs             Only create directory structure"
    ) -Options @(
        "-Force           Force recreate existing resources",
        "-Help, -h        Show this help message"
    ) -Examples @(
        ".\init.ps1                    # Execute all phases",
        ".\init.ps1 check              # Only check environment",
        ".\init.ps1 network -Force    # Force recreate network",
        ".\init.ps1 dirs               # Only create directories"
    )
    Read-Host "Press Enter to exit"
    exit 0
}

# 参数验证
$validModes = @("all", "check", "init", "network", "dirs")
if ($Mode -notin $validModes) {
    Write-Error "Invalid mode '$Mode'. Valid modes: $($validModes -join ', ')"
    Write-Info "Use -Help to see available options"
    Read-Host "Press Enter to exit"
    exit 1
}

# 显示脚本头部
Write-ScriptHeader -Title "$($ProjectConfig.Name) - Environment Init" -Subtitle "Version: v4.0"

# 执行相应模式
$allSuccess = $true

switch ($Mode) {
    "all" {
        $allSuccess = $allSuccess -and (Test-SystemEnvironment)
        $allSuccess = $allSuccess -and (Test-PortAvailability)
        $allSuccess = $allSuccess -and (Initialize-DockerNetwork)
        $allSuccess = $allSuccess -and (Initialize-Directories)
        if ($allSuccess) {
            Set-DirectoryPermissions
        }
    }
    "check" {
        $allSuccess = Test-SystemEnvironment
        $allSuccess = $allSuccess -and (Test-PortAvailability)
    }
    "init" {
        $allSuccess = Initialize-Directories
        if ($allSuccess) {
            Set-DirectoryPermissions
        }
    }
    "network" {
        $allSuccess = Initialize-DockerNetwork
    }
    "dirs" {
        $allSuccess = Initialize-Directories
        if ($allSuccess) {
            Set-DirectoryPermissions
        }
    }
}

# 显示完成信息
Write-Host ""
Write-ScriptHeader -Title "Operation Complete!"

if ($allSuccess) {
    Write-Success "All operations completed successfully"
    Write-Info "Created directories:"
    Write-Detail "$($DirectoryConfig.DataRoot) - Data persistence root directory"
    $allServices = Get-ServiceList
    Write-Detail "  Subdirs: $($allServices -join ', ')"
    Write-Detail "$($DirectoryConfig.ConfigRoot) - Configuration file root directory"
    Write-Detail "$($DirectoryConfig.LogsRoot) - Log file root directory"
    Write-Host ""
    Write-Info "Network information:"
    Write-Detail "Network name: $($ProjectConfig.Network.Name)"
    Write-Detail "Subnet range: $($ProjectConfig.Network.Subnet)"
    Write-Host ""
    Write-Info "Next steps you can take:"
    Write-Detail "1. Run '.\start-all.ps1' to start all services"
    Write-Detail "2. Run '.\start-all.ps1 infra' to start infrastructure only"
    Write-Detail "3. Run '.\build-images.ps1' to build application images"
} else {
    Write-Warning "Some operations completed with warnings"
    Write-Info "Please check the output above for details"
}

Write-Host ""
Read-Host "Press Enter to exit"