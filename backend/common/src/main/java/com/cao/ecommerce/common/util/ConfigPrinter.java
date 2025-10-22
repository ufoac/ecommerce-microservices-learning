package com.cao.ecommerce.common.util;

import java.util.Map;
import java.util.TreeMap;

/**
 * 配置打印工具类
 *
 * 设计原则：
 * 1. 纯Java实现，不依赖Spring Boot
 * 2. 通过方法参数接收配置信息
 * 3. 提供格式化的配置输出功能
 * 4. 符合common模块约束（只能包含工具类）
 *
 * @author cao
 * @version 1.0.0
 */
public class ConfigPrinter {

    /**
     * 打印应用配置信息
     *
     * @param appName 应用名称
     * @param configs 配置信息（键值对）
     */
    public static void printConfig(String appName, Map<String, Object> configs) {
        System.out.println("\n" + "=".repeat(80));
        System.out.println("🚀 " + appName + " 启动配置信息");
        System.out.println("=".repeat(80));

        // 显示环境信息
        String environment = detectEnvironment(configs);
        System.out.println("环境: " + environment);
        System.out.println("启动时间: " + java.time.LocalDateTime.now().format(java.time.format.DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")));

        // 按类别分组显示配置
        printCategoryConfig("基础配置", filterConfigs(configs,
            "server.port", "spring.application.name"));

        printCategoryConfig("Nacos配置", filterConfigs(configs,
            "spring.cloud.nacos"));

        printCategoryConfig("数据库配置", filterConfigs(configs,
            "spring.datasource", "spring.data"));

        printCategoryConfig("Redis配置", filterConfigs(configs,
            "spring.data.redis"));

        printCategoryConfig("MyBatis配置", filterConfigs(configs,
            "mybatis-plus"));

        printCategoryConfig("日志配置", filterConfigs(configs,
            "logging"));

        printCategoryConfig("管理端点配置", filterConfigs(configs,
            "management"));

        System.out.println("=".repeat(80));
        System.out.println("✅ " + appName + " 配置加载完成");
        System.out.println("=".repeat(80) + "\n");
    }

    /**
     * 打印特定类别的配置
     */
    private static void printCategoryConfig(String category, Map<String, Object> configs) {
        if (configs.isEmpty()) {
            return;
        }

        System.out.println("\n📋 " + category + ":");
        System.out.println("-".repeat(40));

        configs.forEach((key, value) -> {
            System.out.println("  " + key + ": " + formatValue(value));
        });
    }

    /**
     * 根据前缀过滤配置
     */
    private static Map<String, Object> filterConfigs(Map<String, Object> configs, String... prefixes) {
        Map<String, Object> filtered = new TreeMap<>();

        for (Map.Entry<String, Object> entry : configs.entrySet()) {
            String key = entry.getKey();

            for (String prefix : prefixes) {
                if (key.startsWith(prefix)) {
                    filtered.put(key, entry.getValue());
                    break;
                }
            }
        }

        return filtered;
    }

    /**
     * 格式化配置值显示
     */
    private static String formatValue(Object value) {
        if (value == null) {
            return "null";
        }

        String strValue = value.toString();

        // 对于较长的配置值（如日志格式），适当截断显示
        if (strValue.length() > 80) {
            return strValue.substring(0, 77) + "...";
        }

        return strValue;
    }

    /**
     * 检测运行环境
     */
    private static String detectEnvironment(Map<String, Object> configs) {
        String nacosAddr = (String) configs.get("spring.cloud.nacos.discovery.server-addr");

        if (nacosAddr != null) {
            if (nacosAddr.contains("localhost") || nacosAddr.contains("127.0.0.1")) {
                return "本地开发环境";
            } else if (nacosAddr.contains("nacos:")) {
                return "Docker容器环境";
            }
        }

        return "未知环境";
    }
}