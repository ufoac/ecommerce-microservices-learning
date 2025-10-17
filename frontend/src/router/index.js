import { createRouter, createWebHistory } from 'vue-router'

/**
 * Vue Router路由配置
 *
 * 技术要点：
 * 1. Vue Router 4.x 版本，支持Vue 3
 * 2. 使用 History 模式，更友好的URL
 * 3. 路由懒加载，优化首屏加载性能
 * 4. 基础路由结构，支持后续扩展
 *
 * 面试要点：
 * - 路由模式：History vs Hash - SEO友好性差异
 * - 路由懒加载：动态import()实现代码分割
 * - 导航守卫：路由拦截、权限控制、页面标题设置
 */

const routes = [
  {
    path: '/',
    name: 'Home',
    component: () => import('@/views/Home.vue'),
    meta: {
      title: '首页 - 电商微服务系统'
    }
  },
  {
    path: '/login',
    name: 'Login',
    component: () => import('@/views/Login.vue'),
    meta: {
      title: '登录 - 电商微服务系统'
    }
  },
  {
    path: '/dashboard',
    name: 'Dashboard',
    component: () => import('@/views/Dashboard.vue'),
    meta: {
      title: '控制台 - 电商微服务系统',
      requiresAuth: true // 需要登录认证
    }
  },
  {
    path: '/services',
    name: 'Services',
    component: () => import('@/views/Services.vue'),
    meta: {
      title: '微服务测试 - 电商微服务系统'
    }
  },
  {
    path: '/products',
    name: 'Products',
    component: () => import('@/views/Products.vue'),
    meta: {
      title: '商品管理 - 电商微服务系统'
    }
  },
  {
    path: '/cart',
    name: 'Cart',
    component: () => import('@/views/Cart.vue'),
    meta: {
      title: '购物车 - 电商微服务系统',
      requiresAuth: true
    }
  },
  {
    path: '/orders',
    name: 'Orders',
    component: () => import('@/views/Orders.vue'),
    meta: {
      title: '订单管理 - 电商微服务系统',
      requiresAuth: true
    }
  },
  // 404页面
  {
    path: '/:pathMatch(.*)*',
    name: 'NotFound',
    component: () => import('@/views/NotFound.vue'),
    meta: {
      title: '页面未找到 - 电商微服务系统'
    }
  }
]

// 创建路由实例
const router = createRouter({
  history: createWebHistory(),
  routes,
  scrollBehavior(to, from, savedPosition) {
    // 路由切换时的滚动行为
    if (savedPosition) {
      return savedPosition
    } else {
      return { top: 0 }
    }
  }
})

// 全局前置守卫
router.beforeEach((to, from, next) => {
  // 设置页面标题
  if (to.meta.title) {
    document.title = to.meta.title
  }

  // 简单的认证检查（后续会完善）
  const isAuthenticated = localStorage.getItem('token')

  if (to.meta.requiresAuth && !isAuthenticated) {
    // 需要认证但未登录，跳转到登录页
    next({
      name: 'Login',
      query: { redirect: to.fullPath }
    })
  } else {
    next()
  }
})

// 全局后置钩子
router.afterEach((to, from) => {
  // 路由切换完成后的处理
  console.log(`路由从 ${from.path} 切换到 ${to.path}`)
})

export default router