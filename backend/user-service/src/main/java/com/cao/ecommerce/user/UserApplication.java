package com.cao.ecommerce.user;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.client.discovery.EnableDiscoveryClient;

/**
 * 电商微服务用户服务启动类
 *
 * 技术要点：
 * 1. @SpringBootApplication：Spring Boot核心注解
 * 2. @EnableDiscoveryClient：启用服务发现功能，注册到Nacos
 * 3. 用户服务负责用户注册、登录、信息管理等核心功能
 *
 * 面试要点：
 * - 微服务的职责单一原则：用户服务只处理用户相关业务
 * - 服务注册发现的作用：实现服务的自动注册和发现，便于服务间调用
 * - Nacos作为注册中心的优势：支持动态配置、服务健康检查
 *
 * @author cao
 * @version 1.0.0
 */
@SpringBootApplication
@EnableDiscoveryClient
public class UserApplication {

    public static void main(String[] args) {
        SpringApplication.run(UserApplication.class, args);
        System.out.println("=================================");
        System.out.println("  用户服务启动成功！");
        System.out.println("  User Service Started!");
        System.out.println("=================================");
    }
}