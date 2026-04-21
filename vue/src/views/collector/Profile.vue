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
      </div>
    </div>

    <div class="profile-content">
      <el-row :gutter="24" class="content-grid">
        <el-col :xs="24" :sm="24" :md="8" :lg="6" class="content-col">
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
                <el-tag :type="auditStatusMeta.type" plain round>{{ auditStatusMeta.text }}</el-tag>
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

        <el-col :xs="24" :sm="24" :md="16" :lg="18" class="content-col">
          <div class="main-grid">
            <div class="content-col grid-span-12">
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
                  <div
                    class="tab-item"
                    :class="{ active: activeTab === 'serviceArea' }"
                    @click="activeTab = 'serviceArea'"
                  >
                    <el-icon><Location /></el-icon>
                    <span>服务区域</span>
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
                    label-width="96px"
                    class="modern-form profile-grid-form"
                  >
                    <el-row :gutter="24" class="form-grid-row">
                      <el-col :xs="24" :xl="12">
                        <el-form-item label="用户名" prop="username">
                          <el-input v-model="form.username" disabled>
                            <template #prefix>
                              <el-icon><User /></el-icon>
                            </template>
                          </el-input>
                        </el-form-item>
                      </el-col>
                      <el-col :xs="24" :xl="12">
                        <el-form-item label="真实姓名" prop="name">
                          <el-input v-model="form.name" placeholder="请输入真实姓名">
                            <template #prefix>
                              <el-icon><UserFilled /></el-icon>
                            </template>
                          </el-input>
                        </el-form-item>
                      </el-col>
                      <el-col :xs="24" :xl="12">
                        <el-form-item label="手机号" prop="phone">
                          <el-input v-model="form.phone" placeholder="请输入手机号" maxlength="11">
                            <template #prefix>
                              <el-icon><Iphone /></el-icon>
                            </template>
                          </el-input>
                        </el-form-item>
                      </el-col>
                      <el-col :xs="24" :xl="12">
                        <el-form-item label="每日接单上限" prop="maxDailyOrders">
                          <el-input-number v-model="form.maxDailyOrders" :min="1" :max="50" class="full-width-number" />
                        </el-form-item>
                      </el-col>
                      <el-col :span="24">
                        <el-form-item label="工作区域" prop="serviceArea" class="full-row-item">
                          <el-input
                            v-model="form.serviceArea"
                            type="textarea"
                            :rows="4"
                            resize="none"
                            placeholder="请输入负责的社区/小区名称，多个用顿号分隔，如：阳光花园、翠苑小区"
                           />
                           <div class="field-tip">请填写负责的社区/小区名称，系统将按社区匹配派单。</div>
                        </el-form-item>
                      </el-col>
                    </el-row>

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

                <!-- 服务区域管理 Tab -->
                <div v-show="activeTab === 'serviceArea'" class="tab-panel">
                  <div class="section-intro">
                    <h3>服务区域设置</h3>
                    <p>设置您负责的社区回收区域，系统将按区域智能派单。</p>
                  </div>

                  <div class="service-area-list" v-if="serviceArea">
                    <div class="area-item">
                      <div class="area-info">
                        <div class="area-region">{{ serviceArea.province }} {{ serviceArea.city }} {{ serviceArea.district }}</div>
                        <div class="area-community">{{ serviceArea.community }}</div>
                        <div class="area-coord" v-if="serviceArea.latitude">
                          经纬度：{{ Number(serviceArea.longitude).toFixed(6) }}, {{ Number(serviceArea.latitude).toFixed(6) }}
                        </div>
                      </div>
                    </div>
                  </div>
                  <el-empty v-else description="暂未设置服务区域" :image-size="80" />

                  <div class="form-actions" style="justify-content: flex-start;">
                    <el-button type="primary" @click="openAddAreaDialog">
                      <el-icon><Location /></el-icon> {{ serviceArea ? '修改服务区域' : '设置服务区域' }}
                    </el-button>
                  </div>
                </div>

                <!-- 设置服务区域弹窗 -->
                <el-dialog v-model="showAddAreaDialog" :title="serviceArea ? '修改服务区域' : '设置服务区域'" width="700px" destroy-on-close @opened="initAreaMap">
                  <el-form :model="areaForm" :rules="areaRules" ref="areaFormRef" label-width="100px">
                    <el-form-item label="地图定位" prop="latitude">
                      <div class="area-map-wrapper">
                        <div class="area-map-toolbar">
                          <div class="area-search-box">
                            <el-icon><Search /></el-icon>
                            <input v-model="areaSearchKeyword" placeholder="搜索地点" @keyup.enter="handleAreaSearch" />
                          </div>
                          <el-button size="small" @click="getAreaCurrentLocation">
                            <el-icon><Aim /></el-icon> 定位
                          </el-button>
                        </div>
                        <div ref="areaMapContainer" style="height: 300px; width: 100%;"></div>
                        <div class="area-selected-loc" v-if="areaSelectedAddress">
                          <span>📍 {{ areaSelectedAddress }}</span>
                          <span class="area-coord-tag" v-if="areaForm.latitude">
                            {{ Number(areaForm.longitude).toFixed(6) }}, {{ Number(areaForm.latitude).toFixed(6) }}
                          </span>
                        </div>
                        <div v-if="areaSearchResults.length" class="area-search-results">
                          <div v-for="(item, idx) in areaSearchResults" :key="idx" class="area-search-item" @click="selectAreaSearchResult(item)">
                            <el-icon><Location /></el-icon>
                            <div>
                              <div style="font-weight:500;">{{ item.name }}</div>
                              <div style="font-size:12px;color:#999;">{{ item.address }}</div>
                            </div>
                          </div>
                        </div>
                      </div>
                    </el-form-item>
                    <el-form-item label="所在地区" prop="region">
                      <el-cascader v-model="areaForm.region" :options="regionData"
                        :props="{ value: 'name', label: 'name', children: 'children' }"
                        placeholder="省 / 市 / 区" filterable clearable style="width: 100%"
                        :key="areaCascaderKey" @change="onAreaRegionChange" />
                    </el-form-item>
                    <el-form-item label="社区/小区" prop="community">
                      <el-input v-model="areaForm.community" placeholder="请输入所在社区或小区名称" maxlength="50" />
                    </el-form-item>
                  </el-form>
                  <template #footer>
                    <el-button @click="showAddAreaDialog = false">取消</el-button>
                    <el-button type="primary" :loading="areaSaving" @click="submitServiceArea">确认保存</el-button>
                  </template>
                </el-dialog>

              </el-card>
            </div>

            <div class="content-col grid-span-6">
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
            </div>

            <div class="content-col grid-span-6">
              <el-card class="profile-card detail-card" shadow="hover">
                <template #header>
                  <div class="card-header">工作概览</div>
                </template>

                <div class="work-grid compact-work-grid">
                  <div class="work-card soft-yellow">
                    <div class="work-card-title">每日接单上限</div>
                    <div class="work-card-value">{{ safeNumber(form.maxDailyOrders) }}<span class="stat-unit">单</span></div>
                  </div>
                  <div class="work-card soft-purple work-card-wide">
                    <div class="work-card-title">服务区域</div>
                    <div class="work-card-value small">{{ serviceAreaText }}</div>
                  </div>
                </div>
              </el-card>
            </div>
          </div>
        </el-col>
      </el-row>
    </div>
  </div>
</template>

<script setup>
import { computed, onMounted, onUnmounted, reactive, ref, nextTick } from 'vue'
import { ElMessage } from 'element-plus'
import { Aim, Iphone, Location, Lock, Plus, Search, User, UserFilled } from '@element-plus/icons-vue'
import request from '@/utils/request'
import regionData from '@/assets/region-data.json'

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
  if (!['[', '{'].includes(trimmed[0])) return trimmed.replace(/,/g, '、')

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

const serviceAreaText = computed(() => {
  if (serviceArea.value) {
    const s = serviceArea.value
    return `${s.district || ''} ${s.community || ''}`.trim() || '未设置'
  }
  return parseServiceArea(form.serviceArea)
})

const syncLocalUser = () => {
  const localUser = JSON.parse(localStorage.getItem('user') || '{}')
  localStorage.setItem('user', JSON.stringify({ ...localUser, ...form }))
}

onMounted(() => {
  loadProfile()
  loadServiceAreas()
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
    const data = { ...form }
    // 统一服务区域格式：顿号/中文逗号/空格 → 英文逗号
    if (data.serviceArea) {
      data.serviceArea = data.serviceArea.replace(/[、，\s]+/g, ',').replace(/^,|,$/g, '')
    }
    await request.put('/collector/update', data)
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

// ========== 服务区域管理 ==========
const serviceArea = ref(null)
const showAddAreaDialog = ref(false)
const areaSaving = ref(false)
const areaFormRef = ref()
const areaMapContainer = ref(null)
const areaSearchKeyword = ref('')
const areaSearchResults = ref([])
const areaSelectedAddress = ref('')
const areaCascaderKey = ref(0)
let areaMap = null
let areaMarker = null
let areaGeocoder = null
let areaSearchSvc = null

const areaForm = reactive({
  collectorId: '',
  province: '',
  city: '',
  district: '',
  community: '',
  latitude: null,
  longitude: null,
  region: []
})

const areaRules = {
  region: [{ required: true, message: '请选择所在地区', trigger: 'change' }],
  community: [{ required: true, message: '请输入社区/小区名称', trigger: 'blur' }],
  latitude: [{ required: true, message: '请在地图上选择位置', trigger: 'change', type: 'number' }]
}

const loadServiceAreas = async () => {
  try {
    const res = await request.get(`/collectorServiceArea/selectByCollectorId/${user.id}`)
    serviceArea.value = res || null
  } catch (e) {}
}

const openAddAreaDialog = () => {
  // 如果已有服务区域，回填数据
  if (serviceArea.value) {
    const s = serviceArea.value
    Object.assign(areaForm, {
      province: s.province || '', city: s.city || '', district: s.district || '',
      community: s.community || '', latitude: s.latitude || null, longitude: s.longitude || null,
      region: (s.province && s.city && s.district) ? [s.province, s.city, s.district] : []
    })
    areaSelectedAddress.value = `${s.province} ${s.city} ${s.district} ${s.community}`
  } else {
    Object.assign(areaForm, { province: '', city: '', district: '', community: '', latitude: null, longitude: null, region: [] })
    areaSelectedAddress.value = ''
  }
  areaSearchKeyword.value = ''
  areaSearchResults.value = []
  areaCascaderKey.value++
  showAddAreaDialog.value = true
}

const initAreaMap = () => {
  nextTick(() => {
    if (!areaMapContainer.value || !window.TMap) {
      ElMessage.error('地图加载失败，请刷新页面')
      return
    }
    const center = new TMap.LatLng(39.9042, 116.4074)
    areaMap = new TMap.Map(areaMapContainer.value, { center, zoom: 14, viewMode: '2D' })
    areaGeocoder = new TMap.service.Geocoder()
    try { areaSearchSvc = new TMap.service.Search({ pageSize: 6 }) } catch (e) {}
    areaMap.on('click', (evt) => {
      placeAreaMarker(evt.latLng)
      reverseAreaGeocode(evt.latLng)
    })
    getAreaCurrentLocation()
  })
}

const placeAreaMarker = (latLng) => {
  areaForm.latitude = latLng.lat
  areaForm.longitude = latLng.lng
  if (areaMarker) { areaMarker.setMap(null); areaMarker = null }
  areaMarker = new TMap.MultiMarker({ map: areaMap, geometries: [{ id: 'sel', position: latLng }] })
}

const reverseAreaGeocode = (latLng) => {
  if (!areaGeocoder) return
  areaGeocoder.getAddress({ location: latLng }).then((result) => {
    const comp = result.result.address_component
    areaForm.province = comp.province
    areaForm.city = comp.city
    areaForm.district = comp.district
    areaForm.region = [comp.province, comp.city, comp.district]
    areaCascaderKey.value++
    areaSelectedAddress.value = result.result.formatted_addresses?.recommend || result.result.address || ''
  }).catch(() => {})
}

const handleAreaSearch = () => {
  const kw = areaSearchKeyword.value.trim()
  if (!kw) return
  areaSearchResults.value = []
  if (areaGeocoder) {
    areaGeocoder.getLocation({ address: kw }).then((r) => {
      if (r?.result?.location) {
        areaSearchResults.value.push({ name: r.result.title || kw, address: r.result.address || kw, location: r.result.location })
      }
    }).catch(() => {})
  }
  if (areaSearchSvc) {
    const center = areaMap.getCenter()
    areaSearchSvc.searchNearby({ keyword: kw, center, radius: 50000 }).then((r) => {
      const list = (r.data || []).map(i => ({ name: i.title, address: i.address, location: i.location }))
      const names = areaSearchResults.value.map(i => i.name)
      list.forEach(p => { if (!names.includes(p.name)) areaSearchResults.value.push(p) })
    }).catch(() => {})
  }
}

const selectAreaSearchResult = (item) => {
  const latLng = new TMap.LatLng(item.location.lat, item.location.lng)
  areaMap.setCenter(latLng)
  areaMap.setZoom(16)
  placeAreaMarker(latLng)
  reverseAreaGeocode(latLng)
  areaSearchKeyword.value = item.name
  areaSearchResults.value = []
}

const getAreaCurrentLocation = () => {
  if (navigator.geolocation) {
    navigator.geolocation.getCurrentPosition(
      (pos) => {
        const latLng = new TMap.LatLng(pos.coords.latitude, pos.coords.longitude)
        areaMap.setCenter(latLng)
        areaMap.setZoom(15)
        placeAreaMarker(latLng)
        reverseAreaGeocode(latLng)
      },
      () => { ElMessage.warning('定位失败，请手动在地图上选择位置') },
      { enableHighAccuracy: true, timeout: 5000 }
    )
  }
}

const onAreaRegionChange = (val) => {
  if (val && val.length === 3) {
    areaForm.province = val[0]
    areaForm.city = val[1]
    areaForm.district = val[2]
  }
}

const submitServiceArea = async () => {
  const valid = await areaFormRef.value?.validate().catch(() => false)
  if (!valid) return
  if (!areaForm.latitude || !areaForm.longitude) {
    ElMessage.warning('请在地图上选择位置')
    return
  }
  areaSaving.value = true
  try {
    const data = { ...areaForm, collectorId: user.id }
    delete data.region
    await request.post('/collectorServiceArea/save', data)
    ElMessage.success('保存成功')
    showAddAreaDialog.value = false
    await loadServiceAreas()
  } catch (e) {
    ElMessage.error(e.message || '添加失败')
  } finally {
    areaSaving.value = false
  }
}


onUnmounted(() => {
  if (areaMap) { areaMap.destroy(); areaMap = null }
})
</script>

<style scoped lang="scss">
.collector-profile-page {
  min-height: calc(100vh - 60px);
  background: #f5f7fb;
}

.profile-hero {
  background: linear-gradient(135deg, #2f7a55 0%, #49a16b 100%);
  padding: 32px 24px 96px;
  color: #fff;
}

.hero-main {
  width: 100%;
  max-width: 1440px;
  margin: 0 auto;
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
  max-width: 1440px;
  margin: 24px 0 0;
  margin-left: auto;
  margin-right: auto;
  display: grid;
  grid-template-columns: repeat(3, minmax(0, 1fr));
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
  max-width: 1440px;
  margin: -58px auto 0;
  padding: 0 24px 32px;
  position: relative;
  z-index: 1;
}

.content-grid {
  row-gap: 24px;
}

.main-grid {
  width: 100%;
  display: grid;
  grid-template-columns: repeat(12, minmax(0, 1fr));
  gap: 24px;
}

.content-col {
  display: flex;
}

.grid-span-12 {
  grid-column: span 12;
}

.grid-span-6 {
  grid-column: span 6;
}

.profile-card {
  width: 100%;
  height: 100%;
  border: none;
  border-radius: 20px;
  box-shadow: 0 10px 30px rgba(15, 23, 42, 0.06);
}

.profile-summary {
  padding: 0 0 20px;
  text-align: center;
  background: linear-gradient(180deg, #f6fff8 0%, #ffffff 52%);
  border-bottom: 1px solid #f1f5f9;
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

.summary-list {
  padding: 0;
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
  padding: 4px 0 0;
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

.form-grid-row {
  row-gap: 4px;
}

.form-actions {
  margin-top: 28px;
  padding-top: 20px;
  border-top: 1px solid #eef2f7;
  display: flex;
  justify-content: flex-end;
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

.compact-work-grid {
  align-items: stretch;
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

.work-card-wide {
  grid-column: 1 / -1;
}

.full-width-number {
  width: 100%;
}

/* 服务区域样式 */
.service-area-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
  margin-bottom: 20px;
}

.area-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 16px;
  background: #f8fafc;
  border-radius: 12px;
  border: 1px solid #e2e8f0;
}

.area-info {
  flex: 1;
}

.area-region {
  font-size: 13px;
  color: #64748b;
  margin-bottom: 4px;
}

.area-community {
  font-size: 16px;
  font-weight: 600;
  color: #1f2937;
}

.area-coord {
  font-size: 12px;
  color: #94a3b8;
  margin-top: 4px;
}

.area-map-wrapper {
  width: 100%;
  border: 1px solid #dcdfe6;
  border-radius: 8px;
  overflow: hidden;
}

.area-map-toolbar {
  padding: 10px 12px;
  background: #f5f7fa;
  border-bottom: 1px solid #e4e7ed;
  display: flex;
  gap: 10px;
  align-items: center;
}

.area-search-box {
  flex: 1;
  display: flex;
  align-items: center;
  background: white;
  border: 1px solid #dcdfe6;
  border-radius: 4px;
  padding: 0 12px;
  height: 32px;

  input {
    flex: 1;
    border: none;
    outline: none;
    font-size: 13px;
    margin: 0 8px;
  }
}

.area-selected-loc {
  padding: 8px 12px;
  background: #e3f2fd;
  border-top: 1px solid #bbdefb;
  font-size: 13px;
  color: #1565c0;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.area-coord-tag {
  font-size: 12px;
  color: #757575;
}

.area-search-results {
  max-height: 200px;
  overflow-y: auto;
  border-top: 1px solid #e4e7ed;
}

.area-search-item {
  padding: 10px 12px;
  display: flex;
  align-items: flex-start;
  gap: 8px;
  cursor: pointer;
  border-bottom: 1px solid #f5f5f5;

  &:hover {
    background: #e3f2fd;
  }
}

:global(.profile-card > .el-card__body) {
  padding: 24px;
}

:global(.detail-card > .el-card__header) {
  padding: 24px 24px 0;
  border-bottom: none;
}

:global(.modern-form .el-form-item__label) {
  font-weight: 600;
  color: #334155;
  padding-bottom: 8px;
}

:global(.profile-grid-form .el-form-item) {
  margin-bottom: 20px;
}

:global(.profile-grid-form .el-form-item__content) {
  display: flex;
  flex-direction: column;
  align-items: stretch;
}

:global(.profile-grid-form .el-form-item__label-wrap) {
  margin-right: 12px;
}

:global(.profile-grid-form .el-form-item__label) {
  padding-bottom: 0;
  line-height: 40px;
}

:global(.profile-grid-form .full-row-item .el-form-item__content) {
  min-width: 0;
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

  .main-grid {
    grid-template-columns: 1fr;
  }

  .grid-span-12,
  .grid-span-6 {
    grid-column: auto;
  }

  .work-grid {
    grid-template-columns: 1fr;
  }

  .work-card-wide {
    grid-column: auto;
  }
}

@media (max-width: 768px) {
  .profile-hero {
    padding: 24px 16px 72px;
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
    padding: 0 16px 24px;
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

  :global(.detail-card > .el-card__header) {
    padding: 18px 18px 0;
  }

  :global(.profile-grid-form .el-form-item__label-wrap) {
    margin-right: 0;
  }

  :global(.profile-grid-form .el-form-item__label) {
    line-height: 1.5;
    padding-bottom: 8px;
  }
}
</style>