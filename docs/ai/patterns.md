# 开发模式和最佳实践（学习项目版）

## 🎯 学习项目特点

### 渐进式学习理念
- **先基础，后高级**：从简单实现开始，逐步深入复杂概念
- **先功能，后优化**：先确保功能正确，再考虑性能优化
- **先模仿，后创新**：先学习现有模式，再尝试改进和创新
- **理论结合实践**：理解概念后立即通过代码验证

## 📚 常见开发场景

### 1. 新功能开发模式

#### 场景：实现新的业务功能
**学习优先流程**：
```
1. 理解需求 → 查阅需求文档，理解业务逻辑
2. 简单设计 → 明确需要什么接口和数据
3. 基础实现 → 实现核心功能，保持简单
4. 功能验证 → 确保基本功能正确
5. 逐步完善 → 添加必要的错误处理和验证
```

**第一阶段：基础实现（必须）**
- [ ] 理解业务需求和功能目标
- [ ] 设计基本的REST API接口
- [ ] 实现核心业务逻辑
- [ ] 确保基本功能可以工作

**第二阶段：逐步完善（建议）**
- [ ] 添加输入参数验证
- [ ] 完善错误处理机制
- [ ] 优化数据库查询
- [ ] 添加必要的日志

**第三阶段：深入实践（可选）**
- [ ] 添加缓存机制
- [ ] 实现异步处理
- [ ] 性能优化
- [ ] 完善测试覆盖

#### 简化的接口设计示例
```java
@RestController
@RequestMapping("/api/users")
public class UserController {

    @PostMapping
    public Result<User> createUser(@RequestBody CreateUserRequest request) {
        // 第一阶段：基本实现
        try {
            User user = userService.createUser(request);
            return Result.success(user);
        } catch (Exception e) {
            return Result.failure("创建用户失败: " + e.getMessage());
        }
    }

    @GetMapping("/{id}")
    public Result<User> getUser(@PathVariable Long id) {
        // 简单实现，直接查询数据库
        User user = userService.getUserById(id);
        if (user == null) {
            return Result.failure("用户不存在");
        }
        return Result.success(user);
    }
}
```

### 2. 问题修复模式

#### 场景：修复功能问题
**学习导向修复流程**：
```
1. 问题复现 → 获取详细的错误信息和步骤
2. 理解原因 → 分析为什么会出现这个问题
3. 解决方案 → 设计最简单的修复方法
4. 实施修复 → 修改代码
5. 验证结果 → 确保问题解决且不引入新问题
6. 学习总结 → 记录问题原因和解决方法
```

**修复原则**：
- **最小化修改**：只修改必要的代码
- **理解根源**：搞清楚问题的根本原因
- **学习导向**：从修复中学习相关知识
- **防止再犯**：思考如何避免类似问题

#### 常见问题类型和解决思路

**空指针异常**
```java
// 问题代码
User user = userService.getUserById(userId);
return user.getName(); // 可能空指针

// 修复方案1：简单检查
User user = userService.getUserById(userId);
if (user != null) {
    return user.getName();
}
return null;

// 修复方案2：更健壮的实现
Optional<User> userOpt = Optional.ofNullable(userService.getUserById(userId));
return userOpt.map(User::getName).orElse("默认用户名");
```

**数据库连接问题**
```java
// 问题：没有处理数据库异常
public User getUser(Long id) {
    return userRepository.findById(id);
}

// 修复：添加异常处理
public User getUser(Long id) {
    try {
        return userRepository.findById(id);
    } catch (Exception e) {
        log.error("查询用户失败, id={}", id, e);
        throw new BusinessException("USER_NOT_FOUND", "用户不存在");
    }
}
```

### 3. 数据库操作模式

#### 基础CRUD实现（第一阶段）
```java
@Service
public class UserService {

    @Autowired
    private UserMapper userMapper;

    public User createUser(CreateUserRequest request) {
        // 基础验证
        if (request.getUsername() == null || request.getUsername().isEmpty()) {
            throw new BusinessException("INVALID_USERNAME", "用户名不能为空");
        }

        // 创建用户对象
        User user = new User();
        user.setUsername(request.getUsername());
        user.setEmail(request.getEmail());
        user.setPassword(passwordEncoder.encode(request.getPassword()));
        user.setCreateTime(new Date());
        user.setUpdateTime(new Date());

        // 保存到数据库
        userMapper.insert(user);
        return user;
    }

    public User getUserById(Long id) {
        return userMapper.selectById(id);
    }

    public User updateUser(Long id, UpdateUserRequest request) {
        User user = getUserById(id);
        if (user == null) {
            throw new BusinessException("USER_NOT_FOUND", "用户不存在");
        }

        // 更新字段
        if (request.getEmail() != null) {
            user.setEmail(request.getEmail());
        }
        user.setUpdateTime(new Date());

        userMapper.updateById(user);
        return user;
    }
}
```

#### 简单的查询优化（第二阶段）
```java
public List<User> searchUsers(String keyword, Integer page, Integer size) {
    // 第一阶段：简单查询
    if (keyword == null || keyword.isEmpty()) {
        return userMapper.selectAll();
    }

    // 第二阶段：添加条件查询
    QueryWrapper<User> wrapper = new QueryWrapper<>();
    wrapper.like("username", keyword)
           .or()
           .like("email", keyword);

    // 第三阶段：添加分页
    if (page != null && size != null) {
        wrapper.last("LIMIT " + size + " OFFSET " + ((page - 1) * size));
    }

    return userMapper.selectList(wrapper);
}
```

### 4. 服务间调用模式

#### 基础Feign调用实现
```java
// 1. 定义Feign客户端
@FeignClient(name = "product-service")
public interface ProductServiceClient {

    @GetMapping("/api/products/{id}")
    Result<Product> getProduct(@PathVariable("id") Long id);

    @PostMapping("/api/products/decrease-stock")
    Result<Void> decreaseStock(@RequestBody DecreaseStockRequest request);
}

// 2. 在业务服务中使用
@Service
public class OrderService {

    @Autowired
    private ProductServiceClient productServiceClient;

    @Transactional
    public Order createOrder(CreateOrderRequest request) {
        // 第一阶段：基本实现
        // 1. 验证商品
        Result<Product> productResult = productServiceClient.getProduct(request.getProductId());
        if (!productResult.isSuccess() || productResult.getData() == null) {
            throw new BusinessException("PRODUCT_NOT_FOUND", "商品不存在");
        }

        Product product = productResult.getData();

        // 2. 检查库存
        if (product.getStock() < request.getQuantity()) {
            throw new BusinessException("INSUFFICIENT_STOCK", "库存不足");
        }

        // 3. 创建订单
        Order order = new Order();
        order.setUserId(request.getUserId());
        order.setProductId(request.getProductId());
        order.setQuantity(request.getQuantity());
        order.setPrice(product.getPrice());
        order.setStatus("PENDING");
        order.setCreateTime(new Date());

        orderMapper.insert(order);

        // 第二阶段：调用商品服务减库存
        try {
            DecreaseStockRequest decreaseRequest = new DecreaseStockRequest();
            decreaseRequest.setProductId(request.getProductId());
            decreaseRequest.setQuantity(request.getQuantity());

            Result<Void> decreaseResult = productServiceClient.decreaseStock(decreaseRequest);
            if (!decreaseResult.isSuccess()) {
                throw new BusinessException("STOCK_DECREASE_FAILED", "库存扣减失败");
            }

            // 更新订单状态
            order.setStatus("CONFIRMED");
            orderMapper.updateById(order);

        } catch (Exception e) {
            // 回滚订单状态
            order.setStatus("FAILED");
            orderMapper.updateById(order);
            throw new BusinessException("ORDER_CREATE_FAILED", "订单创建失败");
        }

        return order;
    }
}
```

#### 错误处理和熔断（第二阶段）
```java
@Component
public class ProductServiceFallback implements ProductServiceClient {

    @Override
    public Result<Product> getProduct(Long id) {
        log.warn("商品服务不可用，使用降级处理, productId={}", id);
        return Result.failure("PRODUCT_SERVICE_UNAVAILABLE", "商品服务暂时不可用");
    }

    @Override
    public Result<Void> decreaseStock(DecreaseStockRequest request) {
        log.warn("商品服务不可用，库存扣减失败, productId={}", request.getProductId());
        return Result.failure("PRODUCT_SERVICE_UNAVAILABLE", "商品服务暂时不可用");
    }
}
```

### 5. 认证授权模式

#### 基础JWT实现（第一阶段）
```java
@Service
public class AuthService {

    @Value("${jwt.secret}")
    private String jwtSecret;

    @Value("${jwt.expiration}")
    private Long jwtExpiration;

    public String generateToken(String username, Long userId) {
        Date now = new Date();
        Date expiryDate = new Date(now.getTime() + jwtExpiration);

        return Jwts.builder()
                .setSubject(username)
                .claim("userId", userId)
                .setIssuedAt(now)
                .setExpiration(expiryDate)
                .signWith(SignatureAlgorithm.HS512, jwtSecret)
                .compact();
    }

    public boolean validateToken(String token) {
        try {
            Jwts.parser().setSigningKey(jwtSecret).parseClaimsJws(token);
            return true;
        } catch (JwtException | IllegalArgumentException e) {
            return false;
        }
    }

    public Long getUserIdFromToken(String token) {
        Claims claims = Jwts.parser()
                .setSigningKey(jwtSecret)
                .parseClaimsJws(token)
                .getBody();
        return claims.get("userId", Long.class);
    }
}
```

#### 基础认证过滤器（第二阶段）
```java
@Component
public class JwtAuthenticationFilter extends OncePerRequestFilter {

    @Autowired
    private AuthService authService;

    @Override
    protected void doFilterInternal(HttpServletRequest request,
                                  HttpServletResponse response,
                                  FilterChain filterChain) throws ServletException, IOException {

        String token = getTokenFromRequest(request);

        if (token != null && authService.validateToken(token)) {
            Long userId = authService.getUserIdFromToken(token);
            // 设置用户信息到请求上下文
            SecurityContextHolder.getContext().setAuthentication(
                new JwtAuthenticationToken(userId, null)
            );
        }

        filterChain.doFilter(request, response);
    }

    private String getTokenFromRequest(HttpServletRequest request) {
        String bearerToken = request.getHeader("Authorization");
        if (bearerToken != null && bearerToken.startsWith("Bearer ")) {
            return bearerToken.substring(7);
        }
        return null;
    }
}
```

### 6. 缓存使用模式

#### 基础缓存实现（第一阶段）
```java
@Service
public class ProductService {

    @Autowired
    private ProductMapper productMapper;

    @Autowired
    private RedisTemplate<String, Object> redisTemplate;

    public Product getProduct(Long productId) {
        String cacheKey = "product:" + productId;

        // 1. 先查缓存
        Product product = (Product) redisTemplate.opsForValue().get(cacheKey);

        if (product == null) {
            // 2. 缓存未命中，查数据库
            product = productMapper.selectById(productId);

            if (product != null) {
                // 3. 写入缓存，设置30分钟过期
                redisTemplate.opsForValue().set(cacheKey, product, 30, TimeUnit.MINUTES);
            }
        }

        return product;
    }

    public void updateProduct(Product product) {
        // 1. 更新数据库
        productMapper.updateById(product);

        // 2. 删除缓存，下次访问时重新加载
        String cacheKey = "product:" + product.getId();
        redisTemplate.delete(cacheKey);
    }
}
```

#### 简单的缓存防击穿（第二阶段）
```java
public Product getProductWithLock(Long productId) {
    String cacheKey = "product:" + productId;
    String lockKey = "lock:product:" + productId;

    Product product = (Product) redisTemplate.opsForValue().get(cacheKey);

    if (product == null) {
        // 尝试获取分布式锁
        Boolean locked = redisTemplate.opsForValue().setIfAbsent(lockKey, "locked", 10, TimeUnit.SECONDS);

        if (Boolean.TRUE.equals(locked)) {
            try {
                // 双重检查
                product = (Product) redisTemplate.opsForValue().get(cacheKey);
                if (product == null) {
                    product = productMapper.selectById(productId);
                    if (product != null) {
                        redisTemplate.opsForValue().set(cacheKey, product, 30, TimeUnit.MINUTES);
                    }
                }
            } finally {
                // 释放锁
                redisTemplate.delete(lockKey);
            }
        } else {
            // 等待并重试
            try {
                Thread.sleep(100);
                return getProduct(productId);
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
                return null;
            }
        }
    }

    return product;
}
```

## 🔍 常见问题和解决方案

### 1. 环境问题解决

#### Docker 容器启动失败
```bash
# 检查容器状态
docker ps -a

# 查看日志
docker logs <container_name>

# 重新构建和启动
docker-compose down
docker-compose up -d --build
```

#### 端口冲突解决
```bash
# 查看端口占用
netstat -tulpn | grep <port>

# 修改配置文件中的端口
# 例如：将MySQL端口从3306改为3307
```

### 2. 依赖问题解决

#### Maven 依赖冲突
```xml
<!-- 在父POM中使用dependencyManagement统一版本 -->
<dependencyManagement>
    <dependencies>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-dependencies</artifactId>
            <version>${spring-boot.version}</version>
            <type>pom</type>
            <scope>import</scope>
        </dependency>
    </dependencies>
</dependencyManagement>
```

#### 依赖版本不兼容
```bash
# 查看依赖树
mvn dependency:tree

# 强制更新依赖
mvn clean install -U
```

### 3. 代码质量问题解决

#### 重复代码提取
```java
// 重复代码示例
public void createUser1() {
    if (username == null || username.isEmpty()) {
        throw new BusinessException("INVALID_USERNAME", "用户名不能为空");
    }
    // 其他逻辑...
}

public void createUser2() {
    if (username == null || username.isEmpty()) {
        throw new BusinessException("INVALID_USERNAME", "用户名不能为空");
    }
    // 其他逻辑...
}

// 提取公共验证方法
private void validateUsername(String username) {
    if (username == null || username.isEmpty()) {
        throw new BusinessException("INVALID_USERNAME", "用户名不能为空");
    }
}
```

#### 异常处理统一化
```java
@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(BusinessException.class)
    public Result<Void> handleBusinessException(BusinessException e) {
        return Result.failure(e.getCode(), e.getMessage());
    }

    @ExceptionHandler(Exception.class)
    public Result<Void> handleException(Exception e) {
        log.error("系统异常", e);
        return Result.failure("SYSTEM_ERROR", "系统异常，请稍后重试");
    }
}
```

## 📈 学习路径建议

### 第一阶段：基础能力培养（1-2周）
- [ ] 理解基本的微服务概念
- [ ] 掌握Spring Boot基础用法
- [ ] 实现基本的CRUD功能
- [ ] 学会使用Docker基础命令

### 第二阶段：架构理解（2-3周）
- [ ] 理解DDD分层架构
- [ ] 掌握RESTful API设计
- [ ] 学习服务间调用（Feign）
- [ ] 实现基础的认证授权

### 第三阶段：实践应用（3-4周）
- [ ] 实现完整的业务功能
- [ ] 学习缓存和消息队列使用
- [ ] 掌握基本的性能优化
- [ ] 完善错误处理和日志

### 第四阶段：深入探索（持续学习）
- [ ] 学习分布式事务处理
- [ ] 掌握高级设计模式
- [ ] 实践性能监控和调优
- [ ] 了解云原生技术

---

**文档版本**: v2.0 (学习项目版)
**适用场景**: 学习项目开发中的常见问题处理
**核心原则**: 渐进式学习，实践优先，理解为本
**更新策略**: 根据学习进度和实际遇到的问题持续补充