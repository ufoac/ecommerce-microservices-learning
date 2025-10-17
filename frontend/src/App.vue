<template>
  <div id="app">
    <!-- 路由视图 -->
    <router-view />
  </div>
</template>

<script setup>
/**
 * 应用根组件
 *
 * 技术要点：
 * 1. Vue 3.4 Composition API setup语法
 * 2. 使用 script setup 语法糖，更简洁的组件定义
 * 3. router-view 用于渲染路由匹配的组件
 *
 * 面试要点：
 * - Composition API vs Options API：更好的逻辑复用、TypeScript支持
 * - script setup 语法糖：自动暴露变量和函数，代码更简洁
 * - 单文件组件(SFC)：将模板、逻辑、样式封装在一个文件中
 */
import { onMounted } from 'vue'

// 组件挂载后的初始化操作
onMounted(() => {
  console.log('🏠 App组件挂载完成')
})
</script>

<style lang="scss">
// 全局样式
#app {
  font-family: 'Helvetica Neue', Helvetica, 'PingFang SC', 'Hiragino Sans GB',
    'Microsoft YaHei', '微软雅黑', Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  color: #2c3e50;
  min-height: 100vh;
}

// 清除默认样式
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

html, body {
  height: 100%;
}
</style>