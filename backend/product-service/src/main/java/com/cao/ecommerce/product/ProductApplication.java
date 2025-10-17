package com.cao.ecommerce.product;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.client.discovery.EnableDiscoveryClient;

/**
 * 电商微服务商品服务启动类
 *
 * 技术要点：
 * 1. @SpringBootApplication：Spring Boot核心注解
 * 2. @EnableDiscoveryClient：启用服务发现功能，注册到Nacos
 * 3. 商品服务负责商品管理、分类、库存等核心功能
 *
 * 面试要点：
 * - 微服务的垂直拆分原则：按业务领域拆分服务
 * - 商品服务在电商系统中的重要性：核心业务数据，高并发读写
 * - 数据库设计考虑：商品表结构设计、索引优化、分库分表策略
 *
 * @author cao
 * @version 1.0.0
 */
@SpringBootApplication
@EnableDiscoveryClient
public class ProductApplication {

    public static void main(String[] args) {
        SpringApplication.run(ProductApplication.class, args);
        System.out.println("=================================");
        System.out.println("  商品服务启动成功！");
        System.out.println("  Product Service Started!");
        System.out.println("=================================");
    }
}