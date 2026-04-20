<template>
  <div class="login-page">
    <div class="login-container">
      <!-- 左侧品牌区域 -->
      <div class="brand-section">
        <div class="brand-content">
          <div class="logo">
            <div class="logo-icon">
              <el-icon :size="48"><Refresh /></el-icon>
            </div>
            <h1 class="brand-title">绿源社区回收</h1>
          </div>
          <p class="brand-slogan">绿色回收 · 智能生活 · 共建美好社区</p>

          <div class="features">
            <div class="feature-item">
              <div class="feature-icon">
                <el-icon><Clock /></el-icon>
              </div>
              <div class="feature-text">
                <h4>30分钟快速响应</h4>
                <p>智能派单，上门回收无需等待</p>
              </div>
            </div>
            <div class="feature-item">
              <div class="feature-icon">
                <el-icon><MapLocation /></el-icon>
              </div>
              <div class="feature-text">
                <h4>智能路线规划</h4>
                <p>最优路径，提高回收效率</p>
              </div>
            </div>
            <div class="feature-item">
              <div class="feature-icon">
                <el-icon><Coin /></el-icon>
              </div>
              <div class="feature-text">
                <h4>积分兑换好礼</h4>
                <p>环保有回报，积分当钱花</p>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- 右侧登录表单区域 -->
      <div class="form-section">
        <div class="form-container">
          <h2 class="form-title">欢迎登录</h2>

          <div class="user-type-tabs">
            <div
                class="type-tab"
                :class="{ active: loginType === 'user' }"
                @click="loginType = 'user'"
            >
              <el-icon><User /></el-icon>
              <span>普通用户</span>
            </div>
            <div
                class="type-tab"
                :class="{ active: loginType === 'collector' }"
                @click="loginType = 'collector'"
            >
              <el-icon><Van /></el-icon>
              <span>回收人员</span>
            </div>
          </div>

          <el-form
              ref="formRef"
              :model="form"
              :rules="rules"
              class="login-form"
              @keyup.enter="handleLogin"
          >
            <el-form-item prop="username">
              <div class="input-label">
                <el-icon><User /></el-icon>
                <span>用户账号</span>
              </div>
              <el-input
                  v-model="form.username"
                  placeholder="请输入用户账号"
                  size="large"
                  clearable
                  class="custom-input"
              />
            </el-form-item>

            <el-form-item prop="password">
              <div class="input-label">
                <el-icon><Lock /></el-icon>
                <span>密码</span>
              </div>
              <el-input
                  v-model="form.password"
                  type="password"
                  placeholder="请输入密码"
                  size="large"
                  show-password
                  class="custom-input"
              />
            </el-form-item>

            <div class="form-options">
              <el-checkbox v-model="rememberMe">记住我</el-checkbox>
              <a class="forgot-link" @click="handleForgot">忘记密码？</a>
            </div>

            <el-button
                type="primary"
                size="large"
                class="login-btn"
                :loading="loading"
                @click="handleLogin"
            >
              立即登录
            </el-button>
          </el-form>

          <div class="register-link">
            <span>还没有账号？</span>
            <a @click="goRegister">立即注册</a>
          </div>

          <div class="admin-entry">
            <el-divider>
              <span class="divider-text">管理员通道</span>
            </el-divider>
            <el-button
                text
                size="small"
                @click="showAdminLogin = true"
            >
              管理员登录
            </el-button>
          </div>
        </div>
      </div>
    </div>

    <!-- 管理员登录弹窗 -->
    <el-dialog
        v-model="showAdminLogin"
        title=""
        width="440px"
        align-center
        class="admin-dialog"
        :show-close="true"
    >
      <div class="admin-dialog-wrapper">
        <div class="admin-dialog-header">
          <div class="admin-avatar">
            <el-icon :size="32"><UserFilled /></el-icon>
          </div>
          <h3 class="admin-title">管理员登录</h3>
          <p class="admin-subtitle">系统管理后台</p>
        </div>

        <div class="admin-dialog-body">
          <el-form
              :model="adminForm"
              :rules="adminRules"
              ref="adminFormRef"
              class="admin-form"
          >
            <el-form-item prop="username">
              <div class="admin-input-group">
                <span class="input-icon">
                  <el-icon><User /></el-icon>
                </span>
                <el-input
                    v-model="adminForm.username"
                    placeholder="请输入管理员账号"
                    size="large"
                    class="custom-input"
                />
              </div>
            </el-form-item>

            <el-form-item prop="password">
              <div class="admin-input-group">
                <span class="input-icon">
                  <el-icon><Lock /></el-icon>
                </span>
                <el-input
                    v-model="adminForm.password"
                    type="password"
                    placeholder="请输入密码"
                    size="large"
                    show-password
                    class="custom-input"
                />
              </div>
            </el-form-item>
          </el-form>
        </div>

        <div class="admin-dialog-footer">
          <el-button
              size="large"
              @click="showAdminLogin = false"
              class="admin-btn admin-btn-cancel"
          >
            取消
          </el-button>
          <el-button
              type="primary"
              size="large"
              @click="handleAdminLogin"
              :loading="loading"
              class="admin-btn admin-btn-confirm"
          >
            登录
          </el-button>
        </div>
      </div>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import {
  Refresh, Clock, MapLocation, Coin, User, Lock, Van, UserFilled
} from '@element-plus/icons-vue'
import userApi from '@/api/user'
import * as collectorApi from '@/api/collector.js'
import adminApi from '@/api/admin'

const router = useRouter()
const formRef = ref()
const adminFormRef = ref()

const loginType = ref('user')
const loading = ref(false)
const rememberMe = ref(false)
const showAdminLogin = ref(false)

const form = reactive({
  username: '',
  password: ''
})

const adminForm = reactive({
  username: '',
  password: ''
})

const rules = {
  username: [{ required: true, message: '请输入用户账号', trigger: 'blur' }],
  password: [{ required: true, message: '请输入密码', trigger: 'blur' }]
}

const adminRules = {
  username: [{ required: true, message: '请输入管理员账号', trigger: 'blur' }],
  password: [{ required: true, message: '请输入密码', trigger: 'blur' }]
}

const isBizError = (res) => res && typeof res === 'object' && res.code && res.code !== '200' && res.code !== 200

const ensureLoginSuccess = (res) => {
  if (isBizError(res)) {
    throw new Error(res.msg || '登录失败')
  }
  return res
}

const handleLogin = async () => {
  await formRef.value.validate()

  loading.value = true
  try {
    let res
    let targetPath
    if (loginType.value === 'user') {
      res = ensureLoginSuccess(await userApi.login(form))
      localStorage.setItem('role', '普通用户')
      targetPath = '/user'
    } else {
      res = ensureLoginSuccess(await collectorApi.login(form))
      localStorage.setItem('role', '回收员')
      targetPath = '/collector'
    }

    // 先写入 token/user，避免路由守卫因无 token 而跳转登录
    localStorage.setItem('token', res?.token || res.token || 'token')
    localStorage.setItem('user', JSON.stringify(res))

    if (rememberMe.value) {
      localStorage.setItem('remember', JSON.stringify(form))
    }

    ElMessage.success('登录成功')
    router.push(targetPath)
  } catch (error) {
    ElMessage.error(error.message || '登录失败')
  } finally {
    loading.value = false
  }
}

const handleAdminLogin = async () => {
  await adminFormRef.value.validate()

  loading.value = true
  try {
    const res = ensureLoginSuccess(await adminApi.login({ ...adminForm, role: '管理员' }))
    localStorage.setItem('token', res?.token || res.token || 'token')
    localStorage.setItem('user', JSON.stringify(res))
    localStorage.setItem('role', '管理员')
    ElMessage.success('管理员登录成功')
    router.push('/admin')
  } catch (error) {
    ElMessage.error(error.message || '登录失败')
  } finally {
    loading.value = false
  }
}

const goRegister = () => {
  if (loginType.value === 'user') {
    router.push('/register')
  } else {
    router.push('/collector-register')
  }
}

const handleForgot = () => {
  ElMessage.info('请联系管理员重置密码')
}
</script>

<style scoped lang="scss">
// ============================================
// 色彩系统
// ============================================

$forest-dark: #2D5A45;
$forest-primary: #3A7A5A;
$forest-medium: #4A9B6E;
$forest-light: #6BC08F;
$sage-green: #8FCCA0;
$mint-cream: #E8F5EC;
$pale-green: #D4EDD9;
$soft-white: #F5FAF7;

$text-dark: #1E3A2B;
$text-medium: #4A6B55;
$text-light: #7A9B85;

$soft-shadow: rgba(45, 90, 69, 0.12);
$medium-shadow: rgba(45, 90, 69, 0.2);

// ============================================
// 登录页主体
// ============================================

.login-page {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background: url('/recycle-bg.png') no-repeat center center;
  background-size: cover;
  position: relative;

  &::before {
    content: '';
    position: absolute;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    background: rgba($forest-primary, 0.15);
    z-index: 0;
  }

  padding: 20px;
}

.login-container {
  display: flex;
  width: 1200px;
  height: 750px;
  background: rgba(255, 255, 255, 0.2);
  border-radius: 24px;
  overflow: hidden;
  box-shadow:
      0 25px 50px -12px rgba($forest-dark, 0.35),
      0 0 0 1px rgba(255, 255, 255, 0.15);
  backdrop-filter: blur(20px);
  position: relative;
  z-index: 1;
}

// ============================================
// 左侧品牌区域
// ============================================

.brand-section {
  flex: 1;
  background: linear-gradient(160deg, rgba($forest-primary, 0.92) 0%, rgba($forest-dark, 0.95) 100%);
  position: relative;
  overflow: hidden;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  padding: 80px;

  &::before {
    content: '';
    position: absolute;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    background:
        radial-gradient(circle at 20% 80%, rgba($sage-green, 0.2) 0%, transparent 50%),
        radial-gradient(circle at 80% 20%, rgba($forest-light, 0.15) 0%, transparent 40%);
    pointer-events: none;
  }

  &::after {
    content: '';
    position: absolute;
    top: 0;
    right: 0;
    bottom: 0;
    width: 1px;
    background: linear-gradient(180deg, transparent 0%, rgba(255,255,255,0.25) 50%, transparent 100%);
  }
}

.brand-content {
  position: relative;
  z-index: 10;
  max-width: 480px;
}

.logo {
  display: flex;
  align-items: center;
  gap: 20px;
  margin-bottom: 24px;
}

.logo-icon {
  width: 72px;
  height: 72px;
  background: rgba(255, 255, 255, 0.15);
  border-radius: 18px;
  display: flex;
  align-items: center;
  justify-content: center;
  backdrop-filter: blur(10px);
  border: 1px solid rgba(255, 255, 255, 0.25);
  color: white;
  transition: all 0.3s ease;

  &:hover {
    background: rgba(255, 255, 255, 0.25);
    transform: rotate(180deg);
  }
}

.brand-title {
  font-size: 38px;
  font-weight: 700;
  margin: 0;
  color: white;
  letter-spacing: 1px;
  text-shadow: 0 2px 8px rgba($forest-dark, 0.3);
}

.brand-slogan {
  font-size: 17px;
  color: rgba(255, 255, 255, 0.9);
  margin-bottom: 56px;
  font-weight: 400;
  letter-spacing: 3px;
}

.features {
  display: flex;
  flex-direction: column;
  gap: 28px;
}

.feature-item {
  display: flex;
  align-items: flex-start;
  gap: 18px;
  transition: transform 0.3s ease;

  &:hover {
    transform: translateX(5px);
  }
}

.feature-icon {
  width: 50px;
  height: 50px;
  background: rgba(255, 255, 255, 0.12);
  border-radius: 14px;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
  backdrop-filter: blur(4px);
  border: 1px solid rgba(255, 255, 255, 0.2);
  color: $sage-green;
  font-size: 22px;
  transition: all 0.3s ease;

  &:hover {
    background: rgba($sage-green, 0.3);
    color: white;
  }
}

.feature-text {
  h4 {
    margin: 0 0 8px 0;
    font-size: 18px;
    font-weight: 600;
    color: white;
    letter-spacing: 0.5px;
  }

  p {
    margin: 0;
    font-size: 14px;
    color: rgba(255, 255, 255, 0.8);
    line-height: 1.5;
  }
}

// ============================================
// 右侧表单区域
// ============================================

.form-section {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 80px;
  background: linear-gradient(135deg, rgba($soft-white, 0.98) 0%, rgba($mint-cream, 0.96) 100%);
  position: relative;

  &::before {
    content: '';
    position: absolute;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    background:
        radial-gradient(circle at 90% 90%, rgba($sage-green, 0.08) 0%, transparent 30%);
    pointer-events: none;
  }
}

.form-container {
  width: 100%;
  max-width: 460px;
  position: relative;
  z-index: 1;
}

.form-title {
  font-size: 32px;
  font-weight: 700;
  color: $forest-dark;
  margin-bottom: 40px;
  text-align: center;
  letter-spacing: 1px;
}

// 用户类型切换
.user-type-tabs {
  display: flex;
  gap: 10px;
  margin-bottom: 40px;
  background: rgba($pale-green, 0.6);
  padding: 6px;
  border-radius: 14px;
  border: 1px solid rgba($forest-medium, 0.15);
}

.type-tab {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 10px;
  padding: 14px;
  border-radius: 12px;
  cursor: pointer;
  transition: all 0.3s ease;
  color: $text-medium;
  font-size: 16px;
  font-weight: 500;

  &:hover {
    color: $forest-medium;
    background: rgba(255, 255, 255, 0.6);
  }

  &.active {
    background: white;
    color: $forest-primary;
    box-shadow: 0 2px 8px $soft-shadow;
    font-weight: 600;
  }

  .el-icon {
    font-size: 20px;
  }
}

// ============================================
// 表单样式 - 使用 :global() 替代 :deep()
// ============================================

.login-form {
  .input-label {
    display: flex;
    align-items: center;
    gap: 8px;
    margin-bottom: 12px;
    color: $text-dark;
    font-size: 16px;
    font-weight: 500;

    .el-icon {
      color: $forest-medium;
      font-size: 18px;
    }
  }

  :global(.el-form-item) {
    margin-bottom: 28px;

    &:last-child {
      margin-bottom: 0;
    }
  }

  // 新版输入框设计：大圆角、明显边框
  :global(.el-input__wrapper) {
    border-radius: 16px;
    background-color: #FFFFFF;
    box-shadow: 0 0 0 2px #4A9B6E inset;
    padding: 4px 16px;

    &:hover {
      box-shadow: 0 0 0 2px #3A7A5A inset;
    }

    &.is-focus {
      box-shadow: 0 0 0 3px #2D5A45 inset;
    }

    // 验证错误状态样式
    &.is-error {
      box-shadow: 0 0 0 2px #F56C6C inset;
    }
  }

  :global(.el-input__inner) {
    height: 56px;
    font-size: 17px;
    color: $text-dark;

    &::placeholder {
      color: rgba($text-medium, 0.6);
      font-size: 16px;
    }
  }

  // 密码框特殊处理
  :global(.el-input--large) {
    .el-input__wrapper {
      padding: 4px 16px;
    }
  }
}

.form-options {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin: 28px 0 36px;

  :global(.el-checkbox__label) {
    color: $text-medium;
    font-size: 15px;
  }

  :global(.el-checkbox__input.is-checked + .el-checkbox__label) {
    color: $forest-medium;
  }

  :global(.el-checkbox__input.is-checked .el-checkbox__inner) {
    background-color: $forest-medium;
    border-color: $forest-medium;
  }

  .forgot-link {
    color: $forest-medium;
    font-size: 15px;
    cursor: pointer;
    transition: all 0.2s;

    &:hover {
      color: $forest-primary;
      text-decoration: underline;
    }
  }
}

.login-btn {
  width: 100%;
  height: 58px;
  border-radius: 14px;
  font-size: 19px;
  font-weight: 600;
  background: linear-gradient(135deg, $forest-medium 0%, $forest-primary 100%);
  border: none;
  box-shadow: 0 4px 16px rgba($forest-medium, 0.35);
  transition: all 0.3s ease;
  letter-spacing: 1px;

  &:hover {
    background: linear-gradient(135deg, $forest-primary 0%, $forest-dark 100%);
    box-shadow: 0 8px 24px rgba($forest-medium, 0.45);
    transform: translateY(-2px);
  }

  &:active {
    transform: translateY(0);
  }
}

.register-link {
  text-align: center;
  margin-top: 32px;
  color: $text-medium;
  font-size: 17px;

  a {
    color: $forest-medium;
    font-weight: 600;
    cursor: pointer;
    margin-left: 6px;
    transition: all 0.2s;

    &:hover {
      color: $forest-primary;
      text-decoration: underline;
    }
  }
}

.admin-entry {
  margin-top: 40px;
  margin-bottom: 20px;
  text-align: center;

  .divider-text {
    color: rgba($text-medium, 0.7);
    font-size: 14px;
    letter-spacing: 1px;
  }

  :global(.el-divider__text) {
    background: linear-gradient(135deg, rgba($soft-white, 0.98) 0%, rgba($mint-cream, 0.96) 100%);
  }

  .el-button {
    color: $text-medium;
    font-size: 15px;

    &:hover {
      color: $forest-medium;
      background: rgba($pale-green, 0.6);
    }
  }
}

// ============================================
// 管理员弹窗 - 同样使用 :global()
// ============================================

.admin-dialog {
  border-radius: 20px;
  overflow: hidden;

  :global(.el-dialog__header) {
    display: none;
  }

  :global(.el-dialog__body) {
    padding: 0;
  }

  :global(.el-overlay) {
    background: rgba($forest-dark, 0.5);
    backdrop-filter: blur(6px);
  }

  :global(.el-dialog) {
    border-radius: 20px;
    box-shadow: 0 25px 60px -12px rgba($forest-dark, 0.5);
  }
}

.admin-dialog-wrapper {
  background: white;
}

.admin-dialog-header {
  padding: 48px 48px 28px;
  text-align: center;
  background: linear-gradient(180deg, $soft-white 0%, white 100%);
  border-bottom: 1px solid rgba($pale-green, 0.6);
}

.admin-avatar {
  width: 90px;
  height: 90px;
  margin: 0 auto 20px;
  background: linear-gradient(135deg, $forest-medium 0%, $forest-primary 100%);
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  box-shadow:
      0 8px 24px rgba($forest-medium, 0.35),
      0 0 0 4px rgba($forest-medium, 0.1);
  position: relative;

  &::before {
    content: '';
    position: absolute;
    inset: -8px;
    border-radius: 50%;
    border: 1px solid rgba($forest-medium, 0.15);
  }
}

.admin-title {
  font-size: 26px;
  font-weight: 700;
  color: $forest-dark;
  margin: 0 0 10px 0;
  letter-spacing: 1px;
}

.admin-subtitle {
  font-size: 15px;
  color: $text-medium;
  margin: 0;
  letter-spacing: 0.5px;
}

.admin-dialog-body {
  padding: 36px 48px;
}

.admin-form {
  :global(.el-form-item) {
    margin-bottom: 24px;

    &:last-child {
      margin-bottom: 0;
    }
  }
}

.admin-input-group {
  display: flex;
  align-items: center;
  background: white;
  border-radius: 16px;
  box-shadow: 0 0 0 2px #4A9B6E inset;
  transition: all 0.3s ease;
  overflow: hidden;

  &:hover {
    box-shadow: 0 0 0 2px #3A7A5A inset;
  }

  &:focus-within {
    box-shadow: 0 0 0 3px #2D5A45 inset;
  }

  .input-icon {
    display: flex;
    align-items: center;
    justify-content: center;
    width: 56px;
    height: 56px;
    color: $forest-medium;
    font-size: 20px;
    flex-shrink: 0;
  }

  :global(.el-input__wrapper) {
    box-shadow: none;
    background: transparent;
    padding: 0;
    flex: 1;
  }

  :global(.el-input__inner) {
    height: 56px;
    font-size: 17px;
    color: $text-dark;
    padding-right: 16px;

    &::placeholder {
      color: rgba($text-medium, 0.5);
    }
  }
}

.admin-dialog-footer {
  display: flex;
  gap: 16px;
  padding: 28px 48px 48px;
  background: white;
  border-top: 1px solid rgba($pale-green, 0.6);
}

.admin-btn {
  flex: 1;
  height: 52px;
  border-radius: 14px;
  font-size: 17px;
  font-weight: 500;
  transition: all 0.3s ease;
}

.admin-btn-cancel {
  border: 1px solid rgba($forest-medium, 0.3);
  color: $text-medium;
  background: white;

  &:hover {
    border-color: $forest-medium;
    color: $forest-medium;
    background: rgba($pale-green, 0.3);
  }
}

.admin-btn-confirm {
  background: linear-gradient(135deg, $forest-medium 0%, $forest-primary 100%);
  border: none;
  color: white;
  box-shadow: 0 4px 16px rgba($forest-medium, 0.35);

  &:hover {
    background: linear-gradient(135deg, $forest-primary 0%, $forest-dark 100%);
    box-shadow: 0 6px 20px rgba($forest-medium, 0.45);
    transform: translateY(-1px);
  }
}
</style>