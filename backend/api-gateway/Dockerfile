# ==========================================
# 电商微服务API网关 Docker 镜像 - 标准版
# 包含 curl 用于健康检查
# ==========================================

# 使用JDK运行时镜像
FROM swr.cn-north-4.myhuaweicloud.com/ddn-k8s/docker.io/openjdk:21-jdk-slim

# 安装 curl（用于健康检查）和基础工具
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

# 设置应用目录
WORKDIR /app

# 复制本地构建的jar包（先执行：mvn clean package -DskipTests）
COPY target/api-gateway-1.0.0.jar ./app.jar

# 创建日志目录
RUN mkdir -p /app/logs

# 暴露端口
EXPOSE 28080

# 优化JVM参数（容器环境优化，适合网关服务）
ENV JAVA_OPTS="-Xms256m -Xmx512m -XX:+UseG1GC -XX:+UseContainerSupport -XX:MaxRAMPercentage=65.0 -XX:+UseStringDeduplication"

# 设置时区（如果需要的话，可以通过环境变量设置）
ENV TZ="Asia/Shanghai"

# 启动命令（设置时区并启动）
ENTRYPOINT ["sh", "-c", "ln -snf /usr/share/zoneinfo/$TZ /etc/localtime 2>/dev/null || true && java $JAVA_OPTS -jar app.jar"]