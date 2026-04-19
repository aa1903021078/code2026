<template>
  <div class="navigation-page">
    <div class="map-container" ref="mapContainer"></div>

    <div class="top-status" v-if="currentOrder">
      <div class="status-item">
        <span class="label">剩余距离</span>
        <span class="value">{{ distance }} 公里</span>
      </div>
      <div class="status-item">
        <span class="label">预计用时</span>
        <span class="value">{{ duration }} 分钟</span>
      </div>
      <div class="status-item">
        <span class="label">状态</span>
        <el-tag :type="simulating ? 'success' : 'info'" size="small">
          {{ simulating ? '行进中' : '未开始' }}
        </el-tag>
      </div>
    </div>

    <div class="route-panel" v-if="currentOrder">
      <div class="panel-header">
        <h4>🚚 当前订单导航</h4>
        <el-button link type="primary" @click="cancelCurrent">切换订单</el-button>
      </div>
      <div class="route-info">
        <p><strong>订单号：</strong>{{ currentOrder.orderNo }}</p>
        <p><strong>品类：</strong>{{ currentOrder.applianceTypeName }}</p>
        <p><strong>目的地：</strong>{{ currentOrder.addressDetail }}</p>
        <p><strong>联系人：</strong>{{ currentOrder.contactName }} {{ currentOrder.contactPhone }}</p>
      </div>
      <div class="panel-actions">
        <el-button :type="simulating ? 'warning' : 'success'" @click="toggleSimulate">
          {{ simulating ? '暂停模拟' : '开始模拟' }}
        </el-button>
        <el-button type="primary" @click="startNavi">外部导航</el-button>
      </div>
    </div>

    <div class="order-selector" v-else>
      <h4>🗺️ 选择订单开始导航</h4>
      <el-select
        v-model="selectedOrderId"
        placeholder="选择进行中的订单"
        style="width: 100%"
        :disabled="activeOrders.length === 0"
      >
        <el-option
          v-for="order in activeOrders"
          :key="order.id"
          :label="order.applianceTypeName + ' - ' + order.addressDetail"
          :value="order.id"
        />
      </el-select>
      <div v-if="activeOrders.length === 0" class="empty-tip">暂无进行中的订单</div>
      <el-button
        type="primary"
        style="margin-top: 10px; width: 100%"
        @click="loadRoute"
        :disabled="activeOrders.length === 0"
      >
        规划路线
      </el-button>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted, nextTick } from 'vue'
import { ElMessage } from 'element-plus'
import request from '@/utils/request'

const mapContainer = ref(null)
const currentOrder = ref(null)
const activeOrders = ref([])
const selectedOrderId = ref(null)
const distance = ref(0)
const duration = ref(0)
const simulating = ref(false)

const user = JSON.parse(localStorage.getItem('user') || '{}')

// 默认起点（回收员当前位置）：北京天安门附近
const DEFAULT_START = { lat: 39.9042, lng: 116.4074 }

let map = null
let collectorMarker = null
let destMarker = null
let polyline = null
let routePath = []
let routeIndex = 0
let simTimer = null

onMounted(() => {
  nextTick(() => initMap())
  loadActiveOrders()
})

onUnmounted(() => {
  stopSimulate()
  if (map) {
    try { map.destroy() } catch (e) { /* ignore */ }
    map = null
  }
})

const initMap = () => {
  if (!mapContainer.value || !window.TMap) {
    ElMessage.error('地图加载失败，请刷新页面')
    return
  }
  const center = new TMap.LatLng(DEFAULT_START.lat, DEFAULT_START.lng)
  map = new TMap.Map(mapContainer.value, {
    center,
    zoom: 13,
    viewMode: '2D'
  })

  collectorMarker = new TMap.MultiMarker({
    map,
    styles: {
      collector: new TMap.MarkerStyle({
        width: 36,
        height: 36,
        anchor: { x: 18, y: 36 },
        src: 'https://mapapi.qq.com/web/lbs/javascriptGL/demo/img/start.png'
      })
    },
    geometries: [{
      id: 'collector',
      styleId: 'collector',
      position: center
    }]
  })
}

const loadActiveOrders = async () => {
  if (!user.id) return
  try {
    const res = await request.get(`/recycleOrder/selectByCollector/${user.id}`)
    activeOrders.value = (res || []).filter(o => o.status === 2 || o.status === 3)
  } catch (e) {
    console.error('加载订单失败', e)
  }
}

const loadRoute = () => {
  const order = activeOrders.value.find(o => o.id === selectedOrderId.value)
  if (!order) {
    ElMessage.warning('请选择订单')
    return
  }
  // 若订单无坐标，使用随机偏移模拟
  const destLat = Number(order.addressLat) || (DEFAULT_START.lat + (Math.random() - 0.5) * 0.05)
  const destLng = Number(order.addressLng) || (DEFAULT_START.lng + (Math.random() - 0.5) * 0.05)

  currentOrder.value = { ...order, addressLat: destLat, addressLng: destLng }
  drawRoute(DEFAULT_START, { lat: destLat, lng: destLng })
}

const drawRoute = (from, to) => {
  if (!map) return

  if (destMarker) { destMarker.setMap(null); destMarker = null }
  if (polyline) { polyline.setMap(null); polyline = null }

  // 线性插值生成路径（带轻微抖动）
  const STEPS = 60
  routePath = []
  for (let i = 0; i <= STEPS; i++) {
    const t = i / STEPS
    const jitter = i > 0 && i < STEPS ? (Math.random() - 0.5) * 0.0015 : 0
    routePath.push({
      lat: from.lat + (to.lat - from.lat) * t + jitter,
      lng: from.lng + (to.lng - from.lng) * t + jitter
    })
  }
  routeIndex = 0

  polyline = new TMap.MultiPolyline({
    map,
    styles: {
      route: new TMap.PolylineStyle({
        color: '#1890ff',
        width: 6,
        borderWidth: 2,
        borderColor: '#ffffff',
        lineCap: 'round'
      })
    },
    geometries: [{
      id: 'route',
      styleId: 'route',
      paths: routePath.map(p => new TMap.LatLng(p.lat, p.lng))
    }]
  })

  destMarker = new TMap.MultiMarker({
    map,
    styles: {
      dest: new TMap.MarkerStyle({
        width: 36,
        height: 36,
        anchor: { x: 18, y: 36 },
        src: 'https://mapapi.qq.com/web/lbs/javascriptGL/demo/img/end.png'
      })
    },
    geometries: [{
      id: 'dest',
      styleId: 'dest',
      position: new TMap.LatLng(to.lat, to.lng)
    }]
  })

  if (collectorMarker) {
    collectorMarker.setGeometries([{
      id: 'collector',
      styleId: 'collector',
      position: new TMap.LatLng(from.lat, from.lng)
    }])
  }

  const km = haversine(from, to)
  distance.value = km.toFixed(2)
  duration.value = Math.max(1, Math.ceil(km / 30 * 60))

  try {
    const bounds = new TMap.LatLngBounds(
      new TMap.LatLng(Math.min(from.lat, to.lat), Math.min(from.lng, to.lng)),
      new TMap.LatLng(Math.max(from.lat, to.lat), Math.max(from.lng, to.lng))
    )
    map.fitBounds(bounds, { padding: 80 })
  } catch (e) { /* ignore */ }
}

const haversine = (a, b) => {
  const R = 6371
  const toRad = (d) => d * Math.PI / 180
  const dLat = toRad(b.lat - a.lat)
  const dLng = toRad(b.lng - a.lng)
  const s = Math.sin(dLat / 2) ** 2 +
    Math.cos(toRad(a.lat)) * Math.cos(toRad(b.lat)) * Math.sin(dLng / 2) ** 2
  return 2 * R * Math.asin(Math.sqrt(s))
}

const toggleSimulate = () => {
  if (simulating.value) stopSimulate()
  else startSimulate()
}

const startSimulate = () => {
  if (!routePath.length) {
    ElMessage.warning('请先规划路线')
    return
  }
  if (routeIndex >= routePath.length - 1) routeIndex = 0
  simulating.value = true
  simTimer = setInterval(() => {
    routeIndex++
    if (routeIndex >= routePath.length) {
      stopSimulate()
      ElMessage.success('已到达目的地')
      distance.value = '0.00'
      duration.value = 0
      return
    }
    const pos = routePath[routeIndex]
    if (collectorMarker) {
      collectorMarker.setGeometries([{
        id: 'collector',
        styleId: 'collector',
        position: new TMap.LatLng(pos.lat, pos.lng)
      }])
    }
    const dest = routePath[routePath.length - 1]
    const remain = haversine(pos, dest)
    distance.value = remain.toFixed(2)
    duration.value = Math.max(0, Math.ceil(remain / 30 * 60))
  }, 500)
}

const stopSimulate = () => {
  simulating.value = false
  if (simTimer) {
    clearInterval(simTimer)
    simTimer = null
  }
}

const cancelCurrent = () => {
  stopSimulate()
  currentOrder.value = null
  selectedOrderId.value = null
  if (destMarker) { destMarker.setMap(null); destMarker = null }
  if (polyline) { polyline.setMap(null); polyline = null }
  routePath = []
  routeIndex = 0
  distance.value = 0
  duration.value = 0
}

const startNavi = () => {
  const { addressLat, addressLng, addressDetail } = currentOrder.value
  const to = encodeURIComponent(addressDetail || '目的地')
  window.open(
    `https://apis.map.qq.com/uri/v1/routeplan?type=drive&to=${to}&tocoord=${addressLat},${addressLng}&referer=recycleSystem`,
    '_blank'
  )
}
</script>

<style scoped lang="scss">
.navigation-page {
  height: calc(100vh - 140px);
  position: relative;

  .map-container {
    width: 100%;
    height: 100%;
    background: #e4e7ed;
  }

  .top-status {
    position: absolute;
    top: 20px;
    left: 20px;
    right: 20px;
    background: rgba(255, 255, 255, 0.95);
    border-radius: 8px;
    padding: 12px 20px;
    display: flex;
    justify-content: space-around;
    box-shadow: 0 2px 12px rgba(0, 0, 0, 0.1);
    z-index: 10;

    .status-item {
      display: flex;
      flex-direction: column;
      align-items: center;
      gap: 4px;

      .label {
        font-size: 12px;
        color: #909399;
      }

      .value {
        font-size: 18px;
        font-weight: bold;
        color: #1890ff;
      }
    }
  }

  .route-panel,
  .order-selector {
    position: absolute;
    bottom: 20px;
    left: 20px;
    right: 20px;
    background: white;
    padding: 20px;
    border-radius: 8px;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.15);
    z-index: 10;

    h4 { margin-bottom: 15px; }

    .panel-header {
      display: flex;
      justify-content: space-between;
      align-items: center;

      h4 { margin-bottom: 0; }
    }

    .route-info {
      margin: 15px 0;

      p {
        margin: 5px 0;
        color: #606266;
      }
    }

    .panel-actions {
      display: flex;
      gap: 10px;

      .el-button { flex: 1; }
    }

    .empty-tip {
      text-align: center;
      color: #909399;
      padding: 20px 0;
      font-size: 13px;
    }
  }
}
</style>