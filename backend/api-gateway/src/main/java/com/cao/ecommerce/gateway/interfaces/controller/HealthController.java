package com.cao.ecommerce.gateway.interfaces.controller;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;

/**
 * 网关服务健康检查控制器
 *
 * @author claude
 * @since 2025-10-22
 */
@RestController
@RequestMapping("/actuator")
public class HealthController {

    @Value("${server.port}")
    private String serverPort;

    @Value("${spring.application.name}")
    private String serviceName;

    /**
     * 健康检查接口
     */
    @GetMapping("/health")
    public Map<String, Object> health() {
        Map<String, Object> result = new HashMap<>();
        result.put("status", "UP");
        result.put("service", serviceName);
        result.put("port", serverPort);
        result.put("timestamp", LocalDateTime.now());
        result.put("message", "网关服务运行正常");
        return result;
    }

    /**
     * 服务信息接口
     */
    @GetMapping("/info")
    public Map<String, Object> info() {
        Map<String, Object> result = new HashMap<>();
        result.put("service", serviceName);
        result.put("port", serverPort);
        result.put("description", "电商微服务API网关");
        result.put("version", "1.0.0");
        result.put("timestamp", LocalDateTime.now());
        return result;
    }
}