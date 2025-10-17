<template>
  <div class="dashboard">
    <div class="dashboard-header">
      <h1>控制台</h1>
      <p>欢迎回来，{{ user?.nickname || '用户' }}！</p>
    </div>

    <el-row :gutter="20" class="dashboard-stats">
      <el-col :span="6">
        <el-card class="stat-card">
          <div class="stat-content">
            <div class="stat-icon">
              <el-icon size="32" color="#67c23a">
                <ShoppingCart />
              </el-icon>
            </div>
            <div class="stat-info">
              <h3>{{ stats.cartCount }}</h3>
              <p>购物车商品</p>
            </div>
          </div>
        </el-card>
      </el-col>

      <el-col :span="6">
        <el-card class="stat-card">
          <div class="stat-content">
            <div class="stat-icon">
              <el-icon size="32" color="#409eff">
                <Document />
              </el-icon>
            </div>
            <div class="stat-info">
              <h3>{{ stats.orderCount }}</h3>
              <p>订单数量</p>
            </div>
          </div>
        </el-card>
      </el-col>

      <el-col :span="6">
        <el-card class="stat-card">
          <div class="stat-content">
            <div class="stat-icon">
              <el-icon size="32" color="#e6a23c">
                <Star />
              </el-icon>
            </div>
            <div class="stat-info">
              <h3>{{ stats.favoriteCount }}</h3>
              <p>收藏商品</p>
            </div>
          </div>
        </el-card>
      </el-col>

      <el-col :span="6">
        <el-card class="stat-card">
          <div class="stat-content">
            <div class="stat-icon">
              <el-icon size="32" color="#f56c6c">
                <Money />
              </el-icon>
            </div>
            <div class="stat-info">
              <h3>¥{{ stats.totalSpent }}</h3>
              <p>累计消费</p>
            </div>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <el-row :gutter="20" class="dashboard-content">
      <el-col :span="16">
        <el-card>
          <template #header>
            <div class="card-header">
              <h3>最近订单</h3>
              <el-button type="primary" text @click="viewAllOrders">
                查看全部
              </el-button>
            </div>
          </template>
          <el-empty v-if="!recentOrders.length" description="暂无订单" />
          <div v-else class="order-list">
            <div
              v-for="order in recentOrders"
              :key="order.id"
              class="order-item"
            >
              <div class="order-info">
                <h4>订单 #{{ order.id }}</h4>
                <p>{{ order.createTime }}</p>
              </div>
              <div class="order-amount">
                <span class="amount">¥{{ order.amount }}</span>
                <el-tag :type="getStatusType(order.status)">
                  {{ getStatusText(order.status) }}
                </el-tag>
              </div>
            </div>
          </div>
        </el-card>
      </el-col>

      <el-col :span="8">
        <el-card>
          <template #header>
            <h3>快捷操作</h3>
          </template>
          <div class="quick-actions">
            <el-button
              type="primary"
              class="action-btn"
              @click="goToProducts"
            >
              <el-icon><Goods /></el-icon>
              去购物
            </el-button>
            <el-button
              type="success"
              class="action-btn"
              @click="goToCart"
            >
              <el-icon><ShoppingCart /></el-icon>
              查看购物车
            </el-button>
            <el-button
              type="warning"
              class="action-btn"
              @click="goToOrders"
            >
              <el-icon><Document /></el-icon>
              订单管理
            </el-button>
            <el-button
              type="info"
              class="action-btn"
              @click="goToServices"
            >
              <el-icon><Monitor /></el-icon>
              服务状态
            </el-button>
          </div>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script setup>
/**
 * 控制台页面组件
 *
 * 技术要点：
 * 1. Vue 3.4 Composition API
 * 2. 响应式数据展示
 * 3. Element Plus布局组件
 * 4. 状态管理和用户信息获取
 * 5. 模拟数据展示（后续会接入后端）
 */

import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import {
  ShoppingCart,
  Document,
  Star,
  Money,
  Goods,
  Monitor
} from '@element-plus/icons-vue'

const router = useRouter()

// 用户信息
const user = computed(() => {
  const userStr = localStorage.getItem('user')
  return userStr ? JSON.parse(userStr) : null
})

// 统计数据（模拟数据，后续会从后端获取）
const stats = ref({
  cartCount: 3,
  orderCount: 12,
  favoriteCount: 8,
  totalSpent: '2,580.00'
})

// 最近订单（模拟数据）
const recentOrders = ref([
  {
    id: '20241017001',
    amount: '299.00',
    status: 'completed',
    createTime: '2024-10-17 14:30:00'
  },
  {
    id: '20241016002',
    amount: '188.00',
    status: 'shipped',
    createTime: '2024-10-16 10:15:00'
  },
  {
    id: '20241015003',
    amount: '567.00',
    status: 'processing',
    createTime: '2024-10-15 16:45:00'
  }
])

// 生命周期
onMounted(() => {
  console.log('📊 控制台组件挂载完成')
})

// 方法
const getStatusType = (status) => {
  const statusMap = {
    pending: 'warning',
    processing: 'primary',
    shipped: 'success',
    completed: 'success',
    cancelled: 'danger'
  }
  return statusMap[status] || 'info'
}

const getStatusText = (status) => {
  const statusMap = {
    pending: '待处理',
    processing: '处理中',
    shipped: '已发货',
    completed: '已完成',
    cancelled: '已取消'
  }
  return statusMap[status] || '未知状态'
}

const viewAllOrders = () => {
  router.push('/orders')
}

const goToProducts = () => {
  router.push('/products')
}

const goToCart = () => {
  router.push('/cart')
}

const goToOrders = () => {
  router.push('/orders')
}

const goToServices = () => {
  router.push('/services')
}
</script>

<style lang="scss" scoped>
.dashboard {
  padding: 20px;
  max-width: 1400px;
  margin: 0 auto;
}

.dashboard-header {
  margin-bottom: 30px;

  h1 {
    color: $text-primary;
    margin-bottom: 8px;
  }

  p {
    color: $text-secondary;
    margin: 0;
  }
}

.dashboard-stats {
  margin-bottom: 30px;
}

.stat-card {
  height: 120px;

  .stat-content {
    display: flex;
    align-items: center;
    height: 100%;

    .stat-icon {
      margin-right: 16px;
    }

    .stat-info {
      h3 {
        font-size: 28px;
        font-weight: bold;
        color: $text-primary;
        margin: 0 0 4px 0;
      }

      p {
        color: $text-secondary;
        margin: 0;
      }
    }
  }
}

.dashboard-content {
  .card-header {
    display: flex;
    justify-content: space-between;
    align-items: center;

    h3 {
      margin: 0;
      color: $text-primary;
    }
  }
}

.order-list {
  .order-item {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 16px 0;
    border-bottom: 1px solid $border-color-lighter;

    &:last-child {
      border-bottom: none;
    }

    .order-info {
      h4 {
        margin: 0 0 4px 0;
        color: $text-primary;
      }

      p {
        margin: 0;
        color: $text-secondary;
        font-size: 13px;
      }
    }

    .order-amount {
      text-align: right;

      .amount {
        display: block;
        font-weight: bold;
        color: $danger-color;
        margin-bottom: 4px;
      }
    }
  }
}

.quick-actions {
  display: flex;
  flex-direction: column;
  gap: 12px;

  .action-btn {
    justify-content: flex-start;
    height: 48px;
    border-radius: 8px;

    .el-icon {
      margin-right: 8px;
    }
  }
}

@media (max-width: $breakpoint-lg) {
  .dashboard-stats {
    .el-col {
      margin-bottom: 16px;
    }
  }

  .dashboard-content {
    .el-col {
      margin-bottom: 16px;
    }
  }
}

@media (max-width: $breakpoint-md) {
  .dashboard {
    padding: 16px;
  }

  .stat-card .stat-content .stat-info h3 {
    font-size: 24px;
  }
}
</style>