# ==========================================
# 电商微服务用户服务 Docker 镜像
# 方案1：简化策略 - 直接使用本地构建的JAR包
# 优势：构建快速，镜像体积小，避免容器内构建复杂性
# 适用：个人学习开发，快速迭代
# swr.cn-north-4.myhuaweicloud.com/ddn-k8s/docker.io/eclipse-temurin:21-jre
# ==========================================

# 使用JDK运行时镜像（华为云镜像源中JRE版本不可用）
FROM swr.cn-north-4.myhuaweicloud.com/ddn-k8s/docker.io/openjdk:21-jdk-slim

# 合并RUN指令减少层数，同时设置时区和安装必要工具
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl && \
    ln -snf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo "Asia/Shanghai" > /etc/timezone && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean && \
    groupadd -r appuser 2>/dev/null || true && \
    useradd -r -g appuser -s /bin/false appuser 2>/dev/null || true

# 设置应用目录
WORKDIR /app

# 复制本地构建的jar包（先执行：mvn clean package -DskipTests）
COPY target/user-service-1.0.0.jar ./app.jar

# 创建日志目录并设置权限
RUN mkdir -p /app/logs && \
    chown -R appuser:appuser /app 2>/dev/null || true

# 暴露端口
EXPOSE 28081

# 优化JVM参数（容器环境优化，适合小型服务）
ENV JAVA_OPTS="-Xms256m -Xmx512m -XX:+UseG1GC -XX:+UseContainerSupport -XX:MaxRAMPercentage=60.0 -XX:+UseStringDeduplication"

# 健康检查（使用轻量级检查）
HEALTHCHECK --interval=60s --timeout=5s --start-period=45s --retries=3 \
  CMD curl -f http://localhost:28081/actuator/health || exit 1

# 启动命令（root用户运行，避免权限问题）
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]