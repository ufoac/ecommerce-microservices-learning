package com.cao.ecommerce.product.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.Map;

/**
 * 商品服务健康检查控制器
 *
 * @author cao
 * @version 1.0.0
 */
@RestController
@RequestMapping("/actuator")
public class HealthController {

    @GetMapping("/health")
    public Map<String, Object> health() {
        Map<String, Object> response = new HashMap<>();
        response.put("status", "UP");
        response.put("timestamp", System.currentTimeMillis());
        response.put("service", "product-service");
        response.put("port", 28082);
        return response;
    }

    @GetMapping("/liveness")
    public Map<String, String> liveness() {
        Map<String, String> response = new HashMap<>();
        response.put("status", "alive");
        response.put("service", "product-service");
        return response;
    }

    @GetMapping("/readiness")
    public Map<String, String> readiness() {
        Map<String, String> response = new HashMap<>();
        response.put("status", "ready");
        response.put("service", "product-service");
        return response;
    }
}