<template>
  <div class="profile-container">
    <!-- 顶部标题栏 - 修复版 -->
    <div class="profile-header-bg">
      <div class="header-content">
        <!-- 左侧：图标+标题 -->
        <div class="header-left">
          <div class="header-icon">
            <el-icon :size="40" color="#52c41a"><UserFilled /></el-icon>
          </div>
          <div class="header-text">
            <h1 class="page-title">个人中心</h1>
            <p class="page-subtitle">管理账户信息 · 共建绿色家园</p>
          </div>
        </div>

        <!-- 右侧：快速统计（带明确标签） -->
        <div class="header-stats">
          <div class="header-stat-item">
            <div class="stat-label">我的积分</div>
            <div class="stat-number">{{ userInfo.points || 0 }}</div>
          </div>
          <div class="divider"></div>
          <div class="header-stat-item">
            <div class="stat-label">回收次数</div>
            <div class="stat-number">{{ userInfo.totalRecycleCount || 0 }}</div>
          </div>
          <div class="divider"></div>
          <div class="header-stat-item">
            <div class="stat-label">回收重量</div>
            <div class="stat-number">{{ userInfo.totalRecycleWeight || 0 }}<span class="unit">kg</span></div>
          </div>
        </div>
      </div>
    </div>

    <div class="profile-content">
      <el-row :gutter="24" class="profile-row overview-row">
        <!-- 左侧：用户档案卡 -->
        <el-col :xs="24" :sm="24" :md="8" :lg="7">
          <el-card class="user-profile-card profile-section-card" shadow="hover">
            <div class="avatar-wrapper">
              <div class="avatar-ring">
                <el-upload
                    class="avatar-uploader"
                    action="/api/files/upload"
                    :show-file-list="false"
                    :on-success="handleAvatarSuccess"
                    :on-error="handleAvatarError"
                    :before-upload="beforeAvatarUpload"
                    accept=".jpg,.jpeg,.png,.gif"
                >
                  <img
                      v-if="userInfo.avatar"
                      :src="userInfo.avatar"
                      class="avatar-img"
                      alt="用户头像"
                  />
                  <div v-else class="avatar-placeholder">
                    <el-icon :size="40" color="#52c41a"><UserFilled /></el-icon>
                    <span class="upload-text">点击上传</span>
                  </div>
                  <div class="avatar-overlay">
                    <el-icon :size="24"><Camera /></el-icon>
                  </div>
                </el-upload>
              </div>
              <h2 class="user-name">{{ userInfo.name || userInfo.username }}</h2>
              <p class="user-role">环保达人 Lv.{{ calculateLevel }}</p>
              <div class="user-id">ID: {{ userInfo.id }}</div>
            </div>

            <!-- 统计网格 -->
            <div class="stats-grid">
              <div class="stat-box">
                <div class="stat-icon points">
                  <el-icon><Coin /></el-icon>
                </div>
                <div class="stat-info">
                  <div class="stat-value">{{ userInfo.points || 0 }}</div>
                  <div class="stat-label">我的积分</div>
                </div>
              </div>
              <div class="stat-box">
                <div class="stat-icon recycle">
                  <el-icon><RefreshRight /></el-icon>
                </div>
                <div class="stat-info">
                  <div class="stat-value">{{ userInfo.totalRecycleCount || 0 }}</div>
                  <div class="stat-label">回收次数</div>
                </div>
              </div>
              <div class="stat-box">
                <div class="stat-icon weight">
                  <el-icon><Goods /></el-icon>
                </div>
                <div class="stat-info">
                  <div class="stat-value">{{ userInfo.totalRecycleWeight || 0 }}<span class="unit">kg</span></div>
                  <div class="stat-label">回收重量</div>
                </div>
              </div>
            </div>
          </el-card>
        </el-col>

        <!-- 右侧：编辑区域 -->
        <el-col :xs="24" :sm="24" :md="16" :lg="17">
          <el-card class="edit-card profile-section-card" shadow="hover">
            <div class="tabs-wrapper">
              <div
                  class="tab-item"
                  :class="{ active: activeTab === 'profile' }"
                  @click="activeTab = 'profile'"
              >
                <el-icon><User /></el-icon>
                <span>基本信息</span>
              </div>
              <div
                  class="tab-item"
                  :class="{ active: activeTab === 'password' }"
                  @click="activeTab = 'password'"
              >
                <el-icon><Lock /></el-icon>
                <span>账号安全</span>
              </div>
            </div>

            <!-- 基本信息表单 -->
            <div v-show="activeTab === 'profile'" class="tab-content">
              <el-form
                  ref="profileFormRef"
                  :model="profileForm"
                  :rules="profileRules"
                  label-position="top"
                  class="modern-form"
              >
                <el-row :gutter="20">
                  <el-col :span="12">
                    <el-form-item label="用户名" prop="username">
                      <el-input
                          v-model="profileForm.username"
                          disabled
                          class="disabled-input"
                      >
                        <template #prefix>
                          <el-icon><User /></el-icon>
                        </template>
                      </el-input>
                    </el-form-item>
                  </el-col>
                  <el-col :span="12">
                    <el-form-item label="真实姓名" prop="name">
                      <el-input
                          v-model="profileForm.name"
                          placeholder="请输入真实姓名"
                          maxlength="20"
                          show-word-limit
                      >
                        <template #prefix>
                          <el-icon><EditPen /></el-icon>
                        </template>
                      </el-input>
                    </el-form-item>
                  </el-col>
                </el-row>

                <el-row :gutter="20">
                  <el-col :span="12">
                    <el-form-item label="手机号码" prop="phone">
                      <el-input
                          v-model="profileForm.phone"
                          placeholder="请输入手机号"
                          maxlength="11"
                      >
                        <template #prefix>
                          <el-icon><Iphone /></el-icon>
                        </template>
                      </el-input>
                    </el-form-item>
                  </el-col>
                </el-row>

                <el-form-item label="个人简介" prop="bio">
                  <el-input
                      v-model="profileForm.bio"
                      type="textarea"
                      :rows="4"
                      placeholder="介绍一下你的环保心得..."
                      maxlength="200"
                      show-word-limit
                      resize="none"
                  />
                </el-form-item>

                <div class="form-actions">
                  <el-button
                      type="primary"
                      size="large"
                      @click="saveProfile"
                      :loading="saving"
                      class="save-btn"
                  >
                    <el-icon v-if="!saving"><Check /></el-icon>
                    <span>保存修改</span>
                  </el-button>
                  <el-button
                      size="large"
                      @click="resetProfile"
                  >
                    重置
                  </el-button>
                </div>
              </el-form>
            </div>

            <!-- 密码修改表单 -->
            <div v-show="activeTab === 'password'" class="tab-content">
              <div class="security-tips">
                <el-alert
                    title="安全提示"
                    description="建议定期更换密码，不要使用过于简单的密码组合"
                    type="info"
                    show-icon
                    :closable="false"
                />
              </div>

              <el-form
                  ref="pwdFormRef"
                  :model="pwdForm"
                  :rules="pwdRules"
                  label-position="top"
                  class="modern-form password-form"
              >
                <el-form-item label="当前密码" prop="oldPassword">
                  <el-input
                      v-model="pwdForm.oldPassword"
                      type="password"
                      show-password
                      placeholder="请输入当前密码"
                      size="large"
                  >
                    <template #prefix>
                      <el-icon><Key /></el-icon>
                    </template>
                  </el-input>
                </el-form-item>

                <el-form-item label="新密码" prop="newPassword">
                  <el-input
                      v-model="pwdForm.newPassword"
                      type="password"
                      show-password
                      placeholder="请输入新密码（至少6位）"
                      size="large"
                  >
                    <template #prefix>
                      <el-icon><Lock /></el-icon>
                    </template>
                  </el-input>
                  <div class="password-strength" v-if="pwdForm.newPassword">
                    <div class="strength-bar">
                      <div
                          class="strength-fill"
                          :style="{ width: passwordStrength + '%', backgroundColor: strengthColor }"
                      ></div>
                    </div>
                    <span class="strength-text" :style="{ color: strengthColor }">
                      {{ strengthText }}
                    </span>
                  </div>
                </el-form-item>

                <el-form-item label="确认新密码" prop="confirmPassword">
                  <el-input
                      v-model="pwdForm.confirmPassword"
                      type="password"
                      show-password
                      placeholder="请再次输入新密码"
                      size="large"
                  >
                    <template #prefix>
                      <el-icon><CircleCheck /></el-icon>
                    </template>
                  </el-input>
                </el-form-item>

                <div class="form-actions">
                  <el-button
                      type="danger"
                      size="large"
                      @click="changePassword"
                      :loading="changingPwd"
                      class="save-btn"
                  >
                    <el-icon v-if="!changingPwd"><Refresh /></el-icon>
                    <span>确认修改密码</span>
                  </el-button>
                </div>
              </el-form>
            </div>
          </el-card>
        </el-col>
      </el-row>

      <el-row :gutter="24" class="profile-row detail-row">
        <el-col :xs="24" :sm="24" :md="8" :lg="7">
          <!-- 环保贡献卡片 -->
          <el-card class="eco-card secondary-card" shadow="hover">
            <template #header>
              <div class="eco-header">
                <span class="eco-title">🌍 环保贡献</span>
                <el-tag type="success" effect="dark" size="small">累计减排</el-tag>
              </div>
            </template>

            <div class="carbon-display">
              <div class="carbon-circle">
                <svg viewBox="0 0 36 36" class="circular-chart">
                  <path
                      class="circle-bg"
                      d="M18 2.0845 a 15.9155 15.9155 0 0 1 0 31.831 a 15.9155 15.9155 0 0 1 0 -31.831"
                  />
                  <path
                      class="circle"
                      :stroke-dasharray="`${Math.min(carbonPercent, 100)}, 100`"
                      d="M18 2.0845 a 15.9155 15.9155 0 0 1 0 31.831 a 15.9155 15.9155 0 0 1 0 -31.831"
                  />
                </svg>
                <div class="carbon-value">
                  <span class="number">{{ userInfo.carbonSaved || 0 }}</span>
                  <span class="unit">kg</span>
                </div>
              </div>
              <p class="carbon-desc">累计减少碳排放</p>
            </div>

            <div class="tree-equivalent">
              <div class="tree-icon">🌳</div>
              <div class="tree-text">
                <div class="tree-count">相当于种植了 <strong>{{ Math.floor((userInfo.carbonSaved || 0) / 18) }}</strong> 棵树</div>
                <div class="tree-sub">为地球增添一份绿色</div>
              </div>
            </div>

            <el-divider />

            <!-- 成就列表 -->
            <div class="achievement-list">
              <div class="achievement-item" v-for="(item, index) in achievements" :key="index">
                <el-icon :size="20" :color="item.color"><component :is="item.icon" /></el-icon>
                <span class="achievement-text">{{ item.text }}</span>
              </div>
            </div>
          </el-card>
        </el-col>

        <el-col :xs="24" :sm="24" :md="16" :lg="17">
          <!-- 最近活动 -->
          <el-card class="activity-card secondary-card" shadow="hover">
            <template #header>
              <div class="activity-header">
                <span>📝 最近动态</span>
                <el-link type="primary" :underline="false" @click="$router.push('/user/orderList')">查看全部</el-link>
              </div>
            </template>
            <el-timeline v-if="recentActivities.length">
              <el-timeline-item
                  v-for="(activity, index) in recentActivities"
                  :key="index"
                  :type="activity.type"
                  :color="activity.color"
                  :timestamp="activity.time"
              >
                {{ activity.content }}
              </el-timeline-item>
            </el-timeline>
            <el-empty v-else description="暂无动态记录" :image-size="88" />
          </el-card>
        </el-col>
      </el-row>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, computed } from 'vue'
import { ElMessage } from 'element-plus'
import {
  UserFilled, Camera, Coin, RefreshRight, Goods,
  User, Lock, EditPen, Iphone, Check, Key,
  CircleCheck, Refresh, Star, Trophy, Collection
} from '@element-plus/icons-vue'
import request from '@/utils/request'

// 统一的用户信息响应式对象
const userInfo = reactive({
  id: '',
  username: '',
  name: '',
  phone: '',
  avatar: '',
  points: 0,
  totalRecycleCount: 0,
  totalRecycleWeight: 0,
  carbonSaved: 0,
  bio: ''
})

// 表单数据
const profileForm = reactive({ ...userInfo })
const pwdForm = reactive({
  oldPassword: '',
  newPassword: '',
  confirmPassword: ''
})

// 状态
const activeTab = ref('profile')
const saving = ref(false)
const changingPwd = ref(false)
const profileFormRef = ref()
const pwdFormRef = ref()
const recentActivities = ref([])

// 初始化加载
onMounted(() => {
  loadUserInfo()
})

// 加载用户信息
const loadUserInfo = async () => {
  try {
    const cachedUser = JSON.parse(localStorage.getItem('user') || '{}')
    Object.assign(userInfo, cachedUser)
    Object.assign(profileForm, cachedUser)

    if (!userInfo.id) {
      recentActivities.value = []
      return
    }

    const res = await request.get(`/user/profile/${userInfo.id}`)
    if (res) {
      Object.assign(userInfo, res)
      Object.assign(profileForm, res)
      localStorage.setItem('user', JSON.stringify(userInfo))
    }

    await loadRecentActivities(userInfo.id)
  } catch (error) {
    console.error('加载用户信息失败:', error)
    recentActivities.value = []
  }
}

const toNumber = (value) => {
  const num = Number(value)
  return Number.isFinite(num) ? num : 0
}

const formatDateTime = (value) => {
  if (!value) return ''
  const date = new Date(typeof value === 'string' ? value.replace(' ', 'T') : value)
  if (Number.isNaN(date.getTime())) {
    return value
  }
  const year = date.getFullYear()
  const month = `${date.getMonth() + 1}`.padStart(2, '0')
  const day = `${date.getDate()}`.padStart(2, '0')
  const hours = `${date.getHours()}`.padStart(2, '0')
  const minutes = `${date.getMinutes()}`.padStart(2, '0')
  return `${year}-${month}-${day} ${hours}:${minutes}`
}

const formatMetric = (value, digits = 2) => {
  const num = toNumber(value)
  if (Number.isInteger(num)) {
    return `${num}`
  }
  return num.toFixed(digits).replace(/\.0+$/, '').replace(/(\.\d*[1-9])0+$/, '$1')
}

const getOrderActivityTime = (order) => {
  if (order.status === 4) return order.completeTime || order.updateTime || order.createTime
  if (order.status === 5) return order.updateTime || order.createTime
  if (order.status === 3) return order.arriveTime || order.updateTime || order.createTime
  if (order.status === 2) return order.acceptTime || order.updateTime || order.createTime
  if (order.status === 1) return order.assignTime || order.updateTime || order.createTime
  return order.createTime || order.updateTime
}

const mapOrderToActivity = (order) => {
  const applianceName = order.applianceTypeName || '家电'
  const activityTime = getOrderActivityTime(order)
  const sortTime = new Date((activityTime || '').replace?.(' ', 'T') || activityTime || 0).getTime() || 0

  if (order.status === 4) {
    return {
      content: `完成了${applianceName}回收，获得${order.pointsEarned || 0}积分`,
      time: formatDateTime(activityTime),
      type: 'success',
      color: '#52c41a',
      sortTime
    }
  }
  if (order.status === 5) {
    return {
      content: `取消了${applianceName}回收预约${order.cancelReason ? `（${order.cancelReason}）` : ''}`,
      time: formatDateTime(activityTime),
      type: 'danger',
      color: '#ff4d4f',
      sortTime
    }
  }
  if (order.status === 3) {
    return {
      content: `${applianceName}回收订单已进入上门处理阶段`,
      time: formatDateTime(activityTime),
      type: 'primary',
      color: '#409eff',
      sortTime
    }
  }
  if (order.status === 2) {
    return {
      content: `${applianceName}回收订单已被回收员接单`,
      time: formatDateTime(activityTime),
      type: 'primary',
      color: '#1677ff',
      sortTime
    }
  }
  if (order.status === 1) {
    return {
      content: `${applianceName}回收预约已派单，等待回收员接单`,
      time: formatDateTime(activityTime),
      type: 'warning',
      color: '#faad14',
      sortTime
    }
  }
  return {
    content: `提交了${applianceName}回收预约`,
    time: formatDateTime(activityTime),
    type: 'warning',
    color: '#f7ba2a',
    sortTime
  }
}

const loadRecentActivities = async (userId) => {
  if (!userId) {
    recentActivities.value = []
    return
  }

  const orders = await request.get(`/recycleOrder/selectByUser/${userId}`)
  recentActivities.value = (Array.isArray(orders) ? orders : [])
    .map(mapOrderToActivity)
    .sort((a, b) => b.sortTime - a.sortTime)
    .slice(0, 6)
    .map(({ sortTime, ...activity }) => activity)
}

const achievements = computed(() => [
  {
    icon: Star,
    color: '#f7ba2a',
    text: userInfo.totalRecycleCount
      ? `累计完成 ${userInfo.totalRecycleCount} 次回收`
      : '完成首次回收后点亮专属成就'
  },
  {
    icon: Trophy,
    color: '#52c41a',
    text: `累计回收 ${formatMetric(userInfo.totalRecycleWeight)} kg 废旧家电`
  },
  {
    icon: Collection,
    color: '#409eff',
    text: `累计减少 ${formatMetric(userInfo.carbonSaved)} kg 碳排放`
  }
])

// 根据碳减排量计算环保达人等级
// 阈值递增：0, 5, 15, 30, 50, 80, 120, 180, 260, 360, ...（每级差值+10）
const calculateLevel = computed(() => {
  const carbon = toNumber(userInfo.carbonSaved)
  let level = 1
  let threshold = 0
  let step = 5
  while (threshold + step <= carbon) {
    threshold += step
    level++
    step += 5
  }
  return level
})

// 碳排放百分比
const carbonPercent = computed(() => {
  const max = 100
  return (toNumber(userInfo.carbonSaved) / max) * 100
})

// 密码强度计算
const passwordStrength = computed(() => {
  const pwd = pwdForm.newPassword
  if (!pwd) return 0
  let strength = 0
  if (pwd.length >= 6) strength += 20
  if (pwd.length >= 10) strength += 20
  if (/[A-Z]/.test(pwd)) strength += 20
  if (/[0-9]/.test(pwd)) strength += 20
  if (/[^A-Za-z0-9]/.test(pwd)) strength += 20
  return strength
})

const strengthColor = computed(() => {
  if (passwordStrength.value <= 40) return '#ff4d4f'
  if (passwordStrength.value <= 70) return '#faad14'
  return '#52c41a'
})

const strengthText = computed(() => {
  if (passwordStrength.value <= 40) return '弱'
  if (passwordStrength.value <= 70) return '中'
  return '强'
})

// 验证规则
const profileRules = {
  name: [{ min: 2, max: 20, message: '长度在 2 到 20 个字符', trigger: 'blur' }],
  phone: [{ pattern: /^1[3-9]\d{9}$/, message: '请输入正确的手机号', trigger: 'blur' }]
}

const pwdRules = {
  oldPassword: [{ required: true, message: '请输入原密码', trigger: 'blur' }],
  newPassword: [
    { required: true, message: '请输入新密码', trigger: 'blur' },
    { min: 6, message: '密码至少6位', trigger: 'blur' }
  ],
  confirmPassword: [
    { required: true, message: '请确认新密码', trigger: 'blur' },
    {
      validator: (rule, value, callback) => {
        if (value !== pwdForm.newPassword) {
          callback(new Error('两次输入的密码不一致'))
        } else {
          callback()
        }
      },
      trigger: 'blur'
    }
  ]
}

// 头像上传前验证
const beforeAvatarUpload = (rawFile) => {
  const isJPG = rawFile.type === 'image/jpeg'
  const isPNG = rawFile.type === 'image/png'
  const isLt2M = rawFile.size / 1024 / 1024 < 2

  if (!isJPG && !isPNG) {
    ElMessage.error('头像只能是 JPG 或 PNG 格式!')
    return false
  }
  if (!isLt2M) {
    ElMessage.error('头像大小不能超过 2MB!')
    return false
  }
  return true
}

// 头像上传成功
const handleAvatarSuccess = (res) => {
  if (res) {
    userInfo.avatar = res
    profileForm.avatar = res
    const cachedUser = JSON.parse(localStorage.getItem('user') || '{}')
    cachedUser.avatar = res
    localStorage.setItem('user', JSON.stringify(cachedUser))
    ElMessage.success('头像更新成功')
  }
}

const handleAvatarError = () => {
  ElMessage.error('头像上传失败，请重试')
}

// 保存个人资料
const saveProfile = async () => {
  const valid = await profileFormRef.value?.validate().catch(() => false)
  if (!valid) return

  saving.value = true
  try {
    await request.put('/user/update', profileForm)
    Object.assign(userInfo, profileForm)
    localStorage.setItem('user', JSON.stringify(userInfo))
    ElMessage.success('个人资料保存成功')
  } catch (error) {
    ElMessage.error(error.message || '保存失败')
  } finally {
    saving.value = false
  }
}

// 重置表单
const resetProfile = () => {
  Object.assign(profileForm, userInfo)
  ElMessage.info('已重置为上次保存的内容')
}

// 修改密码
const changePassword = async () => {
  const valid = await pwdFormRef.value?.validate().catch(() => false)
  if (!valid) return

  changingPwd.value = true
  try {
    await request.put('/updatePassword', {
      username: userInfo.username,
      password: pwdForm.oldPassword,
      newPassword: pwdForm.newPassword,
      role: '普通用户'
    })
    ElMessage.success('密码修改成功，请重新登录')
    localStorage.clear()
    location.href = '/login'
  } catch (error) {
    ElMessage.error(error.message || '修改失败')
  } finally {
    changingPwd.value = false
  }
}
</script>

<!-- 组件局部样式 -->
<style scoped lang="scss">
.profile-container {
  min-height: 100vh;
  background: #f5f7fa;
  position: relative;
  padding-bottom: 40px;
}

.profile-header-bg {
  height: 140px;                    // 减小高度，更紧凑
  background: linear-gradient(135deg, #52c41a 0%, #389e0d 100%);
  position: relative;
  display: flex;                    // 使用 flex 居中
  align-items: center;              // 垂直居中

  .header-content {
    width: 100%;
    max-width: 1200px;
    margin: 0 auto;
    padding: 0 20px;                // 去掉顶部 padding，靠 flex 居中
    display: flex;
    justify-content: space-between;
    align-items: center;

    .header-left {
      display: flex;
      align-items: center;
      gap: 16px;

      .header-icon {
        width: 56px;
        height: 56px;
        background: #ffffff;        // 纯白色背景，不使用毛玻璃
        border-radius: 12px;
        display: flex;
        align-items: center;
        justify-content: center;
        box-shadow: 0 4px 12px rgba(0,0,0,0.1);  // 添加阴影代替毛玻璃
      }

      .header-text {
        color: white;

        .page-title {
          font-size: 28px;
          font-weight: 600;
          margin: 0 0 4px 0;
          letter-spacing: 1px;
          line-height: 1.2;
        }

        .page-subtitle {
          font-size: 13px;
          color: rgba(255, 255, 255, 0.95);  // 提高不透明度
          margin: 0;
          font-weight: 400;
        }
      }
    }

    .header-stats {
      display: flex;
      align-items: center;
      gap: 24px;

      .divider {
        width: 1px;
        height: 40px;
        background: rgba(255, 255, 255, 0.3);
      }

      .header-stat-item {
        text-align: center;
        color: white;

        .stat-label {
          font-size: 12px;
          color: rgba(255, 255, 255, 0.9);   // 标签文字清晰可见
          margin-bottom: 4px;
          text-transform: uppercase;
          letter-spacing: 0.5px;
        }

        .stat-number {
          font-size: 28px;
          font-weight: 700;
          line-height: 1;
          letter-spacing: 0.5px;

          .unit {
            font-size: 14px;
            font-weight: 500;
            margin-left: 2px;
            opacity: 0.9;
          }
        }
      }
    }
  }
}

.profile-content {
  max-width: 1200px;
  margin: -38px auto 0;             // 增强与头部的衔接，下方区域整体上提
  padding: 0 20px;
  position: relative;
  z-index: 1;
}

.profile-row {
  align-items: stretch;

  :deep(.el-col) {
    display: flex;
    flex-direction: column;
  }
}

.overview-row {
  margin-bottom: 16px;
}

.profile-section-card,
.secondary-card {
  height: 100%;
}

.detail-row {
  margin-bottom: 0;
}

.user-profile-card {
  position: relative;
  border-radius: 16px;
  border: none;
  overflow: hidden;
  background: linear-gradient(180deg, #f7fff1 0%, #ffffff 42%);
  box-shadow: 0 10px 30px rgba(82, 196, 26, 0.08);

  &::before {
    content: '';
    position: absolute;
    top: 0;
    left: 0;
    right: 0;
    height: 90px;
    background: linear-gradient(135deg, rgba(82, 196, 26, 0.18), rgba(149, 222, 100, 0.05));
    pointer-events: none;
  }
}

.avatar-wrapper {
  position: relative;
  text-align: center;
  margin-bottom: 16px;
  padding: 24px 24px 0;

  .avatar-ring {
    display: inline-block;
    padding: 3px;
    border-radius: 50%;
    background: linear-gradient(135deg, #52c41a, #95de64);
    margin-bottom: 12px;
    box-shadow: 0 10px 24px rgba(82, 196, 26, 0.18);
  }

  .avatar-uploader {
    position: relative;
    width: 104px;
    height: 104px;
    border-radius: 50%;
    overflow: hidden;
    cursor: pointer;
    background: #fff;

    .avatar-img {
      width: 100%;
      height: 100%;
      object-fit: cover;
      border-radius: 50%;
    }

    .avatar-placeholder {
      width: 100%;
      height: 100%;
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      background: #f6ffed;
      border-radius: 50%;

      .upload-text {
        font-size: 12px;
        color: #52c41a;
        margin-top: 8px;
      }
    }

    .avatar-overlay {
      position: absolute;
      top: 0;
      left: 0;
      width: 100%;
      height: 100%;
      background: rgba(0,0,0,0.4);
      display: flex;
      align-items: center;
      justify-content: center;
      opacity: 0;
      transition: opacity 0.3s;
      color: white;
      border-radius: 50%;
    }

    &:hover .avatar-overlay {
      opacity: 1;
    }
  }

  .user-name {
    font-size: 22px;
    font-weight: 600;
    color: #1f2937;
    margin: 0 0 2px;
    line-height: 1.25;
  }

  .user-role {
    font-size: 13px;
    color: #52c41a;
    font-weight: 600;
    margin: 0 0 10px;
  }

  .user-id {
    font-size: 12px;
    color: #9ca3af;
    font-family: monospace;
    background: rgba(255, 255, 255, 0.82);
    border: 1px solid #eef2f7;
    padding: 4px 10px;
    border-radius: 12px;
    display: inline-block;
  }
}

.stats-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 10px;
  margin-top: 0;
  padding: 0 18px 18px;

  .stat-box {
    background: rgba(255, 255, 255, 0.88);
    border: 1px solid #f1f5f9;
    border-radius: 12px;
    padding: 12px 8px;
    text-align: center;
    transition: transform 0.2s, box-shadow 0.2s;

    &:hover {
      transform: translateY(-2px);
      box-shadow: 0 8px 16px rgba(15, 23, 42, 0.06);
    }

    .stat-icon {
      width: 34px;
      height: 34px;
      border-radius: 10px;
      display: flex;
      align-items: center;
      justify-content: center;
      margin: 0 auto 6px;
      font-size: 18px;

      &.points { background: #fff7e6; color: #fa8c16; }
      &.recycle { background: #f6ffed; color: #52c41a; }
      &.weight { background: #e6f7ff; color: #1890ff; }
    }

    .stat-value {
      font-size: 18px;
      font-weight: 700;
      color: #1f2937;
      line-height: 1.2;

      .unit {
        font-size: 12px;
        font-weight: 400;
        color: #6b7280;
        margin-left: 2px;
      }
    }

    .stat-label {
      font-size: 11px;
      color: #6b7280;
      margin-top: 3px;
    }
  }
}

.eco-card {
  border-radius: 16px;
  border: none;
}

.eco-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 20px;

  .eco-title {
    font-size: 16px;
    font-weight: 600;
    color: #1f2937;
  }
}

.carbon-display {
  text-align: center;
  margin: 20px 0;
  padding: 0 20px;

  .carbon-circle {
    position: relative;
    width: 150px;
    height: 150px;
    margin: 0 auto;

    .circular-chart {
      width: 100%;
      height: 100%;
      transform: rotate(-90deg);
    }

    .circle-bg {
      fill: none;
      stroke: #f3f4f6;
      stroke-width: 3;
    }

    .circle {
      fill: none;
      stroke: #52c41a;
      stroke-width: 3;
      stroke-linecap: round;
      transition: stroke-dasharray 0.5s ease;
    }

    .carbon-value {
      position: absolute;
      top: 50%;
      left: 50%;
      transform: translate(-50%, -50%);
      text-align: center;

      .number {
        display: block;
        font-size: 32px;
        font-weight: 700;
        color: #52c41a;
        line-height: 1;
      }

      .unit {
        font-size: 14px;
        color: #6b7280;
      }
    }
  }

  .carbon-desc {
    color: #6b7280;
    font-size: 14px;
    margin-top: 8px;
  }
}

.tree-equivalent {
  display: flex;
  align-items: center;
  gap: 12px;
  background: #f6ffed;
  padding: 16px;
  border-radius: 12px;
  margin: 20px;

  .tree-icon {
    font-size: 32px;
  }

  .tree-text {
    flex: 1;

    .tree-count {
      font-size: 14px;
      color: #1f2937;
      font-weight: 500;

      strong {
        color: #52c41a;
        font-size: 18px;
      }
    }

    .tree-sub {
      font-size: 12px;
      color: #6b7280;
      margin-top: 2px;
    }
  }
}

.achievement-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
  padding: 0 20px 20px;

  .achievement-item {
    display: flex;
    align-items: center;
    gap: 12px;
    padding: 12px;
    background: #fafafa;
    border-radius: 8px;
    transition: background 0.2s;

    &:hover {
      background: #f0f0f0;
    }

    .achievement-text {
      font-size: 14px;
      color: #4b5563;
    }
  }
}

.edit-card {
  border-radius: 16px;
  border: none;
}

.tabs-wrapper {
  display: flex;
  border-bottom: 1px solid #e5e7eb;
  padding: 0 20px;

  .tab-item {
    padding: 14px 20px;
    cursor: pointer;
    display: flex;
    align-items: center;
    gap: 8px;
    color: #6b7280;
    font-weight: 500;
    border-bottom: 2px solid transparent;
    transition: all 0.3s;
    margin-bottom: -1px;

    &:hover {
      color: #52c41a;
    }

    &.active {
      color: #52c41a;
      border-bottom-color: #52c41a;
    }

    .el-icon {
      font-size: 18px;
    }
  }
}

.tab-content {
  padding: 20px;
  animation: fadeIn 0.3s ease;
}

@keyframes fadeIn {
  from { opacity: 0; transform: translateY(10px); }
  to { opacity: 1; transform: translateY(0); }
}

.modern-form {
  .el-form-item {
    margin-bottom: 18px;
  }
}

.form-actions {
  display: flex;
  gap: 12px;
  margin-top: 24px;
  padding-top: 18px;
  border-top: 1px solid #e5e7eb;

  .save-btn {
    min-width: 140px;
    border-radius: 8px;
    font-weight: 500;

    .el-icon {
      margin-right: 6px;
    }
  }
}

.password-form {
  max-width: 460px;
  margin: 0 auto;
}

.security-tips {
  margin-bottom: 18px;
}

.password-strength {
  margin-top: 8px;

  .strength-bar {
    height: 4px;
    background: #e5e7eb;
    border-radius: 2px;
    overflow: hidden;
    margin-bottom: 4px;
  }

  .strength-fill {
    height: 100%;
    border-radius: 2px;
    transition: all 0.3s;
  }

  .strength-text {
    font-size: 12px;
    font-weight: 500;
  }
}

.activity-card {
  border-radius: 16px;
  border: none;
}

.activity-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 20px 24px;
  font-weight: 600;
  color: #1f2937;
}

// 响应式适配
@media (max-width: 768px) {
  .profile-header-bg {
    height: auto;
    padding: 20px 0;

    .header-content {
      flex-direction: column;
      gap: 20px;

      .header-left {
        .header-icon {
          width: 48px;
          height: 48px;
        }

        .header-text {
          .page-title {
            font-size: 24px;
          }
        }
      }

      .header-stats {
        gap: 16px;

        .divider {
          height: 30px;
        }

        .header-stat-item {
          .stat-number {
            font-size: 20px;
          }
        }
      }
    }
  }

  .profile-content {
    margin-top: -24px;
    padding: 0 12px;
  }

  .overview-row {
    margin-bottom: 12px;
  }

  .stats-grid {
    grid-template-columns: 1fr;
    gap: 8px;

    .stat-box {
      display: flex;
      align-items: center;
      text-align: left;
      gap: 12px;

      .stat-icon {
        margin: 0;
      }
    }
  }

  .tabs-wrapper {
    padding: 0 12px;

    .tab-item {
      padding: 12px 16px;
      font-size: 14px;
    }
  }

  .tab-content {
    padding: 16px;
  }

  .avatar-wrapper {
    padding: 20px 18px 0;

    .avatar-uploader {
      width: 96px;
      height: 96px;
    }
  }
}
</style>

<!-- 全局样式覆盖 -->
<style lang="scss">
.profile-container {
  .profile-section-card,
  .secondary-card {
    display: flex;
    flex-direction: column;
  }

  .user-profile-card .el-card__body {
    padding: 0;
    display: flex;
    flex-direction: column;
    height: 100%;
  }

  .eco-card .el-card__body {
    padding: 0;
  }

  .eco-card .el-card__header {
    padding: 0;
    border-bottom: 1px solid #f3f4f6;
  }

  .edit-card .el-card__body {
    padding: 0;
    display: flex;
    flex-direction: column;
    height: 100%;
  }

  .activity-card .el-card__header {
    padding: 0;
    border-bottom: 1px solid #f3f4f6;
  }

  .modern-form {
    .el-form-item__label {
      font-weight: 500;
      color: #374151;
      padding-bottom: 6px;
    }

    .el-input__wrapper {
      box-shadow: 0 1px 2px 0 rgba(0, 0, 0, 0.05);
      border: 1px solid #e5e7eb;
      border-radius: 8px;
      padding: 2px 12px;
      transition: all 0.2s;

      &:hover, &:focus-within {
        border-color: #52c41a;
        box-shadow: 0 0 0 3px rgba(82, 196, 26, 0.1);
      }
    }

    .el-input__inner {
      height: 36px;
    }

    .el-textarea__inner {
      border-radius: 8px;
      border: 1px solid #e5e7eb;
      padding: 10px 12px;

      &:hover, &:focus {
        border-color: #52c41a;
      }
    }

    .disabled-input {
      .el-input__wrapper {
        background-color: #f9fafb;
      }
      .el-input__inner {
        color: #9ca3af;
      }
    }
  }

  .activity-card {
    .el-timeline {
      padding-left: 12px;
      padding-top: 12px;
    }

    .el-timeline-item__content {
      color: #4b5563;
      font-size: 14px;
    }
  }
}
</style>