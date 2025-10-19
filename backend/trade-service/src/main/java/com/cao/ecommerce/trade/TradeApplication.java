package com.cao.ecommerce.trade;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.jdbc.DataSourceAutoConfiguration;
import org.springframework.boot.autoconfigure.jdbc.DataSourceTransactionManagerAutoConfiguration;
import org.springframework.boot.autoconfigure.orm.jpa.HibernateJpaAutoConfiguration;

/**
 * 电商微服务交易服务启动类
 *
 * 技术要点：
 * 1. @SpringBootApplication：Spring Boot核心注解
 * 2. 第零阶段：独立运行，不依赖外部服务
 * 3. 交易服务负责订单、支付、购物车等核心交易功能
 *
 * 面试要点：
 * - 分布式事务处理：交易服务涉及多个服务的数据一致性
 * - 渐进式开发：先确保服务独立运行，再逐步添加微服务特性
 * - 消息队列的应用：异步处理订单创建、支付通知等场景
 * - 幂等性设计：支付接口的幂等性保证
 *
 * @author cao
 * @version 1.0.0
 */
@SpringBootApplication(exclude = {
    DataSourceAutoConfiguration.class,
    DataSourceTransactionManagerAutoConfiguration.class,
    HibernateJpaAutoConfiguration.class
})
// @EnableDiscoveryClient 和 @EnableFeignClients 将在后续阶段统一添加
public class TradeApplication {

    public static void main(String[] args) {
        SpringApplication.run(TradeApplication.class, args);
        System.out.println("=================================");
        System.out.println("  交易服务启动成功！");
        System.out.println("  Trade Service Started!");
        System.out.println("=================================");
    }
}