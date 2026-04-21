package com.example.controller;
import com.example.common.Result;
import com.example.entity.CollectorServiceArea;
import com.example.service.CollectorServiceAreaService;
import jakarta.annotation.Resource;
import org.springframework.web.bind.annotation.*;
@RestController
@RequestMapping("/collectorServiceArea")
public class CollectorServiceAreaController {
    @Resource
    private CollectorServiceAreaService collectorServiceAreaService;
    @PostMapping("/save")
    public Result save(@RequestBody CollectorServiceArea area) {
        collectorServiceAreaService.save(area);
        return Result.success();
    }
    @DeleteMapping("/delete/{collectorId}")
    public Result deleteByCollectorId(@PathVariable Integer collectorId) {
        collectorServiceAreaService.deleteByCollectorId(collectorId);
        return Result.success();
    }
    @GetMapping("/selectByCollectorId/{collectorId}")
    public Result selectByCollectorId(@PathVariable Integer collectorId) {
        CollectorServiceArea area = collectorServiceAreaService.selectByCollectorId(collectorId);
        return Result.success(area);
    }
}
