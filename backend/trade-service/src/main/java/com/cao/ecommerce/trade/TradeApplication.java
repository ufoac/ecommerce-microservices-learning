package com.cao.ecommerce.trade;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.client.discovery.EnableDiscoveryClient;
import org.springframework.cloud.openfeign.EnableFeignClients;

/**
 * 电商微服务交易服务启动类
 *
 * 技术要点：
 * 1. @SpringBootApplication：Spring Boot核心注解
 * 2. @EnableDiscoveryClient：启用服务发现功能，注册到Nacos
 * 3. @EnableFeignClients：启用OpenFeign客户端，用于服务间调用
 * 4. 交易服务负责订单、支付、购物车等核心交易功能
 *
 * 面试要点：
 * - 分布式事务处理：交易服务涉及多个服务的数据一致性
 * - OpenFeign的作用：声明式的HTTP客户端，简化服务间调用
 * - 消息队列的应用：异步处理订单创建、支付通知等场景
 * - 幂等性设计：支付接口的幂等性保证
 *
 * @author cao
 * @version 1.0.0
 */
@SpringBootApplication
@EnableDiscoveryClient
@EnableFeignClients
public class TradeApplication {

    public static void main(String[] args) {
        SpringApplication.run(TradeApplication.class, args);
        System.out.println("=================================");
        System.out.println("  交易服务启动成功！");
        System.out.println("  Trade Service Started!");
        System.out.println("=================================");
    }
}