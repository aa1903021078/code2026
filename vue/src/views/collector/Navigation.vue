<template>
  <div class="navigation-page">
    <!-- 上方控制面板 -->
    <div class="control-panel">
      <!-- 已选择订单：显示导航状态 -->
      <template v-if="currentOrder">
        <div class="panel-header">
          <h4>🚚 当前订单导航</h4>
          <el-button link type="primary" @click="cancelCurrent">切换订单</el-button>
        </div>
        <div class="status-row">
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
        <div class="route-info">
          <p><strong>订单号：</strong>{{ currentOrder.orderNo }}</p>
          <p><strong>品类：</strong>{{ currentOrder.applianceTypeName }}</p>
          <p><strong>目的地：</strong>{{ currentOrder.addressDetail }}</p>
          <p><strong>联系人：</strong>{{ currentOrder.contactName }} {{ currentOrder.contactPhone }}</p>
        </div>
        <div class="panel-actions">
          <el-button :type="simulating ? 'warning' : 'success'" @click="toggleSimulate">
            {{ simulating ? '暂停导航' : '开始导航' }}
          </el-button>
          <el-button type="primary" @click="startNavi">外部导航</el-button>
          <el-button @click="relocate">
            <el-icon><Aim /></el-icon> 重新定位
          </el-button>
        </div>
      </template>

      <!-- 未选择订单：显示订单选择器 -->
      <template v-else>
        <div class="selector-header">
          <h4>🗺️ 选择订单开始导航</h4>
          <el-button link type="primary" :loading="loading" @click="loadActiveOrders">
            <el-icon><Refresh /></el-icon> 刷新
          </el-button>
        </div>
        <div class="selector-row">
          <el-select
            v-model="selectedOrderId"
            placeholder="选择进行中的订单"
            class="order-select"
            :disabled="activeOrders.length === 0"
          >
            <el-option
              v-for="order in activeOrders"
              :key="order.id"
              :label="`[${statusText(order.status)}] ${order.applianceTypeName} - ${order.addressDetail}`"
              :value="order.id"
            />
          </el-select>
          <el-button
            type="primary"
            @click="loadRoute"
            :disabled="activeOrders.length === 0"
          >
            规划路线
          </el-button>
        </div>
        <div v-if="activeOrders.length === 0" class="empty-tip">
          暂无进行中的订单（需先在"订单中心"点击<strong>"接单"</strong>，订单状态变为"已接单"后才能导航）
        </div>
      </template>
    </div>

    <!-- 下方地图区域 -->
    <div class="map-container" ref="mapContainer"></div>
  </div>
</template>

<script setup>
import { ref, onMounted, onActivated, onUnmounted, nextTick } from 'vue'
import { ElMessage } from 'element-plus'
import { Refresh, Aim } from '@element-plus/icons-vue'
import request from '@/utils/request'

const mapContainer = ref(null)
const currentOrder = ref(null)
const activeOrders = ref([])
const selectedOrderId = ref(null)
const distance = ref(0)
const duration = ref(0)
const simulating = ref(false)
const loading = ref(false)

const user = JSON.parse(localStorage.getItem('user') || '{}')

// 回收员当前位置（起点）。初始给一个默认值，onMounted 后通过定位更新。
const collectorPos = { lat: 39.9042, lng: 116.4074 }
const TENCENT_KEY = 'CXPBZ-EML6W-PKURO-3MD5P-PRNFE-FPBD3'

let map = null
let collectorMarker = null
let destMarker = null
let passedLine = null      // 已走过（灰色虚线）
let remainLine = null      // 未走过（蓝色实线）
let routePath = []
let routeIndex = 0
let totalKm = 0            // 全程距离（km），用于计算剩余
let animationFrame = null
let lastStepTime = 0

onMounted(() => {
  nextTick(() => {
    initMap()
    // 初始化后立即定位
    locateCollector(true)
  })
  loadActiveOrders()
})

// keep-alive 场景下，每次切回页面都重新拉最新订单
onActivated(() => {
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
  const center = new TMap.LatLng(collectorPos.lat, collectorPos.lng)
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

// 浏览器定位 + IP 定位兜底（和 AddressForm 一致）
const locateCollector = (silent = false) => {
  if (!silent) ElMessage.info('正在定位...')
  if (navigator.geolocation) {
    navigator.geolocation.getCurrentPosition(
      (pos) => {
        updateCollectorPos(pos.coords.latitude, pos.coords.longitude, silent ? '' : '定位成功')
      },
      () => ipLocate(silent),
      { enableHighAccuracy: true, timeout: 5000 }
    )
  } else {
    ipLocate(silent)
  }
}

const ipLocate = (silent) => {
  const callbackName = '_qqmap_ip_cb_' + Date.now()
  const script = document.createElement('script')
  window[callbackName] = (res) => {
    delete window[callbackName]
    try { document.head.removeChild(script) } catch (e) { /* ignore */ }
    if (res && res.status === 0 && res.result) {
      const loc = res.result.location
      const city = res.result.ad_info?.city || '当前位置'
      updateCollectorPos(loc.lat, loc.lng, silent ? '' : '已定位到 ' + city)
    } else if (!silent) {
      ElMessage.warning('定位失败，使用默认位置')
    }
  }
  script.src = `https://apis.map.qq.com/ws/location/v1/ip?key=${TENCENT_KEY}&output=jsonp&callback=${callbackName}`
  document.head.appendChild(script)
}

const updateCollectorPos = (lat, lng, successMsg) => {
  collectorPos.lat = lat
  collectorPos.lng = lng
  if (!map || !collectorMarker) return
  const latLng = new TMap.LatLng(lat, lng)
  collectorMarker.setGeometries([{
    id: 'collector',
    styleId: 'collector',
    position: latLng
  }])
  // 仅在没有进行中的导航时把地图中心移到当前位置
  if (!currentOrder.value) {
    map.setCenter(latLng)
    map.setZoom(15)
  }
  if (successMsg) ElMessage.success(successMsg)
}

const relocate = () => {
  if (simulating.value) {
    ElMessage.warning('请先暂停导航')
    return
  }
  locateCollector(false)
}

const loadActiveOrders = async () => {
  if (!user.id) {
    ElMessage.warning('未获取到登录信息，请重新登录')
    return
  }
  loading.value = true
  try {
    const res = await request.get(`/recycleOrder/selectByCollector/${user.id}`)
    console.log('[Navigation] selectByCollector 返回:', res)
    // 后端异常时拦截器返回 Result 对象（非数组），这里做防御式处理
    let list = []
    if (Array.isArray(res)) {
      list = res
    } else if (res && Array.isArray(res.data)) {
      list = res.data
    } else if (res && res.code && res.code !== '200' && res.code !== 200) {
      throw new Error(res.msg || '加载订单失败')
    }
    // 仅"已接单(2)"和"已到达(3)"需要导航
    activeOrders.value = list.filter(o => o.status === 2 || o.status === 3)
    console.log('[Navigation] 进行中订单数量:', activeOrders.value.length,
        '全部状态分布:', list.map(o => ({ id: o.id, status: o.status })))
  } catch (e) {
    console.error('加载订单失败', e)
    activeOrders.value = []
    ElMessage.warning(e?.message || '加载订单失败，请检查网络或重新登录')
  } finally {
    loading.value = false
  }
}

const statusText = (status) => {
  const map = { 2: '已接单', 3: '已到达' }
  return map[status] || '未知'
}

const loadRoute = () => {
  const order = activeOrders.value.find(o => o.id === selectedOrderId.value)
  if (!order) {
    ElMessage.warning('请选择订单')
    return
  }
  // 若订单无坐标，使用当前位置附近的随机点模拟
  const destLat = Number(order.addressLat) || (collectorPos.lat + (Math.random() - 0.5) * 0.05)
  const destLng = Number(order.addressLng) || (collectorPos.lng + (Math.random() - 0.5) * 0.05)

  currentOrder.value = { ...order, addressLat: destLat, addressLng: destLng }
  nextTick(() => {
    try { map && map.resize() } catch (e) { /* ignore */ }
    drawRoute({ lat: collectorPos.lat, lng: collectorPos.lng }, { lat: destLat, lng: destLng })
  })
}

const drawRoute = async (from, to) => {
  if (!map) return

  if (destMarker) { destMarker.setMap(null); destMarker = null }
  if (passedLine) { passedLine.setMap(null); passedLine = null }
  if (remainLine) { remainLine.setMap(null); remainLine = null }

  // 先画终点标记，避免获取真实路径时长时间无反馈
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

  // 获取真实驾车路径：SDK → WebService → 直线兜底
  let pathResult
  try {
    pathResult = await fetchDrivingRoute(from, to)
    console.log('[Navigation] 路线规划成功，点数:', pathResult.path.length,
        '距离(m):', pathResult.distance, '时长(s):', pathResult.duration)
  } catch (e) {
    console.warn('[Navigation] 路径规划失败，使用直线兜底。原因：', e?.message || e)
    pathResult = null
  }

  if (pathResult && pathResult.path.length > 1) {
    routePath = pathResult.path
    totalKm = pathResult.distance / 1000
    duration.value = Math.max(1, Math.round(pathResult.duration / 60))
  } else {
    // 兜底：直线插值
    const STEPS = 200
    routePath = []
    for (let i = 0; i <= STEPS; i++) {
      const t = i / STEPS
      const jitter = i > 0 && i < STEPS ? (Math.random() - 0.5) * 0.0008 : 0
      routePath.push({
        lat: from.lat + (to.lat - from.lat) * t + jitter,
        lng: from.lng + (to.lng - from.lng) * t + jitter
      })
    }
    totalKm = haversine(from, to)
    duration.value = Math.max(1, Math.ceil(totalKm / 30 * 60))
    ElMessage.warning('未获取到真实路径，使用直线模拟')
  }
  routeIndex = 0
  distance.value = totalKm.toFixed(2)

  // 动态调整步长：让整段动画约 20 秒完成，每步 30~150ms
  stepInterval = Math.max(30, Math.min(150, Math.round(20000 / routePath.length)))

  const allLatLng = routePath.map(p => new TMap.LatLng(p.lat, p.lng))

  // 未走过路径（蓝色实线）
  remainLine = new TMap.MultiPolyline({
    map,
    styles: {
      remain: new TMap.PolylineStyle({
        color: '#1890ff',
        width: 7,
        borderWidth: 2,
        borderColor: '#ffffff',
        lineCap: 'round'
      })
    },
    geometries: [{ id: 'remain', styleId: 'remain', paths: allLatLng }]
  })

  // 已走过路径（灰色实线），初始空
  passedLine = new TMap.MultiPolyline({
    map,
    styles: {
      passed: new TMap.PolylineStyle({
        color: '#8c8c8c',
        width: 6,
        borderWidth: 1,
        borderColor: '#ffffff',
        lineCap: 'round',
        showArrow: false
      })
    },
    geometries: [{ id: 'passed', styleId: 'passed', paths: [] }]
  })

  if (collectorMarker) {
    collectorMarker.setGeometries([{
      id: 'collector',
      styleId: 'collector',
      position: new TMap.LatLng(from.lat, from.lng)
    }])
  }

  // 用真实路径包围盒做自适应缩放
  try {
    let minLat = Infinity, maxLat = -Infinity, minLng = Infinity, maxLng = -Infinity
    for (const p of routePath) {
      if (p.lat < minLat) minLat = p.lat
      if (p.lat > maxLat) maxLat = p.lat
      if (p.lng < minLng) minLng = p.lng
      if (p.lng > maxLng) maxLng = p.lng
    }
    const bounds = new TMap.LatLngBounds(
      new TMap.LatLng(minLat, minLng),
      new TMap.LatLng(maxLat, maxLng)
    )
    map.fitBounds(bounds, { padding: 80 })
  } catch (e) { /* ignore */ }
}

// 方案 B：优先用 TMap.service.Direction SDK；失败回退方案 A：WebService JSONP
const fetchDrivingRoute = (from, to) => {
  return new Promise((resolve, reject) => {
    // —— 方案 B：SDK ——
    const hasSdk = !!(window.TMap && TMap.service && TMap.service.Direction)
    console.log('[Navigation] TMap.service.Direction 可用:', hasSdk)
    if (hasSdk) {
      try {
        const direction = new TMap.service.Direction({ mode: 'driving' })
        direction.search({
          from: new TMap.LatLng(from.lat, from.lng),
          to: new TMap.LatLng(to.lat, to.lng)
        }).then((res) => {
          console.log('[Navigation] 方案B SDK 返回:', res)
          const route = res?.result?.routes?.[0]
          if (!route || !Array.isArray(route.polyline) || route.polyline.length === 0) {
            console.warn('[Navigation] 方案B 无有效路径，回退方案A')
            return fetchDrivingRouteWS(from, to).then(resolve, reject)
          }
          const path = route.polyline.map(p => ({
            lat: p.lat ?? p.getLat?.(),
            lng: p.lng ?? p.getLng?.()
          }))
          resolve({
            path,
            distance: route.distance || 0,
            duration: route.duration || 0
          })
        }).catch((err) => {
          console.warn('[Navigation] 方案B 异常，回退方案A：', err?.message || err)
          fetchDrivingRouteWS(from, to).then(resolve, reject)
        })
        return
      } catch (e) {
        console.warn('[Navigation] 方案B 调用抛错，回退方案A：', e)
      }
    }
    // —— 方案 A：WebService JSONP ——
    fetchDrivingRouteWS(from, to).then(resolve, reject)
  })
}

// 方案 A：腾讯 WebService 驾车路线 JSONP
const fetchDrivingRouteWS = (from, to) => {
  return new Promise((resolve, reject) => {
    const cbName = '_qqmap_dir_cb_' + Date.now() + '_' + Math.floor(Math.random() * 1000)
    const script = document.createElement('script')
    const timer = setTimeout(() => {
      try { delete window[cbName] } catch (e) { /* ignore */ }
      try { document.head.removeChild(script) } catch (e) { /* ignore */ }
      reject(new Error('路线规划超时'))
    }, 8000)

    window[cbName] = (res) => {
      clearTimeout(timer)
      try { delete window[cbName] } catch (e) { /* ignore */ }
      try { document.head.removeChild(script) } catch (e) { /* ignore */ }
      console.log('[Navigation] 方案A WebService 返回:', res)
      if (res?.status !== 0 || !res.result?.routes?.[0]) {
        // status != 0 时 message 里通常是原因，例如：
        //   "此key每日调用量已达到上限" / "此key没有使用WebServiceAPI的权限" / "referer校验失败"
        reject(new Error(`[status=${res?.status}] ${res?.message || '无路线结果'}`))
        return
      }
      const route = res.result.routes[0]
      // 解压压缩的 polyline：前两项是绝对 lat,lng；之后每一项 = 上上项 + 当前值/1e6
      const raw = route.polyline
      const kr = 1000000
      const coors = raw.map(Number) // 确保都是数字
      for (let i = 2; i < coors.length; i++) {
        coors[i] = Number((coors[i - 2] + coors[i] / kr).toFixed(6))
      }
      const path = []
      for (let i = 0; i + 1 < coors.length; i += 2) {
        const lat = coors[i]
        const lng = coors[i + 1]
        // 过滤 NaN / 越界 / 0,0（明显无效）
        if (Number.isFinite(lat) && Number.isFinite(lng)
            && lat >= -90 && lat <= 90 && lng >= -180 && lng <= 180
            && !(lat === 0 && lng === 0)) {
          path.push({ lat, lng })
        }
      }
      console.log('[Navigation] 解压后路径点前3个:', path.slice(0, 3),
          '总点数:', path.length, '原始:', raw.length)
      if (path.length < 2) {
        reject(new Error('路径解压后有效点不足'))
        return
      }
      resolve({
        path,
        distance: route.distance || 0,
        duration: (route.duration || 0) * 60 // WebService 的 duration 是分钟，转成秒
      })
    }

    script.onerror = () => {
      clearTimeout(timer)
      try { delete window[cbName] } catch (e) { /* ignore */ }
      reject(new Error('路线请求失败'))
    }
    script.src = `https://apis.map.qq.com/ws/direction/v1/driving/?from=${from.lat},${from.lng}&to=${to.lat},${to.lng}&key=${TENCENT_KEY}&output=jsonp&callback=${cbName}`
    document.head.appendChild(script)
  })
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

// 使用 requestAnimationFrame 做平滑动画，步长在 drawRoute 里根据路径点数动态设置
let stepInterval = 80
const startSimulate = () => {
  if (!routePath.length) {
    ElMessage.warning('请先规划路线')
    return
  }
  if (routeIndex >= routePath.length - 1) routeIndex = 0
  simulating.value = true
  lastStepTime = performance.now()
  const tick = (now) => {
    if (!simulating.value) return
    if (now - lastStepTime >= stepInterval) {
      lastStepTime = now
      routeIndex++
      if (routeIndex >= routePath.length) {
        stopSimulate()
        ElMessage.success('🎉 已到达目的地')
        distance.value = '0.00'
        duration.value = 0
        return
      }
      advanceTo(routeIndex)
    }
    animationFrame = requestAnimationFrame(tick)
  }
  animationFrame = requestAnimationFrame(tick)
}

// 推进到指定索引：更新 marker、分色路径、距离/时间、跟随视角
const advanceTo = (idx) => {
  const pos = routePath[idx]
  if (collectorMarker) {
    collectorMarker.setGeometries([{
      id: 'collector',
      styleId: 'collector',
      position: new TMap.LatLng(pos.lat, pos.lng)
    }])
  }
  // 更新已走/未走路径
  if (passedLine) {
    passedLine.setGeometries([{
      id: 'passed',
      styleId: 'passed',
      paths: routePath.slice(0, idx + 1).map(p => new TMap.LatLng(p.lat, p.lng))
    }])
  }
  if (remainLine) {
    remainLine.setGeometries([{
      id: 'remain',
      styleId: 'remain',
      paths: routePath.slice(idx).map(p => new TMap.LatLng(p.lat, p.lng))
    }])
  }
  // 剩余距离/时间
  const dest = routePath[routePath.length - 1]
  const remain = haversine(pos, dest)
  distance.value = remain.toFixed(2)
  duration.value = Math.max(0, Math.ceil(remain / 30 * 60))

  // 每 10 步跟随一次视角，避免频繁移动造成抖动
  if (map && idx % 10 === 0) {
    try { map.setCenter(new TMap.LatLng(pos.lat, pos.lng)) } catch (e) { /* ignore */ }
  }
}

const stopSimulate = () => {
  simulating.value = false
  if (animationFrame) {
    cancelAnimationFrame(animationFrame)
    animationFrame = null
  }
}

const cancelCurrent = () => {
  stopSimulate()
  currentOrder.value = null
  selectedOrderId.value = null
  if (destMarker) { destMarker.setMap(null); destMarker = null }
  if (passedLine) { passedLine.setMap(null); passedLine = null }
  if (remainLine) { remainLine.setMap(null); remainLine = null }
  routePath = []
  routeIndex = 0
  totalKm = 0
  distance.value = 0
  duration.value = 0
  // 切回选择态时，把视角拉回当前位置
  if (map) {
    try {
      map.setCenter(new TMap.LatLng(collectorPos.lat, collectorPos.lng))
      map.setZoom(15)
    } catch (e) { /* ignore */ }
  }
  nextTick(() => {
    try { map && map.resize() } catch (e) { /* ignore */ }
  })
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
  display: flex;
  flex-direction: column;
  gap: 12px;

  .control-panel {
    flex-shrink: 0;
    background: white;
    padding: 16px 20px;
    border-radius: 8px;
    box-shadow: 0 2px 12px rgba(0, 0, 0, 0.08);

    h4 { margin: 0; }

    .selector-header,
    .panel-header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 12px;
    }

    .selector-row {
      display: flex;
      gap: 12px;
      align-items: center;

      .order-select {
        flex: 1;
      }
    }

    .status-row {
      display: flex;
      gap: 40px;
      margin-bottom: 12px;
      padding: 10px 16px;
      background: #f5f7fa;
      border-radius: 6px;

      .status-item {
        display: flex;
        align-items: center;
        gap: 8px;

        .label {
          font-size: 12px;
          color: #909399;
        }

        .value {
          font-size: 16px;
          font-weight: bold;
          color: #1890ff;
        }
      }
    }

    .route-info {
      margin-bottom: 12px;

      p {
        margin: 4px 0;
        color: #606266;
        font-size: 13px;
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
      padding: 12px 0 0;
      font-size: 13px;
    }
  }

  .map-container {
    flex: 1;
    min-height: 300px;
    width: 100%;
    background: #e4e7ed;
    border-radius: 8px;
    overflow: hidden;
  }
}
</style>