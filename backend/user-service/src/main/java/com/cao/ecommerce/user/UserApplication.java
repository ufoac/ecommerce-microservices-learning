package com.cao.ecommerce.user;

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
 * 电商微服务用户服务启动类
 *
 * 技术要点：
 * 1. @SpringBootApplication：Spring Boot核心注解
 * 2. 第零阶段：独立运行，不依赖外部服务
 * 3. 用户服务负责用户注册、登录、信息管理等核心功能
 *
 * 面试要点：
 * - 微服务的职责单一原则：用户服务只处理用户相关业务
 * - 渐进式开发：先确保服务独立运行，再逐步添加微服务特性
 * - Spring Boot自动配置：简化开发，提高效率
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
public class UserApplication {

    public static void main(String[] args) {
        ConfigurableApplicationContext context = SpringApplication.run(UserApplication.class, args);

        // 打印配置信息
        Environment env = context.getEnvironment();
        ConfigPrinter.printConfig("用户服务", getConfigurationMap(env));

        System.out.println("=================================");
        System.out.println("  用户服务启动成功！");
        System.out.println("  User Service Started!");
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
        configMap.put("logging.level.com.cao.ecommerce.user.mapper", env.getProperty("logging.level.com.cao.ecommerce.user.mapper"));
        configMap.put("logging.pattern.console", env.getProperty("logging.pattern.console"));

        // 管理端点配置
        configMap.put("management.endpoints.web.exposure.include", env.getProperty("management.endpoints.web.exposure.include"));
        configMap.put("management.endpoint.health.show-details", env.getProperty("management.endpoint.health.show-details"));

        return configMap;
    }
}