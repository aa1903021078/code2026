package com.example.entity;
import java.math.BigDecimal;
import java.time.LocalDateTime;
public class CollectorServiceArea {
    private Integer id;
    private Integer collectorId;
    private String province;
    private String city;
    private String district;
    private String community;
    private BigDecimal latitude;
    private BigDecimal longitude;
    private LocalDateTime createTime;
    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }
    public Integer getCollectorId() { return collectorId; }
    public void setCollectorId(Integer collectorId) { this.collectorId = collectorId; }
    public String getProvince() { return province; }
    public void setProvince(String province) { this.province = province; }
    public String getCity() { return city; }
    public void setCity(String city) { this.city = city; }
    public String getDistrict() { return district; }
    public void setDistrict(String district) { this.district = district; }
    public String getCommunity() { return community; }
    public void setCommunity(String community) { this.community = community; }
    public BigDecimal getLatitude() { return latitude; }
    public void setLatitude(BigDecimal latitude) { this.latitude = latitude; }
    public BigDecimal getLongitude() { return longitude; }
    public void setLongitude(BigDecimal longitude) { this.longitude = longitude; }
    public LocalDateTime getCreateTime() { return createTime; }
    public void setCreateTime(LocalDateTime createTime) { this.createTime = createTime; }
}
