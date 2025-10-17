<template>
  <div class="not-found-page">
    <div class="not-found-content">
      <div class="error-code">404</div>
      <h1>页面未找到</h1>
      <p>抱歉，您访问的页面不存在</p>
      <el-button type="primary" @click="goHome">
        返回首页
      </el-button>
    </div>
  </div>
</template>

<script setup>
/**
 * 404页面组件
 */
import { useRouter } from 'vue-router'

const router = useRouter()

const goHome = () => {
  router.push('/')
}
</script>

<style lang="scss" scoped>
.not-found-page {
  min-height: 80vh;
  display: flex;
  align-items: center;
  justify-content: center;
  text-align: center;
}

.not-found-content {
  .error-code {
    font-size: 120px;
    font-weight: bold;
    color: $primary-color;
    margin-bottom: 20px;
    opacity: 0.3;
  }

  h1 {
    color: $text-primary;
    margin-bottom: 16px;
  }

  p {
    color: $text-secondary;
    margin-bottom: 32px;
  }
}
</style>