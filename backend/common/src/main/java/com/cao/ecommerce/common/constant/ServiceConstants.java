package com.cao.ecommerce.common.constant;

/**
 * 服务注册发现相关常量
 *
 * @author claude
 * @since 2025-10-22
 */
public class ServiceConstants {

    /**
     * Nacos服务注册相关常量
     */
    public static class Nacos {
        /** 默认命名空间 */
        public static final String DEFAULT_NAMESPACE = "public";

        /** 默认分组 */
        public static final String DEFAULT_GROUP = "DEFAULT_GROUP";

        /** 服务名前缀 */
        public static final String SERVICE_NAME_PREFIX = "ecommerce-";
    }

    /**
     * 服务端口定义
     */
    public static class Port {
        /** API网关端口 */
        public static final int GATEWAY = 28080;

        /** 用户服务端口 */
        public static final int USER_SERVICE = 28081;

        /** 商品服务端口 */
        public static final int PRODUCT_SERVICE = 28082;

        /** 交易服务端口 */
        public static final int TRADE_SERVICE = 28083;
    }

    /**
     * 服务名称定义
     */
    public static class ServiceName {
        /** API网关服务名 */
        public static final String GATEWAY = "api-gateway";

        /** 用户服务名 */
        public static final String USER_SERVICE = "user-service";

        /** 商品服务名 */
        public static final String PRODUCT_SERVICE = "product-service";

        /** 交易服务名 */
        public static final String TRADE_SERVICE = "trade-service";
    }
}