# ===================================
# E-commerce Microservices Project - Environment Initialization Script
# Version: v3.1 (PowerShell Version)
# ===================================

param(
    [Parameter(Position=0)]
    [ValidateSet("all", "check", "init")]
    [string]$mode = "all",
    [switch]$Help,
    [switch]$h
)

# Display header
Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "   E-commerce Microservices - Environment Init" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# Handle help parameter
if ($Help -or $h) {
    Write-Host "Usage: .\init.ps1 [mode]"
    Write-Host ""
    Write-Host "Modes:"
    Write-Host "  all                  Execute all phases (default)"
    Write-Host "  check                Only check environment"
    Write-Host "  init                 Only initialize network and directories"
    Write-Host ""
    Write-Host "Examples:"
    Write-Host "  .\init.ps1            # Execute all phases"
    Write-Host "  .\init.ps1 check      # Only check environment"
    Write-Host "  .\init.ps1 init       # Only initialize network and directories"
    Write-Host ""
    Read-Host "Press Enter to exit"
    exit 0
}

Write-Host "Execute phase: $mode"
Write-Host ""

# Function to check if command exists
function Test-Command {
    param($Command)
    try {
        Get-Command $Command -ErrorAction Stop | Out-Null
        return $true
    }
    catch {
        return $false
    }
}

# Function to check if port is in use
function Test-PortInUse {
    param($Port)
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

# Phase 1: Environment Check
if ($mode -eq "all" -or $mode -eq "check") {
    Write-Host "==========================================" -ForegroundColor Yellow
    Write-Host "[Phase 1] Environment Check" -ForegroundColor Yellow
    Write-Host "==========================================" -ForegroundColor Yellow

    # Check 1/6: System Memory Check
    Write-Host "[Check 1/6] System Memory Check" -ForegroundColor White
    try {
        # Use Get-WmiObject instead of Get-CimInstance for better compatibility
        $computerSystem = Get-WmiObject -Class Win32_ComputerSystem -ErrorAction Stop
        $totalMemoryKB = $computerSystem.TotalPhysicalMemory
        $totalMemoryGB = [math]::Round($totalMemoryKB / 1GB, 2)

        # Get free memory using performance counters
        $os = Get-WmiObject -Class Win32_OperatingSystem -ErrorAction Stop
        $freeMemoryKB = $os.FreePhysicalMemory
        $freeMemoryGB = [math]::Round($freeMemoryKB / 1MB, 2)

        $usedMemoryGB = $totalMemoryGB - $freeMemoryGB
        $memoryUsagePercent = [math]::Round(($usedMemoryGB / $totalMemoryGB) * 100, 1)

        Write-Host "Total Memory: $totalMemoryGB GB" -ForegroundColor Gray
        Write-Host "Used Memory:  $usedMemoryGB GB ($memoryUsagePercent%)" -ForegroundColor Gray
        Write-Host "Free Memory:  $freeMemoryGB GB" -ForegroundColor Gray

        if ($totalMemoryGB -ge 4) {
            Write-Host "SUCCESS: System has sufficient memory" -ForegroundColor Green
        } elseif ($totalMemoryGB -ge 2) {
            Write-Host "WARNING: System memory is low, but can run basic services" -ForegroundColor Yellow
        } else {
            Write-Host "ERROR: System memory is insufficient (< 2GB)" -ForegroundColor Red
            Write-Host "Please upgrade system memory for better performance" -ForegroundColor Red
        }
    }
    catch {
        Write-Host "ERROR: Failed to get memory information" -ForegroundColor Red
        Write-Host "Error details: $($_.Exception.Message)" -ForegroundColor Red
    }

    # Check 2/6: Disk Space Check
    Write-Host "[Check 2/6] Disk Space Check" -ForegroundColor White
    try {
        # Use Get-WmiObject for disk information
        $diskDrive = Get-WmiObject -Class Win32_LogicalDisk -Filter "DeviceID='C:'" -ErrorAction Stop
        $totalDiskGB = [math]::Round($diskDrive.Size / 1GB, 2)
        $freeDiskGB = [math]::Round($diskDrive.FreeSpace / 1GB, 2)
        $usedDiskGB = $totalDiskGB - $freeDiskGB
        $usagePercent = [math]::Round(($usedDiskGB / $totalDiskGB) * 100, 1)

        Write-Host "Total Disk: $totalDiskGB GB" -ForegroundColor Gray
        Write-Host "Used Disk:  $usedDiskGB GB ($usagePercent%)" -ForegroundColor Gray
        Write-Host "Free Disk:  $freeDiskGB GB" -ForegroundColor Gray

        if ($freeDiskGB -ge 10) {
            Write-Host "SUCCESS: Sufficient disk space available" -ForegroundColor Green
        } elseif ($freeDiskGB -ge 5) {
            Write-Host "WARNING: Limited disk space, monitor usage" -ForegroundColor Yellow
        } else {
            Write-Host "ERROR: Insufficient disk space (< 5GB)" -ForegroundColor Red
            Write-Host "Please free up disk space" -ForegroundColor Red
        }
    }
    catch {
        Write-Host "ERROR: Failed to get disk information" -ForegroundColor Red
        Write-Host "Error details: $($_.Exception.Message)" -ForegroundColor Red
    }

    # Check 3/6: Docker installation status
    Write-Host "[Check 3/6] Docker installation status" -ForegroundColor White
    if (Test-Command "docker") {
        try {
            $dockerVersion = docker --version 2>&1
            if ($LASTEXITCODE -eq 0) {
                Write-Host "SUCCESS: Docker is installed and working" -ForegroundColor Green
                Write-Host "  Version: $dockerVersion" -ForegroundColor Gray
            } else {
                throw "Docker command failed"
            }
        }
        catch {
            Write-Host "ERROR: Docker is not installed or not started" -ForegroundColor Red
            Write-Host "Please install and start Docker Desktop first" -ForegroundColor Red
            Write-Host "Docker Desktop download: https://www.docker.com/products/docker-desktop" -ForegroundColor Yellow
            Read-Host "Press Enter to exit"
            exit 1
        }
    } else {
        Write-Host "ERROR: Docker is not installed or not started" -ForegroundColor Red
        Write-Host "Please install and start Docker Desktop first" -ForegroundColor Red
        Write-Host "Docker Desktop download: https://www.docker.com/products/docker-desktop" -ForegroundColor Yellow
        Read-Host "Press Enter to exit"
        exit 1
    }

    # Check 4/6: Docker Desktop running status
    Write-Host "[Check 4/6] Docker Desktop running status" -ForegroundColor White
    try {
        $dockerInfo = docker info 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "SUCCESS: Docker Desktop is running" -ForegroundColor Green
        } else {
            throw "Docker info failed"
        }
    }
    catch {
        Write-Host "ERROR: Docker Desktop is not running" -ForegroundColor Red
        Write-Host "Please start Docker Desktop" -ForegroundColor Red
        Read-Host "Press Enter to exit"
        exit 1
    }

    # Check 5/6: Docker Compose availability
    Write-Host "[Check 5/6] Docker Compose availability" -ForegroundColor White
    try {
        $composeVersion = docker compose version 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "SUCCESS: Docker Compose is available" -ForegroundColor Green
            Write-Host "  Version: $composeVersion" -ForegroundColor Gray
        } else {
            throw "Docker Compose command failed"
        }
    }
    catch {
        Write-Host "ERROR: Docker Compose is not available" -ForegroundColor Red
        Write-Host "Please ensure Docker Compose is installed" -ForegroundColor Red
        Read-Host "Press Enter to exit"
        exit 1
    }

    # Check 6/6: Key port check
    Write-Host "[Check 6/6] Key port check" -ForegroundColor White
    $ports = @(3306, 6379, 18848, 9876, 10909, 10911, 18080, 28080, 28081, 28082, 28083)
    $conflicts = 0

    foreach ($port in $ports) {
        if (Test-PortInUse -Port $port) {
            Write-Host "WARNING: Port $port is occupied" -ForegroundColor Yellow
            $conflicts++
        } else {
            Write-Host "SUCCESS: Port $port is available" -ForegroundColor Green
        }
    }

    Write-Host ""
    Write-Host "==========================================" -ForegroundColor Cyan
    Write-Host "           Environment Check Summary" -ForegroundColor Cyan
    Write-Host "==========================================" -ForegroundColor Cyan

    if ($conflicts -eq 0) {
        Write-Host "Environment check passed! Ready to deploy project" -ForegroundColor Green
    } else {
        Write-Host "Environment basically meets requirements, but has $conflicts port conflicts" -ForegroundColor Yellow
        Write-Host "Suggest closing programs occupying ports or modify configuration" -ForegroundColor Yellow
    }
    Write-Host ""
}

if ($mode -eq "check") {
    Write-Host "==========================================" -ForegroundColor Cyan
    Write-Host "Operation Complete!" -ForegroundColor Cyan
    Write-Host "==========================================" -ForegroundColor Cyan
    Read-Host "Press Enter to exit"
    exit 0
}

# Phase 2: Initialization
if ($mode -eq "all" -or $mode -eq "init") {
    Write-Host "==========================================" -ForegroundColor Yellow
    Write-Host "[Phase 2] Network and Directory Initialization" -ForegroundColor Yellow
    Write-Host "==========================================" -ForegroundColor Yellow

    # Create Docker network
    Write-Host "Creating Docker network..." -ForegroundColor White
    try {
        $networkExists = docker network inspect ecommerce-network 2>&1
        if ($LASTEXITCODE -ne 0) {
            Write-Host "Creating custom network: ecommerce-network" -ForegroundColor White
            $networkResult = docker network create --driver bridge --subnet=172.20.0.0/16 --gateway=172.20.0.1 ecommerce-network 2>&1
            if ($LASTEXITCODE -eq 0) {
                Write-Host "SUCCESS: Docker network created successfully" -ForegroundColor Green
            } else {
                Write-Host "ERROR: Docker network creation failed" -ForegroundColor Red
                Write-Host "Error details: $networkResult" -ForegroundColor Red
                Read-Host "Press Enter to exit"
                exit 1
            }
        } else {
            Write-Host "SUCCESS: Docker network already exists" -ForegroundColor Green
        }
    }
    catch {
        Write-Host "ERROR: Failed to check/create Docker network" -ForegroundColor Red
        Write-Host "Error details: $($_.Exception.Message)" -ForegroundColor Red
        Read-Host "Press Enter to exit"
        exit 1
    }

    # Create directory structure
    Write-Host ""
    Write-Host "Creating local directory structure..." -ForegroundColor White

    # Main directories
    $mainDirs = @("data", "config", "logs")
    foreach ($dir in $mainDirs) {
        if (-not (Test-Path $dir)) {
            Write-Host "Creating main directory: $dir" -ForegroundColor White
            try {
                New-Item -ItemType Directory -Path $dir -Force | Out-Null
                if (Test-Path $dir) {
                    Write-Host "SUCCESS: Created $dir" -ForegroundColor Green
                } else {
                    Write-Host "ERROR: Failed to create $dir" -ForegroundColor Red
                }
            }
            catch {
                Write-Host "ERROR: Failed to create $dir - $($_.Exception.Message)" -ForegroundColor Red
            }
        } else {
            Write-Host "INFO: Directory $dir already exists" -ForegroundColor Gray
        }
    }

    # Create data subdirectories
    Write-Host ""
    Write-Host "Creating data subdirectories..." -ForegroundColor White
    $dataDirs = @("mysql", "redis", "nacos", "rocketmq", "user-service", "product-service", "trade-service", "api-gateway")
    foreach ($dir in $dataDirs) {
        $dirPath = Join-Path "data" $dir
        if (-not (Test-Path $dirPath)) {
            Write-Host "Creating data directory: data\$dir" -ForegroundColor White
            try {
                New-Item -ItemType Directory -Path $dirPath -Force | Out-Null
                if (Test-Path $dirPath) {
                    Write-Host "SUCCESS: Created data\$dir" -ForegroundColor Green
                } else {
                    Write-Host "ERROR: Failed to create data\$dir" -ForegroundColor Red
                }
            }
            catch {
                Write-Host "ERROR: Failed to create data\$dir - $($_.Exception.Message)" -ForegroundColor Red
            }
        } else {
            Write-Host "INFO: Data directory data\$dir already exists" -ForegroundColor Gray
        }
    }

    # Create config subdirectories
    Write-Host ""
    Write-Host "Creating config subdirectories..." -ForegroundColor White
    $configDirs = @("nginx", "mysql", "redis", "nacos", "rocketmq", "user-service", "product-service", "trade-service", "api-gateway")
    foreach ($dir in $configDirs) {
        $dirPath = Join-Path "config" $dir
        if (-not (Test-Path $dirPath)) {
            Write-Host "Creating config directory: config\$dir" -ForegroundColor White
            try {
                New-Item -ItemType Directory -Path $dirPath -Force | Out-Null
                if (Test-Path $dirPath) {
                    Write-Host "SUCCESS: Created config\$dir" -ForegroundColor Green
                } else {
                    Write-Host "ERROR: Failed to create config\$dir" -ForegroundColor Red
                }
            }
            catch {
                Write-Host "ERROR: Failed to create config\$dir - $($_.Exception.Message)" -ForegroundColor Red
            }
        } else {
            Write-Host "INFO: Config directory config\$dir already exists" -ForegroundColor Gray
        }
    }

    # Create logs subdirectories
    Write-Host ""
    Write-Host "Creating logs subdirectories..." -ForegroundColor White
    $logsDirs = @("infra", "mysql", "redis", "nacos", "rocketmq", "user-service", "product-service", "trade-service", "api-gateway")
    foreach ($dir in $logsDirs) {
        $dirPath = Join-Path "logs" $dir
        if (-not (Test-Path $dirPath)) {
            Write-Host "Creating logs directory: logs\$dir" -ForegroundColor White
            try {
                New-Item -ItemType Directory -Path $dirPath -Force | Out-Null
                if (Test-Path $dirPath) {
                    Write-Host "SUCCESS: Created logs\$dir" -ForegroundColor Green
                } else {
                    Write-Host "ERROR: Failed to create logs\$dir" -ForegroundColor Red
                }
            }
            catch {
                Write-Host "ERROR: Failed to create logs\$dir - $($_.Exception.Message)" -ForegroundColor Red
            }
        } else {
            Write-Host "INFO: Logs directory logs\$dir already exists" -ForegroundColor Gray
        }
    }

    # Set directory permissions (optional, may require admin rights)
    Write-Host ""
    Write-Host "Setting directory permissions..." -ForegroundColor White
    foreach ($dir in $mainDirs) {
        if (Test-Path $dir) {
            Write-Host "Setting directory permissions: $dir" -ForegroundColor White
            try {
                # Try to set permissions (this may fail without admin rights)
                $acl = Get-Acl $dir
                $accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule(
                    "Everyone", "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow"
                )
                $acl.SetAccessRule($accessRule)
                Set-Acl $dir $acl
                Write-Host "SUCCESS: Permissions set for $dir" -ForegroundColor Green
            }
            catch {
                Write-Host "WARNING: Permission setting skipped for $dir (may need admin rights)" -ForegroundColor Yellow
            }
        }
    }

    Write-Host ""
    Write-Host "==========================================" -ForegroundColor Cyan
    Write-Host "           Initialization Complete!" -ForegroundColor Cyan
    Write-Host "==========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Created directories:" -ForegroundColor White
    Write-Host "data - Data persistence root directory" -ForegroundColor Gray
    Write-Host "  mysql, redis, nacos, rocketmq - Basic service data" -ForegroundColor Gray
    Write-Host "config - Configuration file root directory" -ForegroundColor Gray
    Write-Host "  nginx, mysql, redis, nacos, rocketmq - Basic service configs" -ForegroundColor Gray
    Write-Host "  user-service, product-service, trade-service, api-gateway - Business service configs" -ForegroundColor Gray
    Write-Host "logs - Log file root directory" -ForegroundColor Gray
    Write-Host "  Log subdirectories for each service" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Network information:" -ForegroundColor White
    Write-Host "Network name: ecommerce-network" -ForegroundColor Gray
    Write-Host "Subnet range: 172.20.0.0/16" -ForegroundColor Gray
    Write-Host ""
}

# Display completion information
if ($mode -eq "all") {
    Write-Host "Next steps you can take:" -ForegroundColor White
    Write-Host "1. Run .\start-all.bat to start all services" -ForegroundColor Gray
    Write-Host "2. Run .\build-images.bat to build application images" -ForegroundColor Gray
    Write-Host "3. Run .\export-images.bat to export images" -ForegroundColor Gray
    Write-Host ""
}

Write-Host "==========================================" -ForegroundColor Green
Write-Host "Operation Complete!" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green

Read-Host "Press Enter to exit"