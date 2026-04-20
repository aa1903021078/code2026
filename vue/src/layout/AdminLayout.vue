<template>
  <div class="admin-layout" :class="{ collapsed: isCollapsed }">
    <!-- 侧边栏 -->
    <aside class="sidebar">
      <div class="logo-area">
        <div class="logo-icon">
          <el-icon size="24" color="#fff"><ChromeFilled /></el-icon>
        </div>
        <span v-if="!isCollapsed" class="logo-text">绿色回收</span>
      </div>

      <div class="menu-wrapper">
        <!-- 数据概览 -->
        <div class="menu-group">
          <div v-if="!isCollapsed" class="group-title">数据概览</div>
          <router-link to="/admin/dashboard" class="menu-item" :class="{ active: isActive('/admin/dashboard') }">
            <div class="item-icon blue">
              <el-icon><Odometer /></el-icon>
            </div>
            <span v-if="!isCollapsed" class="item-text">数据大屏</span>
          </router-link>
        </div>

        <!-- 订单管理 -->
        <div class="menu-group">
          <div v-if="!isCollapsed" class="group-title">订单管理</div>
          <router-link to="/admin/orderList" class="menu-item" :class="{ active: isActive('/admin/orderList') }">
            <div class="item-icon cyan">
              <el-icon><Document /></el-icon>
            </div>
            <span v-if="!isCollapsed" class="item-text">全部订单</span>
            <span v-if="stats.pendingOrder > 0 && !isCollapsed" class="badge">{{ stats.pendingOrder }}</span>
          </router-link>
          <router-link to="/admin/dispatch" class="menu-item" :class="{ active: isActive('/admin/dispatch') }">
            <div class="item-icon orange">
              <el-icon><Position /></el-icon>
            </div>
            <span v-if="!isCollapsed" class="item-text">智能派单</span>
          </router-link>
        </div>

        <!-- 用户管理 -->
        <div class="menu-group">
          <div v-if="!isCollapsed" class="group-title">用户管理</div>
          <router-link to="/admin/users" class="menu-item" :class="{ active: isActive('/admin/users') }">
            <div class="item-icon purple">
              <el-icon><User /></el-icon>
            </div>
            <span v-if="!isCollapsed" class="item-text">用户管理</span>
          </router-link>
          <router-link to="/admin/collectors" class="menu-item" :class="{ active: isActive('/admin/collectors') }">
            <div class="item-icon green">
              <el-icon><Van /></el-icon>
            </div>
            <span v-if="!isCollapsed" class="item-text">回收员管理</span>
          </router-link>
          <router-link to="/admin/audit" class="menu-item" :class="{ active: isActive('/admin/audit') }">
            <div class="item-icon red">
              <el-icon><Stamp /></el-icon>
            </div>
            <span v-if="!isCollapsed" class="item-text">资质审核</span>
            <span v-if="stats.waitAudit > 0 && !isCollapsed" class="badge danger">{{ stats.waitAudit }}</span>
          </router-link>
        </div>

        <!-- 内容管理 -->
        <div class="menu-group">
          <div v-if="!isCollapsed" class="group-title">内容管理</div>
          <router-link to="/admin/banner" class="menu-item" :class="{ active: isActive('/admin/banner') }">
            <div class="item-icon pink">
              <el-icon><Picture /></el-icon>
            </div>
            <span v-if="!isCollapsed" class="item-text">轮播图管理</span>
          </router-link>
          <router-link to="/admin/notices" class="menu-item" :class="{ active: isActive('/admin/notices') }">
            <div class="item-icon teal">
              <el-icon><Bell /></el-icon>
            </div>
            <span v-if="!isCollapsed" class="item-text">公告管理</span>
          </router-link>
        </div>

        <!-- 系统配置 -->
        <div class="menu-group">
          <div v-if="!isCollapsed" class="group-title">系统配置</div>
          <router-link to="/admin/appliance-types" class="menu-item" :class="{ active: isActive('/admin/appliance-types') }">
            <div class="item-icon indigo">
              <el-icon><Refrigerator /></el-icon>
            </div>
            <span v-if="!isCollapsed" class="item-text">品类管理</span>
          </router-link>
          <router-link to="/admin/points" class="menu-item" :class="{ active: isActive('/admin/points') }">
            <div class="item-icon amber">
              <el-icon><Coin /></el-icon>
            </div>
            <span v-if="!isCollapsed" class="item-text">积分管理</span>
          </router-link>
          <router-link to="/admin/statistics" class="menu-item" :class="{ active: isActive('/admin/statistics') }">
            <div class="item-icon rose">
              <el-icon><TrendCharts /></el-icon>
            </div>
            <span v-if="!isCollapsed" class="item-text">数据统计</span>
          </router-link>
        </div>

        <!-- 个人中心 -->
        <div class="menu-group">
          <div v-if="!isCollapsed" class="group-title">个人中心</div>
          <router-link to="/admin/profile" class="menu-item" :class="{ active: isActive('/admin/profile') }">
            <div class="item-icon gray">
              <el-icon><User /></el-icon>
            </div>
            <span v-if="!isCollapsed" class="item-text">个人中心</span>
          </router-link>
        </div>
      </div>

      <!-- 底部折叠按钮 -->
      <div class="sidebar-footer">
        <button class="collapse-btn" @click="toggleSidebar">
          <el-icon size="16">
            <Fold v-if="!isCollapsed" />
            <Expand v-else />
          </el-icon>
        </button>
      </div>
    </aside>

    <!-- 主内容区 -->
    <main class="main-content">
      <!-- 顶部栏 -->
      <header class="top-header">
        <div class="header-left">
          <h1 class="page-title">{{ $route.meta.title || '管理后台' }}</h1>
          <span class="current-date">{{ currentDate }}</span>
        </div>

        <div class="header-right">
          <div class="search-box">
            <el-icon class="search-icon"><Search /></el-icon>
            <input
                v-model="searchKey"
                type="text"
                placeholder="全局搜索..."
                class="search-input"
            />
          </div>

          <div class="action-btn" @click="showNotifications">
            <el-badge :value="notificationCount" :hidden="notificationCount === 0" :max="99">
              <el-icon size="20"><Bell /></el-icon>
            </el-badge>
          </div>

          <div class="action-btn" @click="toggleFullscreen">
            <el-icon size="20"><FullScreen /></el-icon>
          </div>

          <el-dropdown trigger="click">
            <div class="user-menu">
              <el-avatar :size="36" :src="adminInfo.avatar" />
              <div v-if="!isCollapsed" class="user-info">
                <span class="name">{{ adminInfo.name }}</span>
                <span class="role">{{ adminInfo.role }}</span>
              </div>
              <el-icon class="arrow-icon"><ArrowDown /></el-icon>
            </div>
            <template #dropdown>
              <el-dropdown-menu>
                <el-dropdown-item @click="$router.push('/admin/profile')">
                  <el-icon><User /></el-icon>个人中心
                </el-dropdown-item>
                <el-dropdown-item divided @click="handleLogout">
                  <el-icon><SwitchButton /></el-icon>退出登录
                </el-dropdown-item>
              </el-dropdown-menu>
            </template>
          </el-dropdown>
        </div>
      </header>

      <!-- 内容容器 -->
      <div class="content-wrapper">
        <router-view v-slot="{ Component }">
          <transition name="fade" mode="out-in">
            <keep-alive :include="cachedViews">
              <component :is="Component" :key="route.path" />
            </keep-alive>
          </transition>
        </router-view>
      </div>

      <!-- 页脚 -->
      <footer class="footer">
        <p>© 2026 绿色回收平台 | 清新简洁版</p>
      </footer>
    </main>

    <!-- 通知弹窗 -->
    <el-dialog
        v-model="notificationVisible"
        title="消息通知"
        width="400px"
        align-center
        class="notification-dialog"
    >
      <div class="notification-list">
        <div
            v-for="(item, index) in notifications"
            :key="index"
            class="notification-card"
            :class="{ unread: !item.read }"
            @click="markAsRead(index)"
        >
          <div class="card-icon" :class="item.type">
            <el-icon v-if="item.type === 'order'"><ShoppingCart /></el-icon>
            <el-icon v-else-if="item.type === 'audit'"><Stamp /></el-icon>
            <el-icon v-else><Bell /></el-icon>
          </div>
          <div class="card-content">
            <div class="card-title">{{ item.title }}</div>
            <div class="card-desc">{{ item.content }}</div>
            <div class="card-time">{{ item.time }}</div>
          </div>
          <div v-if="!item.read" class="unread-dot"></div>
        </div>
      </div>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import {
  Odometer, Document, Position, User, Van, Stamp,
  Refrigerator, Coin, Bell, TrendCharts, Tools,
  ChromeFilled, Search, FullScreen, ArrowDown, SwitchButton,
  Fold, Expand, Picture, ShoppingCart
} from '@element-plus/icons-vue'
import { selectPendingAudit } from '@/api/collector'

const route = useRoute()
const router = useRouter()

const isCollapsed = ref(false)
const searchKey = ref('')
const cachedViews = ref(['Dashboard'])
const notificationVisible = ref(false)
const notificationCount = ref(3)

const adminInfo = ref({
  name: '系统管理员',
  role: '超级管理员',
  avatar: 'https://cube.elemecdn.com/0/88/03b0d39583f48206768a7534e55bcpng.png'
})

const stats = ref({
  pendingOrder: 0,
  waitAudit: 0
})

// 拉取待审核回收员数量用于侧边栏角标
const loadWaitAuditCount = async () => {
  try {
    const res = await selectPendingAudit()
    // 拦截器成功时已解包为 data（数组）
    stats.value.waitAudit = Array.isArray(res) ? res.length : 0
  } catch (e) {
    stats.value.waitAudit = 0
  }
}

const notifications = ref([
  { type: 'order', title: '新订单提醒', content: '您有一个新的回收订单待处理', time: '5分钟前', read: false },
  { type: 'audit', title: '资质审核', content: '有新的回收员提交入驻申请', time: '30分钟前', read: false },
  { type: 'system', title: '系统通知', content: '系统将于今晚进行例行维护', time: '2小时前', read: false }
])

const currentDate = computed(() => {
  const date = new Date()
  const week = ['日', '一', '二', '三', '四', '五', '六']
  return `${date.getFullYear()}年${date.getMonth() + 1}月${date.getDate()}日 星期${week[date.getDay()]}`
})

const isActive = (path) => route.path === path

const toggleSidebar = () => {
  isCollapsed.value = !isCollapsed.value
  localStorage.setItem('sidebarCollapsed', isCollapsed.value)
}

const toggleFullscreen = () => {
  if (!document.fullscreenElement) {
    document.documentElement.requestFullscreen()
  } else {
    document.exitFullscreen()
  }
}

const showNotifications = () => {
  notificationVisible.value = true
  notificationCount.value = 0
}

const markAsRead = (index) => {
  notifications.value[index].read = true
}

const handleLogout = async () => {
  try {
    await ElMessageBox.confirm('确定要退出管理系统吗？', '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
    localStorage.clear()
    ElMessage.success('已安全退出')
    router.push('/login')
  } catch {}
}

onMounted(() => {
  const savedState = localStorage.getItem('sidebarCollapsed')
  if (savedState !== null) {
    isCollapsed.value = savedState === 'true'
  }
  const user = JSON.parse(localStorage.getItem('user') || '{}')
  if (user.name) {
    adminInfo.value = { ...adminInfo.value, ...user }
  }
  loadWaitAuditCount()
})
</script>

<style scoped>
/* 基础布局 */
.admin-layout {
  display: flex;
  min-height: 100vh;
  background: #faf9f7;
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
}

/* 侧边栏 - 温暖浅米色 */
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
  transition: width 0.3s ease;
  box-shadow: 2px 0 16px rgba(0, 0, 0, 0.04);
}

.admin-layout.collapsed .sidebar {
  width: 80px;
}

/* Logo区域 - 使用深绿色背景突出 */
.logo-area {
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
  flex-shrink: 0;
  border: 1px solid rgba(255, 255, 255, 0.2);
}

.logo-text {
  font-size: 20px;
  font-weight: 700;
  color: #fff;
  letter-spacing: 0.5px;
}

/* 菜单区域 */
.menu-wrapper {
  flex: 1;
  padding: 24px 16px;
  overflow-y: auto;
  background: #fdfcfa;
}

.menu-wrapper::-webkit-scrollbar {
  width: 5px;
}

.menu-wrapper::-webkit-scrollbar-thumb {
  background: #d6d3cd;
  border-radius: 3px;
}

.menu-group {
  margin-bottom: 28px;
}

.group-title {
  font-size: 11px;
  font-weight: 700;
  color: #a8a49d;
  text-transform: uppercase;
  letter-spacing: 1px;
  padding: 0 12px;
  margin-bottom: 10px;
}

/* 菜单项 - 悬停时温暖背景 */
.menu-item {
  display: flex;
  align-items: center;
  padding: 12px 14px;
  border-radius: 10px;
  color: #57534e;
  text-decoration: none;
  margin-bottom: 6px;
  transition: all 0.25s ease;
  position: relative;
  background: transparent;
  border: 1px solid transparent;
}

.menu-item:hover {
  background: #fff;
  color: #292524;
  border-color: #e7e5e4;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.06);
  transform: translateX(2px);
}

.menu-item.active {
  background: #fff;
  color: #059669;
  border-color: #a7f3d0;
  box-shadow: 0 4px 12px rgba(5, 150, 105, 0.12);
  font-weight: 600;
}

.item-icon {
  width: 38px;
  height: 38px;
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-right: 14px;
  font-size: 18px;
  flex-shrink: 0;
  transition: all 0.25s ease;
}

.menu-item:hover .item-icon {
  transform: scale(1.08);
}

/* 图标配色 - 更柔和的 pastel 色调 */
.item-icon.blue { background: #dbeafe; color: #2563eb; }
.item-icon.cyan { background: #cffafe; color: #0891b2; }
.item-icon.orange { background: #ffedd5; color: #ea580c; }
.item-icon.purple { background: #f3e8ff; color: #9333ea; }
.item-icon.green { background: #dcfce7; color: #16a34a; }
.item-icon.red { background: #fee2e2; color: #dc2626; }
.item-icon.pink { background: #fce7f3; color: #db2777; }
.item-icon.teal { background: #ccfbf1; color: #0d9488; }
.item-icon.indigo { background: #e0e7ff; color: #4f46e5; }
.item-icon.amber { background: #fef3c7; color: #d97706; }
.item-icon.rose { background: #ffe4e6; color: #e11d48; }
.item-icon.gray { background: #f5f5f4; color: #78716c; }

.menu-item.active .item-icon {
  background: #d1fae5;
  color: #059669;
}

.item-text {
  font-size: 14px;
  font-weight: 500;
  flex: 1;
}

/* 角标样式 */
.badge {
  min-width: 20px;
  height: 20px;
  padding: 0 6px;
  background: #f87171;
  color: #fff;
  font-size: 11px;
  font-weight: 600;
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-left: auto;
  box-shadow: 0 2px 6px rgba(248, 113, 113, 0.3);
}

.badge.danger {
  background: #ef4444;
}

/* 折叠状态适配 */
.admin-layout.collapsed .menu-item {
  justify-content: center;
  padding: 14px;
}

.admin-layout.collapsed .item-icon {
  margin-right: 0;
}

/* 侧边栏底部 */
.sidebar-footer {
  padding: 16px;
  background: #faf9f7;
  border-top: 1px solid #e8e5e0;
  display: flex;
  justify-content: center;
}

.collapse-btn {
  width: 40px;
  height: 40px;
  border: 1px solid #d6d3cd;
  background: #fff;
  border-radius: 10px;
  color: #78716c;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.2s ease;
}

.collapse-btn:hover {
  background: #f5f5f4;
  color: #57534e;
  border-color: #a8a29e;
  transform: scale(1.05);
}

/* 主内容区 */
.main-content {
  flex: 1;
  margin-left: 260px;
  display: flex;
  flex-direction: column;
  min-height: 100vh;
  transition: margin-left 0.3s ease;
}

.admin-layout.collapsed .main-content {
  margin-left: 80px;
}

/* 顶部栏 */
.top-header {
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

/* 搜索框 */
.search-box {
  position: relative;
  width: 280px;
}

.search-icon {
  position: absolute;
  left: 14px;
  top: 50%;
  transform: translateY(-50%);
  color: #a8a29e;
  font-size: 16px;
  z-index: 1;
}

.search-input {
  width: 100%;
  height: 42px;
  padding: 0 16px 0 42px;
  border: 1px solid #e7e5e4;
  border-radius: 10px;
  background: #fafaf9;
  font-size: 14px;
  color: #44403c;
  transition: all 0.2s ease;
  outline: none;
}

.search-input:focus {
  background: #fff;
  border-color: #10b981;
  box-shadow: 0 0 0 3px rgba(16, 185, 129, 0.1);
}

.search-input::placeholder {
  color: #a8a29e;
}

/* 操作按钮 */
.action-btn {
  width: 42px;
  height: 42px;
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
.user-menu {
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

.user-menu:hover {
  background: #fafaf9;
  border-color: #d6d3cd;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.06);
}

.user-info {
  display: flex;
  flex-direction: column;
  line-height: 1.3;
}

.user-info .name {
  font-size: 14px;
  font-weight: 600;
  color: #1c1917;
}

.user-info .role {
  font-size: 11px;
  color: #059669;
  font-weight: 600;
}

.arrow-icon {
  color: #a8a29e;
  font-size: 12px;
  margin-left: 4px;
}

/* 内容容器 */
.content-wrapper {
  flex: 1;
  padding: 28px 32px;
  overflow-y: auto;
  background: #faf9f7;
}

/* 页脚 */
.footer {
  padding: 20px 32px;
  text-align: center;
  background: #fff;
  border-top: 1px solid #e8e5e0;
}

.footer p {
  color: #a8a29e;
  font-size: 13px;
  margin: 0;
  font-weight: 500;
}

/* 通知弹窗样式 */
.notification-list {
  padding: 4px;
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.notification-card {
  display: flex;
  align-items: flex-start;
  gap: 14px;
  padding: 16px;
  border-radius: 12px;
  cursor: pointer;
  transition: all 0.2s ease;
  position: relative;
  background: #fafaf9;
  border: 1px solid #f0f0f0;
}

.notification-card:hover {
  background: #fff;
  border-color: #e7e5e4;
  transform: translateX(4px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.06);
}

.notification-card.unread {
  background: #ecfdf5;
  border-color: #a7f3d0;
}

.card-icon {
  width: 42px;
  height: 42px;
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 20px;
  flex-shrink: 0;
}

.card-icon.order { background: #dbeafe; color: #2563eb; }
.card-icon.audit { background: #fee2e2; color: #dc2626; }
.card-icon.system { background: #dcfce7; color: #16a34a; }

.card-content {
  flex: 1;
  min-width: 0;
}

.card-title {
  font-weight: 600;
  color: #1c1917;
  margin-bottom: 6px;
  font-size: 15px;
}

.card-desc {
  color: #57534e;
  font-size: 13px;
  line-height: 1.5;
  margin-bottom: 8px;
}

.card-time {
  color: #a8a29e;
  font-size: 12px;
  font-weight: 500;
}

.unread-dot {
  width: 8px;
  height: 8px;
  background: #10b981;
  border-radius: 50%;
  flex-shrink: 0;
  margin-top: 6px;
  box-shadow: 0 0 0 3px rgba(16, 185, 129, 0.2);
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
@media (max-width: 1024px) {
  .sidebar {
    transform: translateX(-100%);
  }

  .main-content {
    margin-left: 0;
  }

  .search-box {
    width: 220px;
  }
}

@media (max-width: 768px) {
  .top-header {
    padding: 0 20px;
  }

  .search-box,
  .user-info {
    display: none;
  }

  .content-wrapper {
    padding: 20px;
  }
}
</style>