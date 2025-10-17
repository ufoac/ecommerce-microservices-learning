<template>
  <div class="services-page">
    <div class="page-header">
      <h1>微服务测试</h1>
      <p>测试各个微服务的连通性</p>
    </div>

    <el-row :gutter="20">
      <el-col :span="8" v-for="service in services" :key="service.name">
        <el-card class="service-card">
          <div class="service-info">
            <div class="service-icon">
              <el-icon :size="40" :color="service.color">
                <component :is="service.icon" />
              </el-icon>
            </div>
            <h3>{{ service.name }}</h3>
            <p>{{ service.description }}</p>
            <div class="service-status">
              <el-tag :type="service.status === 'running' ? 'success' : 'danger'">
                {{ service.status === 'running' ? '运行中' : '未运行' }}
              </el-tag>
            </div>
          </div>
          <div class="service-actions">
            <el-button
              type="primary"
              size="small"
              @click="testService(service)"
              :loading="service.testing"
            >
              测试连接
            </el-button>
            <el-button
              type="info"
              size="small"
              @click="viewServiceDetails(service)"
            >
              查看详情
            </el-button>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <!-- 服务详情对话框 -->
    <el-dialog v-model="showDetails" title="服务详情" width="600px">
      <div v-if="selectedService">
        <el-descriptions :column="2" border>
          <el-descriptions-item label="服务名称">
            {{ selectedService.name }}
          </el-descriptions-item>
          <el-descriptions-item label="服务端口">
            {{ selectedService.port }}
          </el-descriptions-item>
          <el-descriptions-item label="服务地址">
            {{ selectedService.url }}
          </el-descriptions-item>
          <el-descriptions-item label="状态">
            <el-tag :type="selectedService.status === 'running' ? 'success' : 'danger'">
              {{ selectedService.status === 'running' ? '运行中' : '未运行' }}
            </el-tag>
          </el-descriptions-item>
          <el-descriptions-item label="最后测试时间" span="2">
            {{ selectedService.lastTest || '未测试' }}
          </el-descriptions-item>
        </el-descriptions>
      </div>
    </el-dialog>
  </div>
</template>

<script setup>
/**
 * 微服务测试页面
 *
 * 技术要点：
 * 1. 微服务状态监控
 * 2. HTTP请求测试
 * 3. 响应式状态管理
 * 4. Element Plus组件使用
 */
import { ref, reactive, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { Monitor, User, Goods, ShoppingCart } from '@element-plus/icons-vue'

// 响应式数据
const showDetails = ref(false)
const selectedService = ref(null)

// 服务列表
const services = reactive([
  {
    name: 'API网关',
    description: '统一请求入口',
    icon: 'Monitor',
    color: '#409eff',
    port: 8080,
    url: 'http://localhost:8080',
    status: 'running',
    testing: false,
    lastTest: null
  },
  {
    name: '用户服务',
    description: '用户注册登录管理',
    icon: 'User',
    color: '#67c23a',
    port: 8081,
    url: 'http://localhost:8081',
    status: 'stopped',
    testing: false,
    lastTest: null
  },
  {
    name: '商品服务',
    description: '商品信息管理',
    icon: 'Goods',
    color: '#e6a23c',
    port: 8082,
    url: 'http://localhost:8082',
    status: 'stopped',
    testing: false,
    lastTest: null
  },
  {
    name: '交易服务',
    description: '订单购物车管理',
    icon: 'ShoppingCart',
    color: '#f56c6c',
    port: 8083,
    url: 'http://localhost:8083',
    status: 'stopped',
    testing: false,
    lastTest: null
  }
])

// 方法
const testService = async (service) => {
  service.testing = true

  try {
    // 模拟测试请求（后续会接入真实API）
    await new Promise(resolve => setTimeout(resolve, 1500))

    // 模拟测试结果
    const isRunning = service.name === 'API网关' // 目前只有网关配置完成

    service.status = isRunning ? 'running' : 'stopped'
    service.lastTest = new Date().toLocaleString()

    if (isRunning) {
      ElMessage.success(`${service.name} 连接正常`)
    } else {
      ElMessage.warning(`${service.name} 暂未启动`)
    }
  } catch (error) {
    ElMessage.error(`${service.name} 连接失败`)
    service.status = 'stopped'
  } finally {
    service.testing = false
  }
}

const viewServiceDetails = (service) => {
  selectedService.value = service
  showDetails.value = true
}

onMounted(() => {
  console.log('🔧 服务测试页面挂载完成')
})
</script>

<style lang="scss" scoped>
.services-page {
  padding: 20px;
  max-width: 1200px;
  margin: 0 auto;
}

.page-header {
  margin-bottom: 30px;
  text-align: center;

  h1 {
    color: $text-primary;
    margin-bottom: 8px;
  }

  p {
    color: $text-secondary;
    margin: 0;
  }
}

.service-card {
  margin-bottom: 20px;
  border-radius: 12px;
  transition: transform 0.3s ease;

  &:hover {
    transform: translateY(-5px);
  }

  .service-info {
    text-align: center;
    margin-bottom: 20px;

    .service-icon {
      margin-bottom: 16px;
    }

    h3 {
      color: $text-primary;
      margin-bottom: 8px;
    }

    p {
      color: $text-secondary;
      margin-bottom: 16px;
      font-size: 14px;
    }
  }

  .service-actions {
    display: flex;
    gap: 12px;
    justify-content: center;
  }
}

@media (max-width: $breakpoint-md) {
  .services-page {
    padding: 16px;
  }

  .service-actions {
    flex-direction: column;
  }
}
</style>