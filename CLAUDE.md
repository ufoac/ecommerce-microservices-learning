# 项目上下文 - Claude AI 助手协作指南

## 📋 项目基本信息

| 项目信息 | 详情 |
|---------|------|
| **项目名称** | ecommerce-microservices-learning |
| **项目类型** | 电商交易领域微服务学习项目 |
| **核心目标** | 掌握企业级微服务架构和 DDD 实践 |

## 🗂️ AI 助手文档导航

> **工作流程**：了解项目状态 → 选择工作方法 → 遵循技术规范 → 应用开发模式 → 解决问题困难

| 文档 | 优先级 | 作用 |
|------|-------|------|
| **AI 工作流程** | 高 | 工具使用策略和任务执行规范 |
| **技术约束规范** | 高 | 架构约束、编码规范、技术边界 |
| **故障排查手册** | **高** | **含重要经验教训，避免重复犯错** |
| **开发模式指南** | 中 | 常见问题的标准解决方案 |
| **AI 文档导航** | 低 | AI 专用文档的使用指南 |

## 🚨 重要提醒

### 必读运维经验教训
- **健康检查失败**：不要猜测，要用 `docker inspect` 检查具体原因
- **配置修改后**：必须重新创建容器才能生效
- **Windows端口问题**：要检查系统端口分配限制，不要试错式选择
- **脚本编写**：Windows 环境优先 PowerShell，避免 bat 脚本
- **中文字符**：脚本中避免中文和特殊符号，建议优先使用英文编码问题。
- **PowerShell脚本中文支持**：UTF-8 BOM头 + 脚本开头插入`chcp 65001 | Out-Null`。
- **服务访问密码**：MySQL、Redis、Nacos等服务的认证信息存储在 `deploy/docker-compose/.env` 中，需要密码时请查找此文件。

### 工作原则
- **理解优先**：重点是理解技术概念和实现原理
- **功能优先**：先确保功能正确，再考虑优化
- **经验导向**：遇到问题时先查阅经验教训，不要猜测

## 当前实施阶段

### 已完成 - 第零阶段
- Maven 多模块项目结构搭建 ✅
- Docker 开发环境完整配置 ✅
- 所有微服务基础框架创建 ✅
- 基础设施服务验证通过 ✅
- 前端 Vue 3.4 项目初始化 ✅
- Windows PowerShell 脚本系统 v2.1 ✅

### 下一步计划 - 第一阶段
**高优先级任务**：
- [ ] 为各服务添加 Nacos 客户端依赖和配置
- [ ] 实现服务注册发现机制
- [ ] 配置网关动态路由规则
- [ ] 实现服务间 Feign 客户端调用

## 技术架构概览

### 微服务架构

| 服务 | 端口 | 核心职责 |
|------|------|----------|
| api-gateway | 28080 | 统一入口、认证授权、流量治理 |
| user-service | 28081 | 用户管理、身份认证、权限控制 |
| product-service | 28082 | 商品管理、库存控制、搜索服务 |
| trade-service | 28083 | 交易核心、订单处理、支付集成 |

### 技术栈版本
- **Spring Boot**: 3.2.x | **Spring Cloud**: 2023.0.x | **Spring Cloud Alibaba**: 2023.0.x
- **JDK**: 21 | **Vue**: 3.4 | **Nacos**: 2.x
- **MySQL**: 8.x | **Redis**: 7.x | **RocketMQ**: 5.x

## 🏛️ 工程结构

### 项目结构
```
ecommerce-microservices-learning/
├── frontend/                # Vue 3 前端应用
├── backend/                 # Spring Boot 微服务集群
│   ├── common/              # 通用组件模块
│   ├── api-gateway/         # API 网关服务
│   ├── user-service/        # 用户管理微服务
│   ├── product-service/     # 商品管理微服务
│   └── trade-service/       # 交易核心微服务
├── deploy/                  # 部署配置和脚本
├── docs/                    # 项目文档
│   └── ai/                  # AI 助手专用文档
├── infrastructure/          # 基础设施配置
├── README.md                # 项目说明文档
└── CLAUDE.md                # AI 助手项目记忆文件
```

### DDD 四层架构标准
- **interfaces** - 接口层（REST API、DTO）
- **application** - 应用层（业务流程编排）
- **domain** - 领域层（核心业务逻辑）
- **infrastructure** - 基础设施层（技术实现）

## 📞 快速链接

### 必读文档（按优先级）
1. **[AI工作流程](docs/ai/workflow.md)** - 选择工作方法（含脚本工具集说明）
2. **[技术约束](docs/ai/constraints.md)** - 架构和编码规范
3. **[故障排查手册](docs/ai/troubleshooting.md)** - 含重要经验教训，避免重复犯错
4. **[开发模式](docs/ai/patterns.md)** - 具体实现模式
5. **[AI文档导航](docs/ai/README.md)** - AI文档使用指南

### 🐳 PowerShell脚本工具集 (v2.1)
- **[build-images.ps1](deploy/scripts/windows/images/build-images.ps1)** - 智能构建脚本
- **[export-images.ps1](deploy/scripts/windows/images/export-images.ps1)** - 镜像导出脚本
- **[push-images.ps1](deploy/scripts/windows/images/push-images.ps1)** - 镜像推送脚本

**特性**：
- 统一配置管理，便于修改和维护
- 标准化输出格式和错误处理
- 完整的帮助文档和使用示例
- 智能文件变更检测和构建优化

### 项目文档
- **[业务需求](docs/需求.md)** - 6个核心业务场景
- **[开发计划](docs/开发计划.md)** - 22步完整实施计划
- **[项目说明](README.md)** - 项目整体介绍

---

**文档版本**: v4.1 (脚本优化版)
**最后更新**: 2025-10-20
**维护者**: Claude AI Assistant
**最新更新**: PowerShell脚本工具集优化至v2.1版本

> 💡 **使用提示**：
> 1. 本文档只保留核心信息，详细内容请查阅专门文档
> 2. 遇到环境问题时，优先使用命令检查，不要猜测