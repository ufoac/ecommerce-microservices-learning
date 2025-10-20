# ==========================================
# 电商微服务用户服务 Docker 镜像 - 极简极速版
# 方案3：零网络依赖，构建速度最快
# ==========================================

# 使用JDK运行时镜像
FROM swr.cn-north-4.myhuaweicloud.com/ddn-k8s/docker.io/openjdk:21-jdk-slim

# 设置应用目录
WORKDIR /app

# 复制本地构建的jar包（先执行：mvn clean package -DskipTests）
COPY target/user-service-1.0.0.jar ./app.jar

# 创建日志目录
RUN mkdir -p /app/logs

# 暴露端口
EXPOSE 28081

# 优化JVM参数（容器环境优化，适合小型服务）
ENV JAVA_OPTS="-Xms256m -Xmx512m -XX:+UseG1GC -XX:+UseContainerSupport -XX:MaxRAMPercentage=60.0 -XX:+UseStringDeduplication"

# 设置时区（如果需要的话，可以通过环境变量设置）
ENV TZ="Asia/Shanghai"

# 健康检查：使用Java内置的健康检查，无需curl
HEALTHCHECK --interval=60s --timeout=10s --start-period=45s --retries=3 \
  CMD java -jar app.jar --health-check || exit 1

# 启动命令（设置时区并启动）
ENTRYPOINT ["sh", "-c", "ln -snf /usr/share/zoneinfo/$TZ /etc/localtime 2>/dev/null || true && java $JAVA_OPTS -jar app.jar"]