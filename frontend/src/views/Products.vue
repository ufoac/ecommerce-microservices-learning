<template>
  <div class="products-page">
    <div class="page-header">
      <h1>商品管理</h1>
      <p>浏览和搜索商品</p>
    </div>

    <el-card>
      <el-empty description="商品功能正在开发中，敬请期待..." />
    </el-card>
  </div>
</template>

<script setup>
/**
 * 商品页面组件（占位版本）
 */
</script>

<style lang="scss" scoped>
.products-page {
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