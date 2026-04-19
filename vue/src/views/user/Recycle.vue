<template>
  <div class="recycle-page">
    <div class="page-header">
      <h2>预约上门回收</h2>
      <p>填写回收信息，我们将安排回收员上门服务</p>
    </div>

    <el-row :gutter="30">
      <el-col :span="16">
        <el-card class="form-card">
          <el-form ref="formRef" :model="form" :rules="rules" label-position="top">
            <!-- 选择品类 -->
            <el-form-item label="选择回收品类" prop="applianceTypeId">
              <div class="type-grid" v-if="typeList.length > 0">
                <div
                    v-for="type in typeList"
                    :key="type.id"
                    class="type-item"
                    :class="{ active: form.applianceTypeId === type.id }"
                    @click="selectType(type)"
                >
                  <div class="type-icon">{{ type.icon || '📺' }}</div>
                  <div class="type-name">{{ type.name }}</div>
                  <div class="type-price">{{ type.priceMin }}-{{ type.priceMax }}元</div>
                </div>
              </div>
              <div v-else class="empty-tip-small">
                <el-icon :size="14"><Warning /></el-icon>
                <span>暂无回收品类数据</span>
              </div>
            </el-form-item>

            <el-row :gutter="20">
              <el-col :span="12">
                <el-form-item label="预估重量 (kg)" prop="estimatedWeight">
                  <el-input-number v-model="form.estimatedWeight" :min="1" :max="1000" style="width: 100%" />
                </el-form-item>
              </el-col>
              <el-col :span="12">
                <el-form-item label="数量">
                  <el-input-number v-model="form.quantity" :min="1" :max="10" style="width: 100%" />
                </el-form-item>
              </el-col>
            </el-row>
            <!-- 新增：机况评估（影响预估价格） -->
            <div class="condition-section" v-if="selectedType">
              <h4 class="section-title">📋 机况评估（影响回收价格）</h4>

              <el-form-item label="品牌类型" prop="brandLevel">
                <el-radio-group v-model="form.brandLevel" size="large">
                  <el-radio-button label="一线品牌">
                    <div class="radio-content">
                      <div class="radio-title">一线品牌</div>
                      <div class="radio-desc">格力、美的、海尔等</div>
                    </div>
                  </el-radio-button>
                  <el-radio-button label="二线品牌">
                    <div class="radio-content">
                      <div class="radio-title">二线品牌</div>
                      <div class="radio-desc">奥克斯、志高等</div>
                    </div>
                  </el-radio-button>
                  <el-radio-button label="杂牌">
                    <div class="radio-content">
                      <div class="radio-title">杂牌/其他</div>
                      <div class="radio-desc">小品牌或不知名</div>
                    </div>
                  </el-radio-button>
                </el-radio-group>
              </el-form-item>

              <el-form-item label="使用年限" prop="usageYears">
                <el-radio-group v-model="form.usageYears" size="large">
                  <el-radio-button label="1年内">
                    <div class="radio-content">
                      <div class="radio-title">1年内</div>
                      <div class="radio-desc">准新机</div>
                    </div>
                  </el-radio-button>
                  <el-radio-button label="2-3年">
                    <div class="radio-content">
                      <div class="radio-title">2-3年</div>
                      <div class="radio-desc">正常使用</div>
                    </div>
                  </el-radio-button>
                  <el-radio-button label="5年以上">
                    <div class="radio-content">
                      <div class="radio-title">5年以上</div>
                      <div class="radio-desc">老旧设备</div>
                    </div>
                  </el-radio-button>
                </el-radio-group>
              </el-form-item>

              <el-form-item label="功能状况" prop="functionalStatus">
                <el-radio-group v-model="form.functionalStatus" size="large">
                  <el-radio-button label="正常使用">
                    <div class="radio-content">
                      <div class="radio-title">正常使用</div>
                      <div class="radio-desc">各项功能完好</div>
                    </div>
                  </el-radio-button>
                  <el-radio-button label="零件损坏">
                    <div class="radio-content">
                      <div class="radio-title">零件损坏</div>
                      <div class="radio-desc">部分功能异常</div>
                    </div>
                  </el-radio-button>
                  <el-radio-button label="无法开机">
                    <div class="radio-content">
                      <div class="radio-title">无法开机</div>
                      <div class="radio-desc">完全损坏</div>
                    </div>
                  </el-radio-button>
                </el-radio-group>
              </el-form-item>

              <el-form-item label="外观成色" prop="appearanceLevel">
                <el-radio-group v-model="form.appearanceLevel" size="large">
                  <el-radio-button label="完好">
                    <div class="radio-content">
                      <div class="radio-title">完好</div>
                      <div class="radio-desc">无明显痕迹</div>
                    </div>
                  </el-radio-button>
                  <el-radio-button label="轻微划痕">
                    <div class="radio-content">
                      <div class="radio-title">轻微划痕</div>
                      <div class="radio-desc">正常使用痕迹</div>
                    </div>
                  </el-radio-button>
                  <el-radio-button label="破损">
                    <div class="radio-content">
                      <div class="radio-title">破损</div>
                      <div class="radio-desc">外壳或部件损坏</div>
                    </div>
                  </el-radio-button>
                </el-radio-group>
              </el-form-item>

              <!-- 预估价格展示（带机况系数） -->
              <div class="price-preview-box" v-if="estimatedPrice > 0">
                <div class="price-header">
                  <span class="price-label">预估回收价</span>
                  <el-tag v-if="conditionFactor" type="warning" effect="dark" size="small">
                    机况系数 {{ conditionFactor }}
                  </el-tag>
                </div>
                <div class="price-value">
                  <span class="currency">¥</span>
                  <span class="amount">{{ estimatedPrice }}</span>
                </div>
                <div class="price-range" v-if="selectedType">
                  参考价：{{ selectedType.priceMin }}-{{ selectedType.priceMax }}元 × {{ conditionFactor }}
                </div>
              </div>
            </div>

            <div class="calculate-result" v-if="selectedType">
              <div class="result-item">
                <span>预估积分：</span>
                <strong class="points">{{ estimatedPoints }}</strong>
              </div>
              <div class="result-item">
                <span>预估减碳：</span>
                <strong class="carbon">{{ estimatedCarbon }} kg</strong>
              </div>
            </div>

            <!-- 地址选择 -->
            <el-form-item label="上门地址" prop="addressId">
              <div class="address-list">
                <!-- 已保存的地址卡片 -->
                <div
                    v-for="addr in addressList"
                    :key="addr.id"
                    class="address-item"
                    :class="{ active: form.addressId === addr.id }"
                    @click="selectAddress(addr)"
                >
                  <div class="addr-header">
                    <span class="name">{{ addr.contactName }}</span>
                    <span class="phone">{{ addr.contactPhone }}</span>
                    <el-tag v-if="addr.isDefault" size="small" type="success">默认</el-tag>
                  </div>
                  <div class="addr-detail">
                    {{ addr.province }}{{ addr.city }}{{ addr.district }}{{ addr.detailAddress }}
                  </div>
                  <div class="addr-tags">
                    <el-tag v-if="addr.buildingType === 1" size="small">电梯房</el-tag>
                    <el-tag v-else size="small" type="warning">楼梯房{{ addr.floor }}层</el-tag>
                  </div>
                </div>

                <!-- 添加新地址按钮 -->
                <div class="add-address" @click="showAddAddress = true">
                  <el-icon><Plus /></el-icon>
                  <span>添加新地址</span>
                </div>

                <!-- 调试提示：无地址时显示 -->
                <div v-if="addressList.length === 0" class="empty-address-tip">
                  <el-icon><Info-Filled /></el-icon>
                  <span>暂无保存的地址，请点击上方按钮添加</span>
                </div>
              </div>
            </el-form-item>

            <el-form-item label="期望上门时间" prop="expectDate">
              <el-date-picker
                  v-model="form.expectDate"
                  type="date"
                  placeholder="选择日期"
                  :disabled-date="disabledDate"
                  style="width: 100%"
              />
            </el-form-item>

            <el-form-item prop="expectTime">
              <el-time-picker
                  v-model="form.expectTimeStart"
                  placeholder="开始时间"
                  format="HH:mm"
                  style="width: 48%"
              />
              <span style="margin: 0 2%">至</span>
              <el-time-picker
                  v-model="form.expectTimeEnd"
                  placeholder="结束时间"
                  format="HH:mm"
                  style="width: 48%"
              />
            </el-form-item>

            <el-form-item label="紧急程度">
              <el-radio-group v-model="form.urgencyLevel">
                <el-radio-button :label="1">普通</el-radio-button>
                <el-radio-button :label="2">较急</el-radio-button>
                <el-radio-button :label="3">紧急</el-radio-button>
              </el-radio-group>
            </el-form-item>

            <el-form-item label="物品照片（选填）">
              <el-upload action="http://localhost:9090/files/upload" list-type="picture-card" :on-success="handleUploadSuccess" :limit="3">
                <el-icon><Plus /></el-icon>
              </el-upload>
            </el-form-item>

            <el-form-item label="备注说明">
              <el-input v-model="form.applianceDesc" type="textarea" :rows="3" placeholder="请描述物品的具体情况" />
            </el-form-item>

            <el-form-item>
              <el-button type="primary" size="large" @click="submitOrder" :loading="submitting" style="width: 100%">
                提交预约
              </el-button>
            </el-form-item>
          </el-form>
        </el-card>
      </el-col>

      <el-col :span="8">
        <div class="tips-card">
          <h4>💡 温馨提示</h4>
          <ul>
            <li>请确保物品信息真实准确</li>
            <li>回收员将在预约时间内上门</li>
            <li>请提前准备好身份证件</li>
            <li>大型家电需提前断电</li>
          </ul>
          <div class="process-flow">
            <h4>📋 回收流程</h4>
            <div class="flow-item"><div class="step">1</div><div class="content"><h5>在线预约</h5><p>填写回收信息</p></div></div>
            <div class="flow-item"><div class="step">2</div><div class="content"><h5>智能派单</h5><p>系统分配回收员</p></div></div>
            <div class="flow-item"><div class="step">3</div><div class="content"><h5>上门回收</h5><p>现场称重结算</p></div></div>
            <div class="flow-item"><div class="step">4</div><div class="content"><h5>获得积分</h5><p>积分可兑换礼品</p></div></div>
          </div>
        </div>
      </el-col>
    </el-row>

    <!-- 添加地址对话框 -->
    <el-dialog
        v-model="showAddAddress"
        title="添加新地址"
        width="600px"
        destroy-on-close
        :close-on-click-modal="false"
    >
      <AddressForm
          @success="onAddressAdded"
          @cancel="showAddAddress = false"
      />
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted, nextTick } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { Plus, Warning, InfoFilled } from '@element-plus/icons-vue'
import request from '@/utils/request'
import AddressForm from '@/components/AddressForm.vue'

const router = useRouter()
const formRef = ref()
const submitting = ref(false)
const showAddAddress = ref(false)

const form = reactive({
  applianceTypeId: null,
  estimatedWeight: 10,
  quantity: 1,
  brandLevel: '二线品牌',        // 默认二线品牌（系数1.0）
  usageYears: '2-3年',          // 默认2-3年（系数0.8）
  functionalStatus: '正常使用',  // 默认正常使用（系数1.0）
  appearanceLevel: '轻微划痕',   // 默认轻微划痕（系数0.9）
  addressId: null,
  expectDate: null,
  expectTimeStart: null,
  expectTimeEnd: null,
  urgencyLevel: 1,
  applianceImgs: '',
  applianceDesc: '',
  contactName: '',
  contactPhone: ''
})

const rules = {
  applianceTypeId: [{ required: true, message: '请选择回收品类', trigger: 'change' }],
  addressId: [{ required: true, message: '请选择上门地址', trigger: 'change' }],
  expectDate: [{ required: true, message: '请选择日期', trigger: 'change' }],
  brandLevel: [{ required: true, message: '请选择品牌类型', trigger: 'change' }],
  usageYears: [{ required: true, message: '请选择使用年限', trigger: 'change' }],
  functionalStatus: [{ required: true, message: '请选择功能状况', trigger: 'change' }],
  appearanceLevel: [{ required: true, message: '请选择外观成色', trigger: 'change' }]
}

const typeList = ref([])
const addressList = ref([])
const selectedType = ref(null)

const estimatedPoints = computed(() => {
  if (!selectedType.value || !form.estimatedWeight) return 0
  return Math.floor(form.estimatedWeight * (selectedType.value.pointsPerKg || 0))
})

const estimatedCarbon = computed(() => {
  if (!selectedType.value || !form.estimatedWeight) return 0
  return (form.estimatedWeight * (selectedType.value.carbonFactor || 0)).toFixed(2)
})

// 新增：计算机况综合系数
const conditionFactor = computed(() => {
  // 品牌系数
  const brandFactor = {
    '一线品牌': 1.2,
    '二线品牌': 1.0,
    '杂牌': 0.8
  }[form.brandLevel] || 1.0

  // 年限系数
  const yearFactor = {
    '1年内': 1.0,
    '2-3年': 0.8,
    '5年以上': 0.6
  }[form.usageYears] || 0.8

  // 功能系数
  const functionFactor = {
    '正常使用': 1.0,
    '零件损坏': 0.7,
    '无法开机': 0.4
  }[form.functionalStatus] || 0.7

  // 成色系数
  const appearanceFactor = {
    '完好': 1.0,
    '轻微划痕': 0.9,
    '破损': 0.7
  }[form.appearanceLevel] || 0.9

  // 综合系数（保留2位小数）
  return (brandFactor * yearFactor * functionFactor * appearanceFactor).toFixed(2)
})

// 新增：计算预估价格
const estimatedPrice = computed(() => {
  if (!selectedType.value) return 0

  // 基准价 = (最低 + 最高) / 2
  const priceMin = selectedType.value.priceMin || 0
  const priceMax = selectedType.value.priceMax || 0
  const basePrice = (parseFloat(priceMin) + parseFloat(priceMax)) / 2

  if (basePrice === 0) return 0

  // 预估价 = 基准价 × 机况系数
  let price = basePrice * parseFloat(conditionFactor.value)

  // 限制在价格区间内
  price = Math.max(price, priceMin)  // 不低于最低
  price = Math.min(price, priceMax)  // 不高于最高

  return price.toFixed(2)
})

const formatTime = (date) => {
  if (!date) return null
  try {
    const d = new Date(date)
    const h = d.getHours().toString().padStart(2, '0')
    const m = d.getMinutes().toString().padStart(2, '0')
    return `${h}:${m}:00`
  } catch (e) {
    return null
  }
}

onMounted(() => {
  loadTypes()
  loadAddresses()
})

// 加载品类
const loadTypes = async () => {
  try {
    const res = await request.get('/applianceType/selectEnabled')
    if (res.code === '200') {
      typeList.value = res || []
    } else if (Array.isArray(res)) {
      typeList.value = res
    } else if (res && Array.isArray(res)) {
      typeList.value = res
    } else {
      typeList.value = []
    }
  } catch (e) {
    console.error('加载品类失败:', e)
    typeList.value = []
  }
}

// 修复：强化地址加载函数，增加错误处理和调试日志
const loadAddresses = async () => {
  try {
    const userStr = localStorage.getItem('user')
    console.log('[RecyclePage] 加载地址 - userStr:', userStr)

    if (!userStr) {
      console.warn('[RecyclePage] 未获取到用户信息，无法加载地址')
      return
    }

    let user
    try {
      user = JSON.parse(userStr)
    } catch (e) {
      console.error('[RecyclePage] 解析用户信息失败:', e)
      return
    }

    console.log('[RecyclePage] 加载地址 - user:', user)

    if (!user?.id) {
      console.warn('[RecyclePage] 用户ID不存在')
      return
    }

    const res = await request.get(`/userAddress/selectByUser/${user.id}`)
    console.log('[RecyclePage] 地址API返回:', res)

    // 修复：更健壮的数据处理逻辑
    let list = []
    if (res?.code === '200' && Array.isArray(res)) {
      list = res
    } else if (Array.isArray(res)) {
      list = res
    } else if (res && Array.isArray(res)) {
      list = res
    } else {
      console.warn('[RecyclePage] API返回数据格式异常:', res)
      list = []
    }

    addressList.value = list
    console.log('[RecyclePage] 地址列表已更新，数量:', list.length)

  } catch (e) {
    console.error('[RecyclePage] 加载地址失败:', e)
    ElMessage.error('加载地址列表失败')
  }
}

const selectType = (type) => {
  if (!type?.id) return
  form.applianceTypeId = type.id
  selectedType.value = type
  form.estimatedWeight = type.weightEstimate || 10
}

const selectAddress = (addr) => {
  if (!addr?.id) return
  form.addressId = addr.id
  form.contactName = addr.contactName || ''
  form.contactPhone = addr.contactPhone || ''
}

const disabledDate = (time) => {
  return time.getTime() < Date.now() - 8.64e7
}

const handleUploadSuccess = (res) => {
  form.applianceImgs = res || res
}

// 修复：强化地址添加成功后的处理
const onAddressAdded = async (newAddress) => {
  console.log('[RecyclePage] 收到地址添加成功事件:', newAddress)

  showAddAddress.value = false

  // 使用 nextTick 确保对话框关闭后再加载数据
  await nextTick()

  // 重新加载地址列表
  await loadAddresses()

  // 如果传入了新地址数据，自动选中
  if (newAddress?.id) {
    // 确保列表中已包含新地址（有时后端返回的数据结构可能不同）
    const exists = addressList.value.find(a => a.id === newAddress.id)
    if (exists) {
      selectAddress(exists)
      ElMessage.success('地址添加成功并已选中')
    } else {
      // 如果列表中没有，尝试直接使用返回的数据
      addressList.value.unshift(newAddress)
      selectAddress(newAddress)
      ElMessage.success('地址添加成功并已选中')
    }
  } else {
    ElMessage.success('地址添加成功')
  }
}

const submitOrder = async () => {
  try {
    await formRef.value.validate()
  } catch (e) {
    return
  }

  if (!form.expectTimeStart || !form.expectTimeEnd) {
    ElMessage.warning('请选择上门时间段')
    return
  }

  // 关键：获取选中的完整地址信息
  const selectedAddress = addressList.value.find(addr => addr.id === form.addressId)
  if (!selectedAddress) {
    ElMessage.error('所选地址信息不完整，请重新选择')
    return
  }

  const userStr = localStorage.getItem('user')
  if (!userStr) {
    ElMessage.error('请先登录')
    router.push('/login')
    return
  }

  const user = JSON.parse(userStr)
  const userId = user?.id

  if (!userId) {
    ElMessage.error('登录信息无效')
    router.push('/login')
    return
  }

  submitting.value = true
  try {
    const formatDate = (date) => {
      if (!date) return null
      const d = new Date(date)
      const y = d.getFullYear()
      const m = (d.getMonth() + 1).toString().padStart(2, '0')
      const day = d.getDate().toString().padStart(2, '0')
      return `${y}-${m}-${day}`
    }

    const formatTime = (date) => {
      if (!date) return null
      const d = new Date(date)
      const h = d.getHours().toString().padStart(2, '0')
      const m = d.getMinutes().toString().padStart(2, '0')
      const s = d.getSeconds().toString().padStart(2, '0')
      return `${h}:${m}:${s}`
    }

    // 关键修复：构建完整的地址详情字符串
    const addressDetail = `${selectedAddress.province}${selectedAddress.city}${selectedAddress.district}${selectedAddress.detailAddress}`

    const submitData = {
      userId: userId,
      applianceTypeId: form.applianceTypeId,
      estimatedWeight: form.estimatedWeight,
      quantity: form.quantity,
      // 新增：机况评估字段
      brandLevel: form.brandLevel,
      usageYears: form.usageYears,
      functionalStatus: form.functionalStatus,
      appearanceLevel: form.appearanceLevel,
      addressId: form.addressId,
      // 新增：地址详情（后端必需的字段）
      addressDetail: addressDetail,  // 完整地址字符串
      addressLat: selectedAddress.latitude,      // 纬度
      addressLng: selectedAddress.longitude,     // 经度
      buildingType: selectedAddress.buildingType, // 楼栋类型
      floor: selectedAddress.floor,              // 楼层
      contactName: form.contactName || selectedAddress.contactName,
      contactPhone: form.contactPhone || selectedAddress.contactPhone,
      expectDate: formatDate(form.expectDate),
      expectTimeStart: formatTime(form.expectTimeStart),
      expectTimeEnd: formatTime(form.expectTimeEnd),
      urgencyLevel: form.urgencyLevel,
      applianceImgs: form.applianceImgs || '',
      applianceDesc: form.applianceDesc || ''
    }

    console.log('提交数据（含地址详情）:', submitData)

    const res = await request.post('/recycleOrder/create', submitData)
    console.log('后端返回:', res, 'code类型:', typeof res?.code, 'code值:', res?.code)

    if (res?.code === '200' || res?.code === 200) {
      console.log('走进成功分支')
      ElMessage.success('预约成功')
      router.push('/recycleOrder')
    } else {
      console.error('走进失败分支, res:', res)  // 看这里输出什么
      ElMessage.error(res?.msg || '预约失败')
    }
  } catch (error) {
    console.error('提交失败:', error)
    ElMessage.error(error.message || '预约失败')
  } finally {
    submitting.value = false
  }
}
</script>

<style scoped lang="scss">
.recycle-page {
  padding: 20px;

  .page-header {
    text-align: center;
    margin-bottom: 30px;
    h2 {
      font-size: 28px;
      color: #333;
      margin-bottom: 10px;
    }
    p {
      color: #666;
    }
  }

  .form-card {
    padding: 20px;
  }

  .empty-tip-small {
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 6px;
    padding: 8px 12px;
    color: #909399;
    font-size: 12px;
    background: #f5f7fa;
    border-radius: 4px;
    border: 1px dashed #dcdfe6;
    margin-top: 4px;
  }

  .type-grid {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: 15px;

    .type-item {
      border: 2px solid #e8e8e8;
      border-radius: 8px;
      padding: 20px;
      text-align: center;
      cursor: pointer;
      transition: all 0.3s;

      &:hover, &.active {
        border-color: #52c41a;
        background: #f6ffed;
      }

      .type-icon {
        font-size: 32px;
        margin-bottom: 8px;
      }

      .type-name {
        font-weight: bold;
        margin-bottom: 5px;
      }

      .type-price {
        color: #f5222d;
        font-size: 13px;
      }
    }
  }

  .calculate-result {
    background: #f6ffed;
    padding: 15px 20px;
    border-radius: 8px;
    margin-bottom: 20px;
    display: flex;
    gap: 30px;

    .result-item {
      span {
        color: #666;
      }
      strong {
        font-size: 18px;
        margin-left: 8px;
      }
      .points {
        color: #fa8c16;
      }
      .carbon {
        color: #52c41a;
      }
    }
  }

  .address-list {
    display: grid;
    gap: 15px;

    .address-item {
      border: 1px solid #e8e8e8;
      border-radius: 8px;
      padding: 15px;
      cursor: pointer;
      transition: all 0.3s;

      &:hover, &.active {
        border-color: #52c41a;
        background: #f6ffed;
      }

      .addr-header {
        display: flex;
        align-items: center;
        gap: 10px;
        margin-bottom: 8px;

        .name {
          font-weight: bold;
        }

        .phone {
          color: #666;
        }
      }

      .addr-detail {
        color: #333;
        margin-bottom: 8px;
      }

      .addr-tags {
        margin-top: 8px;
      }
    }

    .add-address {
      border: 2px dashed #d9d9d9;
      border-radius: 8px;
      padding: 20px;
      text-align: center;
      cursor: pointer;
      color: #999;
      transition: all 0.3s;

      &:hover {
        border-color: #52c41a;
        color: #52c41a;
      }
    }

    // 新增：空地址提示样式
    .empty-address-tip {
      display: flex;
      align-items: center;
      justify-content: center;
      gap: 8px;
      padding: 20px;
      color: #909399;
      font-size: 14px;
      background: #f5f7fa;
      border-radius: 8px;
      border: 1px dashed #dcdfe6;
    }
  }

  .tips-card {
    background: white;
    padding: 25px;
    border-radius: 12px;
    box-shadow: 0 2px 12px rgba(0,0,0,0.05);

    h4 {
      color: #333;
      margin-bottom: 15px;
      font-size: 16px;
    }

    ul {
      list-style: none;
      padding: 0;
      margin-bottom: 30px;

      li {
        padding: 8px 0;
        color: #666;
        position: relative;
        padding-left: 20px;

        &::before {
          content: '•';
          color: #52c41a;
          position: absolute;
          left: 0;
          font-weight: bold;
        }
      }
    }

    .process-flow {
      .flow-item {
        display: flex;
        gap: 15px;
        margin-bottom: 20px;

        .step {
          width: 30px;
          height: 30px;
          background: #52c41a;
          color: white;
          border-radius: 50%;
          display: flex;
          align-items: center;
          justify-content: center;
          font-weight: bold;
          flex-shrink: 0;
        }

        .content {
          h5 {
            color: #333;
            margin-bottom: 5px;
          }

          p {
            color: #999;
            font-size: 13px;
          }
        }
      }
    }
  }
}
// 新增：机况评估样式
.condition-section {
  background: #f8f9fa;
  border-radius: 12px;
  padding: 8px;
  margin: 10px 0;
  border: 1px solid #e9ecef;

  .section-title {
    margin: 0 0 20px 0;
    color: #333;
    font-size: 16px;
    font-weight: 600;
    border-bottom: 2px solid #52c41a;
    padding-bottom: 10px;
    display: inline-block;
  }

  // 单选按钮内容样式
  .radio-content {
    padding: 4px 8px;
    text-align: center;

    .radio-title {
      font-size: 14px;
      font-weight: 500;
      margin-bottom: 2px;
    }

    .radio-desc {
      font-size: 12px;
      opacity: 0.8;
      font-weight: normal;
    }
  }

  // 价格预览框
  .price-preview-box {
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    border-radius: 12px;
    padding: 2px;
    text-align: center;
    color: white;
    margin-top: 20px;
    box-shadow: 0 4px 15px rgba(102, 126, 234, 0.4);

    .price-header {
      display: flex;
      justify-content: center;
      align-items: center;
      gap: 10px;
      margin-bottom: 8px;

      .price-label {
        font-size: 10px;
        opacity: 0.9;
      }
    }

    .price-value {
      margin: 10px 0;

      .currency {
        font-size: 12px;
        font-weight: 500;
        margin-right: 4px;
      }

      .amount {
        font-size: 24px;
        font-weight: 700;
        line-height: 1;
      }
    }

    .price-range {
      font-size: 10px;
      opacity: 0.8;
      margin-top: 8px;
    }
  }
}
</style>