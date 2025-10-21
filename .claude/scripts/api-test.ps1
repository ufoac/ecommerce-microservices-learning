# API Test Script for E-commerce Microservices
# Version: 2.0 (English version)

param(
    [string]$service = "all",
    [string]$url = "http://localhost:28080",
    [switch]$help = $false
)

if ($help) {
    Write-Host "=== API Test Script ===" -ForegroundColor Green
    Write-Host "Usage: .\api-test.ps1 [options]"
    Write-Host ""
    Write-Host "Options:"
    Write-Host "  -service <type>   Test type (auth/user/product/trade/all)"
    Write-Host "  -url <gateway>    Gateway URL (default: http://localhost:28080)"
    Write-Host "  -help             Show this help"
    Write-Host ""
    Write-Host "Examples:"
    Write-Host "  .\api-test.ps1                    # Test all APIs"
    Write-Host "  .\api-test.ps1 -service auth      # Test auth APIs only"
    Write-Host "  .\api-test.ps1 -url http://localhost:9090"
    exit 0
}

function Write-TestResult {
    param([string]$TestName, [string]$Status, [string]$Details = "", [string]$Color = "White")
    Write-Host "[$Status] $TestName" -ForegroundColor $Color
    if ($Details) {
        Write-Host "    $Details" -ForegroundColor Gray
    }
}

function Test-ApiCall {
    param(
        [string]$Method,
        [string]$Path,
        [hashtable]$Headers = @{},
        [string]$Body = "",
        [string]$TestName
    )

    $fullUrl = "$url$Path"
    $headersObj = @{}
    foreach ($key in $Headers.Keys) {
        $headersObj[$key] = $Headers[$key]
    }

    try {
        $params = @{
            Uri = $fullUrl
            Method = $Method
            Headers = $headersObj
            TimeoutSec = 30
        }

        if ($Body) {
            $params.Body = $Body
            $headersObj["Content-Type"] = "application/json"
        }

        $response = Invoke-RestMethod @params
        Write-TestResult -TestName $TestName -Status "PASS" -Details "Response received" -Color "Green"
        return @{
            "Success" = $true
            "Response" = $response
            "TestName" = $TestName
        }
    }
    catch {
        $errorMsg = $_.Exception.Message
        Write-TestResult -TestName $TestName -Status "FAIL" -Details $errorMsg -Color "Red"
        return @{
            "Success" = $false
            "Error" = $errorMsg
            "TestName" = $TestName
        }
    }
}

function Test-AuthAPIs {
    Write-Host "`n=== Auth API Tests ===" -ForegroundColor Cyan
    $results = @()

    # Test user registration
    $registerBody = @{
        username = "testuser_$(Get-Random)"
        password = "123456"
        email = "test$(Get-Random)@example.com"
    } | ConvertTo-Json -Depth 3

    $result = Test-ApiCall -Method "POST" -Path "/api/auth/register" -Body $registerBody -TestName "User Registration API"
    $results += $result

    # Test user login
    $loginBody = @{
        username = "testuser"
        password = "123456"
    } | ConvertTo-Json -Depth 3

    $result = Test-ApiCall -Method "POST" -Path "/api/auth/login" -Body $loginBody -TestName "User Login API"
    $results += $result

    return $results
}

function Test-UserAPIs {
    Write-Host "`n=== User Service API Tests ===" -ForegroundColor Cyan
    $results = @()

    $result = Test-ApiCall -Method "GET" -Path "/api/users/profile" -TestName "Get User Profile API"
    $results += $result

    $updateBody = @{
        nickname = "Test User"
        phone = "13800138000"
    } | ConvertTo-Json -Depth 3

    $result = Test-ApiCall -Method "PUT" -Path "/api/users/profile" -Body $updateBody -TestName "Update User Profile API"
    $results += $result

    return $results
}

function Test-ProductAPIs {
    Write-Host "`n=== Product Service API Tests ===" -ForegroundColor Cyan
    $results = @()

    $result = Test-ApiCall -Method "GET" -Path "/api/products?page=1&size=10" -TestName "Get Product List API"
    $results += $result

    $result = Test-ApiCall -Method "GET" -Path "/api/products/1" -TestName "Get Product Detail API"
    $results += $result

    $result = Test-ApiCall -Method "GET" -Path "/api/products/search?keyword=phone" -TestName "Search Product API"
    $results += $result

    return $results
}

function Test-TradeAPIs {
    Write-Host "`n=== Trade Service API Tests ===" -ForegroundColor Cyan
    $results = @()

    $orderBody = @{
        productId = 1
        quantity = 2
        addressId = 1
    } | ConvertTo-Json -Depth 3

    $result = Test-ApiCall -Method "POST" -Path "/api/trades/orders" -Body $orderBody -TestName "Create Order API"
    $results += $result

    $result = Test-ApiCall -Method "GET" -Path "/api/trades/orders?page=1&size=10" -TestName "Get Order List API"
    $results += $result

    $result = Test-ApiCall -Method "GET" -Path "/api/trades/orders/1" -TestName "Get Order Detail API"
    $results += $result

    return $results
}

function Main {
    Write-Host "=== E-commerce Microservices API Test ===" -ForegroundColor Green
    Write-Host "Test Time: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Gray
    Write-Host "Gateway URL: $url" -ForegroundColor Gray
    Write-Host ""

    # Check gateway connectivity
    try {
        $healthCheck = Invoke-RestMethod -Uri "$url/actuator/health" -Method GET -TimeoutSec 10
        Write-Host "Gateway connection: OK" -ForegroundColor Green
    }
    catch {
        Write-Host "Gateway connection failed: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "Please ensure gateway service is running (port: 28080)" -ForegroundColor Yellow
        exit 1
    }

    $allResults = @()

    switch ($service.ToLower()) {
        "auth" { $allResults += Test-AuthAPIs }
        "user" { $allResults += Test-UserAPIs }
        "product" { $allResults += Test-ProductAPIs }
        "trade" { $allResults += Test-TradeAPIs }
        "all" {
            $allResults += Test-AuthAPIs
            $allResults += Test-UserAPIs
            $allResults += Test-ProductAPIs
            $allResults += Test-TradeAPIs
        }
        default {
            Write-Host "ERROR: Unknown test type: $service" -ForegroundColor Red
            Write-Host "Available types: auth, user, product, trade, all" -ForegroundColor Yellow
            exit 1
        }
    }

    # Statistics
    $totalTests = $allResults.Count
    $passedTests = ($allResults | Where-Object { $_.Success }).Count
    $failedTests = $totalTests - $passedTests

    Write-Host "`n=== Test Results Summary ===" -ForegroundColor Cyan
    Write-Host "Total tests: $totalTests" -ForegroundColor White
    Write-Host "Passed: $passedTests" -ForegroundColor Green
    Write-Host "Failed: $failedTests" -ForegroundColor $(if ($failedTests -gt 0) { "Red" } else { "Green" })

    $successRate = if ($totalTests -gt 0) { [math]::Round($passedTests / $totalTests * 100, 2) } else { 0 }
    Write-Host "Success rate: $successRate%" -ForegroundColor $(if ($successRate -eq 100) { "Green" } else { "Yellow" })

    if ($failedTests -gt 0) {
        Write-Host "`nFailed tests:" -ForegroundColor Red
        $allResults | Where-Object { -not $_.Success } | ForEach-Object {
            Write-Host "  - $($_.TestName): $($_.Error)" -ForegroundColor Red
        }
    }

    Write-Host ""
    if ($failedTests -eq 0) {
        Write-Host "All API tests passed!" -ForegroundColor Green
        exit 0
    } else {
        Write-Host "Some API tests failed" -ForegroundColor Yellow
        exit 1
    }
}

Main