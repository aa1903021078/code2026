-- 回收员服务区域表
CREATE TABLE IF NOT EXISTS `collector_service_area` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `collector_id` INT NOT NULL COMMENT '回收员ID',
  `province` VARCHAR(50) DEFAULT NULL COMMENT '省',
  `city` VARCHAR(50) DEFAULT NULL COMMENT '市',
  `district` VARCHAR(50) DEFAULT NULL COMMENT '区',
  `community` VARCHAR(100) DEFAULT NULL COMMENT '社区/小区名称',
  `latitude` DECIMAL(10,7) DEFAULT NULL COMMENT '纬度',
  `longitude` DECIMAL(10,7) DEFAULT NULL COMMENT '经度',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_collector_id` (`collector_id`),
  KEY `idx_district_community` (`district`, `community`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='回收员服务区域';

-- 订单表新增 district 字段（用于派单匹配）
ALTER TABLE `recycle_order` ADD COLUMN `district` VARCHAR(50) DEFAULT NULL COMMENT '区' AFTER `community`;

