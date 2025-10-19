package com.cao.ecommerce.gateway;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.jdbc.DataSourceAutoConfiguration;
import org.springframework.boot.autoconfigure.jdbc.DataSourceTransactionManagerAutoConfiguration;
import org.springframework.boot.autoconfigure.orm.jpa.HibernateJpaAutoConfiguration;

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
// @EnableDiscoveryClient 将在第一阶段统一添加
public class GatewayApplication {

    public static void main(String[] args) {
        SpringApplication.run(GatewayApplication.class, args);
        System.out.println("=================================");
        System.out.println("  电商API网关启动成功！");
        System.out.println("  Gateway Application Started!");
        System.out.println("=================================");
    }
}