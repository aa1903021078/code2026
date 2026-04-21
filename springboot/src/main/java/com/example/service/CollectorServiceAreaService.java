package com.example.service;
import com.example.entity.CollectorServiceArea;
import com.example.exception.CustomException;
import com.example.mapper.CollectorServiceAreaMapper;
import jakarta.annotation.Resource;
import org.springframework.stereotype.Service;
import java.util.List;
@Service
public class CollectorServiceAreaService {
    @Resource
    private CollectorServiceAreaMapper collectorServiceAreaMapper;
    /**
     * 保存服务区域（每个回收员只有一个，先删后插）
     */
    public void save(CollectorServiceArea area) {
        if (area.getCollectorId() == null) {
            throw new CustomException("回收员ID不能为空");
        }
        collectorServiceAreaMapper.deleteByCollectorId(area.getCollectorId());
        collectorServiceAreaMapper.insert(area);
    }
    public void deleteByCollectorId(Integer collectorId) {
        collectorServiceAreaMapper.deleteByCollectorId(collectorId);
    }
    public CollectorServiceArea selectByCollectorId(Integer collectorId) {
        List<CollectorServiceArea> list = collectorServiceAreaMapper.selectByCollectorId(collectorId);
        return list.isEmpty() ? null : list.get(0);
    }
}
