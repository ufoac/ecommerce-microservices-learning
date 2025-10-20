# ==========================================
# E-commerce Microservices - Push Images Script
# Version: v2.2 (Parameter Optimization)
# Purpose: Tag and push Docker images to registry
# ==========================================

# 设置UTF-8编码
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# ==========================================
# 参数处理
# ==========================================

$target = ""
$registry = ""
$namespace = ""
$tag = ""
$showHelp = $false

# 解析命令行参数
for ($i = 0; $i -lt $args.Count; $i++) {
    $arg = $args[$i]

    if ($arg -eq "-h" -or $arg -eq "-help") {
        $showHelp = $true
    }
    elseif ($arg.StartsWith("-")) {
        # 跳过未知选项
        $i++
    }
    elseif ([string]::IsNullOrEmpty($target)) {
        $target = $arg
    }
    elseif ([string]::IsNullOrEmpty($registry)) {
        $registry = $arg
    }
    elseif ([string]::IsNullOrEmpty($namespace)) {
        $namespace = $arg
    }
    elseif ([string]::IsNullOrEmpty($tag)) {
        $tag = $arg
    }
}

# ==========================================
# 标准配置区域
# ==========================================

# 项目基础配置
$ProjectConfig = @{
    Name = "ecommerce"
    Version = "2.2"
    Services = @("user-service", "product-service", "trade-service", "api-gateway")
    ImagePrefix = "ecommerce"
    ServiceAliases = @{
        "user" = "user-service"
        "product" = "product-service"
        "trade" = "trade-service"
        "gateway" = "api-gateway"
        "all" = "all"
    }
}

# Docker配置
$DockerConfig = @{
    DefaultRegistry = "registry.cn-hangzhou.aliyuncs.com"
    DefaultNamespace = "ecommerce"
    DefaultTag = "latest"
}

# 推送配置
$PushConfig = @{
    ConnectionTimeout = 3  # seconds
}

# 输出颜色配置
$Colors = @{
    Header = "Cyan"
    Success = "Green"
    Warning = "Yellow"
    Error = "Red"
    Info = "White"
    Gray = "Gray"
}

$Separator = "=========================================="

# ==========================================
# 参数处理
# ==========================================

$TargetService = $target
$TargetRegistry = $registry
$TargetNamespace = $namespace
$TargetTag = $tag
$ShowHelp = $showHelp

# 处理帮助参数
if ($ShowHelp) {
    Show-Help
}

# ==========================================
# 公共函数
# ==========================================

function Show-ScriptHeader {
    Write-Host $Separator
    Write-Host "  E-commerce Microservices - Push Images"
    Write-Host $Separator
    Write-Host ""
}

function Show-Help {
    Write-Host "Push Docker images to registry - Version v2.2" -ForegroundColor $Colors.Header
    Write-Host ""
    Write-Host "Usage:" -ForegroundColor $Colors.Header
    Write-Host "  .\push-images.ps1 [target] [registry] [namespace] [tag] [options]"
    Write-Host ""
    Write-Host "Parameters:" -ForegroundColor $Colors.Header
    Write-Host "  target         Service to push (default: all)"
    Write-Host "  registry       Registry address (default: $($DockerConfig.DefaultRegistry))"
    Write-Host "  namespace      Registry namespace (default: $($DockerConfig.DefaultNamespace))"
    Write-Host "  tag            Image tag (default: $($DockerConfig.DefaultTag))"
    Write-Host ""
    Write-Host "Options:" -ForegroundColor $Colors.Header
    Write-Host "  -h             Show this help"
    Write-Host ""
    Write-Host "Available Services:" -ForegroundColor $Colors.Header
    Write-Host "  all            Push all application services (default)"
    Write-Host "  user           Push user-service only"
    Write-Host "  product        Push product-service only"
    Write-Host "  trade          Push trade-service only"
    Write-Host "  gateway        Push api-gateway only"
    Write-Host "  user,product   Push multiple services (comma-separated)"
    Write-Host ""
    Write-Host "Examples:" -ForegroundColor $Colors.Header
    Write-Host "  .\push-images.ps1                                    # Push all services with defaults"
    Write-Host "  .\push-images.ps1 user                              # Push specific service"
    Write-Host "  .\push-images.ps1 user,product                      # Push multiple services"
    Write-Host "  .\push-images.ps1 all docker.io myproject v1.0.0    # Push all to Docker Hub"
    Write-Host "  .\push-images.ps1 user registry.example.com org dev # Push user service to custom registry"
    Write-Host ""
    Write-Host "Default Configuration:" -ForegroundColor $Colors.Header
    Write-Host "  Registry: $($DockerConfig.DefaultRegistry)"
    Write-Host "  Namespace: $($DockerConfig.DefaultNamespace)"
    Write-Host "  Tag: $($DockerConfig.DefaultTag)"
    Write-Host ""
    Write-Host "Prerequisites:" -ForegroundColor $Colors.Header
    Write-Host "  1. Docker login to target registry"
    Write-Host "  2. Images built with build-images.ps1"
    Write-Host ""
    exit 0
}

function Test-DockerImage {
    param($imageName)
    try {
        $imageExists = docker images --format "table {{.Repository}}:{{.Tag}}" | Where-Object { $_ -match "^${imageName}$" }
        return ($imageExists -eq $imageName)
    }
    catch {
        return $false
    }
}

function Get-ServicesToPush {
    param([string]$ServiceInput)

    if ([string]::IsNullOrEmpty($ServiceInput)) {
        return $ProjectConfig.Services
    }

    if ($ServiceInput -eq "all") {
        return $ProjectConfig.Services
    }

    $ServiceList = $ServiceInput -split ','
    $ValidServices = @()

    foreach ($svc in $ServiceList) {
        $serviceName = $svc.Trim()

        # 检查是否为别名
        if ($ProjectConfig.ServiceAliases.ContainsKey($serviceName)) {
            $resolvedService = $ProjectConfig.ServiceAliases[$serviceName]
            if ($resolvedService -eq "all") {
                return $ProjectConfig.Services
            }
            if ($resolvedService -in $ProjectConfig.Services -and $resolvedService -notin $ValidServices) {
                $ValidServices += $resolvedService
            }
        }
        # 检查是否为完整服务名
        elseif ($serviceName -in $ProjectConfig.Services) {
            if ($serviceName -notin $ValidServices) {
                $ValidServices += $serviceName
            }
        } else {
            Write-Host "WARNING: Invalid service '$serviceName', will be skipped" -ForegroundColor $Colors.Warning
        }
    }

    return $ValidServices
}

function Write-StepHeader {
    param(
        [int]$Step,
        [int]$Total,
        [string]$Title
    )
    Write-Host $Separator -ForegroundColor $Colors.Header
    Write-Host "[Step $Step/$Total] $Title" -ForegroundColor $Colors.Header
    Write-Host $Separator -ForegroundColor $Colors.Header
}

function Write-PushSummary {
    param(
        [int]$SuccessCount,
        [int]$FailedCount,
        [string[]]$Services,
        [string]$Registry,
        [string]$Namespace,
        [string]$Tag
    )

    Write-Host $Separator -ForegroundColor $Colors.Header
    Write-Host "              Push Summary" -ForegroundColor $Colors.Header
    Write-Host $Separator -ForegroundColor $Colors.Header
    Write-Host "SUCCESS: $SuccessCount images pushed" -ForegroundColor $Colors.Success
    if ($FailedCount -gt 0) {
        Write-Host "FAILED: $FailedCount images failed" -ForegroundColor $Colors.Error
    }
    Write-Host ""

    if ($FailedCount -eq 0) {
        Write-Host "All images pushed successfully!" -ForegroundColor $Colors.Success
        Write-Host ""
        Write-Host "Registry Information:" -ForegroundColor $Colors.Header
        Write-Host "  Registry: $Registry" -ForegroundColor $Colors.Info
        Write-Host "  Namespace: $Namespace" -ForegroundColor $Colors.Info
        Write-Host "  Tag: $Tag" -ForegroundColor $Colors.Info
        Write-Host ""
        Write-Host "Pushed Images:" -ForegroundColor $Colors.Header
        foreach ($svc in $Services) {
            $fullImageName = "$Registry/$Namespace/$svc`:$Tag"
            Write-Host "  $fullImageName" -ForegroundColor $Colors.Info
        }
        Write-Host ""
        Write-Host "Pull commands for other environments:" -ForegroundColor $Colors.Header
        Write-Host "  docker pull $Registry/$Namespace/service-name:$Tag" -ForegroundColor $Colors.Info
        Write-Host ""
        Write-Host "Linux pull commands:" -ForegroundColor $Colors.Header
        foreach ($svc in $Services) {
            Write-Host "  docker pull $Registry/$Namespace/$svc`:$Tag" -ForegroundColor $Colors.Info
        }
    } else {
        Write-Host "Some images failed to push, please check error messages" -ForegroundColor $Colors.Warning
        Write-Host ""
        Write-Host "Login command:" -ForegroundColor $Colors.Header
        Write-Host "  docker login $Registry" -ForegroundColor $Colors.Info
    }
    Write-Host $Separator
}

# ==========================================
# 主要执行逻辑
# ==========================================

# 显示头部
Show-ScriptHeader

# 处理帮助参数
if ($ShowHelp) {
    Show-Help
}

# 解析参数
$ResolvedRegistry = if ([string]::IsNullOrEmpty($TargetRegistry)) { $DockerConfig.DefaultRegistry } else { $TargetRegistry }
$ResolvedNamespace = if ([string]::IsNullOrEmpty($TargetNamespace)) { $DockerConfig.DefaultNamespace } else { $TargetNamespace }
$ResolvedTag = if ([string]::IsNullOrEmpty($TargetTag)) { $DockerConfig.DefaultTag } else { $TargetTag }

# 解析服务列表
$ServicesToPush = Get-ServicesToPush -ServiceInput $TargetService

if ($ServicesToPush.Count -eq 0) {
    Write-Host "ERROR: No valid services to push" -ForegroundColor $Colors.Error
    Write-Host "Available services: $($ProjectConfig.Services -join ', ')" -ForegroundColor $Colors.Info
    exit 1
}

# 显示配置信息
Write-Host "Push Configuration:" -ForegroundColor $Colors.Header
Write-Host "  Registry: $ResolvedRegistry" -ForegroundColor $Colors.Info
Write-Host "  Namespace: $ResolvedNamespace" -ForegroundColor $Colors.Info
Write-Host "  Tag: $ResolvedTag" -ForegroundColor $Colors.Info
Write-Host "  Services: $($ServicesToPush -join ', ')" -ForegroundColor $Colors.Info
Write-Host ""

# ==========================================
# Step 1: 检查Docker环境
# ==========================================

Write-StepHeader -Step 1 -Total 3 -Title "Checking Docker Environment"

try {
    docker --version | Out-Null
    Write-Host "SUCCESS: Docker environment is OK" -ForegroundColor $Colors.Success
} catch {
    Write-Host "ERROR: Docker is not installed or not running" -ForegroundColor $Colors.Error
    exit 1
}

# 检查登录状态
Write-Host "Checking registry login status..." -ForegroundColor $Colors.Info
if ($ResolvedRegistry -ne "docker.io") {
    Write-Host "Attempting to connect to $ResolvedRegistry..." -ForegroundColor $Colors.Info
    Start-Sleep -Seconds $PushConfig.ConnectionTimeout
}

# ==========================================
# Step 2: 检查本地镜像
# ==========================================

Write-StepHeader -Step 2 -Total 3 -Title "Checking Local Images"

$MissingImages = 0
$ValidImages = @()

foreach ($svc in $ServicesToPush) {
    $ImageName = "$($ProjectConfig.ImagePrefix)/$svc`:latest"

    if (Test-DockerImage $ImageName) {
        Write-Host "SUCCESS: Local image exists: $ImageName" -ForegroundColor $Colors.Success
        $ValidImages += $svc
    } else {
        Write-Host "ERROR: Local image missing: $ImageName" -ForegroundColor $Colors.Error
        $MissingImages++
    }
}

if ($MissingImages -gt 0) {
    Write-Host ""
    Write-Host "ERROR: $MissingImages local images missing" -ForegroundColor $Colors.Error
    Write-Host "TIP: Please run build-images.ps1 first" -ForegroundColor $Colors.Warning
    exit 1
}

# 显示将要推送的镜像
Write-Host ""
Write-Host "Images to be pushed:" -ForegroundColor $Colors.Header
foreach ($svc in $ValidImages) {
    $SourceImage = "$($ProjectConfig.ImagePrefix)/$svc`:latest"
    $TargetImage = "$ResolvedRegistry/$ResolvedNamespace/$svc`:$ResolvedTag"
    Write-Host "  $SourceImage -> $TargetImage" -ForegroundColor $Colors.Info
}
Write-Host ""

# ==========================================
# Step 3: 推送镜像
# ==========================================

Write-StepHeader -Step 3 -Total 3 -Title "Pushing Images to Registry"

$PushSuccess = 0
$PushFailed = 0

foreach ($svc in $ValidImages) {
    Write-Host ""
    Write-Host "[Pushing $svc] ================================" -ForegroundColor $Colors.Header

    $SourceImage = "$($ProjectConfig.ImagePrefix)/$svc`:latest"
    $TargetImage = "$ResolvedRegistry/$ResolvedNamespace/$svc`:$ResolvedTag"

    # 标记镜像
    Write-Host "Tagging image: $TargetImage" -ForegroundColor $Colors.Info
    docker tag $SourceImage $TargetImage

    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: Failed to tag $svc image" -ForegroundColor $Colors.Error
        $PushFailed++
        continue
    }

    # 推送镜像
    Write-Host "Pushing image to: $ResolvedRegistry" -ForegroundColor $Colors.Info
    docker push $TargetImage

    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: Failed to push $svc image" -ForegroundColor $Colors.Error
        Write-Host "TIP: Please check:" -ForegroundColor $Colors.Warning
        Write-Host "  1. Are you logged into the target registry?" -ForegroundColor $Colors.Warning
        Write-Host "  2. Network connection is working" -ForegroundColor $Colors.Warning
        Write-Host "  3. Registry address and namespace are correct" -ForegroundColor $Colors.Warning
        $PushFailed++
    } else {
        Write-Host "SUCCESS: $svc image pushed successfully" -ForegroundColor $Colors.Success
        $PushSuccess++
    }

    # 清理本地标记
    docker rmi $TargetImage 2>$null

    Write-Host ""
}

# ==========================================
# 结果汇总
# ==========================================

Write-PushSummary -SuccessCount $PushSuccess -FailedCount $PushFailed -Services $ValidImages -Registry $ResolvedRegistry -Namespace $ResolvedNamespace -Tag $ResolvedTag