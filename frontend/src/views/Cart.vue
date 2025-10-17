<template>
  <div class="cart-page">
    <div class="page-header">
      <h1>购物车</h1>
      <p>管理您的购物车商品</p>
    </div>

    <el-card>
      <el-empty description="购物车功能正在开发中，敬请期待..." />
    </el-card>
  </div>
</template>

<script setup>
/**
 * 购物车页面组件（占位版本）
 */
</script>

<style lang="scss" scoped>
.cart-page {
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