# ===================================
# E-commerce Microservices Project - Stop All Services Script
# Version: v2.0 (PowerShell Enhanced Version)
# ===================================

param(
    [Parameter(Position=0)]
    [ValidateSet("all", "infra", "apps", "mysql", "redis", "nacos", "rocketmq", "api-gateway", "user-service", "product-service", "trade-service")]
    [string]$target = "all",
    [switch]$force,
    [switch]$statusOnly,
    [switch]$Help,
    [switch]$h
)

# Display header
Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "    E-commerce Microservices - Stop Services" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# Handle help parameter
if ($Help -or $h) {
    Write-Host "Usage: .\stop-all.ps1 [target] [options]"
    Write-Host ""
    Write-Host "Targets:"
    Write-Host "  all                  Stop all services (default)"
    Write-Host "  infra                Stop infrastructure services only"
    Write-Host "  apps                 Stop application services only"
    Write-Host "  mysql                Stop MySQL service only"
    Write-Host "  redis                Stop Redis service only"
    Write-Host "  nacos                Stop Nacos service only"
    Write-Host "  rocketmq             Stop RocketMQ services only"
    Write-Host "  api-gateway          Stop API Gateway only"
    Write-Host "  user-service         Stop User Service only"
    Write-Host "  product-service      Stop Product Service only"
    Write-Host "  trade-service        Stop Trade Service only"
    Write-Host ""
    Write-Host "Options:"
    Write-Host "  -force               Skip confirmation prompt"
    Write-Host "  -statusOnly          Show status only, don't stop services"
    Write-Host "  -help, -h            Show this help message"
    Write-Host ""
    Write-Host "Examples:"
    Write-Host "  .\stop-all.ps1            # Stop all services"
    Write-Host "  .\stop-all.ps1 infra      # Stop infrastructure only"
    Write-Host "  .\stop-all.ps1 mysql      # Stop MySQL only"
    Write-Host "  .\stop-all.ps1 apps -force"
    Write-Host ""
    Read-Host "Press Enter to exit"
    exit 0
}

Write-Host "Target: $target"
if ($force) { Write-Host "Options: Skip confirmation" }
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

# Function to display service status
function Show-ServiceStatus {
    param($title = "Current Service Status")

    Write-Host "==========================================" -ForegroundColor Cyan
    Write-Host "            $title" -ForegroundColor Cyan
    Write-Host "==========================================" -ForegroundColor Cyan
    Write-Host ""

    # Fix encoding issue with docker ps output
    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
    $dockerOutput = docker ps --format "table {{.Names}}`t{{.Status}}`t{{.Ports}}" 2>$null
    if ($dockerOutput) {
        $formattedOutput = $dockerOutput | Where-Object { $_ -notmatch "CONTAINER" }
        if ($formattedOutput) {
            $formattedOutput
            $containerCount = ($formattedOutput | Measure-Object).Count
            Write-Host ""
            Write-Host "Total running containers: $containerCount" -ForegroundColor Gray
        } else {
            Write-Host "No containers are currently running." -ForegroundColor Yellow
        }
    } else {
        Write-Host "No containers are currently running." -ForegroundColor Yellow
    }
    Write-Host ""
}

# Set path variables
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$ProjectRoot = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $ScriptDir)))
$ComposeDir = Join-Path $ProjectRoot "deploy\docker-compose"

# Check Docker environment
Write-Host "[Pre-check] Docker environment status..." -ForegroundColor White
if (-not (Test-Command "docker")) {
    Write-Host "ERROR: Docker is not installed or not started" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host "SUCCESS: Docker environment is normal" -ForegroundColor Green
Write-Host ""

# Switch to compose directory
Set-Location $ComposeDir

# Status only mode
if ($statusOnly) {
    Show-ServiceStatus
    Read-Host "Press Enter to exit"
    exit 0
}

# Display current running status
Show-ServiceStatus "Currently Running Services"

# Confirmation prompt (skip if force flag is used)
if (-not $force) {
    $choice = Read-Host "Confirm stop services for target '$target'? (Y/N)"
    if ($choice -ne "Y" -and $choice -ne "y") {
        Write-Host "Operation cancelled" -ForegroundColor Yellow
        Read-Host "Press Enter to exit"
        exit 0
    }
}

# Function to stop services
function Stop-Services {
    param($composeFile, $serviceName, $servicesToStop)

    Write-Host "==========================================" -ForegroundColor Yellow
    Write-Host "Stopping $serviceName" -ForegroundColor Yellow
    Write-Host "==========================================" -ForegroundColor Yellow

    $composeCommand = "docker compose -f $composeFile down"
    if ($servicesToStop) {
        $composeCommand += " " + ($servicesToStop -join " ")
    }

    Write-Host "Command: $composeCommand" -ForegroundColor Gray
    Invoke-Expression $composeCommand

    if ($LASTEXITCODE -eq 0) {
        Write-Host "SUCCESS: $serviceName stopped" -ForegroundColor Green
        return $true
    } else {
        Write-Host "WARNING: Warning occurred while stopping $serviceName" -ForegroundColor Yellow
        return $false
    }
}

# Determine what to stop
switch ($target) {
    "all" {
        # Stop application services first
        Stop-Services "docker-compose.apps.yml" "Application Services"
        Write-Host ""

        # Then stop infrastructure services
        Stop-Services "docker-compose.infra.yml" "Infrastructure Services"
    }

    "infra" {
        Write-Host "==========================================" -ForegroundColor Yellow
        Write-Host "Stopping Infrastructure Services Only" -ForegroundColor Yellow
        Write-Host "==========================================" -ForegroundColor Yellow

        Stop-Services "docker-compose.infra.yml" "Infrastructure Services"
    }

    "apps" {
        Write-Host "==========================================" -ForegroundColor Yellow
        Write-Host "Stopping Application Services Only" -ForegroundColor Yellow
        Write-Host "==========================================" -ForegroundColor Yellow

        Stop-Services "docker-compose.apps.yml" "Application Services"
    }

    default {
        # Single service
        $group = Get-ServiceGroup $target
        if ($group -eq "infra") {
            Stop-Services "docker-compose.infra.yml" $target @($target)
        } elseif ($group -eq "apps") {
            Stop-Services "docker-compose.apps.yml" $target @($target)
        } else {
            Write-Host "ERROR: Unknown service '$target'" -ForegroundColor Red
            Read-Host "Press Enter to exit"
            exit 1
        }
    }
}

Write-Host ""

# Check stop results
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "              Stop Complete!" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

# Get remaining running containers
$runningContainers = docker ps -q 2>$null
$containerCount = 0
if ($runningContainers) {
    $containerCount = ($runningContainers | Measure-Object).Count
}

if ($containerCount -gt 0) {
    Write-Host "WARNING: There are still $containerCount containers running" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Currently running containers:" -ForegroundColor White
    Show-ServiceStatus "Remaining Running Containers"

    Write-Host "INFO: To stop all containers, use:" -ForegroundColor Gray
    Write-Host "docker stop `$`(docker ps -q`)" -ForegroundColor Gray
} else {
    Write-Host "SUCCESS: All project-related services have been stopped" -ForegroundColor Green
}

Write-Host ""
Write-Host "Next steps you can take:" -ForegroundColor White
Write-Host "- .\start-all.ps1            - Restart all services"
Write-Host "- .\start-all.ps1 infra      - Start infrastructure only"
Write-Host "- .\start-all.ps1 apps       - Start application services only"
Write-Host "- .\start-all.ps1 mysql      - Start single service"
Write-Host "- .\stop-all.ps1 -statusOnly  - Check service status"
Write-Host "==========================================" -ForegroundColor Green

Read-Host "Press Enter to exit"