@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: ===================================
:: 电商微服务项目 - 导入镜像脚本
:: 版本: v1.0
:: 作用: 从tar文件导入单个或多个镜像，用于离线部署
:: ===================================

echo.
echo ==========================================
echo   电商微服务项目 - 导入应用镜像
echo ==========================================
echo.

:: 设置路径变量
set SCRIPT_DIR=%~dp0
set PROJECT_ROOT=%SCRIPT_DIR%\..\..\..\
set IMPORT_DIR=%PROJECT_ROOT%\deploy\images

:: 解析命令行参数
set SHOW_HELP=false
set CUSTOM_FILE=

:parse_args
if "%~1"=="" goto :args_done
if "%~1"=="--help" set SHOW_HELP=true & shift & goto :parse_args
if "%~1"=="-h" set SHOW_HELP=true & shift & goto :parse_args
if "%~1"=="--file" set CUSTOM_FILE=%~1 & shift & goto :parse_args
if "%~1"=="-f" set CUSTOM_FILE=%~1 & shift & goto :parse_args
shift
goto :parse_args

:args_done

:: 显示帮助信息
if "%SHOW_HELP%"=="true" (
    echo 用法: import-images.bat [选项]
    echo.
    echo 选项:
    echo   --help, -h      显示此帮助信息
    echo   --file, -f      指定镜像文件路径
    echo.
    echo 示例:
    echo   import-images.bat                              # 自动查找并导入最新镜像文件
    echo   import-images.bat -f "images\ecommerce-images.tar" # 导入指定镜像文件
    echo.
    echo 说明:
    echo   - 默认在 %IMPORT_DIR% 目录查找镜像文件
    echo   - 支持 .tar 和 .tar.gz 格式的镜像文件
    echo.
    pause
    exit /b 0
)

:: 检查导入目录
if not exist "%IMPORT_DIR%" (
    echo ❌ 导入目录不存在: %IMPORT_DIR%
    echo 💡 请确保项目结构完整
    pause
    exit /b 1
)

:: 查找镜像文件
echo ==========================================
echo [步骤1/3] 查找镜像文件
echo ==========================================

set IMAGE_FILE=
LATEST_FILE=

if defined CUSTOM_FILE (
    if exist "%IMPORT_DIR%\%CUSTOM_FILE%" (
        set "IMAGE_FILE=%IMPORT_DIR%\%CUSTOM_FILE%"
        echo ✅ 使用指定的镜像文件: %CUSTOM_FILE%
    ) else (
        echo ❌ 指定的镜像文件不存在: %CUSTOM_FILE%
        pause
        exit /b 1
    )
) else (
    echo 查找最新的镜像文件...
    for %%f in ("%IMPORT_DIR%\ecommerce-images-*.tar") do (
        if exist "%%f" (
            if [!IMAGE_FILE!]==[] (
                set "IMAGE_FILE=%%f"
                set "LATEST_FILE=%%f"
            ) else (
                if "%%f" newer "!LATEST_FILE!" (
                    set "LATEST_FILE=%%f"
                )
            fi
        fi
    done

    if not defined LATEST_FILE (
        echo ❌ 未找到镜像文件
        echo 💡 请确保在 %IMPORT_DIR% 目录中有 ecommerce-images-*.tar 文件
        echo 💡 或在Linux环境运行 export-all-images.bat 导出镜像
        pause
        exit /b 1
    )

    set "IMAGE_FILE=!LATEST_FILE!"
    echo ✅ 找到最新镜像文件: !IMAGE_FILE!
)

for %%F in ("!IMAGE_FILE!") do (
    set FILE_SIZE=%%~zF
    set /a FILE_SIZE_MB=!FILE_SIZE!/1024/1024
    set FILE_MOD_TIME=%%~tF
)
echo 📦 镜像文件大小: !FILE_SIZE_MB! MB
echo 📅 修改时间: !FILE_MOD_TIME!
echo.

:: 检查Docker环境
echo ==========================================
echo [步骤2/3] 检查Docker环境
echo ==========================================

docker --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Docker未安装或未启动
    echo 💡 请先安装并启动Docker Desktop
    pause
    exit /b 1
)

docker info >nul 2>&1
if errorlevel 1 (
    echo ❌ Docker未运行
    echo 💡 请启动Docker Desktop
    pause
    exit /b 1
)

echo ✅ Docker环境正常
echo.

:: 导入镜像
echo ==========================================
echo [步骤3/3] 导入镜像
echo ==========================================

echo 正在导入镜像...
echo 📦 导入文件: !IMAGE_FILE!
echo.

docker load -i "!IMAGE_FILE!"

if errorlevel 1 (
    echo ❌ 镜像导入失败
    echo 💡 请检查：
    echo   1. 镜像文件是否损坏
    echo   2. Docker是否有足够的存储空间
    pause
    exit /b 1
)

echo.
echo ✅ 镜像导入成功
echo.

:: 显示导入结果
echo ==========================================
echo              🎉 导入完成！
echo ==========================================

echo 📋 当前项目镜像列表:
docker images ecommerce/ --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}\t{{.CreatedAt}}" 2>/dev/null || echo "  暂无镜像"
echo.

echo 🚀 接下来您可以：
echo 1. 运行 start-all.bat 启动所有服务
echo 2. 运行 list-images.bat 查看镜像详细信息
echo 3. 运行 push-images.bat 推送到镜像仓库
echo.

echo 💡 提示：
echo - 如果镜像已存在，新导入的镜像会覆盖旧镜像
echo - 可以运行 docker system prune 清理旧镜像
echo ==========================================

pause