# ===================================
# E-commerce Microservices Project - Build Images Script
# Version: v2.0 (PowerShell Enhanced Version)
# Process: Maven Build -> JAR Package -> Docker Image
# ===================================

param(
    [Parameter(Position=0)]
    [ValidateSet("user-service", "product-service", "trade-service", "api-gateway")]
    [string]$service = "all",
    [switch]$force,
    [switch]$build,
    [switch]$Help,
    [switch]$h
)

# Display header
Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "   E-commerce Microservices - Build Images" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# Handle help parameter
if ($Help -or $h) {
    Write-Host "Usage: .\build-images.ps1 [service] [options]"
    Write-Host ""
    Write-Host "Services:"
    Write-Host "  all                  Build all services (default)"
    Write-Host "  user-service         Build User Service only"
    Write-Host "  product-service      Build Product Service only"
    Write-Host "  trade-service        Build Trade Service only"
    Write-Host "  api-gateway          Build API Gateway only"
    Write-Host ""
    Write-Host "Options:"
    Write-Host "  -force               Force full rebuild (Maven + Docker)"
    Write-Host "  -build               Build images only (from existing JARs)"
    Write-Host "  -help, -h            Show this help message"
    Write-Host ""
    Write-Host "Flow Control:"
    Write-Host "  Default:     Check JAR -> Build if missing -> Check Image -> Build if missing"
    Write-Host "  -build:      Skip JAR check -> Force Image Build (from existing JARs)"
    Write-Host "  -force:      Force Maven Build -> Force Image Build (full rebuild)"
    Write-Host ""
    Write-Host "Use Cases:"
    Write-Host "  Default:     Daily development (smart build, save time)"
    Write-Host "  -build:      Dockerfile changed, code unchanged"
    Write-Host "  -force:      Code changed, need complete rebuild"
    Write-Host ""
    Write-Host "Examples:"
    Write-Host "  .\build-images.ps1            # Smart build"
    Write-Host "  .\build-images.ps1 user-service"
    Write-Host "  .\build-images.ps1 -build      # Rebuild images only"
    Write-Host "  .\build-images.ps1 -force      # Full rebuild"
    Write-Host ""
    Read-Host "Press Enter to exit"
    exit 0
}

Write-Host "Target: $service"
if ($build) { Write-Host "Options: Build images only (from existing JARs)" }
if ($force) { Write-Host "Options: Force full rebuild (Maven + Docker)" }
Write-Host ""

# Set path variables
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$ProjectRoot = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $ScriptDir)))
$BackendDir = Join-Path $ProjectRoot "backend"

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

# Function to check if image exists
function Test-DockerImage {
    param($imageName)
    try {
        $imageInfo = docker images --format "{{.Repository}}:{{.Tag}}" $imageName 2>$null
        return ($imageInfo -eq $imageName)
    }
    catch {
        return $false
    }
}

# Check required tools
Write-Host "[Pre-check] Checking required tools..." -ForegroundColor White

# Check Maven
if (-not (Test-Command "mvn")) {
    Write-Host "ERROR: Maven is not installed or not in PATH" -ForegroundColor Red
    Write-Host "Please install Maven" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}
Write-Host "SUCCESS: Maven is available" -ForegroundColor Green

# Check Docker
if (-not (Test-Command "docker")) {
    Write-Host "ERROR: Docker is not installed or not started" -ForegroundColor Red
    Write-Host "Please install and start Docker Desktop" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}
Write-Host "SUCCESS: Docker is available" -ForegroundColor Green

# Check Docker daemon
try {
    $dockerInfo = docker info 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "Docker daemon not running"
    }
    Write-Host "SUCCESS: Docker daemon is running" -ForegroundColor Green
}
catch {
    Write-Host "ERROR: Docker daemon is not running" -ForegroundColor Red
    Write-Host "Please start Docker Desktop" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}
Write-Host ""

# Switch to backend directory
if (-not (Test-Path $BackendDir)) {
    Write-Host "ERROR: Backend directory not found: $BackendDir" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

Set-Location $BackendDir
Write-Host "Working directory: $(Get-Location)" -ForegroundColor Gray

# Define services
$AllServices = @("user-service", "product-service", "trade-service", "api-gateway")
$ServicesToBuild = if ($service -eq "all") { $AllServices } else { @($service) }

Write-Host "Services to build: $($ServicesToBuild -join ', ')" -ForegroundColor White
Write-Host ""

# Maven build phase
Write-Host "==========================================" -ForegroundColor Yellow
Write-Host "[Phase 1/3] Maven Build" -ForegroundColor Yellow
Write-Host "==========================================" -ForegroundColor Yellow

# Check if JAR files exist
$missingJars = @()
foreach ($svc in $ServicesToBuild) {
    $jarPath = Join-Path $svc "target\$svc-1.0.0.jar"
    if (-not (Test-Path $jarPath)) {
        $missingJars += $svc
    }
}

if ($missingJars.Count -gt 0 -or $force) {
    if ($missingJars.Count -gt 0) {
        Write-Host "Found $($missingJars.Count) missing JAR files:" -ForegroundColor Yellow
        foreach ($svc in $missingJars) {
            Write-Host "  - $svc-1.0.0.jar" -ForegroundColor Gray
        }
    }

    if ($force) {
        Write-Host "Force full rebuild requested (-force)" -ForegroundColor Yellow
    }

    Write-Host "Building with Maven..." -ForegroundColor White
    Write-Host "Command: mvn clean package -DskipTests" -ForegroundColor Gray

    $mavenOutput = mvn clean package -DskipTests 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: Maven build failed" -ForegroundColor Red
        Write-Host "Error details:" -ForegroundColor Red
        $mavenOutput | Select-Object -Last 20 | ForEach-Object { Write-Host "  $_" -ForegroundColor Red }
        Read-Host "Press Enter to exit"
        exit 1
    }
    Write-Host "SUCCESS: Maven build completed" -ForegroundColor Green
} else {
    if ($build) {
        Write-Host "Build images only mode (-build), using existing JARs" -ForegroundColor Green
    } else {
        Write-Host "SUCCESS: All JAR files already exist" -ForegroundColor Green
    }
}

Write-Host ""

# JAR verification phase
Write-Host "==========================================" -ForegroundColor Yellow
Write-Host "[Phase 2/3] JAR File Verification" -ForegroundColor Yellow
Write-Host "==========================================" -ForegroundColor Yellow

$verifiedServices = @()
foreach ($svc in $ServicesToBuild) {
    $jarPath = Join-Path $svc "target\$svc-1.0.0.jar"
    if (Test-Path $jarPath) {
        $jarSize = (Get-Item $jarPath).Length / 1MB
        Write-Host "OK: $svc-1.0.0.jar exists ($([math]::Round($jarSize, 2)) MB)" -ForegroundColor Green
        $verifiedServices += $svc
    } else {
        Write-Host "FAIL: $svc-1.0.0.jar not found" -ForegroundColor Red
    }
}

if ($verifiedServices.Count -eq 0) {
    Write-Host "ERROR: No valid JAR files found. Run without -skipMaven first." -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host "Verified $($verifiedServices.Count) service(s)" -ForegroundColor Green
Write-Host ""

# Docker build phase
Write-Host "==========================================" -ForegroundColor Yellow
Write-Host "[Phase 3/3] Docker Image Build" -ForegroundColor Yellow
Write-Host "==========================================" -ForegroundColor Yellow

$buildSuccess = 0
$buildFailed = 0

foreach ($svc in $verifiedServices) {
    Write-Host ""
    Write-Host "[Building $svc] ================================" -ForegroundColor Cyan

    # Check if Dockerfile exists
    $dockerfilePath = Join-Path $svc "Dockerfile"
    if (-not (Test-Path $dockerfilePath)) {
        Write-Host "ERROR: Dockerfile not found: $dockerfilePath" -ForegroundColor Red
        $buildFailed++
        continue
    }

    # Check if image already exists (skip if building or forced)
    $imageName = "ecommerce/$svc`:latest"
    if ((Test-DockerImage $imageName) -and (-not $build) -and (-not $force)) {
        Write-Host "INFO: Image $imageName already exists, skipping (use -build or -force to rebuild)" -ForegroundColor Yellow
        $buildSuccess++
        continue
    }

    if ($build -or $force) {
        $reason = if ($build) { "Build images only mode (-build)" } else { "Force full rebuild (-force)" }
        Write-Host "$reason, rebuilding image" -ForegroundColor Yellow
    }

    # Build Docker image
    Write-Host "Building image: $imageName" -ForegroundColor White
    Write-Host "Command: docker build -t $imageName ./" -ForegroundColor Gray

    Set-Location $svc
    $buildOutput = docker build -t $imageName . 2>&1
    Set-Location $BackendDir

    if ($LASTEXITCODE -eq 0) {
        Write-Host "SUCCESS: $svc image built successfully" -ForegroundColor Green
        $buildSuccess++
    } else {
        Write-Host "ERROR: $svc image build failed" -ForegroundColor Red
        Write-Host "Error details:" -ForegroundColor Red
        $buildOutput | Select-Object -Last 10 | ForEach-Object { Write-Host "  $_" -ForegroundColor Red }
        $buildFailed++
    }
}

Write-Host ""

# Display results
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "              Build Summary" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "OK: Successfully built: $buildSuccess image(s)" -ForegroundColor Green
if ($buildFailed -gt 0) {
    Write-Host "FAIL: Failed to build: $buildFailed image(s)" -ForegroundColor Red
}
Write-Host ""

# Show project images
Write-Host "Project Docker images:" -ForegroundColor White
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$imageList = docker images --format "table {{.Repository}}`t{{.Tag}}`t{{.Size}}`t{{.CreatedAt}}" | Where-Object { $_ -match "ecommerce/" }
if ($imageList) {
    $imageList
} else {
    Write-Host "No ecommerce images found" -ForegroundColor Yellow
}

Write-Host ""

# Next steps guidance
Write-Host "==========================================" -ForegroundColor Cyan
if ($buildFailed -eq 0) {
    Write-Host "🎉 Build completed successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps you can take:" -ForegroundColor White
    Write-Host "- .\export-images.ps1          - Export images to files"
    Write-Host "- .\push-images.ps1            - Push to registry"
    Write-Host "- ..\deploy\start-all.ps1     - Start all services"
    Write-Host "- docker run -d ecommerce/user-service  - Test single service"
} else {
    Write-Host "⚠️  Some builds failed, please check errors above" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Troubleshooting:" -ForegroundColor White
    Write-Host "- Check Maven build logs for compilation errors"
    Write-Host "- Verify Dockerfile exists in each service directory"
    Write-Host "- Check Docker daemon is running"
}
Write-Host "==========================================" -ForegroundColor Green

Read-Host "Press Enter to exit"