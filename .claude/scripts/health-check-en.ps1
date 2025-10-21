# Windows Microservices Health Check Script v1.0
# For e-commerce project testing

param(
    [string]$service = "",
    [switch]$quiet = $false,
    [switch]$help = $false
)

if ($help) {
    Write-Host "=== Microservices Health Check ===" -ForegroundColor Green
    Write-Host "Usage: .\health-check-en.ps1 [options]"
    Write-Host ""
    Write-Host "Options:"
    Write-Host "  -service <name>    Check specific service (gateway/user/product/trade/nacos/all)"
    Write-Host "  -quiet             Quiet mode, show results only"
    Write-Host "  -help              Show this help"
    exit 0
}

$services = @{
    "gateway" = @{ "port" = 28080; "name" = "API Gateway"; "path" = "/actuator/health" }
    "user" = @{ "port" = 28081; "name" = "User Service"; "path" = "/actuator/health" }
    "product" = @{ "port" = 28082; "name" = "Product Service"; "path" = "/actuator/health" }
    "trade" = @{ "port" = 28083; "name" = "Trade Service"; "path" = "/actuator/health" }
    "nacos" = @{ "port" = 18848; "name" = "Nacos"; "path" = "/nacos" }
}

function Write-Result {
    param([string]$Message, [string]$Color = "White")
    if (-not $quiet) {
        Write-Host $Message -ForegroundColor $Color
    }
}

function Test-Service {
    param([string]$ServiceKey)
    $svc = $services[$ServiceKey]
    $url = "http://localhost:$($svc.port)$($svc.path)"

    try {
        $response = Invoke-RestMethod -Uri $url -Method GET -TimeoutSec 10
        return @{
            "Service" = $svc.name
            "Port" = $svc.port
            "Status" = "HEALTHY"
            "Color" = "Green"
        }
    }
    catch {
        return @{
            "Service" = $svc.name
            "Port" = $svc.port
            "Status" = "FAILED"
            "Color" = "Red"
            "Error" = $_.Exception.Message
        }
    }
}

function Main {
    Write-Result "=== E-commerce Microservices Health Check ===" "Green"
    Write-Result "Time: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" "Gray"

    $servicesToCheck = @()
    if ($service -eq "" -or $service -eq "all") {
        $servicesToCheck = $services.Keys
    } elseif ($services.ContainsKey($service)) {
        $servicesToCheck = @($service)
    } else {
        Write-Result "ERROR: Unknown service: $service" "Red"
        exit 1
    }

    Write-Result "`n=== Service Health Check ===" "Cyan"
    $results = @()
    $healthyCount = 0

    foreach ($svcKey in $servicesToCheck) {
        $result = Test-Service $svcKey
        $results += $result
        Write-Result "$($result.Service) (port:$($result.Port)): $($result.Status)" $result.Color
        if ($result.Status -eq "HEALTHY") { $healthyCount++ }
    }

    Write-Result "`n=== Results Summary ===" "Cyan"
    Write-Result "Healthy services: $healthyCount/$($results.Count)" -ForegroundColor $(if ($healthyCount -eq $results.Count) { "Green" } else { "Yellow" })

    if ($healthyCount -eq $results.Count) {
        Write-Result "All services are running normally!" "Green"
        exit 0
    } else {
        Write-Result "Some services are not healthy" "Yellow"
        exit 1
    }
}

Main