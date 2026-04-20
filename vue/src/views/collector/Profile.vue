<template>
  <div class="collector-profile-page">
    <div class="profile-hero">
      <div class="hero-main">
        <div class="hero-title-wrap">
          <h1 class="hero-title">个人中心</h1>
          <p class="hero-subtitle">管理个人资料、服务范围与账号安全，保持高效接单状态</p>
        </div>
        <div class="hero-tags">
          <el-tag :type="workStatusMeta.type" effect="dark" round>
            {{ workStatusMeta.text }}
          </el-tag>
          <el-tag :type="auditStatusMeta.type" round>
            {{ auditStatusMeta.text }}
          </el-tag>
        </div>
      </div>

      <div class="hero-stats">
        <div class="hero-stat-card">
          <div class="stat-label">今日接单</div>
          <div class="stat-value">{{ safeNumber(form.todayOrderCount) }}</div>
        </div>
        <div class="hero-stat-card">
          <div class="stat-label">累计接单</div>
          <div class="stat-value">{{ safeNumber(form.orderCount) }}</div>
        </div>
        <div class="hero-stat-card">
          <div class="stat-label">服务评分</div>
          <div class="stat-value">{{ formatScore(form.rating) }}</div>
        </div>
        <div class="hero-stat-card">
          <div class="stat-label">每日上限</div>
          <div class="stat-value">{{ safeNumber(form.maxDailyOrders) }}<span class="stat-unit">单</span></div>
        </div>
      </div>
    </div>

    <div class="profile-content">
      <el-row :gutter="20" class="overview-row">
        <el-col :xs="24" :sm="24" :md="7" :lg="6">
          <el-card class="profile-card sidebar-card" shadow="hover">
            <div class="profile-summary">
              <div class="avatar-ring">
                <el-upload
                  class="avatar-uploader"
                  action="/api/files/upload"
                  :show-file-list="false"
                  :on-success="handleAvatarSuccess"
                >
                  <img v-if="form.avatar" :src="form.avatar" class="avatar" alt="头像" />
                  <div v-else class="avatar-placeholder">
                    <el-icon :size="36"><UserFilled /></el-icon>
                  </div>
                  <div class="avatar-mask">点击更换头像</div>
                </el-upload>
              </div>

              <h2 class="collector-name">{{ form.name || form.username || '回收员' }}</h2>
              <p class="collector-role">社区回收服务人员</p>

              <div class="summary-tags">
                <el-tag :type="workStatusMeta.type" round>{{ workStatusMeta.text }}</el-tag>
                <el-tag :type="auditStatusMeta.type" plain round>{{ auditStatusMeta.text }}</el-tag>
              </div>

              <div class="rating-box">
                <span class="rating-label">服务评分</span>
                <div class="rating-content">
                  <el-rate :model-value="Number(form.rating) || 0" disabled show-score text-color="#f59e0b" />
                </div>
              </div>
            </div>

            <div class="mini-stats">
              <div class="mini-stat-item">
                <div class="mini-stat-value">{{ safeNumber(form.todayOrderCount) }}</div>
                <div class="mini-stat-label">今日接单</div>
              </div>
              <div class="mini-stat-item">
                <div class="mini-stat-value">{{ safeNumber(form.orderCount) }}</div>
                <div class="mini-stat-label">累计接单</div>
              </div>
              <div class="mini-stat-item">
                <div class="mini-stat-value">{{ safeNumber(form.maxDailyOrders) }}</div>
                <div class="mini-stat-label">每日上限</div>
              </div>
            </div>

            <div class="summary-list">
              <div class="summary-item">
                <span class="label">用户名</span>
                <span class="value">{{ form.username || '-' }}</span>
              </div>
              <div class="summary-item">
                <span class="label">手机号</span>
                <span class="value">{{ form.phone || '未设置' }}</span>
              </div>
              <div class="summary-item">
                <span class="label">服务区域</span>
                <span class="value area-text">{{ serviceAreaText }}</span>
              </div>
            </div>
          </el-card>
        </el-col>

        <el-col :xs="24" :sm="24" :md="17" :lg="18">
          <el-card class="profile-card main-card" shadow="hover">
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

            <div v-show="activeTab === 'profile'" class="tab-panel">
              <div class="section-intro">
                <h3>资料设置</h3>
                <p>完善联系信息和服务配置，便于系统智能派单与用户联系。</p>
              </div>

              <el-form
                ref="profileFormRef"
                :model="form"
                :rules="profileRules"
                label-position="top"
                class="modern-form"
              >
                <el-row :gutter="20">
                  <el-col :xs="24" :sm="12">
                    <el-form-item label="用户名" prop="username">
                      <el-input v-model="form.username" disabled>
                        <template #prefix>
                          <el-icon><User /></el-icon>
                        </template>
                      </el-input>
                    </el-form-item>
                  </el-col>
                  <el-col :xs="24" :sm="12">
                    <el-form-item label="真实姓名" prop="name">
                      <el-input v-model="form.name" placeholder="请输入真实姓名">
                        <template #prefix>
                          <el-icon><UserFilled /></el-icon>
                        </template>
                      </el-input>
                    </el-form-item>
                  </el-col>
                </el-row>

                <el-row :gutter="20">
                  <el-col :xs="24" :sm="12">
                    <el-form-item label="手机号" prop="phone">
                      <el-input v-model="form.phone" placeholder="请输入手机号" maxlength="11">
                        <template #prefix>
                          <el-icon><Iphone /></el-icon>
                        </template>
                      </el-input>
                    </el-form-item>
                  </el-col>
                  <el-col :xs="24" :sm="12">
                    <el-form-item label="每日接单上限" prop="maxDailyOrders">
                      <el-input-number v-model="form.maxDailyOrders" :min="1" :max="50" class="full-width-number" />
                    </el-form-item>
                  </el-col>
                </el-row>

                <el-form-item label="工作区域" prop="serviceArea">
                  <el-input
                    v-model="form.serviceArea"
                    type="textarea"
                    :rows="4"
                    resize="none"
                    placeholder="例如：朝阳社区、幸福小区、人民路街道"
                  />
                  <div class="field-tip">建议填写常驻服务片区，方便平台更精准派单。</div>
                </el-form-item>

                <div class="form-actions">
                  <el-button type="primary" size="large" :loading="saving" @click="saveProfile">
                    保存修改
                  </el-button>
                </div>
              </el-form>
            </div>

            <div v-show="activeTab === 'password'" class="tab-panel">
              <div class="section-intro security-intro">
                <h3>账号安全</h3>
                <p>定期更新密码，保障账号与订单数据安全。</p>
              </div>

              <el-alert
                title="安全提示"
                description="建议新密码不少于 6 位，并避免与旧密码一致。"
                type="info"
                show-icon
                :closable="false"
                class="security-alert"
              />

              <el-form
                ref="pwdFormRef"
                :model="pwdForm"
                :rules="pwdRules"
                label-position="top"
                class="modern-form password-form"
              >
                <el-form-item label="原密码" prop="oldPassword">
                  <el-input v-model="pwdForm.oldPassword" type="password" show-password placeholder="请输入原密码" />
                </el-form-item>

                <el-form-item label="新密码" prop="newPassword">
                  <el-input v-model="pwdForm.newPassword" type="password" show-password placeholder="请输入新密码" />
                </el-form-item>

                <el-form-item label="确认密码" prop="confirmPassword">
                  <el-input v-model="pwdForm.confirmPassword" type="password" show-password placeholder="请再次输入新密码" />
                </el-form-item>

                <div class="form-actions">
                  <el-button type="danger" size="large" :loading="changingPwd" @click="changePassword">
                    修改密码
                  </el-button>
                </div>
              </el-form>
            </div>
          </el-card>
        </el-col>
      </el-row>

      <el-row :gutter="20" class="detail-row">
        <el-col :xs="24" :sm="24" :md="12">
          <el-card class="profile-card detail-card" shadow="hover">
            <template #header>
              <div class="card-header">账户状态</div>
            </template>

            <div class="detail-list">
              <div class="detail-item">
                <div>
                  <div class="detail-label">审核状态</div>
                  <div class="detail-desc">当前资质审核结果</div>
                </div>
                <el-tag :type="auditStatusMeta.type" round>{{ auditStatusMeta.text }}</el-tag>
              </div>
              <div class="detail-item">
                <div>
                  <div class="detail-label">账户状态</div>
                  <div class="detail-desc">是否可正常接收系统服务</div>
                </div>
                <span class="detail-value">{{ form.status === 0 ? '已禁用' : '正常' }}</span>
              </div>
              <div class="detail-item">
                <div>
                  <div class="detail-label">注册时间</div>
                  <div class="detail-desc">加入平台的时间</div>
                </div>
                <span class="detail-value">{{ formatDateTime(form.createTime) || '-' }}</span>
              </div>
              <div v-if="form.auditStatus === 2 && form.rejectReason" class="reject-box">
                <div class="reject-title">审核说明</div>
                <div class="reject-text">{{ form.rejectReason }}</div>
              </div>
            </div>
          </el-card>
        </el-col>

        <el-col :xs="24" :sm="24" :md="12">
          <el-card class="profile-card detail-card" shadow="hover">
            <template #header>
              <div class="card-header">工作概览</div>
            </template>

            <div class="work-grid">
              <div class="work-card soft-green">
                <div class="work-card-title">工作状态</div>
                <div class="work-card-value">{{ workStatusMeta.text }}</div>
              </div>
              <div class="work-card soft-blue">
                <div class="work-card-title">评分表现</div>
                <div class="work-card-value">{{ formatScore(form.rating) }}</div>
              </div>
              <div class="work-card soft-yellow">
                <div class="work-card-title">今日接单</div>
                <div class="work-card-value">{{ safeNumber(form.todayOrderCount) }}</div>
              </div>
              <div class="work-card soft-purple">
                <div class="work-card-title">服务区域</div>
                <div class="work-card-value small">{{ serviceAreaText }}</div>
              </div>
            </div>
          </el-card>
        </el-col>
      </el-row>
    </div>
  </div>
</template>

<script setup>
import { computed, onMounted, reactive, ref } from 'vue'
import { ElMessage } from 'element-plus'
import { Iphone, Lock, User, UserFilled } from '@element-plus/icons-vue'
import request from '@/utils/request'

const user = JSON.parse(localStorage.getItem('user') || '{}')

const activeTab = ref('profile')
const saving = ref(false)
const changingPwd = ref(false)
const profileFormRef = ref()
const pwdFormRef = ref()

const form = reactive({
  id: '',
  username: '',
  name: '',
  phone: '',
  avatar: '',
  serviceArea: '',
  maxDailyOrders: 10,
  workStatus: 0,
  orderCount: 0,
  todayOrderCount: 0,
  rating: 5.0,
  status: 1,
  auditStatus: 0,
  rejectReason: '',
  createTime: ''
})

const pwdForm = reactive({
  oldPassword: '',
  newPassword: '',
  confirmPassword: ''
})

const profileRules = {
  name: [{ min: 2, max: 20, message: '姓名长度为 2-20 个字符', trigger: 'blur' }],
  phone: [{ pattern: /^1[3-9]\d{9}$/, message: '请输入正确的手机号', trigger: 'blur' }],
  maxDailyOrders: [{ required: true, message: '请设置每日接单上限', trigger: 'change' }]
}

const pwdRules = {
  oldPassword: [{ required: true, message: '请输入原密码', trigger: 'blur' }],
  newPassword: [
    { required: true, message: '请输入新密码', trigger: 'blur' },
    { min: 6, message: '新密码至少 6 位', trigger: 'blur' }
  ],
  confirmPassword: [
    { required: true, message: '请确认新密码', trigger: 'blur' },
    {
      validator: (rule, value, callback) => {
        if (value !== pwdForm.newPassword) {
          callback(new Error('两次输入的密码不一致'))
          return
        }
        callback()
      },
      trigger: 'blur'
    }
  ]
}

const safeNumber = (value) => Number(value) || 0

const formatScore = (value) => {
  const num = Number(value)
  return Number.isFinite(num) ? num.toFixed(1) : '0.0'
}

const formatDateTime = (value) => {
  if (!value) return ''
  const date = new Date(typeof value === 'string' ? value.replace(' ', 'T') : value)
  if (Number.isNaN(date.getTime())) return value
  const year = date.getFullYear()
  const month = `${date.getMonth() + 1}`.padStart(2, '0')
  const day = `${date.getDate()}`.padStart(2, '0')
  const hours = `${date.getHours()}`.padStart(2, '0')
  const minutes = `${date.getMinutes()}`.padStart(2, '0')
  return `${year}-${month}-${day} ${hours}:${minutes}`
}

const parseServiceArea = (value) => {
  if (!value) return '未设置'
  if (typeof value !== 'string') return String(value)
  const trimmed = value.trim()
  if (!trimmed) return '未设置'
  if (!['[', '{'].includes(trimmed[0])) return trimmed

  try {
    const parsed = JSON.parse(trimmed)
    if (Array.isArray(parsed)) {
      return parsed.join('、') || '未设置'
    }
    if (parsed && typeof parsed === 'object') {
      return Object.values(parsed).filter(Boolean).join('、') || trimmed
    }
  } catch (e) {
    return trimmed
  }
  return trimmed
}

const workStatusMeta = computed(() => {
  if (Number(form.workStatus) === 1) return { text: '接单中', type: 'success' }
  if (Number(form.workStatus) === 2) return { text: '忙碌中', type: 'warning' }
  return { text: '休息中', type: 'info' }
})

const auditStatusMeta = computed(() => {
  if (Number(form.auditStatus) === 1) return { text: '审核通过', type: 'success' }
  if (Number(form.auditStatus) === 2) return { text: '审核未通过', type: 'danger' }
  return { text: '待审核', type: 'warning' }
})

const serviceAreaText = computed(() => parseServiceArea(form.serviceArea))

const syncLocalUser = () => {
  const localUser = JSON.parse(localStorage.getItem('user') || '{}')
  localStorage.setItem('user', JSON.stringify({ ...localUser, ...form }))
}

onMounted(() => {
  loadProfile()
})

const loadProfile = async () => {
  try {
    const res = await request.get(`/collector/selectById/${user.id}`)
    Object.assign(form, res)
    syncLocalUser()
  } catch (e) {}
}

const handleAvatarSuccess = (res) => {
  form.avatar = res
  syncLocalUser()
  ElMessage.success('头像上传成功')
}

const saveProfile = async () => {
  const valid = await profileFormRef.value?.validate().catch(() => false)
  if (!valid) return

  saving.value = true
  try {
    await request.put('/collector/update', form)
    syncLocalUser()
    ElMessage.success('保存成功')
    await loadProfile()
  } catch (error) {
    ElMessage.error(error.message || '保存失败')
  } finally {
    saving.value = false
  }
}

const resetPasswordForm = () => {
  pwdForm.oldPassword = ''
  pwdForm.newPassword = ''
  pwdForm.confirmPassword = ''
}

const changePassword = async () => {
  const valid = await pwdFormRef.value?.validate().catch(() => false)
  if (!valid) return

  changingPwd.value = true
  try {
    await request.put('/updatePassword', null, {
      params: {
        username: form.username,
        password: pwdForm.oldPassword,
        newPassword: pwdForm.newPassword,
        role: '回收员'
      }
    })
    resetPasswordForm()
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

<style scoped lang="scss">
.collector-profile-page {
  min-height: calc(100vh - 60px);
  background: #f5f7fb;
}

.profile-hero {
  background: linear-gradient(135deg, #2f7a55 0%, #49a16b 100%);
  padding: 32px 0 90px;
  color: #fff;
}

.hero-main {
  width: 100%;
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  gap: 20px;
}

.hero-title {
  margin: 0;
  font-size: 30px;
  font-weight: 700;
}

.hero-subtitle {
  margin: 10px 0 0;
  color: rgba(255, 255, 255, 0.88);
  font-size: 14px;
}

.hero-tags {
  display: flex;
  gap: 10px;
  flex-wrap: wrap;
}

.hero-stats {
  width: 100%;
  margin: 24px 0 0;
  display: grid;
  grid-template-columns: repeat(4, minmax(0, 1fr));
  gap: 18px;
}

.hero-stat-card {
  background: rgba(255, 255, 255, 0.16);
  border: 1px solid rgba(255, 255, 255, 0.18);
  border-radius: 18px;
  padding: 20px 22px;
  backdrop-filter: blur(8px);

  .stat-label {
    font-size: 13px;
    color: rgba(255, 255, 255, 0.82);
  }

  .stat-value {
    margin-top: 10px;
    font-size: 30px;
    font-weight: 700;
    line-height: 1;
  }

  .stat-unit {
    margin-left: 4px;
    font-size: 14px;
    font-weight: 500;
  }
}

.profile-content {
  width: 100%;
  margin: -58px 0 0;
  padding: 0 0 28px;
  position: relative;
  z-index: 1;
}

.overview-row {
  margin-bottom: 20px;
}

.profile-card {
  border: none;
  border-radius: 20px;
  box-shadow: 0 10px 30px rgba(15, 23, 42, 0.06);
}

.sidebar-card {
  overflow: hidden;
}

.profile-summary {
  padding: 28px 28px 22px;
  text-align: center;
  background: linear-gradient(180deg, #f6fff8 0%, #ffffff 52%);
}

.avatar-ring {
  display: inline-flex;
  padding: 4px;
  border-radius: 50%;
  background: linear-gradient(135deg, #4caf72, #7fd39d);
  box-shadow: 0 12px 28px rgba(76, 175, 114, 0.2);
}

.avatar-uploader {
  position: relative;
  width: 112px;
  height: 112px;
  border-radius: 50%;
  overflow: hidden;
  cursor: pointer;
  background: #fff;

  .avatar {
    width: 100%;
    height: 100%;
    object-fit: cover;
  }

  .avatar-placeholder {
    width: 100%;
    height: 100%;
    display: flex;
    align-items: center;
    justify-content: center;
    color: #3d8d5b;
    background: #f2fbf5;
  }

  .avatar-mask {
    position: absolute;
    inset: 0;
    display: flex;
    align-items: center;
    justify-content: center;
    color: #fff;
    font-size: 13px;
    background: rgba(0, 0, 0, 0.42);
    opacity: 0;
    transition: opacity 0.25s ease;
  }

  &:hover .avatar-mask {
    opacity: 1;
  }
}

.collector-name {
  margin: 18px 0 6px;
  font-size: 24px;
  font-weight: 700;
  color: #1f2937;
}

.collector-role {
  margin: 0;
  font-size: 14px;
  color: #6b7280;
}

.summary-tags {
  display: flex;
  justify-content: center;
  gap: 10px;
  flex-wrap: wrap;
  margin-top: 16px;
}

.rating-box {
  margin-top: 18px;
  padding: 16px;
  border-radius: 16px;
  background: #ffffff;
  border: 1px solid #eef2f7;

  .rating-label {
    display: block;
    margin-bottom: 10px;
    font-size: 13px;
    color: #6b7280;
  }
}

.mini-stats {
  display: grid;
  grid-template-columns: repeat(3, minmax(0, 1fr));
  gap: 12px;
  padding: 22px 24px;
  border-top: 1px solid #f1f5f9;

  .mini-stat-item {
    padding: 14px 10px;
    border-radius: 14px;
    background: #f8fafc;
    text-align: center;
  }

  .mini-stat-value {
    font-size: 24px;
    font-weight: 700;
    color: #111827;
  }

  .mini-stat-label {
    margin-top: 6px;
    font-size: 12px;
    color: #6b7280;
  }
}

.summary-list {
  padding: 0 24px 24px;
}

.summary-item {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  gap: 16px;
  padding: 14px 0;
  border-top: 1px solid #f1f5f9;

  .label {
    color: #94a3b8;
    font-size: 13px;
    flex-shrink: 0;
  }

  .value {
    color: #1f2937;
    text-align: right;
    font-size: 14px;
    font-weight: 500;
  }

  .area-text {
    max-width: 220px;
    line-height: 1.6;
  }
}

.main-card {
  min-height: 100%;
}

.tabs-wrapper {
  display: flex;
  gap: 8px;
  padding: 10px;
  background: #f8fafc;
  border-radius: 18px;
  margin-bottom: 24px;
}

.tab-item {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  padding: 14px 18px;
  border-radius: 14px;
  color: #64748b;
  cursor: pointer;
  transition: all 0.25s ease;
  font-weight: 500;

  &:hover {
    color: #2f7a55;
    background: rgba(255, 255, 255, 0.8);
  }

  &.active {
    color: #2f7a55;
    background: #fff;
    box-shadow: 0 6px 18px rgba(15, 23, 42, 0.06);
  }
}

.tab-panel {
  padding: 6px 4px 2px;
}

.section-intro {
  margin-bottom: 22px;

  h3 {
    margin: 0 0 8px;
    font-size: 22px;
    color: #111827;
  }

  p {
    margin: 0;
    color: #6b7280;
    font-size: 14px;
    line-height: 1.7;
  }
}

.security-intro {
  margin-bottom: 14px;
}

.security-alert {
  margin-bottom: 20px;
}

.field-tip {
  margin-top: 8px;
  font-size: 12px;
  color: #94a3b8;
}

.form-actions {
  margin-top: 28px;
  padding-top: 20px;
  border-top: 1px solid #eef2f7;
}

.password-form {
  max-width: 520px;
}

.card-header {
  font-size: 16px;
  font-weight: 600;
  color: #111827;
}

.detail-list {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.detail-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 16px;
  padding: 16px 0;
  border-bottom: 1px solid #f1f5f9;

  &:last-child {
    border-bottom: none;
    padding-bottom: 0;
  }
}

.detail-label {
  font-size: 15px;
  font-weight: 600;
  color: #1f2937;
}

.detail-desc {
  margin-top: 4px;
  font-size: 12px;
  color: #94a3b8;
}

.detail-value {
  color: #334155;
  font-weight: 600;
}

.reject-box {
  margin-top: 18px;
  padding: 16px;
  border-radius: 14px;
  background: #fff2f0;
  border: 1px solid #ffd6d1;
}

.reject-title {
  font-size: 14px;
  font-weight: 600;
  color: #cf1322;
}

.reject-text {
  margin-top: 8px;
  font-size: 13px;
  line-height: 1.7;
  color: #7f1d1d;
}

.work-grid {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 16px;
}

.work-card {
  min-height: 120px;
  border-radius: 18px;
  padding: 18px;
  display: flex;
  flex-direction: column;
  justify-content: space-between;

  &.soft-green { background: linear-gradient(135deg, #ecfdf3, #f8fffb); }
  &.soft-blue { background: linear-gradient(135deg, #eff6ff, #f8fbff); }
  &.soft-yellow { background: linear-gradient(135deg, #fffbeb, #fffef8); }
  &.soft-purple { background: linear-gradient(135deg, #f5f3ff, #fcfbff); }
}

.work-card-title {
  color: #64748b;
  font-size: 13px;
}

.work-card-value {
  font-size: 26px;
  font-weight: 700;
  color: #111827;
  line-height: 1.4;

  &.small {
    font-size: 15px;
    font-weight: 600;
  }
}

.full-width-number {
  width: 100%;
}

:global(.profile-card > .el-card__body) {
  padding: 24px;
}

:global(.sidebar-card > .el-card__body) {
  padding: 0;
}

:global(.modern-form .el-form-item__label) {
  font-weight: 600;
  color: #334155;
  padding-bottom: 8px;
}

:global(.modern-form .el-input__wrapper),
:global(.modern-form .el-textarea__inner),
:global(.modern-form .el-input-number) {
  border-radius: 12px;
}

:global(.modern-form .el-input__wrapper) {
  box-shadow: 0 1px 2px rgba(15, 23, 42, 0.04);
  border: 1px solid #e5e7eb;
  padding: 4px 12px;
}

:global(.modern-form .el-input__wrapper:hover),
:global(.modern-form .el-input__wrapper.is-focus) {
  border-color: #49a16b;
  box-shadow: 0 0 0 3px rgba(73, 161, 107, 0.12);
}

:global(.modern-form .el-input__inner) {
  height: 38px;
}

:global(.modern-form .el-textarea__inner) {
  min-height: 112px !important;
  border: 1px solid #e5e7eb;
  padding: 12px 14px;
}

:global(.modern-form .el-textarea__inner:hover),
:global(.modern-form .el-textarea__inner:focus) {
  border-color: #49a16b;
  box-shadow: 0 0 0 3px rgba(73, 161, 107, 0.12);
}

:global(.full-width-number .el-input-number__decrease),
:global(.full-width-number .el-input-number__increase) {
  border-radius: 12px;
}

:global(.full-width-number .el-input__wrapper) {
  width: 100%;
}

@media (max-width: 992px) {
  .hero-stats {
    grid-template-columns: repeat(2, minmax(0, 1fr));
  }

  .work-grid {
    grid-template-columns: 1fr;
  }
}

@media (max-width: 768px) {
  .profile-hero {
    padding: 24px 0 72px;
  }

  .hero-main {
    flex-direction: column;
  }

  .hero-title {
    font-size: 26px;
  }

  .hero-stats {
    grid-template-columns: 1fr;
    gap: 12px;
  }

  .profile-content {
    margin-top: -44px;
    padding: 0 0 20px;
  }

  .mini-stats {
    grid-template-columns: 1fr;
  }

  .summary-item,
  .detail-item {
    flex-direction: column;
    align-items: flex-start;
  }

  .summary-item .value,
  .summary-item .area-text {
    text-align: left;
    max-width: none;
  }

  .tabs-wrapper {
    flex-direction: column;
  }

  :global(.profile-card > .el-card__body) {
    padding: 18px;
  }
}
</style>