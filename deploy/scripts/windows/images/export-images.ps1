# ==========================================
# E-commerce Microservices - Export Images Script
# Version: v2.2 (Parameter Optimization)
# Purpose: Export Docker images to tar files
# ==========================================

# 设置UTF-8编码
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# ==========================================
# 参数处理
# ==========================================

$target = ""
$outputdir = ""
$includeInfra = $false
$showHelp = $false

# 解析命令行参数
for ($i = 0; $i -lt $args.Count; $i++) {
    $arg = $args[$i]

    if ($arg -eq "-i" -or $arg -eq "-includeinfra") {
        $includeInfra = $true
    }
    elseif ($arg -eq "-h" -or $arg -eq "-help") {
        $showHelp = $true
    }
    elseif ($arg.StartsWith("-")) {
        # 跳过未知选项
        $i++
    }
    elseif ([string]::IsNullOrEmpty($target)) {
        $target = $arg
    }
    elseif ([string]::IsNullOrEmpty($outputdir)) {
        $outputdir = $arg
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

# 路径配置
$PathConfig = @{
    ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
    DefaultImagesDir = "images"
}

# 基础设施镜像配置
$InfraConfig = @{
    Images = @(
        "mysql:8.0",
        "redis:7.2",
        "nacos/nacos-server:v2.3.0",
        "apache/rocketmq:5.1.4",
        "nginx:latest"
    )
}

# 导出配置
$ExportConfig = @{
    TimestampFormat = "yyyyMMdd-HHmmss"
    InfoFileSuffix = "-info.txt"
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
$TargetOutputDir = $outputdir
$IncludeInfra = $includeInfra
$ShowHelp = $showHelp
$CustomFileName = ""

# 处理帮助参数
if ($ShowHelp) {
    Show-Help
}

# ==========================================
# 公共函数
# ==========================================

function Show-ScriptHeader {
    Write-Host $Separator
    Write-Host "E-commerce Microservices - Export Images"
    Write-Host $Separator
}

function Show-Help {
    Write-Host "Export Docker images to tar files - Version v2.2" -ForegroundColor $Colors.Header
    Write-Host ""
    Write-Host "Usage:" -ForegroundColor $Colors.Header
    Write-Host "  .\export-images.ps1 [target] [outputdir] [options]"
    Write-Host ""
    Write-Host "Parameters:" -ForegroundColor $Colors.Header
    Write-Host "  target         Service to export (default: all)"
    Write-Host "  outputdir      Output directory (default: ./images)"
    Write-Host ""
    Write-Host "Options:" -ForegroundColor $Colors.Header
    Write-Host "  -i             Include infrastructure images"
    Write-Host "  -h             Show this help"
    Write-Host ""
    Write-Host "Available Services:" -ForegroundColor $Colors.Header
    Write-Host "  all            Export all application services (default)"
    Write-Host "  user           Export user-service only"
    Write-Host "  product        Export product-service only"
    Write-Host "  trade          Export trade-service only"
    Write-Host "  gateway        Export api-gateway only"
    Write-Host "  user,product   Export multiple services (comma-separated)"
    Write-Host ""
    Write-Host "Infrastructure Images:" -ForegroundColor $Colors.Header
    foreach ($img in $InfraConfig.Images) {
        Write-Host "  - $img"
    }
    Write-Host ""
    Write-Host "Examples:" -ForegroundColor $Colors.Header
    Write-Host "  .\export-images.ps1                              # Export all app services"
    Write-Host "  .\export-images.ps1 user                        # Export specific service"
    Write-Host "  .\export-images.ps1 user,product                # Export multiple services"
    Write-Host "  .\export-images.ps1 all -i                      # Export all with infrastructure"
    Write-Host "  .\export-images.ps1 user D:\backup              # Custom output directory"
    Write-Host "  .\export-images.ps1 product D:\backup -i        # Export service with infra to custom dir"
    Write-Host ""
    Write-Host "Prerequisites:" -ForegroundColor $Colors.Header
    Write-Host "  1. Images built with build-images.ps1"
    Write-Host "  2. Sufficient disk space for export files"
    Write-Host ""
    Read-Host "Press Enter to exit"
    exit 0
}

function Test-DockerImage {
    param($imageName)
    try {
        $result = docker images --format "{{.Repository}}:{{.Tag}}" $imageName 2>$null
        return ($result -eq $imageName)
    }
    catch {
        return $false
    }
}

function Ensure-Directory {
    param($Path)
    if (-not (Test-Path $Path)) {
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
        Write-Host "Created directory: $Path" -ForegroundColor $Colors.Gray
    }
}

function Get-ServicesToExport {
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

function Get-ExportFileName {
    param(
        [string[]]$Services,
        [bool]$IncludeInfra,
        [string]$CustomFileName,
        [string]$Timestamp
    )

    if ([string]::IsNullOrEmpty($CustomFileName)) {
        if ($IncludeInfra -and $Services.Count -eq $ProjectConfig.Services.Count) {
            $baseName = "$($ProjectConfig.Name)-full-export"
        } elseif ($IncludeInfra) {
            $baseName = "$($ProjectConfig.Name)-infrastructure"
        } elseif ($Services.Count -eq $ProjectConfig.Services.Count) {
            $baseName = "$($ProjectConfig.Name)-app-services"
        } elseif ($Services.Count -eq 1) {
            $baseName = "$($ProjectConfig.Name)-$($Services[0])"
        } else {
            $baseName = "$($ProjectConfig.Name)-selected-services"
        }
    } else {
        $baseName = $CustomFileName
    }

    return "$baseName-$Timestamp.tar"
}

function Write-ExportSummary {
    param(
        [string[]]$AppImages,
        [string[]]$InfraImages,
        [string]$ExportFile,
        [double]$FileSizeMB,
        [string]$InfoFile
    )

    Write-Host ""
    Write-Host "Export Summary:" -ForegroundColor $Colors.Header
    Write-Host "Application Services: $($AppImages.Count)" -ForegroundColor $Colors.Success
    foreach ($image in $AppImages) {
        Write-Host "  - $image" -ForegroundColor $Colors.Info
    }

    if ($InfraImages.Count -gt 0) {
        Write-Host "Infrastructure Images: $($InfraImages.Count)" -ForegroundColor $Colors.Success
        foreach ($image in $InfraImages) {
            Write-Host "  - $image" -ForegroundColor $Colors.Info
        }
    }

    Write-Host ""
    Write-Host "File Information:" -ForegroundColor $Colors.Header
    Write-Host "  Export file: $ExportFile" -ForegroundColor $Colors.Info
    Write-Host "  File size: $FileSizeMB MB" -ForegroundColor $Colors.Info
    Write-Host "  Info file: $InfoFile" -ForegroundColor $Colors.Info
    Write-Host ""
    Write-Host "Next Steps:" -ForegroundColor $Colors.Header
    Write-Host "1. Copy files to target machine" -ForegroundColor $Colors.Info
    Write-Host "2. Run: docker load -i $ExportFile" -ForegroundColor $Colors.Info
    Write-Host "3. Start services with deploy scripts" -ForegroundColor $Colors.Info
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

# 解析服务列表
$ServicesToExport = Get-ServicesToExport -ServiceInput $TargetService

if ($ServicesToExport.Count -eq 0) {
    Write-Host "ERROR: No valid services to export" -ForegroundColor $Colors.Error
    Write-Host "Available services: $($ProjectConfig.Services -join ', ')" -ForegroundColor $Colors.Info
    exit 1
}

# 确定导出目录
if ([string]::IsNullOrEmpty($TargetOutputDir)) {
    $ExportDir = Join-Path $PathConfig.ScriptDir $PathConfig.DefaultImagesDir
} else {
    $ExportDir = $TargetOutputDir
}

# 确保导出目录存在
Ensure-Directory -Path $ExportDir

# 获取基础设施镜像
$InfraImagesToExport = @()
if ($IncludeInfra) {
    Write-Host "Checking infrastructure images..." -ForegroundColor $Colors.Info
    foreach ($img in $InfraConfig.Images) {
        if (Test-DockerImage $img) {
            Write-Host "OK: $img" -ForegroundColor $Colors.Success
            $InfraImagesToExport += $img
        } else {
            Write-Host "SKIP: $img (not found locally)" -ForegroundColor $Colors.Warning
        }
    }
}

# 显示配置信息
Write-Host ""
Write-Host "Export Configuration:" -ForegroundColor $Colors.Header
Write-Host "  Output directory: $ExportDir" -ForegroundColor $Colors.Info
Write-Host "  Services: $($ServicesToExport -join ', ')" -ForegroundColor $Colors.Info
Write-Host "  Include infrastructure: $IncludeInfra" -ForegroundColor $Colors.Info
if ($IncludeInfra) {
    Write-Host "  Infrastructure images found: $($InfraImagesToExport.Count)" -ForegroundColor $Colors.Info
}
Write-Host ""

# 检查应用服务镜像
Write-Host "Checking application images..." -ForegroundColor $Colors.Info
$FoundAppImages = @()
foreach ($svc in $ServicesToExport) {
    $imageName = "$($ProjectConfig.ImagePrefix)/$svc`:latest"
    if (Test-DockerImage $imageName) {
        Write-Host "OK: $imageName" -ForegroundColor $Colors.Success
        $FoundAppImages += $imageName
    } else {
        Write-Host "ERROR: $imageName (NOT FOUND)" -ForegroundColor $Colors.Error
        exit 1
    }
}

# 生成导出文件名
$timestamp = Get-Date -Format $ExportConfig.TimestampFormat
$ExportFile = Get-ExportFileName -Services $ServicesToExport -IncludeInfra $IncludeInfra -CustomFileName $CustomFileName -Timestamp $timestamp
$ExportPath = Join-Path $ExportDir $ExportFile

# 准备导出的镜像列表
$AllImagesToExport = $FoundAppImages + $InfraImagesToExport
$ImageList = $AllImagesToExport -join " "

Write-Host ""
Write-Host "Exporting images..." -ForegroundColor $Colors.Header
Write-Host "Command: docker save -o `"$ExportPath`" $ImageList" -ForegroundColor $Colors.Gray

# 执行导出
$Command = "docker save -o `"$ExportPath`" $ImageList"
Invoke-Expression $Command

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Export failed" -ForegroundColor $Colors.Error
    Read-Host "Press Enter to exit"
    exit 1
}

# 检查导出结果
if (Test-Path $ExportPath) {
    $fileInfo = Get-Item $ExportPath
    $fileSizeMB = [math]::Round($fileInfo.Length / 1MB, 2)
    Write-Host "SUCCESS: Export completed" -ForegroundColor $Colors.Success
    Write-Host "File size: $fileSizeMB MB" -ForegroundColor $Colors.Info

    # 创建信息文件
    $InfoFile = Join-Path $ExportDir "$($ExportFile.Replace('.tar', $ExportConfig.InfoFileSuffix))"
    $versionContent = @"
# Export Information
- Export Time: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
- Script Version: $($ProjectConfig.Version)
- Image File: $ExportFile
- File Size: $fileSizeMB MB
- Image Count: $($AllImagesToExport.Count)

## Application Images
"@

    foreach ($image in $FoundAppImages) {
        $versionContent += "`n- $image"
    }

    if ($InfraImagesToExport.Count -gt 0) {
        $versionContent += "`n`nInfrastructure Images:"
        foreach ($image in $InfraImagesToExport) {
            $versionContent += "`n- $image"
        }
    }

    $versionContent += @"

## Import Instructions
docker load -i "$ExportFile"

## Image Details
"@

    # 添加镜像详细信息
    foreach ($image in $AllImagesToExport) {
        try {
            $imageInfo = docker images --format "table {{.Repository}}`t{{.Tag}}`t{{.Size}}`t{{.CreatedAt}}" $image 2>$null
            if ($imageInfo) {
                $versionContent += "`n$imageInfo"
            }
        } catch {
            $versionContent += "`n$image (info unavailable)"
        }
    }

    $versionContent | Out-File -FilePath $InfoFile -Encoding UTF8
    Write-Host "Info file created: $InfoFile" -ForegroundColor $Colors.Success

    # 显示导出汇总
    Write-ExportSummary -AppImages $FoundAppImages -InfraImages $InfraImagesToExport -ExportFile $ExportFile -FileSizeMB $fileSizeMB -InfoFile $InfoFile

} else {
    Write-Host "ERROR: Export file not found" -ForegroundColor $Colors.Error
    exit 1
}

Read-Host "Press Enter to exit"