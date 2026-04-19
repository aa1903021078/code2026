<template>
  <div class="home-page">
    <!-- 轮播图 -->
    <div class="carousel-section">
      <el-carousel height="400px" :interval="5000">
        <el-carousel-item v-for="(item, index) in banners" :key="index">
          <div class="banner-item" :style="{ background: item.bg }">
            <div class="banner-content">
              <h2>{{ item.title }}</h2>
              <p>{{ item.subtitle }}</p>
              <el-button type="primary" size="large" @click="router.push('/user/recycle')">
                立即预约
              </el-button>
            </div>
            <div class="banner-image">{{ item.icon }}</div>
          </div>
        </el-carousel-item>
      </el-carousel>
    </div>

    <!-- 快捷入口 -->
    <div class="quick-actions">
      <div class="action-card" @click="router.push('/user/recycle')">
        <div class="icon">📱</div>
        <h3>预约回收</h3>
        <p>一键预约，上门回收</p>
      </div>
      <div class="action-card" @click="router.push('/user/points')">
        <div class="icon">🎁</div>
        <h3>积分兑换</h3>
        <p>回收得积分，好礼换不停</p>
      </div>
      <div class="action-card" @click="router.push('/user/ecoRank')">
        <div class="icon">🏆</div>
        <h3>环保排名</h3>
        <p>查看社区贡献榜</p>
      </div>
      <div class="action-card" @click="router.push('/user/orderList')">
        <div class="icon">📋</div>
        <h3>订单追踪</h3>
        <p>实时查看回收进度</p>
      </div>
    </div>

    <!-- 环保数据展示 -->
    <div class="eco-stats">
      <h3 class="section-title">🌍 我们的环保贡献</h3>
      <div class="stats-grid">
        <div class="stat-item">
          <div class="number">{{ stats.totalOrders }}</div>
          <div class="label">完成订单</div>
        </div>
        <div class="stat-item">
          <div class="number">{{ stats.totalWeight }}<span>kg</span></div>
          <div class="label">回收重量</div>
        </div>
        <div class="stat-item">
          <div class="number">{{ stats.totalCarbon }}<span>kg</span></div>
          <div class="label">减碳排放</div>
        </div>
        <div class="stat-item">
          <div class="number">{{ stats.activeUsers }}</div>
          <div class="label">参与用户</div>
        </div>
      </div>
    </div>

    <!-- 最新资讯和公告 -->
    <div class="info-section">
      <div class="info-block">
        <h3 class="section-title">
          📢 最新公告
          <router-link to="/notice" class="more">查看更多 →</router-link>
        </h3>
        <div class="notice-list">
          <div
              v-for="notice in notices"
              :key="notice.id"
              class="notice-item"
              @click="viewNotice(notice)"
          >
            <span class="tag" :class="'type-' + notice.type">{{ notice.typeName }}</span>
            <span class="title">{{ notice.title }}</span>
            <span class="time">{{ notice.publishTime }}</span>
          </div>
        </div>
      </div>

      <div class="info-block">
        <h3 class="section-title">
          📰 回收资讯
          <span class="more">实时更新</span>
        </h3>
        <div class="news-list">
          <div v-for="(news, index) in newsList" :key="index" class="news-item">
            <div class="news-image">{{ news.icon }}</div>
            <div class="news-content">
              <h4>{{ news.title }}</h4>
              <p>{{ news.summary }}</p>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- 回收品类展示 -->
    <div class="category-section">
      <h3 class="section-title">♻️ 可回收品类</h3>
      <div class="category-grid">
        <div v-for="cat in categories" :key="cat.id" class="category-card">
          <div class="cat-icon">{{ cat.icon }}</div>
          <h4>{{ cat.name }}</h4>
          <p>预估价：{{ cat.priceMin }}-{{ cat.priceMax }}元</p>
          <p class="points">💚 {{ cat.pointsPerKg }}积分/kg</p>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import {createRouter as $router, useRouter} from 'vue-router'
import { ElMessage } from 'element-plus'
import request from '@/utils/request'

const router = useRouter()

const banners = [
  { title: '让废旧家电变废为宝', subtitle: '专业回收，环保处理，积分奖励', bg: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)', icon: '🌍' },
  { title: '预约上门，快速响应', subtitle: '30分钟响应，2小时上门', bg: 'linear-gradient(135deg, #f093fb 0%, #f5576c 100%)', icon: '🚚' },
  { title: '积分兑换，好礼不停', subtitle: '回收得积分，兑换精美礼品', bg: 'linear-gradient(135deg, #4facfe 0%, #00f2fe 100%)', icon: '🎁' }
]

const stats = ref({
  totalOrders: 0,
  totalWeight: 0,
  totalCarbon: 0,
  activeUsers: 0
})

const notices = ref([])
const categories = ref([])

const newsList = [
  { title: '废旧家电回收新政策出台', summary: '国家发改委发布最新废旧家电回收处理管理办法...', icon: '📄' },
  { title: '如何正确处理废旧电池？', summary: '废旧电池含有重金属，需要专业回收处理...', icon: '🔋' },
  { title: '空调回收注意事项', summary: '空调回收前需要专业拆机，避免氟利昂泄漏...', icon: '❄️' }
]

onMounted(() => {
  loadStats()
  loadNotices()
  loadCategories()
})

const loadStats = async () => {
  try {
    const res = await request.get('/recycleOrder/statistics')
    stats.value = res
  } catch (e) {}
}

const loadNotices = async () => {
  try {
    const res = await request.get('/notice/selectPublished')
    notices.value = res.slice(0, 5).map(n => ({
      ...n,
      typeName: n.type === 1 ? '活动' : n.type === 2 ? '政策' : n.type === 3 ? '知识' : '公告'
    }))
  } catch (e) {}
}

const loadCategories = async () => {
  try {
    const res = await request.get('/applianceType/selectEnabled')
    categories.value = res.slice(0, 8)
  } catch (e) {}
}

const viewNotice = (notice) => {
  // 查看公告详情
  ElMessage.info('查看公告：' + notice.title)
}
</script>

<style scoped lang="scss">
.home-page {
  .carousel-section {
    margin-bottom: 30px;
    border-radius: 12px;
    overflow: hidden;

    .banner-item {
      height: 100%;
      display: flex;
      align-items: center;
      justify-content: space-around;
      padding: 0 60px;
      color: white;

      .banner-content {
        h2 {
          font-size: 36px;
          margin-bottom: 15px;
          font-weight: bold;
        }

        p {
          font-size: 18px;
          margin-bottom: 25px;
          opacity: 0.9;
        }
      }

      .banner-image {
        font-size: 150px;
        opacity: 0.3;
      }
    }
  }

  .quick-actions {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: 20px;
    margin-bottom: 40px;

    .action-card {
      background: white;
      padding: 30px;
      border-radius: 12px;
      text-align: center;
      cursor: pointer;
      transition: all 0.3s;
      box-shadow: 0 2px 12px rgba(0,0,0,0.05);

      &:hover {
        transform: translateY(-5px);
        box-shadow: 0 8px 24px rgba(0,0,0,0.1);

        .icon {
          transform: scale(1.1);
        }
      }

      .icon {
        font-size: 48px;
        margin-bottom: 15px;
        transition: transform 0.3s;
      }

      h3 {
        color: #333;
        margin-bottom: 8px;
        font-size: 18px;
      }

      p {
        color: #999;
        font-size: 14px;
      }
    }
  }

  .eco-stats {
    background: linear-gradient(135deg, #52c41a 0%, #389e0d 100%);
    padding: 40px;
    border-radius: 12px;
    margin-bottom: 40px;
    color: white;

    .section-title {
      text-align: center;
      font-size: 24px;
      margin-bottom: 30px;
    }

    .stats-grid {
      display: grid;
      grid-template-columns: repeat(4, 1fr);
      gap: 30px;
      text-align: center;

      .stat-item {
        .number {
          font-size: 36px;
          font-weight: bold;
          margin-bottom: 8px;

          span {
            font-size: 18px;
            margin-left: 5px;
          }
        }

        .label {
          font-size: 14px;
          opacity: 0.9;
        }
      }
    }
  }

  .info-section {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 30px;
    margin-bottom: 40px;

    .info-block {
      background: white;
      padding: 25px;
      border-radius: 12px;
      box-shadow: 0 2px 12px rgba(0,0,0,0.05);

      .section-title {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 20px;
        font-size: 18px;

        .more {
          font-size: 14px;
          color: #52c41a;
          text-decoration: none;
        }
      }

      .notice-list {
        .notice-item {
          display: flex;
          align-items: center;
          padding: 12px 0;
          border-bottom: 1px solid #f0f0f0;
          cursor: pointer;
          transition: all 0.3s;

          &:hover {
            background: #f6ffed;
            padding-left: 10px;
          }

          .tag {
            padding: 2px 8px;
            border-radius: 4px;
            font-size: 12px;
            margin-right: 10px;

            &.type-1 { background: #e6f7ff; color: #1890ff; }
            &.type-2 { background: #fff7e6; color: #fa8c16; }
            &.type-3 { background: #f6ffed; color: #52c41a; }
            &.type-4 { background: #fff1f0; color: #f5222d; }
          }

          .title {
            flex: 1;
            color: #333;
            font-size: 14px;
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
          }

          .time {
            color: #999;
            font-size: 13px;
          }
        }
      }

      .news-list {
        .news-item {
          display: flex;
          gap: 15px;
          padding: 15px 0;
          border-bottom: 1px solid #f0f0f0;

          .news-image {
            width: 60px;
            height: 60px;
            background: #f5f5f5;
            border-radius: 8px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 24px;
            flex-shrink: 0;
          }

          .news-content {
            h4 {
              color: #333;
              margin-bottom: 8px;
              font-size: 15px;
            }

            p {
              color: #999;
              font-size: 13px;
              line-height: 1.5;
              display: -webkit-box;
              -webkit-line-clamp: 2;
              -webkit-box-orient: vertical;
              overflow: hidden;
            }
          }
        }
      }
    }
  }

  .category-section {
    background: white;
    padding: 30px;
    border-radius: 12px;
    box-shadow: 0 2px 12px rgba(0,0,0,0.05);

    .section-title {
      text-align: center;
      margin-bottom: 30px;
      font-size: 24px;
    }

    .category-grid {
      display: grid;
      grid-template-columns: repeat(4, 1fr);
      gap: 20px;

      .category-card {
        text-align: center;
        padding: 25px;
        border: 1px solid #e8e8e8;
        border-radius: 8px;
        transition: all 0.3s;
        cursor: pointer;

        &:hover {
          border-color: #52c41a;
          box-shadow: 0 4px 12px rgba(82, 196, 26, 0.15);
        }

        .cat-icon {
          font-size: 40px;
          margin-bottom: 10px;
        }

        h4 {
          color: #333;
          margin-bottom: 8px;
        }

        p {
          color: #666;
          font-size: 13px;
          margin-bottom: 5px;
        }

        .points {
          color: #52c41a;
          font-weight: bold;
        }
      }
    }
  }
}

@media (max-width: 768px) {
  .quick-actions {
    grid-template-columns: repeat(2, 1fr) !important;
  }

  .stats-grid {
    grid-template-columns: repeat(2, 1fr) !important;
  }

  .info-section {
    grid-template-columns: 1fr !important;
  }

  .category-grid {
    grid-template-columns: repeat(2, 1fr) !important;
  }
}
</style>