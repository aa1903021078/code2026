/*
 Navicat Premium Dump SQL

 Source Server         : localhost_3306
 Source Server Type    : MySQL
 Source Server Version : 80017 (8.0.17)
 Source Host           : localhost:3306
 Source Schema         : code2026

 Target Server Type    : MySQL
 Target Server Version : 80017 (8.0.17)
 File Encoding         : 65001

 Date: 18/04/2026 18:49:12
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for admin
-- ----------------------------
DROP TABLE IF EXISTS `admin`;
CREATE TABLE `admin`  (
  `id` int(20) NOT NULL AUTO_INCREMENT COMMENT '管理员ID',
  `username` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '用户名',
  `password` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '密码',
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '姓名',
  `avatar` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '头像',
  `role` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'operator' COMMENT '角色',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '管理员表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of admin
-- ----------------------------
INSERT INTO `admin` VALUES (1, 'admin', 'admin', '管理员', 'http://localhost:9090/files/download/avatar.png', '管理员', '2026-02-15 18:21:58');

-- ----------------------------
-- Table structure for appliance_type
-- ----------------------------
DROP TABLE IF EXISTS `appliance_type`;
CREATE TABLE `appliance_type`  (
  `id` int(20) NOT NULL AUTO_INCREMENT COMMENT '家电品类ID',
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '品类名称',
  `icon` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '图标',
  `unit` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '台' COMMENT '计量单位',
  `price_min` decimal(10, 2) NULL DEFAULT NULL COMMENT '最低预估价',
  `price_max` decimal(10, 2) NULL DEFAULT NULL COMMENT '最高预估价',
  `weight_estimate` decimal(8, 2) NULL DEFAULT NULL COMMENT '预估重量(kg)',
  `points_per_kg` decimal(10, 2) NULL DEFAULT 10.00 COMMENT '每公斤积分',
  `carbon_factor` decimal(6, 4) NULL DEFAULT 0.0000 COMMENT '减碳系数',
  `description` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '品类描述',
  `sort_order` int(11) NULL DEFAULT 0 COMMENT '排序',
  `status` tinyint(1) NULL DEFAULT 1 COMMENT '状态：0禁用 1启用',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 7 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '家电品类表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of appliance_type
-- ----------------------------
INSERT INTO `appliance_type` VALUES (1, '冰箱', '❄️', '台', 50.00, 600.00, 60.00, 13.75, 5.5000, '家用单门、双门、对开门冰箱、冰柜', 1, 1, '2026-02-15 17:50:52');
INSERT INTO `appliance_type` VALUES (2, '空调', '🌡️', '台', 150.00, 1500.00, 40.00, 15.00, 6.0000, '壁挂式、柜式空调', 2, 1, '2026-02-15 17:50:52');
INSERT INTO `appliance_type` VALUES (3, '洗衣机', '👔', '台', 30.00, 500.00, 30.00, 7.50, 3.0000, '波轮、滚筒洗衣机', 3, 1, '2026-02-15 17:50:52');
INSERT INTO `appliance_type` VALUES (4, '电视机', '📺', '台', 20.00, 400.00, 15.00, 8.75, 3.5000, '老式、液晶电视', 4, 1, '2026-02-15 17:50:52');
INSERT INTO `appliance_type` VALUES (5, '电脑', '💻', '台', 50.00, 1000.00, 5.00, 11.20, 4.5000, '台式机、笔记本', 5, 1, '2026-02-15 17:50:52');
INSERT INTO `appliance_type` VALUES (6, '热水器', '🔥', '台', 20.00, 500.00, 20.00, 10.00, 4.0000, '电/燃气热水器', 6, 1, '2026-02-15 17:50:52');

-- ----------------------------
-- Table structure for banner
-- ----------------------------
DROP TABLE IF EXISTS `banner`;
CREATE TABLE `banner`  (
  `id` int(20) NOT NULL AUTO_INCREMENT COMMENT '轮播图ID',
  `title` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '标题',
  `subtitle` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '副标题',
  `bg_color` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '背景渐变色彩值',
  `icon` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '?' COMMENT '图标emoji',
  `sort_order` int(11) NULL DEFAULT 0 COMMENT '排序号',
  `status` tinyint(1) NULL DEFAULT 1 COMMENT '状态：0-下架，1-上架',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_status_sort`(`status` ASC, `sort_order` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '首页轮播图表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of banner
-- ----------------------------
INSERT INTO `banner` VALUES (1, '让废旧家电变废为宝', '专业回收，环保处理，积分奖励', 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)', '🌍', 1, 1, '2026-03-11 22:30:10', '2026-03-11 22:30:10');
INSERT INTO `banner` VALUES (2, '预约上门，快速响应', '30分钟响应，2小时上门', 'linear-gradient(135deg, #f093fb 0%, #f5576c 100%)', '🚚', 2, 1, '2026-03-11 22:30:10', '2026-03-11 22:30:10');
INSERT INTO `banner` VALUES (3, '积分兑换，好礼不停', '回收得积分，兑换精美礼品', 'linear-gradient(135deg, #4facfe 0%, #00f2fe 100%)', '🎁', 3, 1, '2026-03-11 22:30:10', '2026-03-11 22:30:10');

-- ----------------------------
-- Table structure for collector
-- ----------------------------
DROP TABLE IF EXISTS `collector`;
CREATE TABLE `collector`  (
  `id` int(20) NOT NULL AUTO_INCREMENT COMMENT '回收员ID',
  `username` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '用户账号',
  `password` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '密码',
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '姓名',
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '手机号',
  `id_card` varchar(18) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '身份证号',
  `id_card_front` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '身份证正面照片',
  `id_card_back` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '身份证反面照片',
  `work_status` tinyint(1) NULL DEFAULT 0 COMMENT '工作状态：0休息 1接单中 2忙碌',
  `rating` decimal(2, 1) NULL DEFAULT 5.0 COMMENT '评分',
  `order_count` int(11) NULL DEFAULT 0 COMMENT '接单数量',
  `today_order_count` int(11) NULL DEFAULT 0 COMMENT '今日接单数',
  `location_lat` decimal(10, 8) NULL DEFAULT NULL COMMENT '当前纬度',
  `location_lng` decimal(11, 8) NULL DEFAULT NULL COMMENT '当前经度',
  `location_update_time` datetime NULL DEFAULT NULL COMMENT '位置更新时间',
  `max_daily_orders` int(11) NULL DEFAULT 10 COMMENT '每日最大接单数',
  `service_area` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '服务区域JSON',
  `status` tinyint(1) NULL DEFAULT 1 COMMENT '状态',
  `audit_status` tinyint(1) NULL DEFAULT 0 COMMENT '审核状态：0待审核 1已通过 2已拒绝',
  `reject_reason` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '拒绝原因',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '回收员表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of collector
-- ----------------------------
INSERT INTO `collector` VALUES (1, 'lisi', 'lisi', '李四', '18300001830', '342000198701023420', 'http://localhost:9090/files/download/1775840371946-男性1.jpg', 'http://localhost:9090/files/download/1775840375949-证件背面.jpg', 0, 5.0, 1, 1, NULL, NULL, NULL, 10, '北京市朝阳区', 1, 1, NULL, '2026-02-25 23:00:10');
INSERT INTO `collector` VALUES (3, 'zhangsan', 'zhangsan', '张三', '19800001980', '341000198001013410', 'http://localhost:9090/files/download/1775840371946-男性1.jpg', 'http://localhost:9090/files/download/1775840375949-证件背面.jpg', 0, 5.0, 0, 0, NULL, NULL, NULL, 10, '北京市朝阳区', 1, 1, NULL, '2026-04-11 01:00:06');
INSERT INTO `collector` VALUES (4, 'liming', 'liming', '李铭', '19900001990', '343000199001033430', 'http://localhost:9090/files/download/1775846020088-女性1.jpg', 'http://localhost:9090/files/download/1775846023836-证件背面.jpg', 0, 5.0, 0, 0, NULL, NULL, NULL, 10, '上海市黄浦区', 0, 2, '不符合审核要求', '2026-04-11 02:33:45');

-- ----------------------------
-- Table structure for community_notice
-- ----------------------------
DROP TABLE IF EXISTS `community_notice`;
CREATE TABLE `community_notice`  (
  `id` int(20) NOT NULL AUTO_INCREMENT COMMENT '社区公告ID',
  `title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '标题',
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '活动类型',
  `type` tinyint(1) NULL DEFAULT 1 COMMENT '1活动通知 2政策解读 3环保知识 4系统公告',
  `cover_image` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '封面图片',
  `is_top` tinyint(1) NULL DEFAULT 0 COMMENT '置顶：0-否 1-是',
  `view_count` int(11) NULL DEFAULT 0 COMMENT '查看次数',
  `publish_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '发布时间',
  `status` tinyint(1) NULL DEFAULT 1 COMMENT '公告状态',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '社区公告表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of community_notice
-- ----------------------------

-- ----------------------------
-- Table structure for daily_recycle_stats
-- ----------------------------
DROP TABLE IF EXISTS `daily_recycle_stats`;
CREATE TABLE `daily_recycle_stats`  (
  `id` int(20) NOT NULL AUTO_INCREMENT,
  `stat_date` date NOT NULL,
  `total_orders` int(11) NULL DEFAULT 0,
  `completed_orders` int(11) NULL DEFAULT 0,
  `cancelled_orders` int(11) NULL DEFAULT 0,
  `total_weight` decimal(12, 2) NULL DEFAULT 0.00,
  `total_carbon_saved` decimal(12, 2) NULL DEFAULT 0.00,
  `total_points_given` int(11) NULL DEFAULT 0,
  `avg_response_time` int(11) NULL DEFAULT 0 COMMENT '平均响应时间(分钟)',
  `active_users` int(11) NULL DEFAULT 0,
  `active_collectors` int(11) NULL DEFAULT 0,
  `appliance_type_stats` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '各品类统计JSON',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_date`(`stat_date` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '每日回收统计表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of daily_recycle_stats
-- ----------------------------
INSERT INTO `daily_recycle_stats` VALUES (1, '2026-03-06', 1, 1, NULL, 32.00, 27.20, 320, NULL, 1, 1, NULL, '2026-03-06 16:13:31');

-- ----------------------------
-- Table structure for dispatch_record
-- ----------------------------
DROP TABLE IF EXISTS `dispatch_record`;
CREATE TABLE `dispatch_record`  (
  `id` int(20) NOT NULL AUTO_INCREMENT COMMENT '派单记录ID',
  `order_id` int(20) NOT NULL COMMENT '订单ID',
  `collector_id` int(20) NOT NULL COMMENT '回收员ID',
  `dispatch_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'auto' COMMENT 'auto智能/manual手动/grab抢单',
  `distance` decimal(8, 2) NULL DEFAULT NULL COMMENT '距离(km)',
  `estimated_time` int(11) NULL DEFAULT NULL COMMENT '预估到达时间(分钟)',
  `is_accepted` tinyint(1) NULL DEFAULT 0 COMMENT '是否接受',
  `reject_reason` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '拒绝原因',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_order_type`(`order_id` ASC, `dispatch_type` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '派单记录表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of dispatch_record
-- ----------------------------
INSERT INTO `dispatch_record` VALUES (1, 1, 1, 'grab', NULL, NULL, 1, NULL, '2026-03-06 16:04:45');

-- ----------------------------
-- Table structure for eco_ranking
-- ----------------------------
DROP TABLE IF EXISTS `eco_ranking`;
CREATE TABLE `eco_ranking`  (
  `id` int(20) NOT NULL AUTO_INCREMENT COMMENT '环保排名ID',
  `user_id` int(20) NOT NULL COMMENT '用户ID',
  `rank_month` varchar(7) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '月份YYYY-MM',
  `recycle_count` int(11) NULL DEFAULT 0 COMMENT '回收次数',
  `recycle_weight` decimal(10, 2) NULL DEFAULT 0.00 COMMENT '回收重量',
  `points_earned` int(11) NULL DEFAULT 0 COMMENT '获得积分',
  `carbon_saved` decimal(10, 2) NULL DEFAULT 0.00 COMMENT '减碳量',
  `rank_num` int(11) NULL DEFAULT 0 COMMENT '排名',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_user_month`(`user_id` ASC, `rank_month` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '环保排名表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of eco_ranking
-- ----------------------------

-- ----------------------------
-- Table structure for points_exchange
-- ----------------------------
DROP TABLE IF EXISTS `points_exchange`;
CREATE TABLE `points_exchange`  (
  `id` int(20) NOT NULL AUTO_INCREMENT COMMENT '积分兑换记录ID',
  `user_id` int(20) NOT NULL COMMENT '用户ID',
  `goods_id` int(20) NOT NULL COMMENT '商品ID',
  `points_spent` int(11) NOT NULL COMMENT '兑换点数',
  `status` tinyint(1) NULL DEFAULT 0 COMMENT '0待发放 1已发放 2已取消',
  `receive_info` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '收货信息',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '积分兑换记录表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of points_exchange
-- ----------------------------

-- ----------------------------
-- Table structure for points_goods
-- ----------------------------
DROP TABLE IF EXISTS `points_goods`;
CREATE TABLE `points_goods`  (
  `id` int(20) NOT NULL AUTO_INCREMENT COMMENT '积分兑换商品ID',
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '商品名称',
  `description` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '描述',
  `image` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '商品图片',
  `points_required` int(11) NOT NULL COMMENT '所需积分',
  `stock` int(11) NULL DEFAULT 0 COMMENT '库存',
  `total_exchanged` int(11) NULL DEFAULT 0 COMMENT '总兑换次数',
  `status` tinyint(1) NULL DEFAULT 1 COMMENT '状态',
  `sort_order` int(11) NULL DEFAULT 0 COMMENT '订单排序号',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `version` int(11) NULL DEFAULT 0 COMMENT '乐观锁版本号',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 6 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '积分兑换商品表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of points_goods
-- ----------------------------
INSERT INTO `points_goods` VALUES (1, '环保购物袋', '可重复使用的环保购物袋', 'http://localhost:9090/files/download/1772611347188-0beecf282a88f57ca5132b97a99621e.jpg', 100, 1000, 0, 1, 1, '2026-02-15 17:50:52', 0);
INSERT INTO `points_goods` VALUES (2, '垃圾分类桶', '家用四分类垃圾桶', NULL, 500, 200, 0, 1, 2, '2026-02-15 17:50:52', 0);
INSERT INTO `points_goods` VALUES (3, '50元话费券', '手机话费充值券', NULL, 1000, 100, 0, 1, 3, '2026-02-15 17:50:52', 0);
INSERT INTO `points_goods` VALUES (4, '环保保温杯', '不锈钢保温杯', NULL, 800, 150, 0, 1, 4, '2026-02-15 17:50:52', 0);
INSERT INTO `points_goods` VALUES (5, '京东E卡100元', '京东购物卡', NULL, 2000, 50, 0, 1, 5, '2026-02-15 17:50:52', 0);

-- ----------------------------
-- Table structure for points_record
-- ----------------------------
DROP TABLE IF EXISTS `points_record`;
CREATE TABLE `points_record`  (
  `id` int(20) NOT NULL AUTO_INCREMENT COMMENT '积分记录ID',
  `user_id` int(20) NOT NULL COMMENT '用户ID',
  `order_id` int(20) NULL DEFAULT NULL COMMENT '关联订单ID',
  `points` int(11) NOT NULL COMMENT '积分变动（正数增加，负数减少）',
  `type` tinyint(1) NOT NULL COMMENT '1回收获得 2兑换消耗 3签到奖励 4活动奖励',
  `description` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '描述',
  `balance` int(11) NOT NULL COMMENT '变动后余额',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_user_id`(`user_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '积分记录表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of points_record
-- ----------------------------
INSERT INTO `points_record` VALUES (1, 1, 1, 320, 1, '完成回收订单：冰箱', 320, '2026-03-06 16:13:31');

-- ----------------------------
-- Table structure for recycle_order
-- ----------------------------
DROP TABLE IF EXISTS `recycle_order`;
CREATE TABLE `recycle_order`  (
  `id` int(20) NOT NULL AUTO_INCREMENT COMMENT '预约订单ID',
  `order_no` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '订单编号',
  `user_id` int(20) NOT NULL COMMENT '用户ID',
  `collector_id` int(20) NULL DEFAULT NULL COMMENT '分配的回收员ID',
  `address_id` int(20) NOT NULL COMMENT '地址ID',
  `address_detail` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '完整地址',
  `address_lat` decimal(10, 8) NULL DEFAULT NULL COMMENT '地址纬度',
  `address_lng` decimal(11, 8) NULL DEFAULT NULL COMMENT '地址经度',
  `building_type` tinyint(1) NULL DEFAULT 1 COMMENT '楼栋类型：1电梯房 2楼梯房',
  `floor` int(3) NULL DEFAULT NULL COMMENT '楼层',
  `contact_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '联系人',
  `contact_phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '联系电话',
  `appliance_type_id` int(20) NOT NULL COMMENT '家电品类ID',
  `appliance_type_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '冗余存储品类名',
  `appliance_desc` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '家电描述',
  `appliance_imgs` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '家电图片',
  `brand_level` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '品牌等级（一线品牌/二线品牌/杂牌）',
  `usage_years` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '使用年限（1年内/2-3年/5年以上）',
  `functional_status` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '功能状况（正常使用/零件损坏/无法开机）',
  `appearance_level` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '外观成色（完好/轻微划痕/破损）',
  `condition_factor` decimal(4, 2) NULL DEFAULT 1.00 COMMENT '机况综合系数（缓存，避免重复计算）',
  `estimated_weight` decimal(8, 2) NULL DEFAULT NULL COMMENT '预估重量',
  `expect_date` date NOT NULL COMMENT '期望日期',
  `expect_time_start` time NOT NULL COMMENT '期望时段开始',
  `expect_time_end` time NOT NULL COMMENT '期望时段结束',
  `urgency_level` tinyint(1) NULL DEFAULT 1 COMMENT '紧急程度：1普通 2较急 3紧急',
  `assign_type` tinyint(1) NULL DEFAULT 1 COMMENT '派单方式：1智能派单 2手动派单 3回收员抢单',
  `assign_time` datetime NULL DEFAULT NULL COMMENT '派单时间',
  `accept_time` datetime NULL DEFAULT NULL COMMENT '接单时间',
  `arrive_time` datetime NULL DEFAULT NULL COMMENT '到达时间',
  `complete_time` datetime NULL DEFAULT NULL COMMENT '完成时间',
  `price_estimate` decimal(10, 2) NULL DEFAULT NULL COMMENT '预估价格',
  `price_actual` decimal(10, 2) NULL DEFAULT NULL COMMENT '实际成交价格',
  `points_earned` int(11) NULL DEFAULT 0 COMMENT '获得积分',
  `weight_actual` decimal(8, 2) NULL DEFAULT NULL COMMENT '实际重量',
  `carbon_saved` decimal(10, 2) NULL DEFAULT 0.00 COMMENT '本次减碳量',
  `status` tinyint(1) NULL DEFAULT 0 COMMENT '0待分配 1待接单 2已接单 3已到达 4已完成 5已取消',
  `cancel_reason` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '取消原因',
  `user_rating` tinyint(1) NULL DEFAULT NULL COMMENT '用户评分',
  `user_comment` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '用户评价',
  `collector_rating` tinyint(1) NULL DEFAULT NULL COMMENT '回收员评分',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `version` int(11) NULL DEFAULT 0 COMMENT '乐观锁版本号',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_order_no`(`order_no` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE,
  INDEX `idx_user_id`(`user_id` ASC) USING BTREE,
  INDEX `idx_collector_id`(`collector_id` ASC) USING BTREE,
  INDEX `idx_expect_date`(`expect_date` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 8 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '预约订单表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of recycle_order
-- ----------------------------
INSERT INTO `recycle_order` VALUES (1, 'REC202603052157131C8C', 1, 1, 1, '北京市北京市朝阳区大街道', 39.92439001, 116.44392609, 1, 1, '李先生', '13700001370', 1, '冰箱', '', 'http://localhost:9090/files/download/1772719031086-1619027397408.jpg', NULL, NULL, NULL, NULL, 1.00, 30.00, '2026-03-06', '09:56:46', '11:56:46', 3, 3, '2026-03-06 16:04:46', '2026-03-06 16:07:37', '2026-03-06 16:09:31', '2026-03-06 16:13:32', NULL, 230.00, 320, 32.00, 27.20, 4, NULL, 5, '上门准时，态度很好，称重准确，价格公道，服务专业', NULL, '2026-03-05 21:57:13', '2026-03-06 17:01:11', 0);
INSERT INTO `recycle_order` VALUES (2, 'REC20260305215931DBE5', 1, NULL, 1, '北京市北京市朝阳区大街道', 39.92439001, 116.44392609, 1, 1, '李先生', '13700001370', 1, '冰箱', '', 'http://localhost:9090/files/download/1772719167652-1619027397408.jpg', NULL, NULL, NULL, NULL, 1.00, 30.00, '2026-03-06', '09:59:04', '11:59:04', 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 300, NULL, 0.00, 5, '用户主动取消', NULL, NULL, NULL, '2026-03-05 21:59:31', '2026-03-08 01:42:31', 0);
INSERT INTO `recycle_order` VALUES (3, 'REC202603052208151E5E', 1, NULL, 1, '北京市北京市朝阳区大街道', 39.92439001, 116.44392609, 1, 1, '李先生', '13700001370', 1, '冰箱', '', 'http://localhost:9090/files/download/1772719692874-1619027397408.jpg', NULL, NULL, NULL, NULL, 1.00, 30.00, '2026-03-06', '09:01:33', '11:02:33', 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 300, NULL, 0.00, 5, '用户主动取消', NULL, NULL, NULL, '2026-03-05 22:08:15', '2026-03-08 01:42:28', 0);
INSERT INTO `recycle_order` VALUES (4, 'REC202603052228015592', 1, NULL, 1, '北京市北京市朝阳区大街道', 39.92439001, 116.44392609, 1, 1, '李先生', '13700001370', 1, '冰箱', '', 'http://localhost:9090/files/download/1772720879908-1619027397408.jpg', NULL, NULL, NULL, NULL, 1.00, 30.00, '2026-03-06', '09:27:11', '11:27:11', 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 300, NULL, 0.00, 5, '用户主动取消', NULL, NULL, NULL, '2026-03-05 22:28:01', '2026-03-08 01:42:25', 0);
INSERT INTO `recycle_order` VALUES (5, 'REC20260305222852A682', 1, NULL, 1, '北京市北京市朝阳区大街道', 39.92439001, 116.44392609, 1, 1, '李先生', '13700001370', 1, '冰箱', '', 'http://localhost:9090/files/download/1772720930902-1619027397408.jpg', NULL, NULL, NULL, NULL, 1.00, 30.00, '2026-03-06', '11:28:36', '16:28:36', 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 300, NULL, 0.00, 5, '用户主动取消', NULL, NULL, NULL, '2026-03-05 22:28:52', '2026-03-08 01:42:20', 0);
INSERT INTO `recycle_order` VALUES (6, 'REC20260305223044A47C', 1, NULL, 1, '北京市北京市朝阳区大街道', 39.92439001, 116.44392609, 1, 1, '李先生', '13700001370', 1, '冰箱', '', 'http://localhost:9090/files/download/1772721042981-1619027397408.jpg', NULL, NULL, NULL, NULL, 1.00, 30.00, '2026-03-06', '11:30:25', '15:30:25', 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 300, NULL, 0.00, 5, '用户主动取消', NULL, NULL, NULL, '2026-03-05 22:30:44', '2026-03-08 01:42:14', 0);
INSERT INTO `recycle_order` VALUES (7, 'REC202604101812576B4D', 2, NULL, 2, '江苏省南京市鼓楼区南京市鼓楼区雨花西路656号附近', 32.07296700, 118.78815500, 1, 1, '胡女士', '19300001930', 2, '空调', '', 'http://localhost:9090/files/download/1775815487462-美的空调.jpg', '一线品牌', '2-3年', '正常使用', '轻微划痕', 0.86, 40.00, '2026-04-11', '09:00:08', '12:00:48', 1, NULL, NULL, NULL, NULL, NULL, 709.50, NULL, 600, NULL, 0.00, 0, NULL, NULL, NULL, NULL, '2026-04-10 18:12:57', '2026-04-10 18:12:57', 0);

-- ----------------------------
-- Table structure for user
-- ----------------------------
DROP TABLE IF EXISTS `user`;
CREATE TABLE `user`  (
  `id` int(20) NOT NULL AUTO_INCREMENT COMMENT '普通用户ID',
  `username` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '用户名',
  `password` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '密码',
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '用户姓名/昵称',
  `role` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'user' COMMENT '角色标识',
  `account` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '登录账号',
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '手机号',
  `avatar` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '头像',
  `points` int(11) NULL DEFAULT 0 COMMENT '环保积分',
  `total_recycle_count` int(11) NULL DEFAULT 0 COMMENT '总回收次数',
  `total_recycle_weight` decimal(10, 2) NULL DEFAULT 0.00 COMMENT '总回收重量(kg)',
  `carbon_saved` decimal(10, 2) NULL DEFAULT 0.00 COMMENT '累计减碳量(kg)',
  `status` tinyint(1) NULL DEFAULT 1 COMMENT '状态',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_username`(`username` ASC) USING BTREE,
  UNIQUE INDEX `uk_phone`(`phone` ASC) USING BTREE,
  UNIQUE INDEX `account`(`account` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '普通用户表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of user
-- ----------------------------
INSERT INTO `user` VALUES (1, 'aaa', '123', NULL, '普通用户', '', '18332401234', 'http://localhost:9090/files/download/1771312893308-0beecf282a88f57ca5132b97a99621e.jpg', 320, 1, 32.00, 27.20, 1, '2026-02-15 23:08:43', '2026-03-07 16:25:49');
INSERT INTO `user` VALUES (2, 'ccc', 'ccc123456', 'ccc', '普通用户', 'ccc', '19300001930', NULL, 0, 0, NULL, NULL, 1, '2026-04-10 16:24:24', '2026-04-10 16:24:24');

-- ----------------------------
-- Table structure for user_address
-- ----------------------------
DROP TABLE IF EXISTS `user_address`;
CREATE TABLE `user_address`  (
  `id` int(20) NOT NULL AUTO_INCREMENT COMMENT '用户地址ID',
  `user_id` int(20) NOT NULL COMMENT '用户ID',
  `contact_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '联系人',
  `contact_phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '联系电话',
  `province` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '省份',
  `city` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '城市',
  `district` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '区县',
  `detail_address` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '详细地址',
  `latitude` decimal(10, 8) NULL DEFAULT NULL COMMENT '纬度',
  `longitude` decimal(11, 8) NULL DEFAULT NULL COMMENT '经度',
  `building_type` tinyint(1) NULL DEFAULT 1 COMMENT '楼栋类型：1电梯房 2楼梯房',
  `floor` int(3) NULL DEFAULT NULL COMMENT '楼层',
  `is_default` tinyint(1) NULL DEFAULT 0 COMMENT '是否默认地址：0-否 1-是',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '用户地址表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of user_address
-- ----------------------------
INSERT INTO `user_address` VALUES (1, 1, '李先生', '13700001370', '北京市', '北京市', '朝阳区', '大街道', 39.92439001, 116.44392609, 1, 1, 1, '2026-03-05 02:40:24');
INSERT INTO `user_address` VALUES (2, 2, '胡女士', '19300001930', '江苏省', '南京市', '鼓楼区', '南京市鼓楼区雨花西路656号附近', 32.07296700, 118.78815500, 1, 1, 1, '2026-04-10 18:00:15');

-- ----------------------------
-- Table structure for user_badge
-- ----------------------------
DROP TABLE IF EXISTS `user_badge`;
CREATE TABLE `user_badge`  (
  `id` int(20) NOT NULL AUTO_INCREMENT,
  `user_id` int(20) NOT NULL,
  `badge_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '徽章编码',
  `badge_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '徽章名称',
  `badge_icon` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '徽章图标',
  `description` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `obtain_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '获得时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_user_badge`(`user_id` ASC, `badge_code` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '用户徽章表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of user_badge
-- ----------------------------

SET FOREIGN_KEY_CHECKS = 1;
