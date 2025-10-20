@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: ===================================
:: 电商微服务项目 - 导出镜像脚本
:: 版本: v1.0
:: 作用: 导出单个或多个镜像为tar文件，用于离线部署
:: ===================================

echo.
echo ==========================================
echo   电商微服务项目 - 导出应用镜像
echo ==========================================
echo.

:: 设置路径变量
set SCRIPT_DIR=%~dp0
set PROJECT_ROOT=%SCRIPT_DIR%\..\..\..\
set EXPORT_DIR=%PROJECT_ROOT%\deploy\images

:: 服务列表
set SERVICES=user-service product-service trade-service api-gateway

:: 解析命令行参数
set TARGET_SERVICE=
set SHOW_HELP=false
set CUSTOM_FILENAME=

:parse_args
if "%~1"=="" goto :args_done
if "%~1"=="--help" set SHOW_HELP=true & shift & goto :parse_args
if "%~1"=="-h" set SHOW_HELP=true & shift & goto :parse_args
if "%~1"=="--service" set TARGET_SERVICE=%~2 & shift & shift & goto :parse_args
if "%~1"=="-s" set TARGET_SERVICE=%~2 & shift & shift & goto :parse_args
if "%~1"=="--file" set CUSTOM_FILENAME=%~2 & shift & shift & goto :parse_args
if "%~1"=="-f" set CUSTOM_FILENAME=%~2 & shift & shift & goto :parse_args
shift
goto :parse_args

:args_done

:: 显示帮助信息
if "%SHOW_HELP%"=="true" (
    echo 用法: export-images.bat [选项]
    echo.
    echo 选项:
    echo   --help, -h              显示此帮助信息
    echo   --service, -s <服务名>   导出指定服务的镜像
    echo   --file, -f <文件名>     自定义导出文件名
    echo.
    echo 可用服务:
    echo   user-service            用户服务
    echo   product-service         商品服务
    echo   trade-service           交易服务
    echo   api-gateway             API网关
    echo.
    echo 示例:
    echo   export-images.bat                           # 导出所有服务镜像
    echo   export-images.bat -s user-service            # 只导出用户服务镜像
    echo   export-images.bat -s api-gateway -f gateway.tar # 导出网关镜像并指定文件名
    echo.
    pause
    exit /b 0
)

:: 验证服务参数
if defined TARGET_SERVICE (
    echo [信息] 将导出指定服务: %TARGET_SERVICE%
    set VALID_SERVICE=false
    for %%s in (%SERVICES%) do (
        if "%%s"=="%TARGET_SERVICE%" set VALID_SERVICE=true
    )
    if "!VALID_SERVICE!"=="false" (
        echo ❌ 无效的服务名: %TARGET_SERVICE%
        echo 可用服务: %SERVICES%
        echo 使用 --help 查看帮助信息
        pause
        exit /b 1
    )
    set SERVICES=%TARGET_SERVICE%
    if not defined CUSTOM_FILENAME (
        set CUSTOM_FILENAME=%TARGET_SERVICE%-image
    )
) else (
    echo [信息] 将导出所有服务镜像
    if not defined CUSTOM_FILENAME (
        set CUSTOM_FILENAME=ecommerce-images
    )
)

:: 生成版本信息
for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set "dt=%%a"
set "YYYY=%dt:~0,4%" & set "MM=%dt:~4,2%" & set "DD=%dt:~6,2%"
set "TIMESTAMP=%YYYY%%MM%%DD%"

if defined CUSTOM_FILENAME (
    set EXPORT_FILE=%CUSTOM_FILENAME%-%TIMESTAMP%.tar
) else (
    set EXPORT_FILE=ecommerce-images-%TIMESTAMP%.tar
)

echo 📅 导出日期: %YYYY%年%MM%月%DD%日
echo 📁 导出目录: %EXPORT_DIR%
echo 📦 导出文件: %EXPORT_FILE%
echo.

:: 检查并创建导出目录
if not exist "%EXPORT_DIR%" (
    echo 创建导出目录: %EXPORT_DIR%
    mkdir "%EXPORT_DIR%"
)

:: 检查镜像是否存在
echo ==========================================
echo [步骤1/2] 检查项目镜像
echo ==========================================
set MISSING_IMAGES=0
set IMAGE_LIST=

for %%s in (%SERVICES%) do (
    docker images ecommerce/%%s:latest --format "table {{.Repository}}:{{.Tag}}" | findstr "ecommerce/%%s:latest" >nul 2>&1
    if errorlevel 1 (
        echo ❌ 镜像不存在: ecommerce/%%s:latest
        set /a MISSING_IMAGES+=1
    ) else (
        echo ✅ 镜像存在: ecommerce/%%s:latest
        set "IMAGE_LIST=!IMAGE_LIST! ecommerce/%%s:latest"
    )
)

if !MISSING_IMAGES! gtr 0 (
    echo.
    echo ❌ 发现 !MISSING_IMAGES! 个镜像缺失
    echo 💡 请先运行 build-images.bat 构建镜像
    pause
    exit /b 1
)

echo.
echo 将导出以下镜像:
for %%s in (%SERVICES%) do (
    echo   - ecommerce/%%s:latest
)
echo.

:: 导出镜像
echo ==========================================
echo [步骤2/2] 导出镜像到文件
echo ==========================================

echo 正在导出镜像到: %EXPORT_DIR%\%EXPORT_FILE%
docker save -o "%EXPORT_DIR%\%EXPORT_FILE%!IMAGE_LIST!

if errorlevel 1 (
    echo ❌ 镜像导出失败
    pause
    exit /b 1
)

:: 获取文件大小
for %%F in ("%EXPORT_DIR%\%EXPORT_FILE%") do set FILE_SIZE=%%~zF
set /a FILE_SIZE_MB=!FILE_SIZE!/1024/1024

:: 生成版本信息文件
set VERSION_FILE=%EXPORT_DIR%\version-info-%TIMESTAMP%.txt
echo 生成版本信息文件: %VERSION_FILE%

> "%VERSION_FILE%" (
echo # 电商微服务项目镜像导出信息
echo # 导出时间: %YYYY%-%MM%-%DD%
echo # 镜像文件: %EXPORT_FILE%
echo # 文件大小: !FILE_SIZE_MB! MB
echo #
echo ## 包含的镜像列表:
for %%s in (%SERVICES%) do (
    echo - ecommerce/%%s:latest
)
echo.
echo ## 使用方法:
echo 1. 将此文件和镜像tar文件复制到目标机器
echo 2. 运行 import-images.sh 导入镜像
echo.
)

:: 显示导出结果
echo ==========================================
echo              🎉 导出完成！
echo ==========================================
echo ✅ 导出文件: %EXPORT_DIR%\%EXPORT_FILE%
echo ✅ 文件大小: !FILE_SIZE_MB! MB
echo ✅ 版本信息: %VERSION_FILE%
echo.
echo 📋 镜像使用说明:
echo 1. 离线部署时，将 %EXPORT_FILE% 复制到目标机器
echo 2. 在Linux环境运行: sudo linux/images/import-images.sh
echo 3. 启动服务: sudo linux/deploy/start-all.sh
echo.
echo 🔍 导出的镜像列表:
docker images ecommerce/ --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}\t{{.CreatedAt}}"
echo ==========================================

pause