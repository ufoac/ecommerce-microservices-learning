# ===================================
# E-commerce Microservices Project - Start All Services Script
# Version: v2.0 (PowerShell Enhanced Version)
# ===================================

param(
    [Parameter(Position=0)]
    [ValidateSet("all", "infra", "apps", "mysql", "redis", "nacos", "rocketmq", "api-gateway", "user-service", "product-service", "trade-service")]
    [string]$target = "all",
    [switch]$noWait,
    [switch]$force,
    [switch]$statusOnly,
    [switch]$Help,
    [switch]$h
)

# Display header
Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "   E-commerce Microservices - Start Services" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# Handle help parameter
if ($Help -or $h) {
    Write-Host "Usage: .\start-all.ps1 [target] [options]"
    Write-Host ""
    Write-Host "Targets:"
    Write-Host "  all                  Start all services (default)"
    Write-Host "  infra                Start infrastructure services only"
    Write-Host "  apps                 Start application services only"
    Write-Host "  mysql                Start MySQL service only"
    Write-Host "  redis                Start Redis service only"
    Write-Host "  nacos                Start Nacos service only"
    Write-Host "  rocketmq             Start RocketMQ services only"
    Write-Host "  api-gateway          Start API Gateway only"
    Write-Host "  user-service         Start User Service only"
    Write-Host "  product-service      Start Product Service only"
    Write-Host "  trade-service        Start Trade Service only"
    Write-Host ""
    Write-Host "Options:"
    Write-Host "  -noWait              Skip health check waiting"
    Write-Host "  -force               Force recreate containers"
    Write-Host "  -statusOnly          Show status only, don't start"
    Write-Host "  -help, -h            Show this help message"
    Write-Host ""
    Write-Host "Examples:"
    Write-Host "  .\start-all.ps1            # Start all services"
    Write-Host "  .\start-all.ps1 infra      # Start infrastructure only"
    Write-Host "  .\start-all.ps1 mysql      # Start MySQL only"
    Write-Host "  .\start-all.ps1 apps -force -noWait"
    Write-Host ""
    Read-Host "Press Enter to exit"
    exit 0
}

Write-Host "Target: $target"
if ($noWait) { Write-Host "Options: Skip health check waiting" }
if ($force) { Write-Host "Options: Force recreate containers" }
if ($statusOnly) { Write-Host "Options: Show status only" }
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

# Function to check service health
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
        Write-Host "Waiting for $serviceName... ($waitCount/$maxWait seconds)" -ForegroundColor Yellow
    }

    return $false
}

# Function to get service group
function Get-ServiceGroup {
    param($service)

    $infraServices = @("mysql", "redis", "nacos", "rocketmq")
    $appServices = @("api-gateway", "user-service", "product-service", "trade-service")

    if ($infraServices -contains $service) {
        return "infra"
    } elseif ($appServices -contains $service) {
        return "apps"
    }
    return "unknown"
}

# Set path variables
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$ProjectRoot = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $ScriptDir)))
$ComposeDir = Join-Path $ProjectRoot "deploy\docker-compose"

# Check Docker environment
Write-Host "[Pre-check] Docker environment status..." -ForegroundColor White
if (-not (Test-Command "docker")) {
    Write-Host "ERROR: Docker is not installed or not started" -ForegroundColor Red
    Write-Host "Please install and start Docker Desktop first" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

try {
    $dockerInfo = docker info 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "Docker info failed"
    }
    Write-Host "SUCCESS: Docker environment is normal" -ForegroundColor Green
}
catch {
    Write-Host "ERROR: Docker is not running" -ForegroundColor Red
    Write-Host "Please start Docker Desktop" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

# Check if network exists
Write-Host "[Pre-check] Docker network status..." -ForegroundColor White
$networkExists = docker network inspect ecommerce-network 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "WARNING: Docker network 'ecommerce-network' does not exist" -ForegroundColor Yellow
    Write-Host "Suggest running init.ps1 first" -ForegroundColor Yellow
    $choice = Read-Host "Create network now? (Y/N)"
    if ($choice -eq "Y" -or $choice -eq "y") {
        Write-Host "Creating network..." -ForegroundColor White
        $networkResult = docker network create --driver bridge --subnet=172.20.0.0/16 --gateway=172.20.0.1 ecommerce-network 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "SUCCESS: Network created successfully" -ForegroundColor Green
        } else {
            Write-Host "ERROR: Network creation failed, cannot continue" -ForegroundColor Red
            Write-Host "Error details: $networkResult" -ForegroundColor Red
            Read-Host "Press Enter to exit"
            exit 1
        }
    }
} else {
    Write-Host "SUCCESS: Docker network is normal" -ForegroundColor Green
}
Write-Host ""

# Switch to compose directory
Set-Location $ComposeDir

# Function to start services
function Start-Services {
    param($composeFile, $serviceName, $servicesToStart)

    Write-Host "Starting $serviceName..." -ForegroundColor White

    $composeCommand = "docker compose -f $composeFile up -d"
    if ($force) {
        $composeCommand += " --force-recreate"
    }

    if ($servicesToStart) {
        $composeCommand += " " + ($servicesToStart -join " ")
    }

    Write-Host "Command: $composeCommand" -ForegroundColor Gray
    Invoke-Expression $composeCommand

    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: $serviceName failed to start" -ForegroundColor Red
        return $false
    }

    Write-Host "SUCCESS: $serviceName start command executed" -ForegroundColor Green
    return $true
}

# Status only mode
if ($statusOnly) {
    Write-Host "==========================================" -ForegroundColor Cyan
    Write-Host "            Current Service Status" -ForegroundColor Cyan
    Write-Host "==========================================" -ForegroundColor Cyan
    Write-Host ""
    # Fix encoding issue with docker ps output
    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
    $dockerOutput = docker ps --format "table {{.Names}}`t{{.Status}}`t{{.Ports}}" 2>$null
    if ($dockerOutput) {
        $dockerOutput | Where-Object { $_ -notmatch "CONTAINER" }
    }
    Write-Host ""
    Read-Host "Press Enter to exit"
    exit 0
}

# Determine what to start
$startedInfra = $false
$startedApps = $false

switch ($target) {
    "all" {
        # Start infrastructure
        Write-Host "==========================================" -ForegroundColor Yellow
        Write-Host "[Phase 1/2] Starting Infrastructure Services" -ForegroundColor Yellow
        Write-Host "==========================================" -ForegroundColor Yellow
        Write-Host "Starting: MySQL, Redis, Nacos, RocketMQ" -ForegroundColor White
        Write-Host ""

        if (Start-Services "docker-compose.infra.yml" "Infrastructure Services") {
            $startedInfra = $true

            if (-not $noWait) {
                Write-Host "Waiting for infrastructure services health check..." -ForegroundColor White

                $infraServices = @("mysql", "redis", "nacos", "rocketmq-nameserver", "rocketmq-broker")
                $healthyCount = 0

                foreach ($service in $infraServices) {
                    Write-Host "Checking $service..." -ForegroundColor Gray
                    if (Test-ServiceHealth $service 60) {
                        $healthyCount++
                        Write-Host "SUCCESS: $service is healthy" -ForegroundColor Green
                    } else {
                        Write-Host "WARNING: $service health check timeout" -ForegroundColor Yellow
                    }
                }

                Write-Host "Infrastructure services ready: $healthyCount/$($infraServices.Count)" -ForegroundColor Cyan
            }
        }
        Write-Host ""

        # Start applications
        Write-Host "==========================================" -ForegroundColor Yellow
        Write-Host "[Phase 2/2] Starting Application Services" -ForegroundColor Yellow
        Write-Host "==========================================" -ForegroundColor Yellow
        Write-Host "Starting: API Gateway, User Service, Product Service, Trade Service" -ForegroundColor White
        Write-Host ""

        if (Start-Services "docker-compose.apps.yml" "Application Services") {
            $startedApps = $true

            if (-not $noWait) {
                Write-Host "Waiting for application services health check..." -ForegroundColor White

                $appServices = @("api-gateway", "user-service", "product-service", "trade-service")
                $healthyCount = 0

                foreach ($service in $appServices) {
                    Write-Host "Checking $service..." -ForegroundColor Gray
                    if (Test-ServiceHealth $service 45) {
                        $healthyCount++
                        Write-Host "SUCCESS: $service is healthy" -ForegroundColor Green
                    } else {
                        Write-Host "WARNING: $service health check timeout" -ForegroundColor Yellow
                    }
                }

                Write-Host "Application services ready: $healthyCount/$($appServices.Count)" -ForegroundColor Cyan
            }
        }
    }

    "infra" {
        Write-Host "==========================================" -ForegroundColor Yellow
        Write-Host "Starting Infrastructure Services Only" -ForegroundColor Yellow
        Write-Host "==========================================" -ForegroundColor Yellow

        $startedInfra = Start-Services "docker-compose.infra.yml" "Infrastructure Services"

        if ($startedInfra -and -not $NoWait) {
            Write-Host "Waiting for infrastructure services health check..." -ForegroundColor White
            $infraServices = @("mysql", "redis", "nacos", "rocketmq-nameserver", "rocketmq-broker")
            foreach ($service in $infraServices) {
                Test-ServiceHealth $service 60 | Out-Null
            }
        }
    }

    "apps" {
        Write-Host "==========================================" -ForegroundColor Yellow
        Write-Host "Starting Application Services Only" -ForegroundColor Yellow
        Write-Host "==========================================" -ForegroundColor Yellow

        $startedApps = Start-Services "docker-compose.apps.yml" "Application Services"

        if ($startedApps -and -not $NoWait) {
            Write-Host "Waiting for application services health check..." -ForegroundColor White
            $appServices = @("api-gateway", "user-service", "product-service", "trade-service")
            foreach ($service in $appServices) {
                Test-ServiceHealth $service 45 | Out-Null
            }
        }
    }

    default {
        # Single service
        $group = Get-ServiceGroup $target
        if ($group -eq "infra") {
            $startedInfra = Start-Services "docker-compose.infra.yml" $target @($target)
            if ($startedInfra -and -not $NoWait) {
                Test-ServiceHealth $target 60 | Out-Null
            }
        } elseif ($group -eq "apps") {
            $startedApps = Start-Services "docker-compose.apps.yml" $target @($target)
            if ($startedApps -and -not $NoWait) {
                Test-ServiceHealth $target 45 | Out-Null
            }
        } else {
            Write-Host "ERROR: Unknown service '$target'" -ForegroundColor Red
            Read-Host "Press Enter to exit"
            exit 1
        }
    }
}

# Display final status
Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "              Startup Complete!" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

Write-Host "Service Status Overview:" -ForegroundColor White
Write-Host ""
# Fix encoding issue with docker ps output
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$dockerOutput = docker ps --format "table {{.Names}}`t{{.Status}}`t{{.Ports}}" 2>$null
if ($dockerOutput) {
    $dockerOutput | Where-Object { $_ -notmatch "CONTAINER" }
}

Write-Host ""
Write-Host "Access URLs:" -ForegroundColor White
Write-Host ""
Write-Host "Infrastructure Services:" -ForegroundColor Gray
Write-Host "- MySQL Database:     localhost:3306"
Write-Host "- Redis Cache:        localhost:6379"
Write-Host "- Nacos Console:      http://localhost:18848/nacos (nacos/nacos)"
Write-Host "- RocketMQ Console:   http://localhost:18080"
Write-Host ""
Write-Host "Application Services:" -ForegroundColor Gray
Write-Host "- API Gateway:        http://localhost:28080"
Write-Host "- User Service:       http://localhost:28081"
Write-Host "- Product Service:    http://localhost:28082"
Write-Host "- Trade Service:      http://localhost:28083"
Write-Host ""
Write-Host "Health Check Endpoints:" -ForegroundColor Gray
Write-Host "- API Gateway:        http://localhost:28080/actuator/health"
Write-Host "- User Service:       http://localhost:28081/actuator/health"
Write-Host "- Product Service:    http://localhost:28082/actuator/health"
Write-Host "- Trade Service:      http://localhost:28083/actuator/health"
Write-Host ""

Write-Host "Common Operations:" -ForegroundColor White
Write-Host "- .\start-all.ps1 --status-only  - View detailed service status"
Write-Host "- .\stop-all.ps1              - Stop all services"
Write-Host "- .\start-all.ps1 mysql       - Start single service"
Write-Host "- .\start-all.ps1 apps --force - Force restart application services"
Write-Host "==========================================" -ForegroundColor Green

Read-Host "Press Enter to exit"