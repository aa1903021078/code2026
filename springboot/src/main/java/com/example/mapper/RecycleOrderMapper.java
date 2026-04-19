package com.example.mapper;

import com.example.entity.RecycleOrder;
import org.apache.ibatis.annotations.Param;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;

/**
 * 操作recycle_order相关数据接口
 */
public interface RecycleOrderMapper {


    void insert(RecycleOrder recycleOrder);

    void deleteById(Integer id);


    void updateById(RecycleOrder recycleOrder);

    RecycleOrder selectById(Integer id);


    List<RecycleOrder> selectAll(RecycleOrder recycleOrder);

    List<RecycleOrder> selectByUser(Integer userId);

    List<RecycleOrder> selectByCollector(Integer collectorId);

    List<RecycleOrder> selectByStatus(Integer status);

    BigDecimal selectAvgRatingByCollector(Integer collectorId);

    int countTotal();

    int countToday();

    int countByStatus(@Param("status") Integer status);

    BigDecimal sumTotalWeight();

    int countActiveUsers();

    BigDecimal sumTotalCarbonSaved();


    List<Map<String, Object>> selectApplianceTypeStats();

    List<Map<String, Object>> selectCollectorRanking(@Param("limit") Integer limit);

    RecycleOrder selectByIdWithVersion(@Param("id") Integer orderId);

    int grabOrderWithVersion(@Param("id") Integer orderId,
                             @Param("collectorId") Integer collectorId,
                             @Param("oldVersion") Integer oldVersion);

    /**
     * 查询回收员月度统计
     */
    Map<String, Object> selectCollectorMonthStats(@Param("collectorId") Integer collectorId);

    /**
     * 查询回收员每日收入明细
     */
    List<Map<String, Object>> selectCollectorIncomeList(@Param("collectorId") Integer collectorId, @Param("days") Integer days);
}
