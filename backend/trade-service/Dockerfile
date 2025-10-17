# 使用多阶段构建优化镜像大小
FROM maven:3.9.11-openjdk-21-slim AS builder

# 设置工作目录
WORKDIR /app

# 复制pom.xml文件并下载依赖（利用Docker层缓存）
COPY pom.xml .
COPY ../pom.xml ../
COPY ../common ../common

# 下载依赖
RUN mvn dependency:go-offline -B

# 复制源代码
COPY src ./src

# 构建应用
RUN mvn clean package -DskipTests

# 运行时镜像
FROM openjdk:21-jre-slim

# 安装必要的工具
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

# 设置工作目录
WORKDIR /app

# 创建非root用户
RUN groupadd -r appuser && useradd -r -g appuser appuser

# 从构建阶段复制jar包
COPY --from=builder /app/target/*.jar app.jar

# 设置文件权限
RUN chown -R appuser:appuser /app

# 切换到非root用户
USER appuser

# 暴露端口
EXPOSE 8083

# 设置JVM参数（交易服务需要更多内存处理消息队列）
ENV JAVA_OPTS="-Xms512m -Xmx1536m -XX:+UseG1GC -XX:+UseContainerSupport"

# 健康检查
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD curl -f http://localhost:8083/actuator/health || exit 1

# 启动命令
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]