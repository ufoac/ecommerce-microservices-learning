package com.cao.ecommerce.common.config;

/**
 * Nacos服务注册发现配置常量
 *
 * 注意：Common模块不能包含Spring Boot依赖，这里只提供配置常量
 * 具体的@ConfigurationProperties配置由各个服务自行实现
 *
 * @author claude
 * @since 2025-10-22
 */
public class NacosDiscoveryConstants {

    /** 默认Nacos服务器地址 */
    public static final String DEFAULT_SERVER_ADDR = "localhost:18848";

    /** 默认命名空间 */
    public static final String DEFAULT_NAMESPACE = "public";

    /** 默认分组 */
    public static final String DEFAULT_GROUP = "DEFAULT_GROUP";

    /** 默认权重 */
    public static final double DEFAULT_WEIGHT = 1.0;

    /** 默认启用状态 */
    public static final boolean DEFAULT_ENABLED = true;

    /** 默认注册启用状态 */
    public static final boolean DEFAULT_REGISTER_ENABLED = true;
}