# 社区家电回收预约系统

中文回复。

## 项目简介

基于 **Spring Boot + Vue 3** 的前后端分离社区家电回收预约管理系统。用户可在线预约回收旧家电，回收员上门回收，管理员后台统一管理，实现废旧家电回收的数字化、规范化。

## 技术栈

| 层级 | 技术 |
|------|------|
| 前端 | Vue 3 + Vite + Element Plus + Pinia + ECharts + Axios |
| 后端 | Spring Boot 3.3.1 + MyBatis + PageHelper + Hutool |
| 数据库 | MySQL |
| Java 版本 | JDK 21 |

## 项目结构

```
code2026/
├── springboot/          # 后端 Spring Boot 项目（端口 9090）
│   └── src/main/java/com/example/
│       ├── controller/  # 控制器（Admin/User/Collector/Order 等）
│       ├── entity/      # 实体类（User/Collector/RecycleOrder 等）
│       ├── mapper/      # MyBatis Mapper 接口
│       ├── service/     # 业务逻辑层
│       ├── dto/         # 数据传输对象
│       ├── config/      # 配置类
│       ├── common/      # 公共模块
│       ├── utils/       # 工具类
│       └── exception/   # 异常处理
├── vue/                 # 前端 Vue 3 项目
│   └── src/
│       ├── views/       # 页面组件
│       │   ├── admin/       # 管理员后台页面
│       │   ├── user/        # 用户端页面
│       │   ├── collector/   # 回收员端页面
│       │   └── front/       # 前台公共页面
│       ├── layout/      # 布局组件
│       ├── router/      # 路由配置
│       ├── api/         # API 接口封装
│       ├── utils/       # 工具函数
│       └── components/  # 公共组件
└── files/               # 文件上传存储目录
```

## 系统角色与功能

### 普通用户
- 首页浏览、预约回收、我的订单
- 地址管理、积分商城、环保排名
- 社区公告、个人中心

### 回收员
- 工作台、订单中心、地图导航
- 收益统计、个人中心
- 注册需提交资质，管理员审核通过后上岗

### 管理员
- 数据大屏、智能派单、订单管理
- 用户管理、回收员管理、资质审核
- 品类管理、积分管理、公告管理
- 数据统计、轮播图管理

## 核心实体

- `User` - 普通用户
- `Collector` - 回收员
- `Admin` - 管理员
- `RecycleOrder` - 回收订单
- `ApplianceType` - 家电品类
- `UserAddress` - 用户地址
- `PointsGoods / PointsExchange / PointsRecord` - 积分体系
- `CommunityNotice` - 社区公告
- `Banner` - 轮播图
- `DispatchRecord` - 派单记录
- `DailyRecycleStats` - 每日回收统计

## 启动方式

### 后端
```bash
cd springboot
mvn spring-boot:run
# 运行在 http://localhost:9090
```

### 前端
```bash
cd vue
npm install
npm run dev
```