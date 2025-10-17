<template>
  <div class="orders-page">
    <div class="page-header">
      <h1>订单管理</h1>
      <p>查看和管理您的订单</p>
    </div>

    <el-card>
      <el-empty description="订单功能正在开发中，敬请期待..." />
    </el-card>
  </div>
</template>

<script setup>
/**
 * 订单页面组件（占位版本）
 */
</script>

<style lang="scss" scoped>
.orders-page {
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
</style>