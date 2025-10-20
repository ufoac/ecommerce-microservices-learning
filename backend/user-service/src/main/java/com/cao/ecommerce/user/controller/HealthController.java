package com.cao.ecommerce.user.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.Map;

/**
 * 用户服务健康检查控制器
 *
 * 技术要点：
 * 1. 提供简单的健康检查端点
 * 2. 返回服务状态信息
 * 3. 支持Docker健康检查
 *
 * @author cao
 * @version 1.0.0
 */
@RestController
@RequestMapping("/actuator")
public class HealthController {

    /**
     * 健康检查端点
     *
     * 返回服务健康状态，用于Docker健康检查和负载均衡器探测
     *
     * @return 健康状态响应
     */
    @GetMapping("/health")
    public Map<String, Object> health() {
        Map<String, Object> response = new HashMap<>();
        response.put("status", "UP");
        response.put("timestamp", System.currentTimeMillis());
        response.put("service", "user-service");
        response.put("port", 28081);

        return response;
    }

    /**
     * 简单的存活检查端点
     *
     * @return 简单的存活响应
     */
    @GetMapping("/liveness")
    public Map<String, String> liveness() {
        Map<String, String> response = new HashMap<>();
        response.put("status", "alive");
        response.put("service", "user-service");
        return response;
    }

    /**
     * 就绪检查端点
     *
     * @return 就绪状态响应
     */
    @GetMapping("/readiness")
    public Map<String, String> readiness() {
        Map<String, String> response = new HashMap<>();
        response.put("status", "ready");
        response.put("service", "user-service");
        return response;
    }
}