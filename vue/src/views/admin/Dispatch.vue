<template>
  <div class="dispatch-container">
    <!-- 顶部统计栏 -->
    <el-row :gutter="20" class="stats-bar">
      <el-col :span="6">
        <el-statistic title="待派单" :value="stats.pendingCount" value-style="color: #f56c6c">
          <template #prefix><el-icon><Document /></el-icon></template>
        </el-statistic>
      </el-col>
      <el-col :span="6">
        <el-statistic title="在线回收员" :value="stats.onlineCollectors" value-style="color: #67c23a">
          <template #prefix><el-icon><User /></el-icon></template>
        </el-statistic>
      </el-col>
      <el-col :span="6">
        <el-statistic title="今日已派单" :value="stats.todayDispatched">
          <template #prefix><el-icon><CircleCheck /></el-icon></template>
        </el-statistic>
      </el-col>
      <el-col :span="6">
        <el-statistic title="平均响应" :value="stats.avgResponseTime" suffix="分钟">
          <template #prefix><el-icon><Timer /></el-icon></template>
        </el-statistic>
      </el-col>
    </el-row>

    <!-- 主内容区 -->
    <el-row :gutter="20" class="main-content">
      <!-- 左侧：待派单列表 -->
      <el-col :span="10">
        <el-card class="order-list-card" shadow="hover">
          <template #header>
            <div class="card-header">
              <span class="title">📋 待派单列表</span>
              <div style="display:flex;gap:8px;align-items:center;">
                <el-button type="success" size="small" :loading="batchLoading" @click="handleBatchDispatch">
                  ⚡ 一键智能派单
                </el-button>
                <el-radio-group v-model="viewMode" size="small">
                  <el-radio-button value="card">卡片</el-radio-button>
                  <el-radio-button value="table">表格</el-radio-button>
                </el-radio-group>
              </div>
            </div>
          </template>

          <!-- 卡片视图 -->
          <div v-if="viewMode === 'card'" class="order-cards">
            <el-empty v-if="pendingOrders.length === 0" description="暂无待派单订单" />

            <el-card
                v-for="order in pendingOrders"
                :key="order.id"
                class="order-item"
                :class="{ 'active': selectedOrder?.id === order.id }"
                shadow="hover"
                @click="selectOrder(order)"
            >
              <div class="order-header">
                <span class="order-no">{{ order.orderNo }}</span>
                <div style="display:flex;gap:4px;">
                  <el-tag v-if="order.preferredCollectorId" size="small" type="danger">用户指定</el-tag>
                  <el-tag size="small" type="warning">待派单</el-tag>
                </div>
              </div>

              <div class="order-body">
                <div class="info-row">
                  <el-icon><Location /></el-icon>
                  <span class="address" :title="order.addressDetail">
                    <span v-if="order.community" style="color:#67c23a;font-weight:500;">【{{ order.community }}】</span>
                    {{ order.addressDetail }}
                  </span>
                </div>
                <div class="info-row">
                  <el-icon><Refrigerator /></el-icon>
                  <span>{{ order.applianceTypeName }} · {{ order.estimatedWeight }}kg</span>
                  <el-tag size="small" type="info" class="time-tag">{{ formatTime(order.createTime) }}</el-tag>
                </div>
              </div>

              <div class="order-actions">
                <el-button
                    type="primary"
                    size="small"
                    :icon="MagicStick"
                    :loading="loadingOrderId === order.id && dispatchType === 'auto'"
                    @click.stop="handleAutoDispatch(order)"
                >
                  智能派单
                </el-button>
                <el-button
                    type="warning"
                    size="small"
                    plain
                    :icon="User"
                    @click.stop="openManualDispatch(order)"
                >
                  手动派单
                </el-button>
              </div>
            </el-card>
          </div>

          <!-- 表格视图 -->
          <el-table v-else :data="pendingOrders" style="width: 100%" v-loading="loading">
            <el-table-column prop="orderNo" label="订单号" width="140" />
            <el-table-column label="社区" width="100">
              <template #default="{ row }">
                <span v-if="row.community" style="color:#67c23a;">{{ row.community }}</span>
                <span v-else style="color:#ccc;">-</span>
              </template>
            </el-table-column>
            <el-table-column prop="addressDetail" label="地址" show-overflow-tooltip />
            <el-table-column prop="applianceTypeName" label="类型" width="100" />
            <el-table-column label="指定" width="70">
              <template #default="{ row }">
                <el-tag v-if="row.preferredCollectorId" size="small" type="danger">是</el-tag>
              </template>
            </el-table-column>
            <el-table-column label="操作" width="200" fixed="right">
              <template #default="{ row }">
                <el-button
                    type="primary"
                    size="small"
                    @click="handleAutoDispatch(row)"
                    :loading="loadingOrderId === row.id && dispatchType === 'auto'"
                >
                  智能
                </el-button>
                <el-button
                    type="warning"
                    size="small"
                    plain
                    @click="openManualDispatch(row)"
                >
                  手动
                </el-button>
              </template>
            </el-table-column>
          </el-table>
        </el-card>
      </el-col>

      <!-- 中间：地图展示（简化版，实际可接入高德/百度地图） -->
      <el-col :span="9">
        <el-card class="map-card" shadow="hover">
          <template #header>
            <div class="card-header">
              <span class="title">🗺️ 位置分布</span>
              <el-button v-if="selectedOrder" type="primary" size="small" text @click="centerMap">
                定位选中订单
              </el-button>
            </div>
          </template>

          <div class="map-container" ref="mapContainer">
            <!-- 实际项目中这里接入高德地图 -->
            <div v-if="!selectedOrder" class="map-placeholder">
              <el-icon :size="48" color="#dcdfe6"><MapLocation /></el-icon>
              <p>点击左侧订单查看位置分布</p>
              <p class="sub-text">红色标记：订单位置 | 绿色标记：回收员位置</p>
            </div>

            <div v-else class="map-content">
              <div class="selected-order-info">
                <h4>当前选中订单</h4>
                <p><strong>地址：</strong>{{ selectedOrder.addressDetail }}</p>
                <p><strong>坐标：</strong>{{ selectedOrder.addressLat }}, {{ selectedOrder.addressLng }}</p>
                <div class="nearby-collectors" v-if="nearbyCollectors.length > 0">
                  <h5>可用回收员（{{ nearbyCollectors.length }}人）</h5>
                  <div v-for="c in nearbyCollectors" :key="c.id" class="collector-marker">
                    <el-avatar :size="24">{{ (c.name || '').charAt(0) }}</el-avatar>
                    <span>{{ c.name }}（{{ formatDistance(c.distance) }}km）</span>
                    <el-tag size="small" :type="c.workStatus === 1 ? 'success' : 'warning'">
                      {{ workStatusText(c.workStatus) }}
                    </el-tag>
                  </div>
                </div>
                <el-empty v-else description="暂无可用回收员" :image-size="60" />
              </div>
            </div>
          </div>
        </el-card>
      </el-col>

      <!-- 右侧：最近派单记录 -->
      <el-col :span="5">
        <el-card class="recent-dispatch" shadow="hover">
          <template #header>
            <span class="title">📈 最近派单</span>
          </template>
          <el-timeline>
            <el-timeline-item
                v-for="(record, index) in recentRecords"
                :key="index"
                :type="record.status === 'success' ? 'success' : 'danger'"
                :timestamp="record.time"
                placement="top"
            >
              <p class="record-title">{{ record.orderNo }}</p>
              <p class="record-desc">
                {{ record.type === 'auto' ? '🤖 智能派单' : '👤 手动派单' }} 给 {{ record.collectorName }}
              </p>
            </el-timeline-item>
          </el-timeline>
          <el-empty v-if="recentRecords.length === 0" description="暂无记录" :image-size="60" />
        </el-card>
      </el-col>
    </el-row>

    <!-- 手动派单抽屉 -->
    <el-drawer
        v-model="manualDrawerVisible"
        title="手动选择回收员"
        size="400px"
        :destroy-on-close="true"
    >
      <div v-if="currentOrder" class="manual-drawer-content">
        <el-alert
            :title="`为订单 ${currentOrder.orderNo} 选择回收员`"
            type="info"
            :closable="false"
            class="order-alert"
        />

        <div class="order-detail">
          <p><strong>地址：</strong>{{ currentOrder.addressDetail }}</p>
          <p><strong>家电：</strong>{{ currentOrder.applianceTypeName }}（{{ currentOrder.estimatedWeight }}kg）</p>
        </div>

        <el-divider content-position="left">可用回收员列表</el-divider>

        <el-radio-group v-model="selectedCollectorId" class="collector-list">
          <el-radio
              v-for="collector in availableCollectors"
              :key="collector.id"
              :value="collector.id"
              class="collector-radio"
          >
            <div class="collector-info">
              <div class="collector-main">
                <el-avatar :size="40">{{ (collector.name || '').charAt(0) }}</el-avatar>
                <div class="collector-text">
                  <div class="name">{{ collector.name }}</div>
                  <div class="stats">
                    <span>评分 {{ collector.rating }}</span>
                    <el-divider direction="vertical" />
                    <span>今日 {{ collector.todayOrderCount || 0 }}单</span>
                  </div>
                </div>
                <el-tag
                    :type="collector.workStatus === 1 ? 'success' : 'warning'"
                    size="small"
                >
                  {{ workStatusText(collector.workStatus) }}
                </el-tag>
              </div>
              <div class="distance" v-if="collector.distance != null">
                <el-icon><Location /></el-icon>
                距离订单 {{ formatDistance(collector.distance) }}km
              </div>
            </div>
          </el-radio>
        </el-radio-group>

        <div class="drawer-footer">
          <el-button @click="manualDrawerVisible = false">取消</el-button>
          <el-button
              type="warning"
              @click="confirmManualDispatch"
              :loading="loadingOrderId === currentOrder?.id && dispatchType === 'manual'"
              :disabled="!selectedCollectorId"
          >
            确认派单
          </el-button>
        </div>
      </div>
    </el-drawer>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, onUnmounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import {
  Document, User, CircleCheck, Timer,
  MagicStick, Location, Refrigerator, MapLocation
} from '@element-plus/icons-vue'
import request from '@/utils/request'

// 统计数据
const stats = reactive({
  pendingCount: 0,
  onlineCollectors: 0,
  todayDispatched: 0,
  avgResponseTime: 0
})

// 视图模式
const viewMode = ref('card')

// 数据列表
const pendingOrders = ref([])
const loading = ref(false)
const loadingOrderId = ref(null)
const dispatchType = ref('') // 'auto' | 'manual'

// 选中订单（用于地图展示）
const selectedOrder = ref(null)
const nearbyCollectors = ref([])

// 手动派单相关
const manualDrawerVisible = ref(false)
const currentOrder = ref(null)
const availableCollectors = ref([])
const selectedCollectorId = ref(null)

// 最近派单记录
const recentRecords = ref([])

// 批量派单loading
const batchLoading = ref(false)

// 获取待派单列表
const loadPendingOrders = async () => {
  loading.value = true
  try {
    const res = await request.get('/recycleOrder/selectPendingDispatch')
    pendingOrders.value = Array.isArray(res) ? res : []
    stats.pendingCount = pendingOrders.value.length
  } catch (error) {
    ElMessage.error('获取订单列表失败')
  } finally {
    loading.value = false
  }
}

// 判断响应是否为业务错误（拦截器对非200会原样返回 {code, msg}）
const isBizError = (res) => res && typeof res === 'object' && res.code && res.code !== '200' && res.code !== 200

const formatTime = (t) => {
  if (!t) return ''
  return String(t).replace('T', ' ').substring(0, 16)
}

const formatDistance = (d) => {
  if (d == null) return '-'
  const n = Number(d)
  return Number.isFinite(n) ? n.toFixed(2) : d
}

const workStatusText = (s) => {
  if (s === 1) return '接单中'
  if (s === 2) return '忙碌'
  return '休息'
}

// 选中订单查看详情/地图
const selectOrder = async (order) => {
  selectedOrder.value = order
  nearbyCollectors.value = []

  // 先尝试按坐标查附近回收员
  if (order.addressLat != null && order.addressLng != null) {
    try {
      const res = await request.get('/collector/selectNearby', {
        params: { lat: order.addressLat, lng: order.addressLng, radius: 5000 }
      })
      if (Array.isArray(res) && res.length > 0) {
        nearbyCollectors.value = res
        return
      }
    } catch (error) {
      console.error('获取附近回收员失败:', error)
    }
  }

  // 附近无人或无坐标，查询所有可用回收员
  try {
    const res = await request.get('/collector/selectAvailable')
    nearbyCollectors.value = Array.isArray(res) ? res : []
  } catch (error) {
    console.error('获取可用回收员失败:', error)
  }
}

// 智能派单（自动）
const handleAutoDispatch = async (order) => {
  try {
    await ElMessageBox.confirm(
        `确定对订单 ${order.orderNo} 执行智能派单吗？系统将自动选择5公里内最近的可用回收员`,
        '确认智能派单',
        {
          confirmButtonText: '确认派单',
          cancelButtonText: '取消',
          type: 'warning'
        }
    )
  } catch (e) {
    return // 用户取消
  }

  loadingOrderId.value = order.id
  dispatchType.value = 'auto'
  try {
    const res = await request.post(`/recycleOrder/dispatch/${order.id}`)
    if (isBizError(res)) {
      ElMessage.error(res.msg || '派单失败')
      return
    }
    ElMessage.success(`订单 ${order.orderNo} 智能派单成功！`)
    await loadPendingOrders()
    loadDispatchStats()
    loadRecentRecords()
    if (selectedOrder.value?.id === order.id) {
      selectedOrder.value = null
    }
  } catch (error) {
    ElMessage.error(error?.response?.data?.message || '派单失败')
  } finally {
    loadingOrderId.value = null
    dispatchType.value = ''
  }
}

// 打开手动派单抽屉
const openManualDispatch = async (order) => {
  currentOrder.value = order
  selectedCollectorId.value = null
  manualDrawerVisible.value = true
  availableCollectors.value = []

  // 先尝试按坐标查附近回收员
  if (order.addressLat != null && order.addressLng != null) {
    try {
      const res = await request.get('/collector/selectNearby', {
        params: { lat: order.addressLat, lng: order.addressLng, radius: 10000 }
      })
      if (Array.isArray(res) && res.length > 0) {
        availableCollectors.value = res
        return
      }
    } catch (error) {
      console.error('获取附近回收员失败:', error)
    }
  }

  // 附近无人或无坐标，查询所有可用回收员
  try {
    const res = await request.get('/collector/selectAvailable')
    availableCollectors.value = Array.isArray(res) ? res : []
    if (availableCollectors.value.length === 0) {
      ElMessage.warning('暂无可用回收员')
    }
  } catch (error) {
    console.error('获取可用回收员失败:', error)
    ElMessage.warning('获取回收员列表失败，请稍后重试')
  }
}

// 确认手动派单
const confirmManualDispatch = async () => {
  if (!selectedCollectorId.value) {
    ElMessage.warning('请选择回收员')
    return
  }

  const collector = availableCollectors.value.find(c => c.id === selectedCollectorId.value)

  try {
    loadingOrderId.value = currentOrder.value.id
    dispatchType.value = 'manual'

    // 后端使用 @RequestParam，必须通过 query params 传递
    const res = await request.post('/recycleOrder/manualDispatch', null, {
      params: {
        orderId: currentOrder.value.id,
        collectorId: selectedCollectorId.value
      }
    })
    if (isBizError(res)) {
      ElMessage.error(res.msg || '手动派单失败')
      return
    }

    ElMessage.success(`已手动派单给 ${collector?.name || '回收员'}`)

    manualDrawerVisible.value = false
    await loadPendingOrders()
    loadDispatchStats()
    loadRecentRecords()
  } catch (error) {
    ElMessage.error(error?.response?.data?.message || '手动派单失败')
  } finally {
    loadingOrderId.value = null
    dispatchType.value = ''
  }
}

// 一键批量智能派单
const handleBatchDispatch = async () => {
  if (pendingOrders.value.length === 0) {
    ElMessage.info('暂无待派单订单')
    return
  }
  try {
    await ElMessageBox.confirm(
        `将对所有待派单订单（共 ${pendingOrders.value.length} 个）执行智能派单。\n用户指定回收员的订单将被跳过，需手动派单。`,
        '确认一键智能派单',
        { confirmButtonText: '确认', cancelButtonText: '取消', type: 'warning' }
    )
  } catch (e) { return }

  batchLoading.value = true
  try {
    const res = await request.post('/recycleOrder/batchDispatch')
    if (isBizError(res)) {
      ElMessage.error(res.msg || '批量派单失败')
      return
    }
    const success = res?.success || 0
    const fail = res?.fail || 0
    ElMessage.success(`批量派单完成：成功 ${success} 个，跳过/失败 ${fail} 个`)
    await loadPendingOrders()
    loadDispatchStats()
    loadRecentRecords()
  } catch (error) {
    ElMessage.error('批量派单失败')
  } finally {
    batchLoading.value = false
  }
}

// 地图居中（模拟）
const centerMap = () => {
  ElMessage.info('地图已定位到选中订单位置')
}

// 加载统计数据
const loadDispatchStats = async () => {
  try {
    const res = await request.get('/recycleOrder/dispatchStats')
    if (res && typeof res === 'object' && !res.code) {
      Object.assign(stats, res)
    }
  } catch (e) {
    console.error('加载统计失败:', e)
  }
}

// 加载最近派单记录
const loadRecentRecords = async () => {
  try {
    const res = await request.get('/recycleOrder/recentDispatchRecords', { params: { limit: 10 } })
    if (Array.isArray(res)) {
      recentRecords.value = res.map(r => ({
        orderNo: r.orderNo || '',
        type: r.dispatchType || 'auto',
        collectorName: r.collectorName || '未知',
        time: formatTime(r.time),
        status: 'success'
      }))
    }
  } catch (e) {
    console.error('加载派单记录失败:', e)
  }
}

let refreshTimer = null
onMounted(() => {
  loadPendingOrders()
  loadDispatchStats()
  loadRecentRecords()
  refreshTimer = setInterval(() => {
    loadPendingOrders()
    loadDispatchStats()
  }, 30000)
})
onUnmounted(() => {
  if (refreshTimer) clearInterval(refreshTimer)
})
</script>

<style scoped lang="scss">
.dispatch-container {
  padding: 20px;
  background: #f5f7fa;
  min-height: calc(100vh - 84px);

  .stats-bar {
    margin-bottom: 20px;

    :global(.el-statistic__content) {
      font-size: 24px;
      font-weight: 600;
    }
  }

  .main-content {
    .card-header {
      display: flex;
      justify-content: space-between;
      align-items: center;

      .title {
        font-size: 16px;
        font-weight: 600;
      }
    }

    .order-list-card {
      height: calc(100vh - 220px);

      .order-cards {
        height: calc(100% - 40px);
        overflow-y: auto;

        .order-item {
          margin-bottom: 12px;
          cursor: pointer;
          transition: all 0.3s;

          &:hover, &.active {
            border-color: #409eff;
            transform: translateY(-2px);
          }

          .order-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 12px;

            .order-no {
              font-weight: 600;
              color: #303133;
            }
          }

          .order-body {
            margin-bottom: 12px;

            .info-row {
              display: flex;
              align-items: center;
              margin-bottom: 8px;
              color: #606266;
              font-size: 13px;

              .el-icon {
                margin-right: 6px;
              }

              .address {
                overflow: hidden;
                text-overflow: ellipsis;
                white-space: nowrap;
                flex: 1;
              }

              .time-tag {
                margin-left: auto;
              }
            }
          }

          .order-actions {
            display: flex;
            gap: 8px;

            .el-button {
              flex: 1;
            }
          }
        }
      }
    }

    .map-card {
      height: calc(100vh - 220px);

      .map-container {
        height: calc(100% - 40px);
        background: #f5f7fa;
        border-radius: 4px;
        position: relative;

        .map-placeholder {
          height: 100%;
          display: flex;
          flex-direction: column;
          align-items: center;
          justify-content: center;
          color: #909399;

          .sub-text {
            font-size: 12px;
            margin-top: 8px;
          }
        }

        .map-content {
          padding: 16px;

          .selected-order-info {
            h4 {
              margin: 0 0 12px 0;
              color: #303133;
            }

            p {
              margin: 8px 0;
              color: #606266;
              font-size: 14px;
            }

            .nearby-collectors {
              margin-top: 20px;

              h5 {
                margin: 0 0 12px 0;
                color: #303133;
              }

              .collector-marker {
                display: flex;
                align-items: center;
                gap: 8px;
                padding: 8px;
                background: #fff;
                border-radius: 4px;
                margin-bottom: 8px;
                border: 1px solid #e4e7ed;
              }
            }
          }
        }
      }
    }

    .recent-dispatch {
      height: calc(100vh - 220px);

      .record-title {
        font-weight: 600;
        margin: 0 0 4px 0;
      }

      .record-desc {
        font-size: 12px;
        color: #909399;
        margin: 0;
      }
    }
  }

  .manual-drawer-content {
    .order-alert {
      margin-bottom: 16px;
    }

    .order-detail {
      background: #f5f7fa;
      padding: 12px;
      border-radius: 4px;
      margin-bottom: 16px;

      p {
        margin: 4px 0;
        color: #606266;
      }
    }

    .collector-list {
      width: 100%;

      .collector-radio {
        width: 100%;
        margin-bottom: 12px;
        margin-right: 0;

        :global(.el-radio__input) {
          margin-top: 12px;
        }

        :global(.el-radio__label) {
          width: calc(100% - 24px);
          padding-left: 8px;
        }
      }

      .collector-info {
        width: 100%;

        .collector-main {
          display: flex;
          align-items: center;
          gap: 12px;

          .collector-text {
            flex: 1;

            .name {
              font-weight: 600;
              color: #303133;
              margin-bottom: 4px;
            }

            .stats {
              font-size: 12px;
              color: #909399;
            }
          }
        }

        .distance {
          margin-top: 8px;
          color: #409eff;
          font-size: 13px;
          display: flex;
          align-items: center;
          gap: 4px;
        }
      }
    }

    .drawer-footer {
      position: absolute;
      bottom: 0;
      left: 0;
      right: 0;
      padding: 16px;
      background: #fff;
      border-top: 1px solid #e4e7ed;
      display: flex;
      justify-content: flex-end;
      gap: 12px;
    }
  }
}
</style>