import { createRouter, createWebHistory } from 'vue-router'
import { ElMessage } from 'element-plus'

const routes = [
  // ========== 登录注册 ==========
  {
    path: '/login',
    name: 'Login',
    component: () => import('@/views/Login.vue'),
    meta: { title: '登录 - 绿色回收平台', public: true }
  },
  {
    path: '/register',
    name: 'UserRegister',
    component: () => import('@/views/register/UserRegister.vue'),
    meta: { title: '用户注册', public: true }
  },
  {
    path: '/collector-register',
    name: 'CollectorRegister',
    component: () => import('@/views/register/CollectorRegister.vue'),
    meta: { title: '回收员申请', public: true }
  },
  {
    path: '/collector-status-query',
    name: 'CollectorStatusQuery',
    component: () => import('@/views/collector/CollectorStatusQuery.vue'),
    meta:{ title: '查询审核详情'}
  },
  {
    path: '/register-success',           // 图中显示的这个路由
    name: 'RegisterSuccess',
    component: () => import('@/views/register/RegisterSuccess.vue'),
    meta:{title: '注册成功页面'}
  },

  // ========== 用户端（前台） ==========
  {
    path: '/user',
    component: () => import('@/layout/UserLayout.vue'),
    meta: { requireAuth: true, role: '普通用户' },
    children: [
      { path: '', redirect: '/user/home' },
      {
        path: 'home',
        name: 'UserHome',
        component: () => import('@/views/user/Home.vue'),
        meta: { title: '首页', keepAlive: true }
      },
      {
        path: 'recycle',
        name: 'UserRecycle',
        component: () => import('@/views/user/Recycle.vue'),
        meta: { title: '预约回收' }
      },
      {
        path: 'orderList',
        name: 'UserOrderList',
        component: () => import('@/views/user/OrderList.vue'),
        meta: { title: '我的订单' }
      },
      {
        path: 'addressManage',
        name: 'UserAddress',
        component: () => import('@/views/user/AddressManage.vue'),
        meta: { title: '地址管理' }
      },
      {
        path: 'points',
        name: 'UserPointsMall',
        component: () => import('@/views/user/PointsMall.vue'),
        meta: { title: '积分商城' }
      },
      {
        path: 'ecoRank',
        name: 'UserEcoRank',
        component: () => import('@/views/user/EcoRank.vue'),
        meta: { title: '环保排名' }
      },
      {
        path: 'notice',
        name: 'UserNotice',
        component: () => import('@/views/user/Notice.vue'),
        meta: { title: '社区公告' }
      },
      {
        path: 'profile',
        name: 'UserProfile',
        component: () => import('@/views/user/Profile.vue'),
        meta: { title: '个人中心' }
      }
    ]
  },

  // ========== 回收员端（前台） ==========
  {
    path: '/collector',
    component: () => import('@/layout/CollectorLayout.vue'),
    meta: { requireAuth: true, role: '回收员' },
    children: [
      { path: '', redirect: '/collector/workbench' },
      {
        path: 'workbench',
        name: 'CollectorWorkbench',
        component: () => import('@/views/collector/Workbench.vue'),
        meta: { title: '工作台' }
      },
      {
        path: 'orderCenter',
        name: 'CollectorOrderCenter',
        component: () => import('@/views/collector/OrderCenter.vue'),
        meta: { title: '订单中心' }
      },
      {
        path: 'navigation',
        name: 'CollectorNavigation',
        component: () => import('@/views/collector/Navigation.vue'),
        meta: { title: '地图导航' }
      },
      {
        path: 'income',
        name: 'CollectorIncome',
        component: () => import('@/views/collector/Income.vue'),
        meta: { title: '收益统计' }
      },
      {
        path: 'profile',
        name: 'CollectorProfile',
        component: () => import('@/views/collector/Profile.vue'),
        meta: { title: '个人中心' }
      }
    ]
  },

  // ========== 管理员端（后台） ==========
  {
    path: '/admin',
    component: () => import('@/layout/AdminLayout.vue'),
    meta: { requireAuth: true, role: '管理员' },
    children: [
      { path: '', redirect: '/admin/dashboard' },
      {
        path: 'dashboard',
        name: 'AdminDashboard',
        component: () => import('@/views/admin/Dashboard.vue'),
        meta: { title: '数据大屏', icon: 'DataLine' }
      },
      {
        path: 'dispatch',
        name: 'OrderDispatch',
        component: () => import('@/views/admin/Dispatch.vue'),
        meta: { title: '智能派单', icon: 'MapLocation' }
      },
      {
        path: 'orderList',
        name: 'OrderManage',
        component: () => import('@/views/admin/OrderManage.vue'),
        meta: { title: '订单管理', icon: 'List' }
      },
      {
        path: 'users',
        name: 'UserManage',
        component: () => import('@/views/admin/UserManage.vue'),
        meta: { title: '用户管理', icon: 'User' }
      },
      {
        path: 'collectors',
        name: 'CollectorManage',
        component: () => import('@/views/admin/CollectorManage.vue'),
        meta: { title: '回收员管理', icon: 'UserFilled' }
      },
      {
        path: 'audit',
        name: 'CollectorAudit',
        component: () => import('@/views/admin/CollectorAudit.vue'),
        meta: { title: '资质审核', icon: 'CircleCheck' }
      },
      {
        path: 'appliance-types',
        name: 'ApplianceTypeManage',
        component: () => import('@/views/admin/ApplianceTypeManage.vue'),
        meta: { title: '品类管理', icon: 'Refrigerator' }
      },
      {
        path: 'points',
        name: 'PointsManage',
        component: () => import('@/views/admin/PointsManage.vue'),
        meta: { title: '积分管理', icon: 'Coin' }
      },
      {
        path: 'notices',
        name: 'NoticeManage',
        component: () => import('@/views/admin/NoticeManage.vue'),
        meta: { title: '公告管理', icon: 'Bell' }
      },
      {
        path: 'statistics',
        name: 'Statistics',
        component: () => import('@/views/admin/Statistics.vue'),
        meta: { title: '数据统计', icon: 'TrendCharts' }
      },
      {
        path: 'banner',
        name: 'Banner',
        component: () => import('@/views/admin/Banner.vue'),
        meta: { title: '轮播图管理', icon: 'Picture' }
      },
      {
        path: 'profile',
        name: 'AdminProfile',
        component: () => import('@/views/admin/Profile.vue'),
        meta: { title: '个人中心', icon: 'User' }
      }
    ]
  },

  // ========== 404 重定向 ==========
  {
    path: '/:pathMatch(.*)*',
    redirect: '/login'
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes,
  scrollBehavior() {
    return { top: 0 }
  }
})

// ========== 路由守卫 - 权限验证 ==========
router.beforeEach((to, from, next) => {
  // 设置页面标题
  document.title = to.meta.title || '社区家电回收预约系统'

  const token = localStorage.getItem('token')
  const role = localStorage.getItem('role')

  // 公开页面直接放行
  if (to.meta.public) {
    next()
    return
  }

  // 需要登录的页面验证
  if (to.meta.requireAuth && !token) {
    ElMessage.warning('请先登录')
    next('/login')
    return
  }

  // 角色权限验证
  if (to.meta.requireAuth && to.meta.role) {
    if (to.meta.role !== role) {
      ElMessage.error('无权访问该页面')
      next('/login')
      return
    }
  }

  next()
})

export default router