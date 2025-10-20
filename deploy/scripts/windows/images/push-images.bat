@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: ===================================
:: 电商微服务项目 - 推送镜像脚本
:: 版本: v1.0
:: 作用: 推送单个或多个镜像到镜像仓库
:: ===================================

echo.
echo ==========================================
echo   电商微服务项目 - 推送应用镜像
echo ==========================================
echo.

:: 服务列表
set SERVICES=user-service product-service trade-service api-gateway

:: 默认镜像仓库配置
set DEFAULT_REGISTRY=registry.cn-hangzhou.aliyuncs.com
set DEFAULT_NAMESPACE=ecommerce

:: 解析命令行参数
set TARGET_SERVICE=
set SHOW_HELP=false
set REGISTRY=%DEFAULT_REGISTRY%
set NAMESPACE=%DEFAULT_NAMESPACE%
set TAG=latest

:parse_args
if "%~1"=="" goto :args_done
if "%~1"=="--help" set SHOW_HELP=true & shift & goto :parse_args
if "%~1"=="-h" set SHOW_HELP=true & shift & goto :parse_args
if "%~1"=="--service" set TARGET_SERVICE=%~2 & shift & shift & goto :parse_args
if "%~1"=="-s" set TARGET_SERVICE=%~2 & shift & shift & goto :parse_args
if "%~1"=="--registry" set REGISTRY=%~2 & shift & shift & goto :parse_args
if "%~1"=="-r" set REGISTRY=%~2 & shift & shift & goto :parse_args
if "%~1"=="--namespace" set NAMESPACE=%~2 & shift & shift & goto :parse_args
if "%~1"=="-n" set NAMESPACE=%~2 & shift & shift & goto :parse_args
if "%~1"=="--tag" set TAG=%~2 & shift & shift & goto :parse_args
if "%~1"=="-t" set TAG=%~2 & shift & shift & goto :parse_args
shift
goto :parse_args

:args_done

:: 显示帮助信息
if "%SHOW_HELP%"=="true" (
    echo 用法: push-images.bat [选项]
    echo.
    echo 选项:
    echo   --help, -h              显示此帮助信息
    echo   --service, -s <服务名>   推送指定服务的镜像
    echo   --registry, -r <仓库地址> 镜像仓库地址 ^(默认: %DEFAULT_REGISTRY%^)
    echo   --namespace, -n <命名空间> 命名空间 ^(默认: %DEFAULT_NAMESPACE%^)
    echo   --tag, -t <标签>        镜像标签 ^(默认: latest^)
    echo.
    echo 可用服务:
    echo   user-service            用户服务
    echo   product-service         商品服务
    echo   trade-service           交易服务
    echo   api-gateway             API网关
    echo.
    echo 示例:
    echo   push-images.bat                           # 推送所有服务镜像
    echo   push-images.bat -s user-service            # 只推送用户服务镜像
    echo   push-images.bat -r docker.io -n myproject # 推送到指定仓库和命名空间
    echo   push-images.bat -t v1.0.0                # 推送指定版本标签
    echo.
    echo 准备工作:
    echo   1. 确保已登录到目标镜像仓库
    echo   2. 确保镜像已构建完成
    echo.
    pause
    exit /b 0
)

:: 验证服务参数
if defined TARGET_SERVICE (
    echo [信息] 将推送指定服务: %TARGET_SERVICE%
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
) else (
    echo [信息] 将推送所有服务镜像
)

echo 📋 推送配置:
echo   镜像仓库: %REGISTRY%
echo   命名空间: %NAMESPACE%
echo   镜像标签: %TAG%
echo.

:: 检查Docker登录状态
echo ==========================================
echo [步骤1/3] 检查Docker环境
echo ==========================================

docker --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Docker未安装或未启动
    pause
    exit /b 1
)

echo ✅ Docker环境正常
echo.

:: 检查登录状态
echo 检查镜像仓库登录状态...
if not "%REGISTRY%"=="docker.io" (
    echo 尝试连接到 %REGISTRY%...
    timeout /t 3 >nul
)

:: 检查镜像是否存在
echo ==========================================
echo [步骤2/3] 检查本地镜像
echo ==========================================

set MISSING_IMAGES=0
for %%s in (%SERVICES%) do (
    docker images ecommerce/%%s:latest --format "table {{.Repository}}:{{.Tag}}" | findstr "ecommerce/%%s:latest" >nul 2>&1
    if errorlevel 1 (
        echo ❌ 本地镜像不存在: ecommerce/%%s:latest
        set /a MISSING_IMAGES+=1
    ) else (
        echo ✅ 本地镜像存在: ecommerce/%%s:latest
    )
)

if !MISSING_IMAGES! gtr 0 (
    echo.
    echo ❌ 发现 !MISSING_IMAGES! 个本地镜像缺失
    echo 💡 请先运行 build-images.bat 构建镜像
    pause
    exit /b 1
)

echo.
echo 将推送以下镜像:
for %%s in (%SERVICES%) do (
    echo   - ecommerce/%%s:latest → %REGISTRY%/%NAMESPACE%/%%s:%TAG%
)
echo.

:: 推送镜像
echo ==========================================
echo [步骤3/3] 推送镜像到仓库
echo ==========================================

set PUSH_SUCCESS=0
set PUSH_FAILED=0

for %%s in (%SERVICES%) do (
    echo.
    echo [推送 %%s] ================================

    :: 标记镜像
    echo 正在标记镜像: %REGISTRY%/%NAMESPACE%/%%s:%TAG
    docker tag ecommerce/%%s:latest %REGISTRY%/%NAMESPACE%/%%s:%TAG

    if errorlevel 1 (
        echo ❌ %%s 镜像标记失败
        set /a PUSH_FAILED+=1
        goto :next_service
    )

    :: 推送镜像
    echo 正在推送镜像到: %REGISTRY%
    docker push %REGISTRY%/%NAMESPACE%/%%s:%TAG

    if errorlevel 1 (
        echo ❌ %%s 镜像推送失败
        echo 💡 请检查：
        echo   1. 是否已登录到目标镜像仓库
        echo   2. 网络连接是否正常
        echo   3. 仓库地址和命名空间是否正确
        set /a PUSH_FAILED+=1
    ) else (
        echo ✅ %%s 镜像推送成功
        set /a PUSH_SUCCESS+=1
    )

    :: 清理本地标记
    docker rmi %REGISTRY%/%NAMESPACE%/%%s:%TAG 2>nul

    :next_service
    echo.
)

:: 显示推送结果
echo ==========================================
echo              推送结果汇总
echo ==========================================
echo ✅ 成功推送: !PUSH_SUCCESS! 个镜像
if !PUSH_FAILED! gtr 0 (
    echo ❌ 推送失败: !PUSH_FAILED! 个镜像
)
echo.

if !PUSH_FAILED! equ 0 (
    echo 🎉 所有镜像推送完成！
    echo.
    echo 镜像仓库信息:
    echo   仓库地址: %REGISTRY%
    echo   命名空间: %NAMESPACE%
    echo   镜像列表:
    for %%s in (%SERVICES%) do (
        echo     %REGISTRY%/%NAMESPACE%/%%s:%TAG
    )
    echo.
    echo 在其他环境使用:
    echo   docker pull %REGISTRY%/%NAMESPACE%/service-name:%TAG
    echo.
    echo Linux环境拉取命令:
    for %%s in (%SERVICES%) do (
        echo   docker pull %REGISTRY%/%NAMESPACE%/%%s:%TAG
    )
) else (
    echo ⚠️  部分镜像推送失败，请检查错误信息
    echo.
    echo 登录镜像仓库的命令:
    echo   docker login %REGISTRY%
)

echo ==========================================

pause