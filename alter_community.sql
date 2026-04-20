-- 第一批数据库变更：增加社区相关字段

-- 1. user_address 增加社区/小区字段
ALTER TABLE user_address ADD COLUMN community VARCHAR(100) COMMENT '社区/小区名称' AFTER district;

-- 2. recycle_order 增加社区和指定回收员字段
ALTER TABLE recycle_order ADD COLUMN community VARCHAR(100) COMMENT '社区/小区名称' AFTER address_detail;
ALTER TABLE recycle_order ADD COLUMN preferred_collector_id INT COMMENT '用户指定的回收员ID' AFTER collector_id;

