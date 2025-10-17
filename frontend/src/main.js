import { createApp } from 'vue'
import { createPinia } from 'pinia'
import ElementPlus from 'element-plus'
import 'element-plus/dist/index.css'
import * as ElementPlusIconsVue from '@element-plus/icons-vue'

import App from './App.vue'
import router from './router'

// 导入全局样式
import './styles/index.scss'

/**
 * Vue应用主入口文件
 *
 * 技术要点：
 * 1. Vue 3.4 Composition API
 * 2. Element Plus UI框架集成
 * 3. Pinia状态管理
 * 4. Vue Router路由管理
 * 5. Vite构建工具
 *
 * 面试要点：
 * - Vue 3相比Vue 2的优势：Composition API、性能提升、TypeScript支持
 * - Pinia与Vuex的区别：更简洁的API、更好的TypeScript支持、无mutations
 * - Element Plus的特点：支持Vue 3、组件丰富、主题定制
 */

const app = createApp(App)

// 注册Element Plus图标
for (const [key, component] of Object.entries(ElementPlusIconsVue)) {
  app.component(key, component)
}

// 安装插件
app.use(createPinia())    // 状态管理
app.use(router)           // 路由管理
app.use(ElementPlus)      // UI框架

// 挂载应用
app.mount('#app')

// 开发环境配置
if (import.meta.env.DEV) {
  console.log('🚀 电商微服务前端启动成功！')
  console.log('📍 开发环境：', import.meta.env.MODE)
}