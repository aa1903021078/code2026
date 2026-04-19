<template>
  <div class="notice-page">
    <div class="notice-tabs">
      <el-radio-group v-model="noticeType" size="large" @change="loadNotices">
        <el-radio-button :label="null">全部</el-radio-button>
        <el-radio-button :label="1">活动通知</el-radio-button>
        <el-radio-button :label="2">政策解读</el-radio-button>
        <el-radio-button :label="3">环保知识</el-radio-button>
        <el-radio-button :label="4">系统公告</el-radio-button>
      </el-radio-group>
    </div>

    <div class="notice-list" v-loading="loading">
      <div
          v-for="notice in notices"
          :key="notice.id"
          class="notice-item"
          @click="viewDetail(notice)"
      >
        <div class="notice-cover" v-if="notice.coverImage">
          <img :src="notice.coverImage" />
        </div>
        <div class="notice-content">
          <div class="header">
            <el-tag :type="typeColor(notice.type)" size="small">{{ typeText(notice.type) }}</el-tag>
            <span class="time">{{ formatTime(notice.publishTime) }}</span>
            <el-tag v-if="notice.isTop" type="danger" size="small" effect="dark">置顶</el-tag>
          </div>
          <h3>{{ notice.title }}</h3>
          <p class="summary">{{ notice.content.substring(0, 100) }}...</p>
          <div class="footer">
            <span><el-icon><View /></el-icon> {{ notice.viewCount }} 阅读</span>
          </div>
        </div>
      </div>

      <el-empty v-if="notices.length === 0" description="暂无公告" />
    </div>

    <!-- 公告详情弹窗 -->
    <el-dialog v-model="detailVisible" :title="currentNotice.title" width="700px">
      <div class="notice-detail">
        <div class="meta">
          <el-tag :type="typeColor(currentNotice.type)">{{ typeText(currentNotice.type) }}</el-tag>
          <span>{{ formatTime(currentNotice.publishTime) }}</span>
        </div>
        <div class="content" v-html="currentNotice.content"></div>
      </div>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { View } from '@element-plus/icons-vue'
import request from '@/utils/request'
import dayjs from 'dayjs'

const noticeType = ref(null)
const notices = ref([])
const loading = ref(false)
const detailVisible = ref(false)
const currentNotice = ref({})

onMounted(() => {
  loadNotices()
})

const loadNotices = async () => {
  loading.value = true
  try {
    const res = await request.get('/notice/selectPublished', { params: { type: noticeType.value } })
    notices.value = res
  } catch (e) {}
  loading.value = false
}

const typeText = (type) => {
  const map = { 1: '活动', 2: '政策', 3: '知识', 4: '公告' }
  return map[type] || '其他'
}

const typeColor = (type) => {
  const map = { 1: 'success', 2: 'warning', 3: 'info', 4: 'danger' }
  return map[type] || 'info'
}

const formatTime = (time) => {
  return dayjs(time).format('YYYY-MM-DD')
}

const viewDetail = async (notice) => {
  currentNotice.value = notice
  detailVisible.value = true
  // 增加阅读量
  try {
    await request.put(`/notice/incrementView/${notice.id}`)
  } catch (e) {}
}
</script>

<style scoped lang="scss">
.notice-page {
  .notice-tabs {
    margin-bottom: 20px;
    text-align: center;
  }

  .notice-list {
    .notice-item {
      background: white;
      border-radius: 8px;
      padding: 20px;
      margin-bottom: 15px;
      display: flex;
      gap: 20px;
      cursor: pointer;
      transition: all 0.3s;
      box-shadow: 0 2px 12px rgba(0,0,0,0.05);

      &:hover {
        box-shadow: 0 8px 24px rgba(0,0,0,0.1);
        transform: translateY(-2px);
      }

      .notice-cover {
        width: 200px;
        height: 120px;
        border-radius: 4px;
        overflow: hidden;
        flex-shrink: 0;

        img {
          width: 100%;
          height: 100%;
          object-fit: cover;
        }
      }

      .notice-content {
        flex: 1;

        .header {
          display: flex;
          gap: 10px;
          align-items: center;
          margin-bottom: 10px;

          .time {
            color: #909399;
            font-size: 13px;
          }
        }

        h3 {
          color: #303133;
          margin-bottom: 10px;
          font-size: 18px;
        }

        .summary {
          color: #606266;
          line-height: 1.6;
          margin-bottom: 10px;
        }

        .footer {
          color: #909399;
          font-size: 13px;
        }
      }
    }
  }

  .notice-detail {
    .meta {
      margin-bottom: 20px;
      display: flex;
      gap: 15px;
      align-items: center;
    }

    .content {
      line-height: 1.8;
      color: #303133;
    }
  }
}
</style>