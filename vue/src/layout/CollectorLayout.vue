<template>
  <div class="collector-layout">
    <!-- 侧边栏 -->
    <aside class="sidebar">
      <div class="logo">
        <div class="logo-icon">
          <el-icon size="24" color="#fff"><ChromeFilled /></el-icon>
        </div>
        <span class="logo-text">绿源回收</span>
      </div>

      <nav class="menu">
        <router-link
            v-for="item in menuItems"
            :key="item.path"
            :to="item.path"
            :class="{ active: $route.path === item.path }"
        >
          <div class="menu-icon" :class="item.colorClass">
            <el-icon :size="18">
              <component :is="item.icon" />
            </el-icon>
          </div>
          <span class="menu-text">{{ item.name }}</span>
          <span v-if="item.path === '/collector/orderCenter' && pendingCount > 0" class="badge">
            {{ pendingCount }}
          </span>
        </router-link>
      </nav>

      <div class="status-bar">
        <div class="status-info">
          <span class="status-dot" :class="{ active: isWorking }"></span>
          <span class="status-text">{{ isWorking ? '接单中' : '休息中' }}</span>
        </div>
        <el-switch
            v-model="isWorking"
            @change="toggleStatus"
            class="status-switch"
        />
      </div>
    </aside>

    <!-- 主内容 -->
    <main class="main-content">
      <header class="header">
        <div class="header-left">
          <h1 class="page-title">{{ $route.meta.title }}</h1>
          <span class="current-date">{{ currentDate }}</span>
        </div>
        <div class="header-right">
          <div class="action-btn" v-if="pendingCount > 0">
            <el-badge :value="pendingCount" :hidden="pendingCount === 0">
              <el-icon size="20"><Bell /></el-icon>
            </el-badge>
          </div>
          <el-dropdown trigger="click">
            <div class="user">
              <el-avatar :size="36" :src="user.avatar" />
              <span class="user-name">{{ user.name }}</span>
              <el-icon size="14"><ArrowDown /></el-icon>
            </div>
            <template #dropdown>
              <el-dropdown-menu class="dropdown-menu">
                <el-dropdown-item @click="$router.push('/collector/profile')">
                  <el-icon><User /></el-icon>个人中心
                </el-dropdown-item>
                <el-dropdown-item divided @click="logout">
                  <el-icon><SwitchButton /></el-icon>退出登录
                </el-dropdown-item>
              </el-dropdown-menu>
            </template>
          </el-dropdown>
        </div>
      </header>

      <div class="content">
        <router-view />
      </div>
    </main>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import {
  Monitor,
  List,
  MapLocation,
  Money,
  User,
  ArrowDown,
  Bell,
  SwitchButton,
  ChromeFilled
} from '@element-plus/icons-vue'
import request from '@/utils/request'

const router = useRouter()
const user = ref(JSON.parse(localStorage.getItem('user') || '{}'))
const isWorking = ref(false)
const pendingCount = ref(0)

const menuItems = [
  { path: '/collector/workbench', name: '工作台', icon: Monitor, colorClass: 'blue' },
  { path: '/collector/orderCenter', name: '订单中心', icon: List, colorClass: 'cyan' },
  { path: '/collector/navigation', name: '地图导航', icon: MapLocation, colorClass: 'green' },
  { path: '/collector/income', name: '收益统计', icon: Money, colorClass: 'amber' },
  { path: '/collector/profile', name: '个人中心', icon: User, colorClass: 'purple' }
]

const currentDate = computed(() => {
  const date = new Date()
  const week = ['日', '一', '二', '三', '四', '五', '六']
  return `${date.getFullYear()}年${date.getMonth() + 1}月${date.getDate()}日 星期${week[date.getDay()]}`
})

let timer = null

onMounted(() => {
  isWorking.value = user.value.workStatus === 1
  loadPendingCount()
  timer = setInterval(loadPendingCount, 30000)
})

onUnmounted(() => {
  if (timer) clearInterval(timer)
})

const loadPendingCount = async () => {
  try {
    const res = await request.get(`/recycleOrder/selectByCollector/${user.value.id}`)
    pendingCount.value = res.filter(o => o.status === 1).length
  } catch (e) {}
}

const toggleStatus = async (val) => {
  try {
    await request.put('/collector/updateWorkStatus', null, {
      params: { id: user.value.id, workStatus: val ? 1 : 0 }
    })
    user.value.workStatus = val ? 1 : 0
    localStorage.setItem('user', JSON.stringify(user.value))
    ElMessage.success(val ? '开始接单' : '已休息')
  } catch (error) {
    ElMessage.error('状态切换失败')
    isWorking.value = !val
  }
}

const logout = () => {
  localStorage.clear()
  router.push('/login')
}
</script>

<style scoped>
/* 基础布局 - 温暖米白色调 */
.collector-layout {
  display: flex;
  min-height: 100vh;
  background: #faf9f7;
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
}

/* 侧边栏 - 温暖米白色 */
.sidebar {
  width: 260px;
  background: #fdfcfa;
  border-right: 1px solid #e8e5e0;
  display: flex;
  flex-direction: column;
  position: fixed;
  left: 0;
  top: 0;
  bottom: 0;
  z-index: 100;
  box-shadow: 2px 0 16px rgba(0, 0, 0, 0.04);
}

/* Logo区域 - 深绿色背景 */
.logo {
  height: 72px;
  display: flex;
  align-items: center;
  padding: 0 20px;
  background: #064e3b;
  gap: 12px;
}

.logo-icon {
  width: 40px;
  height: 40px;
  background: rgba(255, 255, 255, 0.15);
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  border: 1px solid rgba(255, 255, 255, 0.2);
}

.logo-text {
  font-size: 20px;
  font-weight: 700;
  color: #fff;
  letter-spacing: 0.5px;
}

/* 菜单区域 */
.menu {
  flex: 1;
  padding: 24px 16px;
  overflow-y: auto;
}

.menu::-webkit-scrollbar {
  width: 5px;
}

.menu::-webkit-scrollbar-thumb {
  background: #d6d3cd;
  border-radius: 3px;
}

.menu a {
  display: flex;
  align-items: center;
  padding: 12px 14px;
  margin-bottom: 8px;
  color: #57534e;
  text-decoration: none;
  border-radius: 10px;
  transition: all 0.25s ease;
  font-size: 14px;
  gap: 12px;
  position: relative;
  background: transparent;
  border: 1px solid transparent;
}

.menu a:hover {
  background: #fff;
  color: #292524;
  border-color: #e7e5e4;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.06);
  transform: translateX(2px);
}

.menu a.active {
  background: #fff;
  color: #059669;
  border-color: #a7f3d0;
  box-shadow: 0 4px 12px rgba(5, 150, 105, 0.12);
  font-weight: 600;
}

/* 菜单图标 */
.menu-icon {
  width: 38px;
  height: 38px;
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 18px;
  flex-shrink: 0;
  transition: all 0.25s ease;
}

.menu a:hover .menu-icon {
  transform: scale(1.08);
}

/* 图标配色 - pastel 柔和色调 */
.menu-icon.blue { background: #dbeafe; color: #2563eb; }
.menu-icon.cyan { background: #cffafe; color: #0891b2; }
.menu-icon.green { background: #dcfce7; color: #16a34a; }
.menu-icon.amber { background: #fef3c7; color: #d97706; }
.menu-icon.purple { background: #f3e8ff; color: #9333ea; }

.menu a.active .menu-icon {
  background: #d1fae5;
  color: #059669;
}

.menu-text {
  font-size: 14px;
  font-weight: 500;
  flex: 1;
}

/* 角标 */
.badge {
  min-width: 20px;
  height: 20px;
  padding: 0 6px;
  background: #ef4444;
  color: #fff;
  font-size: 11px;
  font-weight: 600;
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: 0 2px 6px rgba(239, 68, 68, 0.3);
}

/* 状态栏 */
.status-bar {
  padding: 20px 16px;
  background: #faf9f7;
  border-top: 1px solid #e8e5e0;
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.status-info {
  display: flex;
  align-items: center;
  gap: 10px;
}

.status-dot {
  width: 10px;
  height: 10px;
  border-radius: 50%;
  background: #d6d3cd;
  transition: all 0.3s;
}

.status-dot.active {
  background: #10b981;
  box-shadow: 0 0 0 4px rgba(16, 185, 129, 0.2);
}

.status-text {
  font-size: 14px;
  color: #57534e;
  font-weight: 600;
}

/* 主内容区 */
.main-content {
  flex: 1;
  margin-left: 260px;
  display: flex;
  flex-direction: column;
  min-height: 100vh;
}

/* 顶部栏 */
.header {
  height: 72px;
  background: #fff;
  border-bottom: 1px solid #e8e5e0;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 32px;
  position: sticky;
  top: 0;
  z-index: 50;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
}

.header-left {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.page-title {
  font-size: 24px;
  font-weight: 700;
  color: #1c1917;
  margin: 0;
  letter-spacing: -0.5px;
}

.current-date {
  font-size: 13px;
  color: #78716c;
  font-weight: 500;
}

.header-right {
  display: flex;
  align-items: center;
  gap: 16px;
}

/* 操作按钮 */
.action-btn {
  width: 44px;
  height: 44px;
  border-radius: 10px;
  background: #fafaf9;
  border: 1px solid #e7e5e4;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #78716c;
  cursor: pointer;
  transition: all 0.2s ease;
}

.action-btn:hover {
  background: #fff;
  border-color: #d6d3cd;
  color: #57534e;
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
}

/* 用户菜单 */
.user {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 6px 14px 6px 6px;
  border-radius: 10px;
  cursor: pointer;
  transition: all 0.2s ease;
  border: 1px solid #e7e5e4;
  background: #fff;
}

.user:hover {
  background: #fafaf9;
  border-color: #d6d3cd;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.06);
}

.user-name {
  font-size: 14px;
  color: #1c1917;
  font-weight: 600;
}

/* 内容区域 */
.content {
  flex: 1;
  padding: 28px 32px;
  background: #faf9f7;
  max-width: 1400px;
  width: 100%;
  margin: 0 auto;
}

/* 过渡动画 */
.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.3s ease, transform 0.3s ease;
}

.fade-enter-from {
  opacity: 0;
  transform: translateY(10px);
}

.fade-leave-to {
  opacity: 0;
  transform: translateY(-10px);
}

/* 响应式 */
@media (max-width: 768px) {
  .sidebar {
    transform: translateX(-100%);
  }
  .main-content {
    margin-left: 0;
  }
  .user-name {
    display: none;
  }
}
</style>

<style>
/* 全局样式覆盖 */
.collector-layout .status-switch .el-switch__core {
  border-color: #d6d3cd !important;
  background-color: #d6d3cd !important;
}

.collector-layout .status-switch.is-checked .el-switch__core {
  border-color: #10b981 !important;
  background-color: #10b981 !important;
}

.collector-layout .status-switch .el-switch__action {
  background-color: white !important;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1) !important;
}

.collector-layout .dropdown-menu {
  border-radius: 10px !important;
  border: 1px solid #e7e5e4 !important;
  box-shadow: 0 10px 40px rgba(0,0,0,0.08) !important;
  padding: 8px !important;
}

.collector-layout .dropdown-menu .el-dropdown-menu__item {
  padding: 10px 16px !important;
  border-radius: 8px !important;
  font-size: 14px !important;
  color: #57534e !important;
  display: flex !important;
  align-items: center !important;
  gap: 10px !important;
}

.collector-layout .dropdown-menu .el-dropdown-menu__item:hover {
  background: #f5f5f4 !important;
  color: #059669 !important;
}

.collector-layout .dropdown-menu .el-dropdown-menu__item .el-icon {
  color: #a8a29e !important;
  font-size: 16px !important;
}

.collector-layout .dropdown-menu .el-dropdown-menu__item:hover .el-icon {
  color: #10b981 !important;
}

.collector-layout .dropdown-menu .el-dropdown-menu__item--divided {
  margin: 8px 0 !important;
  border-top-color: #e7e5e4 !important;
}

.collector-layout .dropdown-menu .el-dropdown-menu__item--divided::before {
  display: none !important;
}

.collector-layout .el-avatar {
  background: linear-gradient(135deg, #059669 0%, #10b981 100%) !important;
  color: white !important;
  font-weight: 500 !important;
}
</style>