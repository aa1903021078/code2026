<template>
  <div class="address-form">
    <el-form :model="form" :rules="rules" ref="formRef" label-width="100px">
      <el-form-item label="地图定位" prop="latitude">
        <div class="map-wrapper">
          <div class="map-box">
            <div class="map-toolbar">
              <div class="search-box">
                <el-icon><Search /></el-icon>
                <input v-model="searchKeyword" placeholder="搜索地点" @focus="showSearchPanel = true" @keyup.enter="handleSearch" />
                <el-icon v-if="searchKeyword" class="clear-btn" @click="clearSearch"><CircleClose /></el-icon>
              </div>
              <el-button size="small" class="locate-btn" @click="getCurrentLocation">
                <el-icon><Aim /></el-icon> 定位
              </el-button>
            </div>
            <div ref="mapContainer" class="real-map"></div>
            <div class="selected-location" v-if="selectedAddress">
              <el-icon class="loc-icon"><LocationFilled /></el-icon>
              <div class="loc-info">
                <div class="loc-name">{{ selectedAddress.name }}</div>
                <div class="loc-detail">{{ selectedAddress.detail }}</div>
                <div class="loc-coord">
                  经纬度：{{ form.longitude?.toFixed(6) }}, {{ form.latitude?.toFixed(6) }}
                  <span class="update-tag" v-if="justUpdated">已更新</span>
                </div>
              </div>
            </div>
          </div>
          <div v-if="showSearchPanel && searchResults.length" class="search-panel">
            <div class="panel-header">
              <span>搜索结果</span>
              <el-icon class="close-btn" @click="showSearchPanel = false"><Close /></el-icon>
            </div>
            <div v-for="(item, index) in searchResults" :key="index" class="search-item" @click="selectSearchResult(item)">
              <el-icon><Location /></el-icon>
              <div class="item-info">
                <div class="item-name">{{ item.name }}</div>
                <div class="item-addr">{{ item.address }}</div>
              </div>
            </div>
          </div>
        </div>
      </el-form-item>
      <el-form-item label="所在地区" prop="region">
        <el-cascader :key="cascaderKey" v-model="form.region" :options="regionData"
            :props="{ value: 'name', label: 'name', children: 'children', checkStrictly: false }"
            placeholder="省 / 市 / 区" filterable clearable style="width: 100%" @change="onRegionChange" />
      </el-form-item>
      <el-form-item label="社区/小区" prop="community">
        <el-input v-model="form.community" placeholder="请输入所在社区或小区名称，如：阳光花园、幸福小区" maxlength="50">
          <template #prefix><el-icon><OfficeBuilding /></el-icon></template>
        </el-input>
      </el-form-item>
      <el-form-item label="详细地址" prop="detailAddress">
        <el-input v-model="form.detailAddress" type="textarea" :rows="2" placeholder="街道、门牌号、楼栋等" maxlength="100" show-word-limit />
        <div class="input-hint" v-if="addressFromMap">
          <el-icon><InfoFilled /></el-icon>
          <span>已根据地图位置自动填充，可手动修改</span>
        </div>
      </el-form-item>
      <el-divider content-position="left"><el-icon><User /></el-icon> 联系人信息</el-divider>
      <el-form-item label="联系人" prop="contactName">
        <el-input v-model="form.contactName" placeholder="姓名" maxlength="20">
          <template #prefix><el-icon><User /></el-icon></template>
        </el-input>
      </el-form-item>
      <el-form-item label="手机号" prop="contactPhone">
        <el-input v-model="form.contactPhone" placeholder="手机号" maxlength="11">
          <template #prefix><el-icon><Phone /></el-icon></template>
        </el-input>
      </el-form-item>
      <el-divider content-position="left"><el-icon><OfficeBuilding /></el-icon> 楼栋信息</el-divider>
      <el-form-item label="楼栋类型" prop="buildingType">
        <el-radio-group v-model="form.buildingType">
          <el-radio-button :label="1"><el-icon><OfficeBuilding /></el-icon> 电梯房</el-radio-button>
          <el-radio-button :label="2"><el-icon><House /></el-icon> 楼梯房</el-radio-button>
        </el-radio-group>
      </el-form-item>
      <el-form-item label="楼层" v-if="form.buildingType === 2" prop="floor">
        <el-input-number v-model="form.floor" :min="1" :max="50" controls-position="right" />
        <span class="unit">层</span>
      </el-form-item>
      <el-form-item label="设为默认">
        <el-switch v-model="form.isDefault" :active-value="1" :inactive-value="0" active-text="默认地址" inactive-text="普通地址" />
      </el-form-item>
      <el-form-item class="form-actions">
        <el-button type="primary" @click="submit" :loading="loading" size="large"><el-icon><Check /></el-icon> 保存地址</el-button>
        <el-button @click="$emit('cancel')" size="large">取消</el-button>
      </el-form-item>
    </el-form>
  </div>
</template>
<script setup>
import { ref, reactive, onMounted, onUnmounted, nextTick } from 'vue'
import { ElMessage } from 'element-plus'
import {
  Search, Aim, Location, InfoFilled, OfficeBuilding, House,
  User, Phone, LocationFilled, Check, Close, CircleClose
} from '@element-plus/icons-vue'
import request from '@/utils/request'
import regionData from '@/assets/region-data.json'
const props = defineProps({
  editData: { type: Object, default: null }
})
const emit = defineEmits(['success', 'cancel'])
const formRef = ref()
const loading = ref(false)
const searchKeyword = ref('')
const showSearchPanel = ref(false)
const selectedAddress = ref(null)
const searchResults = ref([])
const mapContainer = ref(null)
const addressFromMap = ref(false)
const justUpdated = ref(false)
const cascaderKey = ref(0)
let map = null
let marker = null
let geocoder = null
let searchSvc = null
const form = reactive({
  userId: '',
  contactName: '',
  contactPhone: '',
  region: [],
  province: '',
  city: '',
  district: '',
  community: '',
  detailAddress: '',
  latitude: null,
  longitude: null,
  buildingType: 1,
  floor: 1,
  isDefault: 0
})
const rules = {
  region: [{ required: true, message: '请选择所在地区', trigger: 'change' }],
  community: [{ required: true, message: '请输入社区/小区名称', trigger: 'blur' }],
  detailAddress: [{ required: true, message: '请输入详细地址', trigger: 'blur' }],
  contactName: [{ required: true, message: '请输入联系人姓名', trigger: 'blur' }],
  contactPhone: [
    { required: true, message: '请输入手机号', trigger: 'blur' },
    { pattern: /^1[3-9]\d{9}$/, message: '手机号格式不正确', trigger: 'blur' }
  ],
  floor: [{ required: true, message: '请输入楼层', trigger: 'change', type: 'number' }],
  latitude: [{ required: true, message: '请在地图上选择位置', trigger: 'change', type: 'number' }]
}
onMounted(() => {
  if (props.editData) {
    const d = props.editData
    Object.assign(form, {
      id: d.id,
      userId: d.userId,
      contactName: d.contactName || '',
      contactPhone: d.contactPhone || '',
      province: d.province || '',
      city: d.city || '',
      district: d.district || '',
      community: d.community || '',
      detailAddress: d.detailAddress || '',
      latitude: d.latitude || null,
      longitude: d.longitude || null,
      buildingType: d.buildingType !== undefined ? d.buildingType : 1,
      floor: d.floor || 1,
      isDefault: d.isDefault || 0,
      region: (d.province && d.city && d.district) ? [d.province, d.city, d.district] : []
    })
    cascaderKey.value++
  }
  nextTick(() => { initMap() })
  document.addEventListener('click', handleClickOutside)
})
onUnmounted(() => {
  if (map) { map.destroy(); map = null }
  document.removeEventListener('click', handleClickOutside)
})
const initMap = () => {
  if (!mapContainer.value || !window.TMap) {
    ElMessage.error('地图加载失败，请刷新页面')
    return
  }
  const defaultCenter = new TMap.LatLng(39.9042, 116.4074)
  map = new TMap.Map(mapContainer.value, {
    center: defaultCenter,
    zoom: 14,
    viewMode: '2D'
  })
  geocoder = new TMap.service.Geocoder()
  try { searchSvc = new TMap.service.Search({ pageSize: 6 }) } catch (e) { console.warn(e) }
  map.on('click', (evt) => {
    placeMarker(evt.latLng)
    reverseGeocode(evt.latLng)
  })
  // 编辑模式：定位到已有坐标
  if (form.latitude && form.longitude) {
    const latLng = new TMap.LatLng(form.latitude, form.longitude)
    map.setCenter(latLng)
    map.setZoom(15)
    placeMarker(latLng)
    selectedAddress.value = { name: form.detailAddress || '', detail: `${form.province} ${form.city} ${form.district}` }
  } else {
    getCurrentLocation()
  }
}
const placeMarker = (latLng) => {
  form.latitude = latLng.lat
  form.longitude = latLng.lng
  if (marker) { marker.setMap(null); marker = null }
  marker = new TMap.MultiMarker({
    map: map,
    geometries: [{ id: 'sel', position: latLng }]
  })
}
const reverseGeocode = (latLng) => {
  if (!geocoder) return
  geocoder.getAddress({ location: latLng }).then((result) => {
    const res = result.result
    const comp = res.address_component
    form.province = comp.province
    form.city = comp.city
    form.district = comp.district
    form.region = [comp.province, comp.city, comp.district]
    cascaderKey.value++
    const detail = res.formatted_addresses?.recommend || res.address || ''
    form.detailAddress = detail
    addressFromMap.value = true
    selectedAddress.value = { name: detail, detail: res.address }
    justUpdated.value = true
    setTimeout(() => { justUpdated.value = false }, 2000)
  }).catch((err) => { console.error('逆地址解析失败:', err) })
}
const handleSearch = () => {
  const kw = searchKeyword.value.trim()
  if (!kw) return
  searchResults.value = []
  // 先用地址解析（支持城市名、详细地址）
  if (geocoder) {
    geocoder.getLocation({ address: kw }).then((result) => {
      if (result && result.result && result.result.location) {
        const r = result.result
        searchResults.value.push({
          name: r.title || kw,
          address: r.address || kw,
          location: r.location
        })
        showSearchPanel.value = true
      }
    }).catch(() => {})
  }
  // 同时搜附近POI（以当前地图中心为基准，扩大范围）
  if (searchSvc) {
    const center = map.getCenter()
    searchSvc.searchNearby({ keyword: kw, center: center, radius: 50000 }).then((result) => {
      const list = (result.data || []).map(item => ({
        name: item.title, address: item.address, location: item.location
      }))
      const existNames = searchResults.value.map(i => i.name)
      list.forEach(p => { if (!existNames.includes(p.name)) searchResults.value.push(p) })
      showSearchPanel.value = true
      if (!searchResults.value.length) ElMessage.info('未找到相关地点')
    }).catch((err) => {
      console.warn('POI搜索失败:', err)
      showSearchPanel.value = true
      if (!searchResults.value.length) ElMessage.info('未找到相关地点')
    })
  }
}
const clearSearch = () => { searchKeyword.value = ''; searchResults.value = []; showSearchPanel.value = false }
const selectSearchResult = (item) => {
  const latLng = new TMap.LatLng(item.location.lat, item.location.lng)
  map.setCenter(latLng)
  map.setZoom(16)
  placeMarker(latLng)
  reverseGeocode(latLng)
  searchKeyword.value = item.name
  showSearchPanel.value = false
}
const getCurrentLocation = () => {
  // 优先用浏览器定位
  if (navigator.geolocation) {
    navigator.geolocation.getCurrentPosition(
      (pos) => {
        const latLng = new TMap.LatLng(pos.coords.latitude, pos.coords.longitude)
        map.setCenter(latLng)
        map.setZoom(15)
        placeMarker(latLng)
        reverseGeocode(latLng)
        ElMessage.success('定位成功')
      },
      () => { ipLocate() },
      { enableHighAccuracy: true, timeout: 5000 }
    )
  } else {
    ipLocate()
  }
}
// IP定位兜底 - 通过 jsonp 调用腾讯位置服务 IP 定位
const ipLocate = () => {
  const callbackName = '_qqmap_ip_cb_' + Date.now()
  window[callbackName] = (res) => {
    delete window[callbackName]
    document.head.removeChild(script)
    if (res && res.status === 0 && res.result) {
      const loc = res.result.location
      const latLng = new TMap.LatLng(loc.lat, loc.lng)
      map.setCenter(latLng)
      map.setZoom(14)
      placeMarker(latLng)
      reverseGeocode(latLng)
      ElMessage.success('已定位到 ' + (res.result.ad_info?.city || '当前位置'))
    } else {
      ElMessage.warning('定位失败，请手动在地图上选择位置')
    }
  }
  const script = document.createElement('script')
  script.src = 'https://apis.map.qq.com/ws/location/v1/ip?key=CXPBZ-EML6W-PKURO-3MD5P-PRNFE-FPBD3&output=jsonp&callback=' + callbackName
  document.head.appendChild(script)
}
const onRegionChange = (val) => {
  if (val && val.length === 3) { form.province = val[0]; form.city = val[1]; form.district = val[2] }
}
const submit = async () => {
  try { await formRef.value.validate() } catch (e) { return }
  if (!form.latitude || !form.longitude) { ElMessage.warning('请在地图上选择位置'); return }
  loading.value = true
  try {
    const user = JSON.parse(localStorage.getItem('user') || '{}')
    if (!user?.id) { ElMessage.error('用户ID不存在'); return }
    form.userId = user.id
    const submitData = { ...form }
    delete submitData.region
    let res
    if (props.editData && props.editData.id) {
      res = await request.put('/userAddress/update', submitData)
    } else {
      res = await request.post('/userAddress/add', submitData)
    }
    emit('success', res)
  } catch (error) {
    ElMessage.error(error.message || (props.editData ? '修改失败' : '添加失败'))
  } finally { loading.value = false }
}
const handleClickOutside = (e) => {
  if (!e.target.closest('.search-box') && !e.target.closest('.search-panel')) showSearchPanel.value = false
}
</script>
<style scoped lang="scss">
.address-form {
  max-width: 800px;
  margin: 0 auto;
  .map-wrapper { position: relative; }
  .map-box {
    border: 1px solid #dcdfe6;
    border-radius: 8px;
    .map-toolbar {
      padding: 12px;
      background: #f5f7fa;
      border-bottom: 1px solid #e4e7ed;
      display: flex;
      gap: 10px;
      align-items: center;
      .search-box {
        flex: 1;
        display: flex;
        align-items: center;
        background: white;
        border: 1px solid #dcdfe6;
        border-radius: 4px;
        padding: 0 12px;
        height: 32px;
        &:focus-within { border-color: #409eff; }
        input { flex: 1; border: none; outline: none; font-size: 13px; margin: 0 8px; color: #606266; }
        .clear-btn { cursor: pointer; color: #c0c4cc; &:hover { color: #909399; } }
      }
      .locate-btn {
        border-color: #dcdfe6; color: #606266;
        &:hover { color: #409eff; border-color: #409eff; background: #ecf5ff; }
      }
    }
    .real-map { height: 350px; width: 100%; overflow: hidden; }
    .selected-location {
      padding: 8px 12px;
      background: #e3f2fd;
      border-top: 1px solid #bbdefb;
      display: flex;
      align-items: center;
      gap: 8px;
      .loc-icon { color: #1976d2; font-size: 20px; }
      .loc-info {
        flex: 1; overflow: hidden;
        .loc-name { color: #1565c0; font-weight: 600; font-size: 14px; margin-bottom: 2px; }
        .loc-detail { color: #424242; font-size: 13px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
        .loc-coord {
          color: #757575; font-size: 12px; margin-top: 2px; display: flex; align-items: center; gap: 8px;
          .update-tag { background: #1976d2; color: white; padding: 0 6px; border-radius: 4px; font-size: 11px; }
        }
      }
    }
  }
  .search-panel {
    position: absolute; top: 50px; left: 12px; right: 12px;
    background: white; border-radius: 8px; box-shadow: 0 4px 12px rgba(0,0,0,0.15);
    max-height: 300px; overflow-y: auto; z-index: 9999;
    .panel-header {
      padding: 12px; border-bottom: 1px solid #e3f2fd; display: flex;
      justify-content: space-between; align-items: center; font-weight: 500; color: #1976d2;
      .close-btn { cursor: pointer; color: #90a4ae; &:hover { color: #1976d2; } }
    }
    .search-item {
      padding: 12px; display: flex; align-items: flex-start; gap: 8px;
      cursor: pointer; border-bottom: 1px solid #f5f5f5;
      &:hover { background: #e3f2fd; }
      .el-icon { color: #1976d2; margin-top: 2px; }
      .item-info {
        flex: 1;
        .item-name { font-size: 14px; color: #1976d2; margin-bottom: 4px; font-weight: 500; }
        .item-addr { font-size: 12px; color: #616161; }
      }
    }
  }
  .input-hint { margin-top: 6px; font-size: 12px; color: #1976d2; display: flex; align-items: center; gap: 4px; }
  .unit { margin-left: 8px; color: #909399; }
  .form-actions {
    margin-top: 30px; padding-top: 20px; border-top: 1px solid #e0e0e0;
    .el-button { min-width: 120px; }
    .el-button--primary { background: #1976d2; border-color: #1976d2; &:hover { background: #1565c0; border-color: #1565c0; } }
  }
  :global(.el-divider__text) { font-size: 14px; color: #424242; font-weight: 600; display: flex; align-items: center; gap: 6px; }
}
</style>
