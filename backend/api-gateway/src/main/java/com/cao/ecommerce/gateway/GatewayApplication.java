package com.cao.ecommerce.gateway;

import com.cao.ecommerce.common.util.ConfigPrinter;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.jdbc.DataSourceAutoConfiguration;
import org.springframework.boot.autoconfigure.jdbc.DataSourceTransactionManagerAutoConfiguration;
import org.springframework.boot.autoconfigure.orm.jpa.HibernateJpaAutoConfiguration;
import org.springframework.cloud.client.discovery.EnableDiscoveryClient;
import org.springframework.context.ConfigurableApplicationContext;
import org.springframework.core.env.Environment;

/**
 * 电商微服务API网关启动类
 *
 * 技术要点：
 * 1. @SpringBootApplication：Spring Boot核心注解，包含自动配置、组件扫描等
 * 2. 第零阶段：独立运行，基础路由配置
 * 3. API网关作为请求入口，负责路由转发和统一处理
 *
 * 面试要点：
 * - API网关的作用：路由转发、负载均衡、认证授权、限流熔断
 * - Spring Cloud Gateway基于WebFlux，是响应式编程模型
 * - 与Zuul的区别：性能更好，支持非阻塞IO
 * - 渐进式开发：先配置基础路由，再逐步添加高级特性
 *
 * @author cao
 * @version 1.0.0
 */
@SpringBootApplication(exclude = {
        DataSourceAutoConfiguration.class,
        DataSourceTransactionManagerAutoConfiguration.class,
        HibernateJpaAutoConfiguration.class
})
@EnableDiscoveryClient
public class GatewayApplication {

    public static void main(String[] args) {
        ConfigurableApplicationContext context = SpringApplication.run(GatewayApplication.class, args);

        // 打印配置信息
        Environment env = context.getEnvironment();
        ConfigPrinter.printConfig("网关服务", getConfigurationMap(env));

        System.out.println("=================================");
        System.out.println("  电商API网关启动成功！");
        System.out.println("  Gateway Application Started!");
        System.out.println("=================================");
    }

    /**
     * 获取配置信息Map
     */
    private static java.util.Map<String, Object> getConfigurationMap(Environment env) {
        java.util.Map<String, Object> configMap = new java.util.HashMap<>();

        // 基础配置
        configMap.put("server.port", env.getProperty("server.port"));
        configMap.put("spring.application.name", env.getProperty("spring.application.name"));

        // Nacos配置
        configMap.put("spring.cloud.nacos.discovery.server-addr", env.getProperty("spring.cloud.nacos.discovery.server-addr"));
        configMap.put("spring.cloud.nacos.discovery.namespace", env.getProperty("spring.cloud.nacos.discovery.namespace"));
        configMap.put("spring.cloud.nacos.discovery.group", env.getProperty("spring.cloud.nacos.discovery.group"));
        configMap.put("spring.cloud.nacos.discovery.username", env.getProperty("spring.cloud.nacos.discovery.username"));
        configMap.put("spring.cloud.nacos.discovery.password", env.getProperty("spring.cloud.nacos.discovery.password"));
        configMap.put("spring.cloud.nacos.discovery.enabled", env.getProperty("spring.cloud.nacos.discovery.enabled"));
        configMap.put("spring.cloud.nacos.discovery.register-enabled", env.getProperty("spring.cloud.nacos.discovery.register-enabled"));

        // 数据库配置（虽然目前注释掉，但仍然获取）
        configMap.put("spring.datasource.driver-class-name", env.getProperty("spring.datasource.driver-class-name"));
        configMap.put("spring.datasource.url", env.getProperty("spring.datasource.url"));
        configMap.put("spring.datasource.username", env.getProperty("spring.datasource.username"));
        configMap.put("spring.datasource.password", env.getProperty("spring.datasource.password"));

        // Redis配置
        configMap.put("spring.data.redis.host", env.getProperty("spring.data.redis.host"));
        configMap.put("spring.data.redis.port", env.getProperty("spring.data.redis.port"));
        configMap.put("spring.data.redis.password", env.getProperty("spring.data.redis.password"));
        configMap.put("spring.data.redis.database", env.getProperty("spring.data.redis.database"));

        // MyBatis配置
        configMap.put("mybatis-plus.configuration.map-underscore-to-camel-case", env.getProperty("mybatis-plus.configuration.map-underscore-to-camel-case"));
        configMap.put("mybatis-plus.configuration.log-impl", env.getProperty("mybatis-plus.configuration.log-impl"));
        configMap.put("mybatis-plus.global-config.db-config.logic-delete-field", env.getProperty("mybatis-plus.global-config.db-config.logic-delete-field"));
        configMap.put("mybatis-plus.global-config.db-config.logic-delete-value", env.getProperty("mybatis-plus.global-config.db-config.logic-delete-value"));
        configMap.put("mybatis-plus.global-config.db-config.logic-not-delete-value", env.getProperty("mybatis-plus.global-config.db-config.logic-not-delete-value"));

        // 日志配置
        configMap.put("logging.level.com.cao.ecommerce", env.getProperty("logging.level.com.cao.ecommerce"));
        configMap.put("logging.level.com.cao.ecommerce.gateway.mapper", env.getProperty("logging.level.com.cao.ecommerce.gateway.mapper"));
        configMap.put("logging.pattern.console", env.getProperty("logging.pattern.console"));

        // 管理端点配置
        configMap.put("management.endpoints.web.exposure.include", env.getProperty("management.endpoints.web.exposure.include"));
        configMap.put("management.endpoint.health.show-details", env.getProperty("management.endpoint.health.show-details"));

        return configMap;
    }
}