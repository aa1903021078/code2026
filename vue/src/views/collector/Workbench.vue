<template>
  <div class="workbench-page">
    <div class="overview-section">
      <div class="section-heading">
        <div>
          <h3>工作概览</h3>
          <p>查看今日接单、完成情况与收益表现</p>
        </div>
        <el-button type="primary" plain @click="refreshOrders">刷新数据</el-button>
      </div>

      <div class="stats-cards">
        <div class="stat-card blue">
          <div class="icon">📦</div>
          <div class="info">
            <div class="value">{{ stats.todayOrderCount }}</div>
            <div class="label">今日接单</div>
          </div>
        </div>
        <div class="stat-card green">
          <div class="icon">✅</div>
          <div class="info">
            <div class="value">{{ stats.completedCount }}</div>
            <div class="label">已完成</div>
          </div>
        </div>
        <div class="stat-card orange">
          <div class="icon">💰</div>
          <div class="info">
            <div class="value">¥{{ stats.todayIncome }}</div>
            <div class="label">今日收入</div>
          </div>
        </div>
        <div class="stat-card purple">
          <div class="icon">⭐</div>
          <div class="info">
            <div class="value">{{ stats.rating }}</div>
            <div class="label">我的评分</div>
          </div>
        </div>
      </div>
    </div>

    <div class="orders-section">
      <div class="section-heading compact">
        <div>
          <h3>新订单待接单</h3>
          <p>及时处理新派发订单，提升接单效率</p>
        </div>
      </div>

      <div v-if="newOrders.length > 0" class="order-list">
        <div v-for="order in newOrders" :key="order.id" class="order-item">
          <div class="order-info">
            <div class="order-top">
              <div class="order-title-group">
                <span class="order-no">{{ order.orderNo }}</span>
                <span class="order-name">{{ order.applianceTypeName }}</span>
              </div>
              <el-tag :type="order.urgencyLevel === 3 ? 'danger' : order.urgencyLevel === 2 ? 'warning' : 'info'">
                {{ urgencyText(order.urgencyLevel) }}
              </el-tag>
            </div>

            <div class="detail-grid">
              <div class="detail-item">
                <span class="detail-label">预估重量</span>
                <span class="detail-value">{{ order.estimatedWeight }}kg</span>
              </div>
              <div class="detail-item wide">
                <span class="detail-label">上门地址</span>
                <span class="detail-value">{{ order.addressDetail }}</span>
              </div>
              <div class="detail-item wide">
                <span class="detail-label">期望时间</span>
                <span class="detail-value">{{ order.expectDate }} {{ order.expectTimeStart }}-{{ order.expectTimeEnd }}</span>
              </div>
            </div>
          </div>

          <div class="order-actions">
            <el-button type="success" size="large" @click="acceptOrder(order.id)">
              立即接单
            </el-button>
            <el-button type="danger" size="large" plain @click="rejectOrder(order.id)">
              拒绝
            </el-button>
          </div>
        </div>
      </div>

      <el-empty v-else description="当前没有待接订单" :image-size="92" />
    </div>

    <div class="active-section">
      <div class="section-heading compact">
        <div>
          <h3>进行中的订单</h3>
          <p>跟进已接单与已到达订单，及时推进处理进度</p>
        </div>
      </div>

      <el-timeline v-if="activeOrders.length > 0">
        <el-timeline-item
          v-for="order in activeOrders"
          :key="order.id"
          :type="order.status === 2 ? 'primary' : 'warning'"
        >
          <div class="active-order-item">
            <div class="info">
              <div class="active-order-title">{{ order.applianceTypeName }} - {{ order.orderNo }}</div>
              <p>{{ order.addressDetail }}</p>
              <p>联系人：{{ order.contactName }} {{ order.contactPhone }}</p>
            </div>
            <div class="actions">
              <el-button
                v-if="order.status === 2"
                type="primary"
                @click="arrive(order.id)"
              >
                确认到达
              </el-button>
              <el-button
                v-if="order.status === 3"
                type="success"
                @click="complete(order)"
              >
                完成订单
              </el-button>
            </div>
          </div>
        </el-timeline-item>
      </el-timeline>

      <el-empty v-else description="暂无进行中的订单" :image-size="92" />
    </div>

    <!-- 完成订单弹窗 -->
    <el-dialog v-model="completeVisible" title="完成订单" width="500px">
      <el-form :model="completeForm" label-width="100px">
        <el-form-item label="实际重量(kg)">
          <el-input-number v-model="completeForm.weightActual" :min="0.1" :precision="2" style="width: 100%" />
        </el-form-item>
        <el-form-item label="实际金额(元)">
          <el-input-number v-model="completeForm.priceActual" :min="0" :precision="2" style="width: 100%" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="completeVisible = false">取消</el-button>
        <el-button type="primary" @click="confirmComplete" :loading="completing">确认完成</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import request from '@/utils/request'

const user = JSON.parse(localStorage.getItem('user') || '{}')
const stats = ref({
  todayOrderCount: 0,
  completedCount: 0,
  todayIncome: 0,
  rating: 5.0
})
const newOrders = ref([])
const activeOrders = ref([])
const timer = ref(null)
const completeVisible = ref(false)
const completing = ref(false)
const completeForm = ref({
  orderId: null,
  weightActual: 0,
  priceActual: 0
})

onMounted(() => {
  loadStats()
  loadOrders()
  timer.value = setInterval(loadOrders, 10000) // 每10秒刷新
})

onUnmounted(() => {
  clearInterval(timer.value)
})

const loadStats = async () => {
  try {
    stats.value = await request.get(`/collector/todayStats/${user.id}`)
  } catch (e) {}
}

const loadOrders = async () => {
  try {
    const res = await request.get(`/recycleOrder/selectByCollector/${user.id}`)
    // 待接单（status=1）
    newOrders.value = res.filter(o => o.status === 1)
    // 进行中（status=2已接单 或 status=3已到达）
    activeOrders.value = res.filter(o => o.status === 2 || o.status === 3)
  } catch (e) {}
}

const urgencyText = (level) => {
  const map = { 1: '普通', 2: '较急', 3: '紧急' }
  return map[level] || '普通'
}

const refreshOrders = () => {
  loadOrders()
  ElMessage.success('已刷新')
}

const acceptOrder = async (orderId) => {
  try {
    await request.post('/recycleOrder/accept', null, { params: { orderId, collectorId: user.id } })
    ElMessage.success('接单成功')
    loadOrders()
    loadStats()
  } catch (error) {
    ElMessage.error(error.message || '接单失败')
  }
}

const rejectOrder = async (orderId) => {
  try {
    await ElMessageBox.confirm('确认拒绝此订单？', '提示')
    await request.post('/recycleOrder/cancel', null, { params: { orderId, reason: '回收员拒绝' } })
    ElMessage.success('已拒绝')
    loadOrders()
  } catch (e) {}
}

const arrive = async (orderId) => {
  try {
    await request.post('/recycleOrder/arrive', null, { params: { orderId } })
    ElMessage.success('已确认到达')
    loadOrders()
  } catch (error) {
    ElMessage.error(error.message || '操作失败')
  }
}

const complete = (order) => {
  completeForm.value = {
    orderId: order.id,
    weightActual: order.estimatedWeight,
    priceActual: order.priceEstimate || 0
  }
  completeVisible.value = true
}

const confirmComplete = async () => {
  completing.value = true
  try {
    await request.post('/recycleOrder/complete', {
      id: completeForm.value.orderId,
      weightActual: completeForm.value.weightActual,
      priceActual: completeForm.value.priceActual
    })
    ElMessage.success('订单完成')
    completeVisible.value = false
    loadOrders()
    loadStats()
  } catch (error) {
    ElMessage.error(error.message || '操作失败')
  } finally {
    completing.value = false
  }
}
</script>

<style scoped lang="scss">
.workbench-page {
  min-height: calc(100vh - 128px);
  background: #f5f7fa;
}

.overview-section,
.orders-section,
.active-section {
  background: #fff;
  padding: 20px;
  border-radius: 12px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.05);
}

.overview-section,
.orders-section {
  margin-bottom: 20px;
}

.section-heading {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 16px;
  margin-bottom: 20px;

  h3 {
    margin: 0;
    font-size: 18px;
    font-weight: 600;
    color: #303133;
  }

  p {
    margin: 6px 0 0;
    font-size: 13px;
    color: #909399;
  }
}

.section-heading.compact {
  margin-bottom: 16px;
}

.stats-cards {
  display: grid;
  grid-template-columns: repeat(4, minmax(0, 1fr));
  gap: 20px;
}

.stat-card {
  background: #fff;
  padding: 20px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  border: 1px solid #eef2f7;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.03);

  &.blue { border-left: 4px solid #1890ff; }
  &.green { border-left: 4px solid #52c41a; }
  &.orange { border-left: 4px solid #fa8c16; }
  &.purple { border-left: 4px solid #722ed1; }

  .icon {
    font-size: 38px;
    margin-right: 16px;
  }

  .info {
    min-width: 0;

    .value {
      font-size: 28px;
      font-weight: 700;
      color: #303133;
      line-height: 1.2;
    }

    .label {
      margin-top: 6px;
      color: #909399;
      font-size: 13px;
    }
  }
}

.order-list {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.order-item {
  display: flex;
  justify-content: space-between;
  align-items: stretch;
  gap: 20px;
  padding: 20px;
  border: 1px solid #ebeef5;
  border-radius: 12px;
  background: #fafbfd;
}

.order-info {
  flex: 1;
  min-width: 0;
}

.order-top {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 12px;
  margin-bottom: 16px;
}

.order-title-group {
  display: flex;
  align-items: center;
  gap: 12px;
  flex-wrap: wrap;
}

.order-no {
  font-size: 16px;
  font-weight: 700;
  color: #303133;
}

.order-name {
  font-size: 14px;
  color: #606266;
}

.detail-grid {
  display: grid;
  grid-template-columns: repeat(3, minmax(0, 1fr));
  gap: 12px;
}

.detail-item {
  padding: 14px 16px;
  border-radius: 10px;
  background: #fff;
  border: 1px solid #f0f2f5;

  &.wide {
    grid-column: span 2;
  }
}

.detail-label {
  display: block;
  margin-bottom: 6px;
  font-size: 12px;
  color: #909399;
}

.detail-value {
  color: #303133;
  font-size: 14px;
  line-height: 1.6;
  word-break: break-all;
}

.order-actions {
  width: 140px;
  display: flex;
  flex-direction: column;
  justify-content: center;
  gap: 12px;
  flex-shrink: 0;
}

.active-order-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 20px;
  padding: 18px 20px;
  background: #f6ffed;
  border-radius: 10px;
  border: 1px solid #d9f7be;

  .info {
    flex: 1;
    min-width: 0;

    p {
      color: #606266;
      font-size: 13px;
      margin: 4px 0 0;
      line-height: 1.6;
    }
  }
}

.active-order-title {
  font-size: 15px;
  font-weight: 700;
  color: #303133;
}

.actions {
  flex-shrink: 0;
}

@media (max-width: 1200px) {
  .stats-cards {
    grid-template-columns: repeat(2, minmax(0, 1fr));
  }

  .detail-grid {
    grid-template-columns: repeat(2, minmax(0, 1fr));
  }
}

@media (max-width: 768px) {
  .overview-section,
  .orders-section,
  .active-section {
    padding: 16px;
  }

  .section-heading,
  .order-item,
  .active-order-item {
    flex-direction: column;
    align-items: stretch;
  }

  .stats-cards,
  .detail-grid {
    grid-template-columns: 1fr;
  }

  .detail-item.wide {
    grid-column: span 1;
  }

  .order-actions {
    width: 100%;
  }

  .order-top {
    flex-direction: column;
    align-items: flex-start;
  }
}
</style>