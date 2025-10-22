# AI 设计约束指南

## 核心约束（必须遵守）

### Common 模块约束（绝对禁止）
**关键教训**：Common是共享组件，不是业务服务

**禁止内容**：
- Web依赖：`spring-boot-starter-web`
- Web注解：`@RestController`、`@RequestMapping`
- Controller类、Service类、业务逻辑

**只能包含**：
- DTO类、常量、异常、工具类、枚举、注解

### 微服务边界
- **User Service**：用户注册、登录、权限管理
- **Product Service**：商品管理、库存控制、搜索
- **Trade Service**：订单处理、购物车、支付
- **API Gateway**：路由转发、基础认证、限流

**基本要求**：
- 服务间通过API调用，不直接访问数据库
- 避免功能职责混乱
- 保持服务边界清晰

### DDD 分层架构
```
interfaces/     # 接口层 - REST API、请求响应
application/    # 应用层 - 业务流程协调
domain/         # 领域层 - 核心业务逻辑
infrastructure/ # 基础设施层 - 数据库、外部服务
```

**基本要求**：
- 避免跨层直接调用
- 保持领域层的相对独立性
- 理解分层概念和职责边界

## 项目规范（必须遵守）

### 包命名规范
```
根包名: com.cao.ecommerce
服务包名: com.cao.ecommerce.{service}
通用包名: com.cao.ecommerce.common
```

### 类命名规范
| 类型 | 命名模式 | 示例 |
|------|----------|------|
| 实体类 | 名词，驼峰 | User, Product, Order |
| 服务类 | 名词+Service | UserService, ProductService |
| 控制器 | 名词+Controller | UserController, ProductController |
| DTO类 | 名词+DTO/Request/Response | UserDTO, CreateUserRequest |

### 方法命名规范
- 查询方法：findXxx, getXxx, searchXxx
- 操作方法：createXxx, updateXxx, deleteXxx
- 验证方法：validateXxx, checkXxx

## 技术栈约束（严格使用）

### 框架版本
```xml
<properties>
    <spring-boot.version>3.2.x</spring-boot.version>
    <spring-cloud.version>2023.0.x</spring-cloud.version>
    <spring-cloud-alibaba.version>2023.0.x</spring-cloud-alibaba.version>
</properties>
```

### 基本要求
- 使用项目已有的技术栈版本
- 避免引入不必要的新依赖
- 基础配置统一管理

## API 设计规范

### 响应格式（统一使用）
```json
{
  "code": 200,
  "message": "success",
  "data": {},
  "timestamp": 1234567890
}
```

### 错误码定义
- **200**：成功
- **400**：请求参数错误
- **401**：未授权
- **404**：资源不存在
- **500**：服务器内部错误
- **1000-1999**：业务错误码（按需添加）

## 数据库规范

### 表结构规范
- **表名**：单数蛇形命名（user, product, order）
- **字段名**：蛇形命名（user_id, create_time）
- **基础字段**：id, create_time, update_time
- **主键**：BIGINT 类型，自增ID

### 数据类型规范
| 字段类型 | 适用场景 | 示例 |
|---------|----------|------|
| BIGINT | 主键、ID | user_id, order_id |
| DECIMAL(10,2) | 金额字段 | price, amount |
| DATETIME | 时间字段 | create_time, update_time |
| TINYINT | 状态字段 | status, type |
| VARCHAR | 字符串字段 | name, description |

### 索引规范
- **唯一索引**：uk_ 前缀（如 uk_user_email）
- **普通索引**：idx_ 前缀（如 idx_user_status）
- **原则**：按需添加，不过度优化

## 安全约束

### 基础安全（必须实现）
- **密码存储**：使用 BCrypt 加密
- **输入验证**：基本的参数校验
- **接口鉴权**：业务接口需要进行权限验证

### 学习项目暂不要求
- 复杂的安全策略
- 高级加密算法
- 复杂的权限控制

## 编码规范

### Git 提交规范
```bash
<type>(<scope>): <subject>
```

**类型说明**：
- feat: 新功能
- fix: 修复问题
- docs: 文档更新
- style: 代码格式调整
- refactor: 代码重构
- test: 测试相关
- chore: 构建工具或辅助工具变动

### 分支管理
- **main**：主分支，稳定代码
- **develop**：开发分支
- **feature/***：功能开发分支
- **hotfix/***：紧急修复分支

## 性能参考（学习项目宽松标准）

### 响应时间
- **API响应**：< 1s（功能优先）
- **数据库查询**：< 500ms（基础查询）
- **缓存命中**：< 50ms（使用缓存时）

### 资源使用
- 合理使用内存，避免明显泄漏
- 数据库连接池配置合理
- 不要求严格的资源限制

## 禁止事项（绝对避免）

### 架构约束
- 跨层直接调用（如 interfaces → domain）
- 在Controller中实现复杂业务逻辑
- 微服务间直接访问数据库
- 忽略基本的安全要求
- **Common模块包含Web依赖或Controller类**

### 编码约束
- 硬编码敏感信息
- 忽略基本异常处理
- 不遵循命名规范
- 提交不规范的代码

---

**文档定位**：AI设计约束指南，提供项目特有的技术和设计限制
**使用原则**：生成代码和设计方案时，必须遵守这些项目特定约束
**核心价值**：确保AI生成的内容符合项目架构和规范要求