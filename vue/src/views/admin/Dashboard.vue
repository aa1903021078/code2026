<template>
  <div class="dashboard">
    <!-- 数据概览 -->
    <div class="data-overview">
      <div class="data-card primary">
        <div class="icon"><el-icon><Document /></el-icon></div>
        <div class="content">
          <div class="number">{{ overview.totalOrders }}</div>
          <div class="label">总订单数</div>
        </div>
      </div>
      <div class="data-card success">
        <div class="icon"><el-icon><CircleCheck /></el-icon></div>
        <div class="content">
          <div class="number">{{ overview.completedOrders }}</div>
          <div class="label">已完成</div>
        </div>
      </div>
      <div class="data-card warning">
        <div class="icon"><el-icon><Timer /></el-icon></div>
        <div class="content">
          <!-- 待处理 = 待分配(0) + 待接单(1) + 已接单(2) + 已到达(3)，即所有未完成且未取消的订单 -->
          <div class="number">{{ (overview.pendingOrders || 0) + (overview.processingOrders || 0) }}</div>
          <div class="label">待处理</div>
        </div>
      </div>
      <div class="data-card info">
        <div class="icon"><el-icon><Weight /></el-icon></div>
        <div class="content">
          <div class="number">{{ overview.totalWeight }}<span>kg</span></div>
          <div class="label">回收重量</div>
        </div>
      </div>
    </div>

    <!-- 图表区域 -->
    <el-row :gutter="20" class="chart-row">
      <el-col :span="12">
        <el-card>
          <template #header>
            <span>📊 近7日订单趋势</span>
          </template>
          <div ref="orderChartRef" style="height: 300px;"></div>
        </el-card>
      </el-col>

      <el-col :span="12">
        <el-card>
          <template #header>
            <span>♻️ 品类回收占比</span>
          </template>
          <div ref="categoryChartRef" style="height: 300px;"></div>
        </el-card>
      </el-col>
    </el-row>

    <!-- 待办事项 -->
    <el-row :gutter="20" style="margin-top: 20px;">
      <el-col :span="12">
        <el-card>
          <template #header>
            <span>⏰ 待办事项</span>
          </template>
          <el-timeline>
            <el-timeline-item
                v-for="(item, index) in todos"
                :key="index"
                :type="item.type"
                :timestamp="item.time"
            >
              {{ item.content }}
            </el-timeline-item>
          </el-timeline>
        </el-card>
      </el-col>

      <el-col :span="12">
        <el-card>
          <template #header>
            <span>🌍 环保贡献</span>
          </template>
          <div class="eco-display">
            <div class="eco-item">
              <div class="value">{{ overview.totalCarbonSaved }}</div>
              <div class="label">减少碳排放(kg)</div>
            </div>
            <div class="eco-item">
              <div class="value">{{ treeCount }}</div>
              <div class="label">相当于种树(棵)</div>
            </div>
          </div>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted, onActivated, nextTick, computed } from 'vue'
import * as echarts from 'echarts'
import request from '@/utils/request'

const overview = ref({
  totalOrders: 0,
  completedOrders: 0,
  pendingOrders: 0,
  totalWeight: 0,
  totalCarbonSaved: 0
})

const todos = ref([])

const treeCount = computed(() => {
  return Math.floor((overview.value.totalCarbonSaved || 0) / 18)
})

// 定义 ref 绑定 DOM 元素
const orderChartRef = ref(null)
const categoryChartRef = ref(null)

// 存储图表实例以便销毁
let orderChartInstance = null
let categoryChartInstance = null

onMounted(async () => {
  await loadData()
  // 使用 nextTick 确保 DOM 完全渲染后再初始化图表
  nextTick(() => {
    initOrderChart()
    initCategoryChart()
  })
})

// 由于 AdminLayout 的 keep-alive 缓存了 Dashboard，切换菜单回来不会重新 mount
// 通过 onActivated 在每次激活时重新拉取数据并刷新图表（首次挂载由 onMounted 处理，这里只处理非首次激活）
let isFirstActivate = true
onActivated(async () => {
  if (isFirstActivate) {
    isFirstActivate = false
    return
  }
  await loadData()
  nextTick(() => {
    orderChartInstance?.dispose()
    categoryChartInstance?.dispose()
    orderChartInstance = null
    categoryChartInstance = null
    initOrderChart()
    initCategoryChart()
  })
})

onUnmounted(() => {
  // 组件卸载时销毁图表，防止内存泄漏
  if (orderChartInstance) {
    orderChartInstance.dispose()
  }
  if (categoryChartInstance) {
    categoryChartInstance.dispose()
  }
})

const dailyStats = ref([])
const applianceStats = ref([])

const loadData = async () => {
  try {
    const [ov, daily, appliance] = await Promise.all([
      request.get('/statistics/overview'),
      request.get('/statistics/dailyStats'),
      request.get('/statistics/applianceTypeStats')
    ])
    overview.value = ov || {}
    dailyStats.value = Array.isArray(daily) ? daily : []
    applianceStats.value = Array.isArray(appliance) ? appliance : []
    buildTodos()
  } catch (e) {
    console.error('加载数据失败:', e)
  }
}

const buildTodos = () => {
  const items = []
  if (overview.value.pendingOrders > 0) {
    items.push({ content: `有 ${overview.value.pendingOrders} 个订单待派单`, time: '刚刚', type: 'warning' })
  }
  if (overview.value.processingOrders > 0) {
    items.push({ content: `${overview.value.processingOrders} 个订单正在处理中`, time: '刚刚', type: 'primary' })
  }
  if (overview.value.completedOrders > 0) {
    items.push({ content: `累计已完成 ${overview.value.completedOrders} 个订单`, time: '统计', type: 'success' })
  }
  if (items.length === 0) {
    items.push({ content: '暂无待办事项', time: '刚刚', type: 'info' })
  }
  todos.value = items
}

const initOrderChart = () => {
  if (!orderChartRef.value) return
  orderChartInstance = echarts.init(orderChartRef.value)

  // 取最近7天（dailyStats 按日期升序返回）
  const recent = dailyStats.value.slice(-7)
  const xData = recent.map(d => String(d.statDate || '').slice(5))
  const yData = recent.map(d => d.totalOrders || 0)

  orderChartInstance.setOption({
    tooltip: { trigger: 'axis' },
    xAxis: {
      type: 'category',
      data: xData.length ? xData : ['暂无数据']
    },
    yAxis: { type: 'value' },
    series: [{
      data: yData.length ? yData : [0],
      type: 'line',
      smooth: true,
      areaStyle: {
        color: {
          type: 'linear',
          x: 0, y: 0, x2: 0, y2: 1,
          colorStops: [
            { offset: 0, color: 'rgba(82, 196, 26, 0.3)' },
            { offset: 1, color: 'rgba(82, 196, 26, 0.05)' }
          ]
        }
      },
      itemStyle: { color: '#52c41a' }
    }]
  })
}

const initCategoryChart = () => {
  if (!categoryChartRef.value) return
  categoryChartInstance = echarts.init(categoryChartRef.value)

  const colors = ['#5470c6', '#91cc75', '#fac858', '#ee6666', '#73c0de', '#3ba272', '#fc8452']
  const pieData = applianceStats.value.length > 0
      ? applianceStats.value.map((item, i) => ({
          value: Number(item.count) || 0,
          name: item.name || '未知',
          itemStyle: { color: colors[i % colors.length] }
        }))
      : [{ value: 1, name: '暂无数据', itemStyle: { color: '#dcdfe6' } }]

  categoryChartInstance.setOption({
    tooltip: { trigger: 'item' },
    legend: { bottom: '5%' },
    series: [{
      type: 'pie',
      radius: ['40%', '70%'],
      avoidLabelOverlap: false,
      itemStyle: {
        borderRadius: 10,
        borderColor: '#fff',
        borderWidth: 2
      },
      label: { show: false },
      data: pieData
    }]
  })
}
</script>

<style scoped lang="scss">
.dashboard {
  .data-overview {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: 20px;
    margin-bottom: 20px;

    .data-card {
      background: white;
      padding: 20px;
      border-radius: 8px;
      display: flex;
      align-items: center;
      box-shadow: 0 2px 12px rgba(0,0,0,0.05);

      &.primary { border-left: 4px solid #409eff; .icon { color: #409eff; } }
      &.success { border-left: 4px solid #67c23a; .icon { color: #67c23a; } }
      &.warning { border-left: 4px solid #e6a23c; .icon { color: #e6a23c; } }
      &.info { border-left: 4px solid #909399; .icon { color: #909399; } }

      .icon {
        font-size: 40px;
        margin-right: 15px;
      }

      .content {
        .number {
          font-size: 28px;
          font-weight: bold;
          color: #303133;

          span {
            font-size: 14px;
            margin-left: 5px;
          }
        }

        .label {
          color: #909399;
          margin-top: 5px;
        }
      }
    }
  }

  .eco-display {
    display: flex;
    justify-content: space-around;
    padding: 40px 0;

    .eco-item {
      text-align: center;

      .value {
        font-size: 48px;
        font-weight: bold;
        color: #52c41a;
      }

      .label {
        color: #666;
        margin-top: 10px;
      }
    }
  }
}
</style>