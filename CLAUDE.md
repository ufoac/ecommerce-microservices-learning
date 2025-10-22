# 项目上下文 - AI助手协作指南

## 项目基本信息
- **项目名称**: ecommerce-microservices-learning
- **项目类型**: 电商交易领域微服务学习项目
- **核心目标**: 掌握企业级微服务架构和DDD实践
- **当前阶段**: 基础设施搭建完成，微服务技术骨架实现中

## 微服务架构
- **api-gateway**: 28080 - 统一入口、认证授权、流量治理
- **user-service**: 28081 - 用户管理、身份认证、权限控制
- **product-service**: 28082 - 商品管理、库存控制、搜索服务
- **trade-service**: 28083 - 交易核心、订单处理、支付集成

## 核心约束
### 必须遵守的约束
- **容器重建**: 配置修改后必须`docker-compose down`再`up`，restart无效
- **镜像构建**: 代码/配置修改后，如果还要正式走容器验证，必须重新构建镜像
- **Common模块**: 禁止Web依赖，只能包含DTO、常量、异常、工具类
- **构建顺序**: 先构建common模块，再构建具体服务

### 脚本执行规则
- **PowerShell脚本**: `powershell.exe -ExecutionPolicy Bypass -File "script.ps1"`
- **工作目录**: docker-compose命令在`deploy/docker-compose/`，脚本在项目根目录
- **网络通信**: 容器间使用服务名，本地使用localhost

## 关键认证信息
- **MySQL**: root/root123456, ecommerce/ecommerce123, localhost:3306/mysql:3306
- **Nacos**: nacos/nacos, localhost:18848/nacos:8848
- **Redis**: redis123456, localhost:6379/redis:6379
- **数据库名**: ecommerce

## 核心工作流程
### 验证方式选择
- **本地验证**: 单服务开发、API调试、快速启动 → `mvn spring-boot:run`
- **容器验证**: 跨服务测试、提交前验证 → 构建镜像+compose启动

### 标准修改流程
1. **代码/配置修改**
2. **选择验证方式**（本地或容器）
3. **执行验证**（参考[AI工作流程](docs/ai/workflow.md)）
4. **确认功能正常**

## 项目目录结构

### 核心目录
- **backend/** - 后端微服务
  - **common/** - 公共模块（DTO、常量、工具类，禁止Web依赖）
  - **api-gateway/** - API网关服务 (28080)
  - **user-service/** - 用户服务 (28081)
  - **product-service/** - 商品服务 (28082)
  - **trade-service/** - 交易服务 (28083)

### 部署目录
- **deploy/** - 部署相关
  - **docker-compose/** - Docker编排文件
    - **.env** - 环境变量配置
    - **docker-compose.infra.yml** - 基础设施编排
    - **docker-compose.apps.yml** - 应用服务编排
  - **scripts/** - 部署脚本
    - **windows/** - PowerShell脚本
      - **images/build-images.ps1** - 镜像构建脚本
      - **deploy/start-all.ps1** - 服务启动脚本
      - **deploy/stop-all.ps1** - 服务停止脚本

### 文档目录
- **docs/** - 项目文档
  - **ai/** - AI协作专用文档
  - **开发计划.md**
  - **需求.md**

### 前端目录
- **frontend/** - Vue.js前端应用

### 关键文件路径
- **各服务启动类**: `backend/{service}/src/main/java/com/cao/ecommerce/{service}/*Application.java`
- **各服务配置**: `backend/{service}/src/main/resources/application.yml`
- **父级POM**: `backend/pom.xml`
- **Common模块**: `backend/common/src/main/java/com/cao/ecommerce/common/`

### 基础设施
- **infrastructure/** - 基础设施配置
  - **database/** - 数据库相关
  - **nginx/** - Nginx配置
  - **monitoring/** - 监控配置

## 常用脚本速查
```bash
# 构建镜像
build-images.ps1 -Target all
build-images.ps1 -Target [user|product|trade|gateway]

# 容器管理
start-all.ps1
stop-all.ps1
start-all.ps1 -Target [service-name]

# Docker Compose (工作目录: deploy/docker-compose/)
docker-compose -f docker-compose.apps.yml down
docker-compose -f docker-compose.apps.yml up -d
```

## 文档导航
### 必读文档（按优先级）
- **[故障排查指南](docs/ai/troubleshooting.md)** - 环境问题、容器故障、配置错误排查
- **[脚本使用指南](docs/ai/scripts-guide.md)** - 详细脚本操作说明
- **[AI工作流程](docs/ai/workflow.md)** - 详细的开发流程和操作规范

### 使用原则
- **docs/ai/**: 详细操作指南和故障排查
- **遇到困难问题时**: 先查看troubleshooting.md

## AI文档设计原则
面向AI、项目特有、增强能力、高信息密度。遇到问题先查阅troubleshooting.md。

---

**重要提醒**: 遇到问题时，请优先查阅[故障排查指南](docs/ai/troubleshooting.md)