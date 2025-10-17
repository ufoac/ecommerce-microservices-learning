<template>
  <div class="login-page">
    <div class="login-container">
      <el-card class="login-card">
        <template #header>
          <div class="login-header">
            <h2>用户登录</h2>
            <p>电商微服务系统</p>
          </div>
        </template>

        <el-form
          ref="loginFormRef"
          :model="loginForm"
          :rules="loginRules"
          class="login-form"
          size="large"
        >
          <el-form-item prop="username">
            <el-input
              v-model="loginForm.username"
              placeholder="请输入用户名"
              :prefix-icon="User"
              clearable
            />
          </el-form-item>

          <el-form-item prop="password">
            <el-input
              v-model="loginForm.password"
              type="password"
              placeholder="请输入密码"
              :prefix-icon="Lock"
              show-password
              clearable
            />
          </el-form-item>

          <el-form-item>
            <el-button
              type="primary"
              class="login-button"
              :loading="loading"
              @click="handleLogin"
            >
              {{ loading ? '登录中...' : '登录' }}
            </el-button>
          </el-form-item>
        </el-form>

        <div class="login-footer">
          <p>
            没有账号？
            <el-link type="primary" @click="showRegister = true">
              立即注册
            </el-link>
          </p>
          <el-divider>测试账号</el-divider>
          <p class="test-accounts">
            用户名: test / 密码: 123456
          </p>
        </div>
      </el-card>
    </div>

    <!-- 注册对话框（基础版本，后续会完善） -->
    <el-dialog
      v-model="showRegister"
      title="用户注册"
      width="400px"
      center
    >
      <p>注册功能正在开发中，敬请期待...</p>
      <template #footer>
        <el-button @click="showRegister = false">关闭</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
/**
 * 登录页面组件
 *
 * 技术要点：
 * 1. Vue 3.4 Composition API
 * 2. Element Plus表单组件和验证
 * 3. 响应式设计
 * 4. 表单验证和状态管理
 * 5. 登录逻辑（基础版本，后续会接入后端）
 *
 * 面试要点：
 * - 表单验证：前端验证与后端验证的配合
 * - 安全考虑：密码加密存储、防暴力破解
 * - 用户体验：加载状态、错误提示、记住密码
 */

import { ref, reactive } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { ElMessage } from 'element-plus'
import { User, Lock } from '@element-plus/icons-vue'

const router = useRouter()
const route = useRoute()

// 响应式数据
const loginFormRef = ref()
const loading = ref(false)
const showRegister = ref(false)

// 表单数据
const loginForm = reactive({
  username: '',
  password: ''
})

// 表单验证规则
const loginRules = reactive({
  username: [
    { required: true, message: '请输入用户名', trigger: 'blur' },
    { min: 3, max: 20, message: '用户名长度在 3 到 20 个字符', trigger: 'blur' }
  ],
  password: [
    { required: true, message: '请输入密码', trigger: 'blur' },
    { min: 6, max: 20, message: '密码长度在 6 到 20 个字符', trigger: 'blur' }
  ]
})

// 登录方法
const handleLogin = async () => {
  if (!loginFormRef.value) return

  try {
    // 表单验证
    await loginFormRef.value.validate()

    loading.value = true

    // 模拟登录请求（后续会接入真实后端API）
    setTimeout(() => {
      // 简单的测试账号验证
      if (loginForm.username === 'test' && loginForm.password === '123456') {
        // 登录成功
        const token = 'mock-jwt-token-' + Date.now()
        const user = {
          id: 1,
          username: loginForm.username,
          nickname: '测试用户',
          avatar: ''
        }

        // 保存到localStorage
        localStorage.setItem('token', token)
        localStorage.setItem('user', JSON.stringify(user))

        ElMessage.success('登录成功！')

        // 跳转到之前的页面或首页
        const redirect = route.query.redirect || '/'
        router.push(redirect)
      } else {
        ElMessage.error('用户名或密码错误')
      }
      loading.value = false
    }, 1000)

  } catch (error) {
    console.error('表单验证失败:', error)
    loading.value = false
  }
}

// 快速填充测试账号
const fillTestAccount = () => {
  loginForm.username = 'test'
  loginForm.password = '123456'
}
</script>

<style lang="scss" scoped>
.login-page {
  min-height: 100vh;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 20px;
}

.login-container {
  width: 100%;
  max-width: 400px;
}

.login-card {
  border-radius: 12px;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
  border: none;

  .login-header {
    text-align: center;

    h2 {
      color: $text-primary;
      margin-bottom: 8px;
    }

    p {
      color: $text-secondary;
      margin: 0;
    }
  }
}

.login-form {
  .el-form-item {
    margin-bottom: 24px;
  }

  .login-button {
    width: 100%;
    height: 48px;
    font-size: 16px;
    border-radius: 8px;
  }
}

.login-footer {
  text-align: center;
  margin-top: 20px;

  p {
    color: $text-secondary;
    margin: 8px 0;
  }

  .test-accounts {
    font-size: 12px;
    color: $info-color;
    background: $background-color-light;
    padding: 8px;
    border-radius: 4px;
    cursor: pointer;
    transition: background-color 0.3s;

    &:hover {
      background: $background-color-base;
    }
  }
}

:deep(.el-card__header) {
  padding: 30px 30px 20px;
}

:deep(.el-card__body) {
  padding: 20px 30px 30px;
}

@media (max-width: $breakpoint-sm) {
  .login-container {
    max-width: 320px;
  }

  :deep(.el-card__header),
  :deep(.el-card__body) {
    padding-left: 20px;
    padding-right: 20px;
  }
}
</style>