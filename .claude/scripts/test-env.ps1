# 简单环境测试脚本
param([switch]$help = $false)

if ($help) {
    Write-Host "Usage: .\test-env.ps1" -ForegroundColor Green
    exit 0
}

Write-Host "=== Environment Test ===" -ForegroundColor Green
Write-Host "Time: $(Get-Date)" -ForegroundColor Gray

# Test Docker
try {
    $dockerVersion = & docker --version 2>&1
    Write-Host "Docker: OK - $dockerVersion" -ForegroundColor Green
} catch {
    Write-Host "Docker: FAILED" -ForegroundColor Red
}

# Test network
try {
    $network = docker network ls | findstr ecommerce-network
    if ($network) {
        Write-Host "Docker Network: OK" -ForegroundColor Green
    } else {
        Write-Host "Docker Network: NOT FOUND" -ForegroundColor Yellow
    }
} catch {
    Write-Host "Docker Network: FAILED" -ForegroundColor Red
}

# Test images
try {
    $images = docker images | findstr ecommerce
    $imageCount = ($images | Measure-Object).Count
    Write-Host "Docker Images: $imageCount found" -ForegroundColor $(if ($imageCount -ge 4) { "Green" } else { "Yellow" })
} catch {
    Write-Host "Docker Images: FAILED" -ForegroundColor Red
}

Write-Host "=== Test Complete ===" -ForegroundColor Green