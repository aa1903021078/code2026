<template>
  <div class="user-layout">
    <!-- 顶部导航 -->
    <header class="user-header">
      <div class="header-content">
        <div class="logo" @click="$router.push('/')">
          <span class="logo-icon">♻️</span>
          <span class="logo-text">绿色回收</span>
        </div>

        <nav class="main-nav">
          <router-link to="/user/home" :class="{ active: $route.path === '/user/home' }">首页</router-link>
          <router-link to="/user/recycle" :class="{ active: $route.path === '/user/recycle' }">预约回收</router-link>
          <router-link to="/user/orderList" :class="{ active: $route.path === '/user/orderList' }">我的订单</router-link>
          <router-link to="/user/points" :class="{ active: $route.path === '/user/points' }">积分商城</router-link>
          <router-link to="/user/ecoRank" :class="{ active: $route.path === '/user/ecoRank' }">环保榜</router-link>
          <router-link to="/user/notice" :class="{ active: $route.path === '/user/notice' }">公告</router-link>
        </nav>

        <div class="user-actions">
          <el-dropdown v-if="user">
            <span class="user-info">
              <el-avatar :size="32" :src="user.avatar || '/default-avatar.png'" />
              <span class="username">{{ user.name }}</span>
              <el-icon><ArrowDown /></el-icon>
            </span>
            <template #dropdown>
              <el-dropdown-menu>
                <el-dropdown-item @click="$router.push('/user/profile')">个人中心</el-dropdown-item>
                <el-dropdown-item @click="$router.push('/user/addressManage')">地址管理</el-dropdown-item>
                <el-dropdown-item divided @click="logout">退出登录</el-dropdown-item>
              </el-dropdown-menu>
            </template>
          </el-dropdown>
          <el-button v-else type="primary" @click="$router.push('/login')">登录</el-button>
        </div>
      </div>
    </header>

    <!-- 主内容区 -->
    <main class="main-content">
      <router-view v-slot="{ Component }">
        <transition name="fade" mode="out-in">
          <component :is="Component" />
        </transition>
      </router-view>
    </main>

    <!-- 底部 -->
    <footer class="user-footer">
      <div class="footer-content">
        <div class="footer-section">
          <h4>关于我们</h4>
          <p>致力于打造便捷、高效的废旧家电回收平台，推动绿色循环经济发展。</p>
        </div>
        <div class="footer-section">
          <h4>联系方式</h4>
          <p>客服热线：400-888-8888</p>
          <p>邮箱：service@recycle.com</p>
        </div>
        <div class="footer-section">
          <h4>环保数据</h4>
          <p>已累计回收：{{ totalWeight }}kg</p>
          <p>减少碳排放：{{ totalCarbon }}kg</p>
        </div>
      </div>
      <div class="copyright">
        © 2026 社区家电回收预约平台 版权所有
      </div>
    </footer>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { ArrowDown } from '@element-plus/icons-vue'
import request from '@/utils/request'

const router = useRouter()
const user = ref(JSON.parse(localStorage.getItem('user') || '{}'))
const totalWeight = ref(0)
const totalCarbon = ref(0)

onMounted(async () => {
  try {
    const res = await request.get('/recycleOrder/statistics')
    totalWeight.value = res.totalWeight || 0
    totalCarbon.value = res.totalCarbonSaved || 0
  } catch (e) {}
})

const logout = () => {
  localStorage.clear()
  ElMessage.success('已退出登录')
  router.push('/login')
}
</script>

<style scoped lang="scss">
.user-layout {
  min-height: 100vh;
  display: flex;
  flex-direction: column;
  background: #f5f7fa;
}

.user-header {
  background: #fff;
  box-shadow: 0 2px 8px rgba(0,0,0,0.1);
  position: sticky;
  top: 0;
  z-index: 100;

  .header-content {
    max-width: 1200px;
    margin: 0 auto;
    height: 64px;
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 0 20px;
  }

  .logo {
    display: flex;
    align-items: center;
    cursor: pointer;

    .logo-icon {
      font-size: 32px;
      margin-right: 8px;
    }

    .logo-text {
      font-size: 20px;
      font-weight: bold;
      color: #52c41a;
    }
  }

  .main-nav {
    display: flex;
    gap: 30px;

    a {
      color: #666;
      text-decoration: none;
      font-size: 15px;
      padding: 8px 0;
      position: relative;
      transition: color 0.3s;

      &:hover, &.active {
        color: #52c41a;

        &::after {
          content: '';
          position: absolute;
          bottom: 0;
          left: 0;
          right: 0;
          height: 2px;
          background: #52c41a;
          border-radius: 2px;
        }
      }
    }
  }

  .user-actions {
    .user-info {
      display: flex;
      align-items: center;
      cursor: pointer;
      gap: 8px;

      .username {
        color: #333;
        font-size: 14px;
      }
    }
  }
}

.main-content {
  flex: 1;
  max-width: 1200px;
  width: 100%;
  margin: 0 auto;
  padding: 20px;
}

.user-footer {
  background: #2c3e50;
  color: #fff;
  padding: 40px 20px 20px;

  .footer-content {
    max-width: 1200px;
    margin: 0 auto;
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: 40px;
    margin-bottom: 30px;

    .footer-section {
      h4 {
        font-size: 18px;
        margin-bottom: 15px;
        color: #52c41a;
      }

      p {
        color: #bdc3c7;
        line-height: 1.8;
        font-size: 14px;
      }
    }
  }

  .copyright {
    text-align: center;
    padding-top: 20px;
    border-top: 1px solid #34495e;
    color: #95a5a6;
    font-size: 14px;
  }
}

.fade-enter-active, .fade-leave-active {
  transition: opacity 0.3s ease;
}

.fade-enter-from, .fade-leave-to {
  opacity: 0;
}
</style>