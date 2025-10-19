package com.cao.ecommerce.user;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.jdbc.DataSourceAutoConfiguration;
import org.springframework.boot.autoconfigure.jdbc.DataSourceTransactionManagerAutoConfiguration;
import org.springframework.boot.autoconfigure.orm.jpa.HibernateJpaAutoConfiguration;

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
// @EnableDiscoveryClient 将在第一阶段统一添加
public class UserApplication {

    public static void main(String[] args) {
        SpringApplication.run(UserApplication.class, args);
        System.out.println("=================================");
        System.out.println("  用户服务启动成功！");
        System.out.println("  User Service Started!");
        System.out.println("=================================");
    }
}