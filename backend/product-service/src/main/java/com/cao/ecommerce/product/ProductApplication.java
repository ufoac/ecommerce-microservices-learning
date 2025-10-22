package com.cao.ecommerce.product;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.jdbc.DataSourceAutoConfiguration;
import org.springframework.boot.autoconfigure.jdbc.DataSourceTransactionManagerAutoConfiguration;
import org.springframework.boot.autoconfigure.orm.jpa.HibernateJpaAutoConfiguration;
import org.springframework.cloud.client.discovery.EnableDiscoveryClient;

/**
 * 电商微服务商品服务启动类
 *
 * 技术要点：
 * 1. @SpringBootApplication：Spring Boot核心注解
 * 2. 第零阶段：独立运行，不依赖外部服务
 * 3. 商品服务负责商品管理、分类、库存等核心功能
 *
 * 面试要点：
 * - 微服务的垂直拆分原则：按业务领域拆分服务
 * - 商品服务在电商系统中的重要性：核心业务数据，高并发读写
 * - 渐进式开发：先确保服务独立运行，再逐步添加微服务特性
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
public class ProductApplication {

    public static void main(String[] args) {
        SpringApplication.run(ProductApplication.class, args);
        System.out.println("=================================");
        System.out.println("  商品服务启动成功！");
        System.out.println("  Product Service Started!");
        System.out.println("=================================");
    }
}