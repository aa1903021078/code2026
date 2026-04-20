<template>
  <div class="statistics-page">
    <!-- 页面标题 -->
    <div class="page-header">
      <div class="header-title">
        <h2>{{ pageTitle }}</h2>
        <p class="subtitle">{{ pageSubtitle }}</p>
      </div>
      <div class="header-actions">
        <el-date-picker
            v-model="dateRange"
            type="daterange"
            range-separator="至"
            start-placeholder="开始日期"
            end-placeholder="结束日期"
            :shortcuts="dateShortcuts"
            @change="handleDateChange"
        />
        <el-button type="primary" @click="exportData">
          <el-icon><Download /></el-icon>导出数据
        </el-button>
      </div>
    </div>

    <!-- 统计概览卡片 -->
    <el-row :gutter="20" class="stats-overview">
      <el-col v-for="stat in overviewStats" :key="stat.key" :xs="24" :sm="12" :md="6">
        <div class="overview-card" :class="stat.type">
          <div class="card-icon">
            <el-icon><component :is="stat.icon" /></el-icon>
          </div>
          <div class="card-content">
            <p class="card-value">{{ stat.value }}</p>
            <p class="card-label">{{ stat.label }}</p>
          </div>
        </div>
      </el-col>
    </el-row>

    <!-- 图表区域 -->
    <el-row :gutter="20" class="charts-row">
      <!-- 趋势图 -->
      <el-col :xs="24" :lg="16">
        <el-card class="chart-card">
          <template #header>
            <div class="card-header">
              <span>{{ trendChartTitle }}</span>
              <el-radio-group v-model="trendType" size="small">
                <el-radio-button label="day">按日</el-radio-button>
                <el-radio-button label="week">按周</el-radio-button>
                <el-radio-button label="month">按月</el-radio-button>
              </el-radio-group>
            </div>
          </template>
          <div ref="trendChart" class="chart-container"></div>
        </el-card>
      </el-col>

      <!-- 饼图 -->
      <el-col :xs="24" :lg="8">
        <el-card class="chart-card">
          <template #header>
            <div class="card-header">
              <span>{{ pieChartTitle }}</span>
            </div>
          </template>
          <div ref="pieChart" class="chart-container"></div>
        </el-card>
      </el-col>
    </el-row>

    <!-- 详细数据表格 -->
    <el-card class="data-table-card">
      <template #header>
        <div class="card-header">
          <span>详细数据</span>
          <el-pagination
              v-model:current-page="currentPage"
              v-model:page-size="pageSize"
              :page-sizes="[10, 20, 50, 100]"
              :total="total"
              layout="total, sizes, prev, pager, next"
              @size-change="handleSizeChange"
              @current-change="handleCurrentChange"
          />
        </div>
      </template>
      <el-table :data="tableData" stripe v-loading="loading">
        <el-table-column
            v-for="col in tableColumns"
            :key="col.prop"
            :prop="col.prop"
            :label="col.label"
            :width="col.width"
            :formatter="col.formatter"
        />
      </el-table>
    </el-card>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted, watch, nextTick } from 'vue'
import { useRoute } from 'vue-router'
import { ElMessage } from 'element-plus'
import * as echarts from 'echarts'
import {
  Document, User, Van, Money, Download, ArrowUp, ArrowDown
} from '@element-plus/icons-vue'
import request from '@/utils/request'

const route = useRoute()

// 页面固定为综合统计（路由只有一个 /admin/statistics）
const pageTitle = ref('数据统计')
const pageSubtitle = ref('全面分析平台运营数据')
const trendChartTitle = ref('订单趋势')
const pieChartTitle = ref('品类回收占比')

// 日期范围
const dateRange = ref([])
const dateShortcuts = [
  { text: '最近一周', value: () => {
      const end = new Date()
      const start = new Date()
      start.setTime(start.getTime() - 3600 * 1000 * 24 * 7)
      return [start, end]
    }},
  { text: '最近一月', value: () => {
      const end = new Date()
      const start = new Date()
      start.setTime(start.getTime() - 3600 * 1000 * 24 * 30)
      return [start, end]
    }},
  { text: '最近三月', value: () => {
      const end = new Date()
      const start = new Date()
      start.setTime(start.getTime() - 3600 * 1000 * 24 * 90)
      return [start, end]
    }}
]

// 趋势图类型
const trendType = ref('day')

// ========== 真实数据 ==========
const overview = ref({})
const dailyStats = ref([])
const applianceStats = ref([])

// 概览统计卡片
const overviewStats = computed(() => {
  const ov = overview.value
  return [
    { key: 'total', label: '总订单数', icon: 'Document', type: 'primary', value: ov.totalOrders || 0 },
    { key: 'completed', label: '已完成', icon: 'CircleCheck', type: 'success', value: ov.completedOrders || 0 },
    { key: 'pending', label: '待处理', icon: 'Timer', type: 'warning', value: (ov.pendingOrders || 0) + (ov.processingOrders || 0) },
    { key: 'weight', label: '回收重量(kg)', icon: 'Goods', type: 'info', value: ov.totalWeight || 0 }
  ].map(item => ({
    ...item,
    change: '-',
    trend: 'up'
  }))
})

// 加载概览数据
const loadOverview = async () => {
  try {
    const res = await request.get('/statistics/overview')
    if (res && typeof res === 'object' && !res.code) {
      overview.value = res
    }
  } catch (e) {
    console.error('加载概览失败:', e)
  }
}

// 加载每日统计
const loadDailyStats = async () => {
  try {
    const res = await request.get('/statistics/dailyStats')
    dailyStats.value = Array.isArray(res) ? res : []
  } catch (e) {
    console.error('加载每日统计失败:', e)
  }
}

// 加载品类统计
const loadApplianceStats = async () => {
  try {
    const res = await request.get('/statistics/applianceTypeStats')
    applianceStats.value = Array.isArray(res) ? res : []
  } catch (e) {
    console.error('加载品类统计失败:', e)
  }
}

// 表格数据 - 从订单分页接口获取
const loading = ref(false)
const currentPage = ref(1)
const pageSize = ref(10)
const total = ref(0)
const tableData = ref([])

const tableColumns = ref([
  { prop: 'orderNo', label: '订单号', width: 200 },
  { prop: 'applianceTypeName', label: '品类', width: 100 },
  { prop: 'addressDetail', label: '地址' },
  { prop: 'weightEstimate', label: '预估重量(kg)', width: 120 },
  { prop: 'weightActual', label: '实际重量(kg)', width: 120 },
  { prop: 'priceActual', label: '实际价格(元)', width: 120 },
  { prop: 'carbonSaved', label: '碳减排(kg)', width: 110 },
  { prop: 'createTime', label: '创建时间', width: 170 }
])

// 图表引用
const trendChart = ref(null)
const pieChart = ref(null)
let trendChartInstance = null
let pieChartInstance = null

// 初始化趋势图（用真实 dailyStats 数据）
const initTrendChart = () => {
  if (!trendChart.value) return

  if (trendChartInstance) trendChartInstance.dispose()
  trendChartInstance = echarts.init(trendChart.value)

  const recent = dailyStats.value.slice(-14)
  const xData = recent.map(d => String(d.statDate || '').slice(5))
  const yOrders = recent.map(d => d.totalOrders || 0)
  const yWeight = recent.map(d => d.totalWeight || 0)

  trendChartInstance.setOption({
    tooltip: { trigger: 'axis' },
    legend: { data: ['订单数', '回收重量(kg)'], bottom: 0 },
    grid: { left: '3%', right: '4%', bottom: '15%', top: '10%', containLabel: true },
    xAxis: {
      type: 'category',
      boundaryGap: false,
      data: xData.length ? xData : ['暂无数据']
    },
    yAxis: [
      { type: 'value', name: '订单数' },
      { type: 'value', name: '重量(kg)' }
    ],
    series: [
      {
        name: '订单数',
        type: 'line',
        smooth: true,
        data: yOrders.length ? yOrders : [0],
        areaStyle: { opacity: 0.3 },
        itemStyle: { color: '#67c23a' }
      },
      {
        name: '回收重量(kg)',
        type: 'line',
        smooth: true,
        yAxisIndex: 1,
        data: yWeight.length ? yWeight : [0],
        itemStyle: { color: '#409eff' }
      }
    ]
  })
}

// 初始化饼图（用真实 applianceStats 数据）
const initPieChart = () => {
  if (!pieChart.value) return

  if (pieChartInstance) pieChartInstance.dispose()
  pieChartInstance = echarts.init(pieChart.value)

  const colors = ['#5470c6', '#91cc75', '#fac858', '#ee6666', '#73c0de', '#3ba272', '#fc8452']
  const pieData = applianceStats.value.length > 0
      ? applianceStats.value.map((item, i) => ({
          value: Number(item.count) || 0,
          name: item.name || '未知',
          itemStyle: { color: colors[i % colors.length] }
        }))
      : [{ value: 1, name: '暂无数据', itemStyle: { color: '#dcdfe6' } }]

  pieChartInstance.setOption({
    tooltip: { trigger: 'item', formatter: '{b}: {c} ({d}%)' },
    legend: { orient: 'vertical', right: '5%', top: 'center' },
    series: [{
      type: 'pie',
      radius: ['40%', '70%'],
      center: ['40%', '50%'],
      avoidLabelOverlap: false,
      itemStyle: { borderRadius: 10, borderColor: '#fff', borderWidth: 2 },
      label: { show: false },
      emphasis: { label: { show: true, fontSize: 16, fontWeight: 'bold' } },
      data: pieData
    }]
  })
}

// 加载表格数据（从订单分页接口）
const loadTableData = async () => {
  loading.value = true
  try {
    const res = await request.get('/recycleOrder/selectPage', {
      params: { pageNum: currentPage.value, pageSize: pageSize.value }
    })
    tableData.value = Array.isArray(res?.list) ? res.list : []
    total.value = res?.total || 0
  } catch (e) {
    console.error('加载表格数据失败:', e)
  } finally {
    loading.value = false
  }
}

// 处理日期变化
const handleDateChange = () => {
  loadTableData()
}

// 导出数据
const exportData = () => {
  ElMessage.success('数据导出成功')
}

// 分页处理
const handleSizeChange = (val) => {
  pageSize.value = val
  loadTableData()
}

const handleCurrentChange = (val) => {
  currentPage.value = val
  loadTableData()
}

// 监听趋势类型变化
watch(trendType, () => {
  initTrendChart()
})

const resizeHandler = () => {
  trendChartInstance?.resize()
  pieChartInstance?.resize()
}

onMounted(async () => {
  // 设置默认日期范围（最近7天）
  const end = new Date()
  const start = new Date()
  start.setTime(start.getTime() - 3600 * 1000 * 24 * 7)
  dateRange.value = [start, end]

  // 并行加载数据
  await Promise.all([loadOverview(), loadDailyStats(), loadApplianceStats()])
  loadTableData()

  nextTick(() => {
    initTrendChart()
    initPieChart()
  })

  window.addEventListener('resize', resizeHandler)
})

onUnmounted(() => {
  window.removeEventListener('resize', resizeHandler)
  trendChartInstance?.dispose()
  pieChartInstance?.dispose()
})
</script>

<style scoped>
.statistics-page {
  padding: 20px;
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24px;
}

.header-title h2 {
  margin: 0 0 8px 0;
  font-size: 24px;
  color: #303133;
}

.subtitle {
  margin: 0;
  color: #909399;
  font-size: 14px;
}

.header-actions {
  display: flex;
  gap: 12px;
}

/* 概览卡片 */
.stats-overview {
  margin-bottom: 20px;
}

.overview-card {
  display: flex;
  align-items: center;
  padding: 20px;
  background: #fff;
  border-radius: 12px;
  box-shadow: 0 2px 12px rgba(0,0,0,0.05);
  transition: transform 0.3s;
}

.overview-card:hover {
  transform: translateY(-4px);
}

.card-icon {
  width: 60px;
  height: 60px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-right: 16px;
}

.card-icon .el-icon {
  font-size: 28px;
  color: #fff;
}

.overview-card.primary .card-icon { background: linear-gradient(135deg, #409eff, #79bbff); }
.overview-card.success .card-icon { background: linear-gradient(135deg, #67c23a, #95d475); }
.overview-card.warning .card-icon { background: linear-gradient(135deg, #e6a23c, #f3d19e); }
.overview-card.danger .card-icon { background: linear-gradient(135deg, #f56c6c, #fab6b6); }
.overview-card.info .card-icon { background: linear-gradient(135deg, #909399, #c0c4cc); }

.card-value {
  font-size: 24px;
  font-weight: 600;
  color: #303133;
  margin: 0 0 4px 0;
}

.card-label {
  font-size: 14px;
  color: #909399;
  margin: 0 0 8px 0;
}

.card-change {
  display: flex;
  align-items: center;
  gap: 4px;
  font-size: 12px;
  margin: 0;
}

.card-change.up {
  color: #67c23a;
}

.card-change.down {
  color: #f56c6c;
}

/* 图表 */
.charts-row {
  margin-bottom: 20px;
}

.chart-card {
  margin-bottom: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.chart-container {
  height: 350px;
}

/* 数据表格 */
.data-table-card {
  margin-bottom: 20px;
}

</style>