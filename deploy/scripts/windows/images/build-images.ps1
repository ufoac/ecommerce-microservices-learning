# ==========================================
# E-commerce Microservices - Build Images Script
# Version: v2.3 (Simplified Force Build)
# Process: Maven Clean -> Maven Build -> Docker Build
# ==========================================

param(
    [Parameter(Position=0)]
    [ValidateSet("all", "user", "product", "trade", "gateway")]
    [string]$target = "all",

    [Parameter(Position=1)]
    [string]$tag = "",

    [switch]$h
)

# ==========================================
# 标准配置区域
# ==========================================

# 项目基础配置
$ProjectConfig = @{
    Name = "ecommerce"
    Version = "2.3"
    Services = @("user-service", "product-service", "trade-service", "api-gateway")
    JarVersion = "1.0.0"
    ImagePrefix = "ecommerce"
    ServiceAliases = @{
        "user" = "user-service"
        "product" = "product-service"
        "trade" = "trade-service"
        "gateway" = "api-gateway"
    }
}

# 构建配置
$BuildConfig = @{
    MavenCommand = "mvn clean package -DskipTests"
    DockerBuildCommand = "docker build"
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
# 公共函数
# ==========================================

function Show-ScriptHeader {
    Write-Host $Separator
    Write-Host "  E-commerce Microservices - Build Images"
    Write-Host $Separator
    Write-Host ""
}

function Show-Help {
    Write-Host "Build Docker images - Version v2.3 (Simplified)" -ForegroundColor $Colors.Header
    Write-Host ""
    Write-Host "Usage:" -ForegroundColor $Colors.Header
    Write-Host "  .\build-images.ps1 [target] [tag] [options]"
    Write-Host ""
    Write-Host "Parameters:" -ForegroundColor $Colors.Header
    Write-Host "  target         Build target (default: all)"
    Write-Host "  tag            Image tag (default: latest)"
    Write-Host ""
    Write-Host "Options:" -ForegroundColor $Colors.Header
    Write-Host "  -h             Show this help message"
    Write-Host ""
    Write-Host "Available Services:" -ForegroundColor $Colors.Header
    Write-Host "  all            Build all services (default)"
    Write-Host "  user           Build User Service"
    Write-Host "  product        Build Product Service"
    Write-Host "  trade          Build Trade Service"
    Write-Host "  gateway        Build API Gateway"
    Write-Host ""
    Write-Host "Build Process:" -ForegroundColor $Colors.Header
    Write-Host "  1. Maven Clean Package (force rebuild)"
    Write-Host "  2. Docker Image Build"
    Write-Host "  3. Image Tagging"
    Write-Host ""
    Write-Host "Examples:" -ForegroundColor $Colors.Header
    Write-Host "  .\build-images.ps1                      # Build all services"
    Write-Host "  .\build-images.ps1 user                 # Build User Service only"
    Write-Host "  .\build-images.ps1 user v1.0             # Build with custom tag"
    Write-Host "  .\build-images.ps1 product,trade        # Build multiple services"
    Write-Host "  .\build-images.ps1 all production       # Build all with custom tag"
    Write-Host ""
    Write-Host "Prerequisites:" -ForegroundColor $Colors.Header
    Write-Host "  1. Maven 3.6+ installed"
    Write-Host "  2. Docker environment running"
    Write-Host "  3. Sufficient disk space"
    Write-Host ""
    Read-Host "Press Enter to exit"
    exit 0
}

function Test-Command {
    param($command)
    try {
        Get-Command $command -ErrorAction Stop | Out-Null
        return $true
    } catch {
        return $false
    }
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

function Get-ProjectPaths {
    # 使用当前工作目录和相对路径计算
    $currentDir = Get-Location

    # 我们在 deploy/scripts/windows/images/ 目录下
    # 需要向上4级到达项目根目录
    $projectRoot = (Get-Item $currentDir).Parent.Parent.Parent.Parent.FullName
    $backendDir = Join-Path $projectRoot "backend"

    return @{
        ProjectRoot = $projectRoot
        BackendDir = $backendDir
    }
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

function Get-ServicesToBuild {
    param([string]$TargetInput)

    if ([string]::IsNullOrEmpty($TargetInput) -or $TargetInput -eq "all") {
        return $ProjectConfig.Services
    }

    # 检查是否为别名
    if ($ProjectConfig.ServiceAliases.ContainsKey($TargetInput)) {
        $resolvedService = $ProjectConfig.ServiceAliases[$TargetInput]
        if ($resolvedService -in $ProjectConfig.Services) {
            return @($resolvedService)
        }
    }

    # 检查是否为完整服务名
    if ($TargetInput -in $ProjectConfig.Services) {
        return @($TargetInput)
    }

    Write-Host "ERROR: Invalid service '$TargetInput'" -ForegroundColor $Colors.Error
    Write-Host "Available services: $($ProjectConfig.Services -join ', ')" -ForegroundColor $Colors.Info
    return @()
}

function Build-MavenProject {
    param([string]$ServiceName, [string]$ProjectDir)

    Write-Host "Building Maven project: $ServiceName" -ForegroundColor $Colors.Info
    Write-Host "Command: $($BuildConfig.MavenCommand)" -ForegroundColor $Colors.Gray
    Write-Host "Directory: $ProjectDir" -ForegroundColor $Colors.Gray
    Write-Host ""

    Push-Location $ProjectDir
    try {
        # 直接执行Maven命令，显示实时输出
        & cmd /c "$($BuildConfig.MavenCommand) 2>&1"
        $exitCode = $LASTEXITCODE

        Write-Host ""
        if ($exitCode -eq 0) {
            Write-Host "SUCCESS: Maven build completed for $ServiceName" -ForegroundColor $Colors.Success
            return $true
        } else {
            Write-Host "ERROR: Maven build failed for $ServiceName (exit code: $exitCode)" -ForegroundColor $Colors.Error
            return $false
        }
    } catch {
        Write-Host "ERROR: Maven build exception for $ServiceName`: $($_.Exception.Message)" -ForegroundColor $Colors.Error
        return $false
    } finally {
        Pop-Location
    }
}

function Build-DockerImage {
    param([string]$ServiceName, [string]$ServiceDir, [string]$ImageTag)

    $imageName = "$($ProjectConfig.ImagePrefix)/$ServiceName`:$ImageTag"
    Write-Host "Building Docker image: $imageName" -ForegroundColor $Colors.Info
    Write-Host "Context: $ServiceDir" -ForegroundColor $Colors.Gray
    Write-Host "Command: docker build -t $imageName $ServiceDir" -ForegroundColor $Colors.Gray
    Write-Host ""

    try {
        # 使用Start-Process来显示实时输出
        $process = Start-Process -FilePath "docker" -ArgumentList "build", "-t", $imageName, $ServiceDir -NoNewWindow -Wait -PassThru

        $exitCode = $process.ExitCode

        Write-Host ""
        if ($exitCode -eq 0) {
            Write-Host "SUCCESS: Docker image built: $imageName" -ForegroundColor $Colors.Success

            # 显示镜像信息
            $imageInfo = docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}\t{{.CreatedAt}}" $imageName 2>$null
            if ($imageInfo) {
                Write-Host "Image details:" -ForegroundColor $Colors.Info
                Write-Host $imageInfo -ForegroundColor $Colors.Gray
            }

            return $true
        } else {
            Write-Host "ERROR: Docker build failed for $ServiceName (exit code: $exitCode)" -ForegroundColor $Colors.Error
            return $false
        }
    } catch {
        Write-Host "ERROR: Docker build exception for $ServiceName`: $($_.Exception.Message)" -ForegroundColor $Colors.Error
        return $false
    }
}

# ==========================================
# 主要执行逻辑
# ==========================================

# 显示头部
Show-ScriptHeader

# 处理帮助参数
if ($h.IsPresent) {
    Show-Help
}

# 解析参数
$TargetService = $target
$ImageTag = if ([string]::IsNullOrEmpty($tag)) { "latest" } else { $tag }

# 显示配置信息
Write-Host "Build Configuration:" -ForegroundColor $Colors.Header
Write-Host "  Target: $TargetService" -ForegroundColor $Colors.Info
Write-Host "  Tag: $ImageTag" -ForegroundColor $Colors.Info
Write-Host ""

# 获取项目路径
$paths = Get-ProjectPaths

# 解析服务列表
$ServicesToBuild = Get-ServicesToBuild -TargetInput $TargetService

if ($ServicesToBuild.Count -eq 0) {
    Write-Host "ERROR: No valid services to build" -ForegroundColor $Colors.Error
    exit 1
}

Write-Host "Services to build: $($ServicesToBuild -join ', ')" -ForegroundColor $Colors.Info
Write-Host ""

# ==========================================
# Step 1: 检查环境
# ==========================================

Write-StepHeader -Step 1 -Total 2 -Title "Checking Build Environment"

# 检查Maven
if (Test-Command "mvn") {
    Write-Host "SUCCESS: Maven is available" -ForegroundColor $Colors.Success
} else {
    Write-Host "ERROR: Maven is not installed or not in PATH" -ForegroundColor $Colors.Error
    exit 1
}

# 检查Docker
if (Test-Command "docker") {
    Write-Host "SUCCESS: Docker is available" -ForegroundColor $Colors.Success
} else {
    Write-Host "ERROR: Docker is not installed or not running" -ForegroundColor $Colors.Error
    exit 1
}

# 检查项目目录
if (Test-Path $paths.BackendDir) {
    Write-Host "SUCCESS: Backend directory found: $($paths.BackendDir)" -ForegroundColor $Colors.Success
} else {
    Write-Host "ERROR: Backend directory not found: $($paths.BackendDir)" -ForegroundColor $Colors.Error
    exit 1
}

Write-Host ""

# ==========================================
# Step 2: 构建服务和镜像
# ==========================================

Write-StepHeader -Step 2 -Total 2 -Title "Building Services and Images"

$BuildSuccess = 0
$BuildFailed = 0

foreach ($service in $ServicesToBuild) {
    Write-Host ""
    Write-Host "[Building $service] ================================" -ForegroundColor $Colors.Header

    $serviceDir = Join-Path $paths.BackendDir $service

    # 检查服务目录
    if (-not (Test-Path $serviceDir)) {
        Write-Host "ERROR: Service directory not found: $serviceDir" -ForegroundColor $Colors.Error
        $BuildFailed++
        continue
    }

    # Maven构建
    $mavenSuccess = Build-MavenProject -ServiceName $service -ProjectDir $serviceDir
    if (-not $mavenSuccess) {
        $BuildFailed++
        continue
    }

    # Docker构建
    $dockerSuccess = Build-DockerImage -ServiceName $service -ServiceDir $serviceDir -ImageTag $ImageTag
    if ($dockerSuccess) {
        $BuildSuccess++
    } else {
        $BuildFailed++
    }

    Write-Host ""
}

# ==========================================
# 构建结果汇总
# ==========================================

Write-Host $Separator -ForegroundColor $Colors.Header
Write-Host "              Build Summary" -ForegroundColor $Colors.Header
Write-Host $Separator -ForegroundColor $Colors.Header
Write-Host "SUCCESS: $BuildSuccess services built" -ForegroundColor $Colors.Success
if ($BuildFailed -gt 0) {
    Write-Host "FAILED: $BuildFailed services failed" -ForegroundColor $Colors.Error
}
Write-Host ""

if ($BuildFailed -eq 0) {
    Write-Host "All services built successfully!" -ForegroundColor $Colors.Success
    Write-Host ""
    Write-Host "Built Images:" -ForegroundColor $Colors.Header
    foreach ($service in $ServicesToBuild) {
        $imageName = "$($ProjectConfig.ImagePrefix)/$service`:$ImageTag"
        Write-Host "  - $imageName" -ForegroundColor $Colors.Info
    }
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor $Colors.Header
    Write-Host "1. Test images: docker run --rm $($ProjectConfig.ImagePrefix)/service-name:$ImageTag" -ForegroundColor $Colors.Info
    Write-Host "2. Export images: .\export-images.ps1" -ForegroundColor $Colors.Info
    Write-Host "3. Push images: .\push-images.ps1" -ForegroundColor $Colors.Info
} else {
    Write-Host "Some services failed to build, please check error messages" -ForegroundColor $Colors.Warning
}
Write-Host $Separator