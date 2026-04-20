package com.example.mapper;

import com.example.entity.DispatchRecord;
import org.apache.ibatis.annotations.Param;

import java.util.List;
import java.util.Map;

public interface DispatchRecordMapper {
    void insert(DispatchRecord dispatchRecord);

    void updateAcceptStatus(@Param("orderId")Integer orderId, @Param("collectorId")Integer collectorId,@Param("isAccepted")Integer isAccepted);

    /**
     * 查询最近的派单记录（关联订单号和回收员姓名）
     */
    List<Map<String, Object>> selectRecent(@Param("limit") int limit);

    /**
     * 今日已派单数
     */
    int countToday();
}
