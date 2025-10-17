<template>
  <div class="home">
    <!-- 头部导航 -->
    <el-header class="header">
      <div class="header-content">
        <div class="logo">
          <h1>电商微服务系统</h1>
        </div>
        <el-menu
          mode="horizontal"
          :default-active="activeMenu"
          class="nav-menu"
          @select="handleMenuSelect"
        >
          <el-menu-item index="/">
            <el-icon><House /></el-icon>
            首页
          </el-menu-item>
          <el-menu-item index="/products">
            <el-icon><Goods /></el-icon>
            商品
          </el-menu-item>
          <el-menu-item index="/cart">
            <el-icon><ShoppingCart /></el-icon>
            购物车
          </el-menu-item>
          <el-menu-item index="/orders">
            <el-icon><Document /></el-icon>
            订单
          </el-menu-item>
          <el-menu-item index="/services">
            <el-icon><Monitor /></el-icon>
            服务测试
          </el-menu-item>
        </el-menu>
        <div class="user-actions">
          <el-button type="primary" @click="goToLogin" v-if="!isLoggedIn">
            登录
          </el-button>
          <el-dropdown v-else>
            <span class="user-info">
              <el-icon><User /></el-icon>
              用户
            </span>
            <template #dropdown>
              <el-dropdown-menu>
                <el-dropdown-item @click="goToDashboard">
                  控制台
                </el-dropdown-item>
                <el-dropdown-item @click="logout">
                  退出登录
                </el-dropdown-item>
              </el-dropdown-menu>
            </template>
          </el-dropdown>
        </div>
      </div>
    </el-header>

    <!-- 主要内容区域 -->
    <el-main class="main-content">
      <div class="hero-section">
        <div class="hero-content">
          <h1>欢迎使用电商微服务系统</h1>
          <p>基于 Spring Cloud + Vue 3 的现代化电商平台</p>
          <div class="hero-buttons">
            <el-button type="primary" size="large" @click="goToProducts">
              开始购物
            </el-button>
            <el-button size="large" @click="goToServices">
              查看服务状态
            </el-button>
          </div>
        </div>
      </div>

      <!-- 技术栈展示 -->
      <div class="tech-section">
        <h2>技术栈</h2>
        <el-row :gutter="20">
          <el-col :span="6" v-for="tech in techStack" :key="tech.name">
            <el-card class="tech-card">
              <div class="tech-icon">
                <el-icon :size="40">
                  <component :is="tech.icon" />
                </el-icon>
              </div>
              <h3>{{ tech.name }}</h3>
              <p>{{ tech.description }}</p>
            </el-card>
          </el-col>
        </el-row>
      </div>
    </el-main>
  </div>
</template>

<script setup>
/**
 * 首页组件
 *
 * 技术要点：
 * 1. Vue 3.4 Composition API setup语法
 * 2. Element Plus UI组件使用
 * 3. Vue Router导航
 * 4. 响应式布局设计
 * 5. 状态管理（localStorage）
 */

import { ref, computed, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import {
  House,
  Goods,
  ShoppingCart,
  Document,
  Monitor,
  User,
  Setting,
  Cloud,
  Link
} from '@element-plus/icons-vue'

const router = useRouter()
const route = useRoute()

// 响应式数据
const activeMenu = ref(route.path)
const isLoggedIn = computed(() => localStorage.getItem('token'))

// 技术栈数据
const techStack = ref([
  {
    name: 'Spring Boot 3.3.5',
    icon: 'Setting',
    description: '现代化Java开发框架'
  },
  {
    name: 'Spring Cloud',
    icon: 'Cloud',
    description: '微服务架构解决方案'
  },
  {
    name: 'Vue 3.4',
    icon: 'Document',
    description: '渐进式JavaScript框架'
  },
  {
    name: 'Element Plus',
    icon: 'Goods',
    description: 'Vue 3企业级UI组件库'
  }
])

// 生命周期
onMounted(() => {
  console.log('🏠 首页组件挂载完成')
})

// 方法
const handleMenuSelect = (index) => {
  router.push(index)
}

const goToLogin = () => {
  router.push('/login')
}

const goToProducts = () => {
  router.push('/products')
}

const goToServices = () => {
  router.push('/services')
}

const goToDashboard = () => {
  router.push('/dashboard')
}

const logout = () => {
  localStorage.removeItem('token')
  localStorage.removeItem('user')
  router.push('/')
}
</script>

<style lang="scss" scoped>
.home {
  min-height: 100vh;
  display: flex;
  flex-direction: column;
}

.header {
  background: white;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  padding: 0;

  .header-content {
    max-width: 1200px;
    margin: 0 auto;
    height: 60px;
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 0 20px;

    .logo h1 {
      color: $primary-color;
      font-size: 20px;
      margin: 0;
    }

    .nav-menu {
      border: none;
      flex: 1;
      margin: 0 40px;
    }

    .user-actions {
      display: flex;
      align-items: center;

      .user-info {
        display: flex;
        align-items: center;
        gap: 4px;
        cursor: pointer;
        color: $text-primary;
      }
    }
  }
}

.main-content {
  flex: 1;
  padding: 0;
}

.hero-section {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  padding: 80px 20px;
  text-align: center;

  .hero-content {
    max-width: 600px;
    margin: 0 auto;

    h1 {
      font-size: 48px;
      margin-bottom: 16px;
      font-weight: bold;
    }

    p {
      font-size: 18px;
      margin-bottom: 32px;
      opacity: 0.9;
    }

    .hero-buttons {
      display: flex;
      gap: 16px;
      justify-content: center;

      .el-button {
        border-radius: 25px;
        padding: 12px 32px;
      }
    }
  }
}

.tech-section {
  padding: 60px 20px;
  max-width: 1200px;
  margin: 0 auto;

  h2 {
    text-align: center;
    margin-bottom: 40px;
    color: $text-primary;
  }

  .tech-card {
    text-align: center;
    border-radius: 12px;
    transition: transform 0.3s ease;

    &:hover {
      transform: translateY(-5px);
    }

    .tech-icon {
      margin-bottom: 16px;
      color: $primary-color;
    }

    h3 {
      margin-bottom: 8px;
      color: $text-primary;
    }

    p {
      color: $text-secondary;
      font-size: 14px;
    }
  }
}

@media (max-width: $breakpoint-md) {
  .header-content {
    .nav-menu {
      margin: 0 20px;
    }
  }

  .hero-section {
    padding: 60px 20px;

    .hero-content h1 {
      font-size: 32px;
    }
  }

  .hero-buttons {
    flex-direction: column;
    align-items: center;
  }
}
</style>