package com.example.mapper;
import com.example.entity.CollectorServiceArea;
import org.apache.ibatis.annotations.Param;
import java.util.List;
public interface CollectorServiceAreaMapper {
    void insert(CollectorServiceArea area);
    void deleteById(Integer id);
    void deleteByCollectorId(Integer collectorId);
    List<CollectorServiceArea> selectByCollectorId(Integer collectorId);
    int countByCollectorId(Integer collectorId);
}
