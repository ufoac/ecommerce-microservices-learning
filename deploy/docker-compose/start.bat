@echo off
chcp 65001 >nul

echo ==========================================
echo   电商微服务Docker环境启动脚本
echo   E-commerce Microservices Docker Startup
echo ==========================================

REM 检查Docker是否安装
docker --version >nul 2>&1
if errorlevel 1 (
    echo 错误: Docker未安装，请先安装Docker Desktop
    pause
    exit /b 1
)

REM 检查Docker Compose是否安装
docker-compose --version >nul 2>&1
if errorlevel 1 (
    echo 错误: Docker Compose未安装，请先安装Docker Compose
    pause
    exit /b 1
)

REM 进入项目目录
cd /d "%~dp0"

echo 创建必要的日志和数据目录...
if not exist "logs\nacos" mkdir "logs\nacos"
if not exist "logs\mysql" mkdir "logs\mysql"
if not exist "logs\redis" mkdir "logs\redis"
if not exist "logs\rocketmq" mkdir "logs\rocketmq"

echo 启动基础中间件服务...
docker-compose up -d mysql redis nacos

echo 等待基础服务启动完成（30秒）...
timeout /t 30 /nobreak >nul

echo 检查基础服务状态...
docker-compose ps

echo 启动消息队列和分布式事务服务...
docker-compose up -d rocketmq-nameserver rocketmq-broker rocketmq-console seata-server

echo 等待所有服务启动完成（20秒）...
timeout /t 20 /nobreak >nul

echo ==========================================
echo 所有服务启动完成，状态如下：
echo ==========================================
docker-compose ps

echo.
echo ==========================================
echo 服务访问地址：
echo ==========================================
echo Nacos控制台:     http://localhost:8848/nacos (nacos/nacos)
echo MySQL数据库:     localhost:3306 (root/root123456)
echo Redis缓存:       localhost:6379
echo RocketMQ控制台:  http://localhost:8081
echo Seata控制台:     http://localhost:7091
echo ==========================================

echo.
echo 提示：使用 'docker-compose logs -f [服务名]' 查看服务日志
echo 提示：使用 'docker-compose down' 停止所有服务
pause