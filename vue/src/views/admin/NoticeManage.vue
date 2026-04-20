<template>
  <div class="notice-manage">
    <!-- 搜索区域 -->
    <div class="search-section">
      <div class="search-box">
        <i class="el-icon-search"></i>
        <input
            v-model="searchKeyword"
            placeholder="搜索公告标题"
            @keyup.enter="handleSearch"
        />
        <el-button type="primary" @click="handleSearch">搜索</el-button>
      </div>
      <el-select v-model="searchType" placeholder="公告类型" clearable style="width: 140px" @change="handleSearch">
        <el-option label="活动通知" :value="1" />
        <el-option label="政策解读" :value="2" />
        <el-option label="环保知识" :value="3" />
        <el-option label="系统公告" :value="4" />
      </el-select>
      <el-button type="text" icon="el-icon-refresh" @click="resetSearch">重置</el-button>
    </div>

    <!-- 数据表格 -->
    <div class="table-container">
      <div class="table-header">
        <span>公告列表</span>
        <div class="table-header-right">
          <span class="total">共 {{ total }} 条</span>
          <el-button type="primary" @click="showAdd = true">+ 发布公告</el-button>
        </div>
      </div>

      <el-table
          :data="noticeList"
          v-loading="loading"
          stripe
          style="width: 100%"
          border
      >
        <el-table-column type="index" label="#" width="50" align="center" />

        <el-table-column prop="title" label="标题" min-width="200" show-overflow-tooltip />

        <el-table-column prop="type" label="类型" width="100" align="center">
          <template #default="{ row }">
            <el-tag :type="typeColor(row.type)" size="small">{{ typeText(row.type) }}</el-tag>
          </template>
        </el-table-column>

        <el-table-column prop="isTop" label="置顶" width="80" align="center">
          <template #default="{ row }">
            <el-tag v-if="row.isTop === 1" type="danger" size="small">置顶</el-tag>
            <span v-else class="text-muted">-</span>
          </template>
        </el-table-column>

        <el-table-column prop="viewCount" label="阅读量" width="100" align="center">
          <template #default="{ row }">
            <span class="view-count">{{ row.viewCount || 0 }}</span>
          </template>
        </el-table-column>

        <el-table-column prop="publishTime" label="发布时间" width="180" align="center" />

        <el-table-column label="状态" width="100" align="center">
          <template #default="{ row }">
            <el-switch
                v-model="row.status"
                :active-value="1"
                :inactive-value="0"
                active-color="#67c23a"
                inactive-color="#f56c6c"
                @change="updateStatus(row)"
            />
          </template>
        </el-table-column>

        <el-table-column label="操作" width="220" align="center" fixed="right">
          <template #default="{ row }">
            <div class="action-buttons">
              <el-button type="primary" link @click="edit(row)">编辑</el-button>
              <el-button type="warning" link @click="toggleTop(row)">
                {{ row.isTop === 1 ? '取消置顶' : '置顶' }}
              </el-button>
              <el-button type="danger" link @click="remove(row)">删除</el-button>
            </div>
          </template>
        </el-table-column>
      </el-table>

      <el-pagination
          background
          v-model:current-page="pageNum"
          v-model:page-size="pageSize"
          :page-sizes="[10, 20, 50]"
          :total="total"
          layout="total, sizes, prev, pager, next"
          @size-change="handleSizeChange"
          @current-change="handleCurrentChange"
          class="pagination"
      />
    </div>

    <!-- 发布公告弹窗 -->
    <el-dialog v-model="showAdd" :title="form.id ? '编辑公告' : '发布公告'" width="700px" :close-on-click-modal="false" @close="resetForm">
      <el-form :model="form" label-width="80px">
        <el-form-item label="标题">
          <el-input v-model="form.title" placeholder="请输入公告标题" />
        </el-form-item>
        <el-form-item label="类型">
          <el-radio-group v-model="form.type">
            <el-radio-button :label="1">活动通知</el-radio-button>
            <el-radio-button :label="2">政策解读</el-radio-button>
            <el-radio-button :label="3">环保知识</el-radio-button>
            <el-radio-button :label="4">系统公告</el-radio-button>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="封面图">
          <el-input v-model="form.coverImage" placeholder="图片URL" />
        </el-form-item>
        <el-form-item label="内容">
          <el-input v-model="form.content" type="textarea" :rows="10" placeholder="请输入公告内容" />
        </el-form-item>
        <el-form-item label="置顶">
          <el-switch v-model="form.isTop" :active-value="1" :inactive-value="0" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="showAdd = false">取 消</el-button>
        <el-button type="primary" @click="submit" :loading="submitting">{{ form.id ? '保存' : '发布' }}</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import request from '@/utils/request'

const loading = ref(false)
const noticeList = ref([])
const showAdd = ref(false)
const submitting = ref(false)
const searchKeyword = ref('')
const searchType = ref(null)
const pageNum = ref(1)
const pageSize = ref(10)
const total = ref(0)

const emptyForm = () => ({
  id: null,
  title: '',
  type: 1,
  coverImage: '',
  content: '',
  isTop: 0
})

const form = ref(emptyForm())

onMounted(() => {
  loadData()
})

const loadData = async () => {
  loading.value = true
  try {
    const res = await request.get('/notice/selectAll', {})
    let list = Array.isArray(res) ? res : []
    // 前端过滤
    if (searchKeyword.value.trim()) {
      list = list.filter(item => item.title && item.title.includes(searchKeyword.value.trim()))
    }
    if (searchType.value) {
      list = list.filter(item => item.type === searchType.value)
    }
    total.value = list.length
    const start = (pageNum.value - 1) * pageSize.value
    noticeList.value = list.slice(start, start + pageSize.value)
  } catch (e) {
    noticeList.value = []
    total.value = 0
  }
  loading.value = false
}

const handleSearch = () => {
  pageNum.value = 1
  loadData()
}

const resetSearch = () => {
  searchKeyword.value = ''
  searchType.value = null
  pageNum.value = 1
  loadData()
}

const handleSizeChange = (val) => {
  pageSize.value = val
  pageNum.value = 1
  loadData()
}

const handleCurrentChange = (val) => {
  pageNum.value = val
  loadData()
}

const typeText = (type) => {
  const map = { 1: '活动', 2: '政策', 3: '知识', 4: '公告' }
  return map[type] || '其他'
}

const typeColor = (type) => {
  const map = { 1: 'success', 2: 'warning', 3: 'info', 4: 'danger' }
  return map[type] || 'info'
}

const updateStatus = async (row) => {
  try {
    await request.put('/notice/update', { id: row.id, status: row.status })
    ElMessage.success('状态更新成功')
  } catch (e) {
    row.status = row.status === 1 ? 0 : 1
  }
}

const toggleTop = async (row) => {
  try {
    await request.put(`/notice/setTop/${row.id}`, null, { params: { isTop: row.isTop === 1 ? 0 : 1 } })
    ElMessage.success('操作成功')
    loadData()
  } catch (e) {
    ElMessage.error('操作失败')
  }
}

const resetForm = () => {
  form.value = emptyForm()
}

const submit = async () => {
  if (!form.value.title?.trim()) {
    ElMessage.warning('请输入标题')
    return
  }
  submitting.value = true
  try {
    if (form.value.id) {
      await request.put('/notice/update', form.value)
      ElMessage.success('保存成功')
    } else {
      await request.post('/notice/add', form.value)
      ElMessage.success('发布成功')
    }
    showAdd.value = false
    resetForm()
    loadData()
  } catch (error) {
    ElMessage.error(error.message || '操作失败')
  } finally {
    submitting.value = false
  }
}

const edit = (row) => {
  form.value = {
    id: row.id,
    title: row.title,
    type: row.type,
    coverImage: row.coverImage || '',
    content: row.content || '',
    isTop: row.isTop || 0
  }
  showAdd.value = true
}

const remove = async (row) => {
  try {
    await ElMessageBox.confirm(`确定删除公告「${row.title}」？`, '提示', { type: 'warning' })
  } catch (e) { return }
  try {
    await request.delete(`/notice/delete/${row.id}`)
    ElMessage.success('删除成功')
    loadData()
  } catch (e) {
    ElMessage.error('删除失败')
  }
}
</script>

<style scoped>
.notice-manage {
  padding: 20px;
  background-color: #f5f7fa;
  min-height: calc(100vh - 60px);
}

.search-section {
  background: #fff;
  padding: 20px;
  border-radius: 12px;
  margin-bottom: 20px;
  display: flex;
  align-items: center;
  gap: 16px;
  box-shadow: 0 2px 12px 0 rgba(0, 0, 0, 0.05);
}

.search-box {
  display: flex;
  align-items: center;
  flex: 1;
  max-width: 500px;
  background: #f5f7fa;
  border-radius: 8px;
  padding: 4px;
  border: 1px solid #e4e7ed;
}

.search-box i {
  color: #909399;
  font-size: 16px;
  margin: 0 12px;
}

.search-box input {
  flex: 1;
  border: none;
  background: transparent;
  padding: 8px 0;
  font-size: 14px;
  outline: none;
  color: #606266;
}

.search-box input::placeholder {
  color: #c0c4cc;
}

.search-box .el-button {
  border-radius: 6px;
  margin-left: 8px;
}

.table-container {
  background: #fff;
  padding: 20px;
  border-radius: 12px;
  box-shadow: 0 2px 12px 0 rgba(0, 0, 0, 0.05);
}

.table-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
  font-size: 16px;
  font-weight: 500;
  color: #303133;
}

.table-header-right {
  display: flex;
  align-items: center;
  gap: 16px;
}

.table-header .total {
  font-size: 14px;
  color: #909399;
  font-weight: normal;
}

.text-muted {
  color: #c0c4cc;
}

.view-count {
  color: #409eff;
  font-weight: 600;
}

.action-buttons {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
}

.pagination {
  margin-top: 20px;
  text-align: right;
}
</style>
