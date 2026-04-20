# 管理员端页面假数据清单

> 范围：本次处理的 4 个管理员页面
> `vue/src/views/admin/Dashboard.vue`、`Dispatch.vue`、`NoticeManage.vue`、`Statistics.vue`
> 标注：✅ 真实接口 ｜ ⚠️ 部分写死 ｜ ❌ 完全写死

## 1. 数据大屏 `Dashboard.vue` —— ⚠️ 部分写死

| 模块 | 状态 | 说明 |
|------|------|------|
| 顶部 4 个数据卡（总订单/已完成/待处理/回收重量） | ✅ | `GET /statistics/overview` |
| 近 7 日订单趋势图 | ✅ | `GET /statistics/dailyStats` |
| 品类回收占比图 | ✅ | `GET /statistics/applianceTypeStats` |
| 待办事项 | ⚠️ | 由 overview 数据动态生成文案，但"时间戳"是固定的"刚刚 / 统计"字符串，不是真正的发生时间 |
| 环保贡献 - 减少碳排放 | ✅ | `overview.totalCarbonSaved` |
| 环保贡献 - 相当于种树（棵） | ⚠️ | **前端计算**：`Math.floor(totalCarbonSaved / 18)`，系数 18 是写死的经验值，应由后端提供或配置化 |

**写死位置**
- `Dashboard.vue` 第 117 行 `treeCount` 计算中的 `18`
- `Dashboard.vue` 第 165/171/175 行 `buildTodos()` 中的 `time: '刚刚' / '统计'`

---

## 2. 智能派单 `Dispatch.vue` —— ⚠️ 部分写死

| 模块 | 状态 | 说明 |
|------|------|------|
| 待派单列表 | ✅ | `GET /recycleOrder/selectPendingDispatch` |
| 待派单数量（顶部统计） | ✅ | 取 `pendingOrders.length` |
| **在线回收员数**（顶部统计） | ❌ | 硬编码 `8`，无后端接口 |
| **今日已派单数**（顶部统计） | ❌ | 硬编码 `12`，无后端接口 |
| **平均响应时间**（顶部统计） | ❌ | 硬编码 `5.2` 分钟，无后端接口 |
| 附近可用回收员列表 | ✅ | `GET /collector/selectNearby` |
| 智能派单 | ✅ | `POST /recycleOrder/dispatch/{orderId}` |
| 手动派单 | ✅ | `POST /recycleOrder/manualDispatch` |
| 最近派单记录（右侧时间轴） | ⚠️ | **仅内存维护**，`recentRecords` 只保存当前会话内派单成功的 10 条；刷新页面后消失。应由后端 `/dispatch/record` 接口提供 |
| 地图可视化 | ⚠️ | 目前只是文字列表形式的"伪地图"，未接入真实地图组件（AMap / 腾讯地图），坐标标记点未渲染 |

**写死位置**
- `Dispatch.vue` 第 271-276 行 `stats` 初始值：
  ```js
  const stats = reactive({
    pendingCount: 0,
    onlineCollectors: 8,    // ❌ 写死
    todayDispatched: 12,    // ❌ 写死
    avgResponseTime: 5.2    // ❌ 写死
  })
  ```
- `Dispatch.vue` 第 440 行 `centerMap()`：仅弹出 toast，未真正操作地图
- `Dispatch.vue` 第 428 行 `addRecentRecord()`：只 push 到前端内存数组

**后端侧的写死**（非本文件但相关）：
- `RecycleOrderService.dispatchOrder()` 中 `dispatchRecord.setDistance(new BigDecimal("1.5"))` 和 `setEstimatedTime(15)` 是硬编码，未根据真实经纬度计算距离

---

## 3. 公告管理 `NoticeManage.vue` —— ✅ 全部真实

| 模块 | 状态 | 说明 |
|------|------|------|
| 公告列表 | ✅ | `GET /notice/selectAll` |
| 新增公告 | ✅ | `POST /notice/add` |
| 编辑公告 | ✅ | `PUT /notice/update` |
| 删除公告 | ✅ | `DELETE /notice/delete/{id}` |
| 启用/停用开关 | ✅ | `PUT /notice/update` |
| 置顶/取消置顶 | ✅ | `PUT /notice/setTop/{id}` |
| 类型文本/颜色映射 | ⚠️ | 前端本地 `typeText/typeColor` 的映射表是写死的常量（合理，非业务数据） |

---

## 4. 数据统计 `Statistics.vue` —— ❌ 基本全部写死

> 这是四个页面里假数据最多的。整个页面除了 URL 路由参数以外，几乎所有展示内容都是本地生成的模拟数据，**没有调用任何后端接口**。

| 模块 | 状态 | 说明 |
|------|------|------|
| 页面标题 / 子标题 | —— | 根据路由 `computed` 出来（合理） |
| 顶部概览卡片 - 数值 | ❌ | 来自第 233-238 行 `statsData` 常量（订单 1258、用户 5680、收益 ¥128,560、碳减排 15680 …全写死） |
| 顶部概览卡片 - "较上期 X%" | ❌ | `Math.floor(Math.random() * 30) + 5`（第 227 行） |
| 顶部概览卡片 - 上升/下降趋势 | ❌ | `Math.random() > 0.5 ? 'up' : 'down'`（第 228 行） |
| 趋势图（左侧折线） | ❌ | 第 318/326 行 `data: [120,132,101,134,90,230,210]` 等全部写死，X 轴固定为"周一…周日" |
| 饼图（右侧） | ❌ | 第 341-361 行 `pieData` 四种类型下的 value 全写死（已完成 986、待处理 198…） |
| 详细数据表格 | ❌ | 第 394-417 行 `loadTableData()` 内全是 `Math.random()` 生成的数据，和真实数据库无关 |
| 日期范围筛选 | ❌ | 切换日期只是重新初始化图表（模拟数据照旧），不会真正按日期查询 |
| 导出数据按钮 | ❌ | 第 431 行 `exportData()` 只弹 `ElMessage.success`，不产出文件 |
| 分页 | ❌ | `total` 固定为 `100`（第 248 行） |

**需要的后端接口（目前都不存在）**：
- `GET /statistics/orders?type=day|week|month&start&end` —— 订单统计趋势 + 饼图 + 明细
- `GET /statistics/users?...` —— 用户统计
- `GET /statistics/revenue?...` —— 收益统计
- `GET /statistics/environment?...` —— 环保贡献统计
- `GET /statistics/export?type=orders&format=xlsx` —— 导出

**写死位置汇总**
| 行号 | 内容 |
|------|------|
| 227-228 | 概览卡 change/trend 随机数 |
| 233-238 | `statsData` 四套硬编码数值 |
| 310 | 趋势图 x 轴固定为周一~周日 |
| 318, 326 | 趋势图 series 数据固定数组 |
| 341-361 | 饼图各类型数据固定 |
| 394-417 | 表格 tableData 全部 `Math.random()` |
| 248 | `total.value = 100` |
| 431-433 | `exportData()` 空实现 |

---

## 关联文件里的其它假数据（顺带记录）

| 文件 | 行号 | 说明 |
|------|------|------|
| `vue/src/views/admin/DataAnalysis.vue` | 124-129 | 周一~周日 回收重量/减碳量 柱线图固定数据；接口失败时兜底三条回收员排行假数据 |
| `vue/src/views/collector/Income.vue` | 130-143 | 接口失败时兜底今日/月度/总收入及明细列表的假数据（仅 `catch` 分支，正常走真实接口） |
| `vue/src/views/collector/Navigation.vue` | 272-328 | 地图导航路径在缺失坐标时用 `Math.random()` 生成模拟目的地和途经点（模拟导航，不是数据展示假数据） |

---

## 建议处理优先级

1. **高**：`Statistics.vue` 整页对接真实接口（本次未处理）
2. **中**：`Dispatch.vue` 顶部三个统计指标补后端接口（`/dispatch/todayStats`）
3. **中**：`Dispatch.vue` 最近派单记录改为后端查询 `dispatch_record` 表
4. **低**：`Dashboard.vue` 的 `treeCount` 系数 18 改为后端配置项
5. **低**：`DataAnalysis.vue` 环保趋势柱线图接入 `dailyStats`


