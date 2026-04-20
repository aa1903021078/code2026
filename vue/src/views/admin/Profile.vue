<template>
  <div class="admin-profile">
    <!-- 第一行：个人信息 + 修改密码 -->
    <div class="row">
      <div class="profile-card">
        <div class="card-inner">
          <div class="avatar-section">
            <el-avatar :size="72" :src="adminInfo.avatar || defaultAvatar" />
            <div class="user-meta">
              <h3>{{ adminInfo.name || '管理员' }}</h3>
              <el-tag type="success" size="small">{{ adminInfo.role === 'ADMIN' ? '超级管理员' : '管理员' }}</el-tag>
            </div>
          </div>
          <div class="info-list">
            <div class="info-item">
              <span class="label">用户名</span>
              <span class="value">{{ adminInfo.username || '-' }}</span>
            </div>
            <div class="info-item">
              <span class="label">姓名</span>
              <span class="value">{{ adminInfo.name || '未设置' }}</span>
            </div>
            <div class="info-item">
              <span class="label">创建时间</span>
              <span class="value">{{ adminInfo.createTime || '-' }}</span>
            </div>
          </div>
          <el-button type="primary" class="edit-btn" @click="editMode = true">编辑信息</el-button>
        </div>
      </div>

      <div class="pwd-card">
        <div class="card-inner">
          <div class="section-header">🔒 修改密码</div>
          <el-form :model="pwdForm" :rules="pwdRules" ref="pwdFormRef" label-width="100px">
            <el-form-item label="原密码" prop="password">
              <el-input v-model="pwdForm.password" type="password" show-password placeholder="请输入原密码" />
            </el-form-item>
            <el-form-item label="新密码" prop="newPassword">
              <el-input v-model="pwdForm.newPassword" type="password" show-password placeholder="请输入新密码" />
            </el-form-item>
            <el-form-item label="确认新密码" prop="confirmPassword">
              <el-input v-model="pwdForm.confirmPassword" type="password" show-password placeholder="请再次输入新密码" />
            </el-form-item>
            <el-form-item>
              <el-button type="primary" @click="changePassword" :loading="changingPwd">确认修改</el-button>
            </el-form-item>
          </el-form>
        </div>
      </div>
    </div>

    <!-- 第二行：系统信息 + 退出登录 -->
    <div class="row">
      <div class="profile-card">
        <div class="card-inner">
          <div class="section-header">ℹ️ 系统信息</div>
          <div class="sys-info-list">
            <div class="sys-info-item">
              <span class="label">系统版本</span>
              <span class="value">v2.0.0</span>
            </div>
            <div class="sys-info-item">
              <span class="label">运行环境</span>
              <span class="value">Production</span>
            </div>
            <div class="sys-info-item">
              <span class="label">当前时间</span>
              <span class="value">{{ currentTime }}</span>
            </div>
          </div>
        </div>
      </div>

      <div class="pwd-card">
        <div class="card-inner logout-card">
          <div class="section-header">🚪 账户操作</div>
          <div class="logout-content">
            <p class="logout-tip">退出后需要重新登录才能使用管理系统</p>
            <el-button type="danger" @click="logout" class="logout-btn">
              <el-icon><SwitchButton /></el-icon>
              退出登录
            </el-button>
          </div>
        </div>
      </div>
    </div>

    <!-- 编辑信息弹窗 -->
    <el-dialog v-model="editMode" title="编辑个人信息" width="500px" :close-on-click-modal="false">
      <el-form :model="editForm" label-width="80px">
        <el-form-item label="用户名">
          <el-input v-model="adminInfo.username" disabled />
        </el-form-item>
        <el-form-item label="姓名">
          <el-input v-model="editForm.name" placeholder="请输入姓名" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="editMode = false">取 消</el-button>
        <el-button type="primary" @click="saveProfile" :loading="saving">保 存</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, onUnmounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { SwitchButton } from '@element-plus/icons-vue'
import request from '@/utils/request'

const router = useRouter()
const defaultAvatar = 'https://cube.elemecdn.com/0/88/03b0d39583f48206768a7534e55bcpng.png'

const adminInfo = ref({})
const editMode = ref(false)
const saving = ref(false)
const changingPwd = ref(false)
const currentTime = ref('')
let timer = null

const editForm = reactive({ name: '' })

const pwdForm = reactive({ password: '', newPassword: '', confirmPassword: '' })
const pwdFormRef = ref(null)
const pwdRules = {
  password: [{ required: true, message: '请输入原密码', trigger: 'blur' }],
  newPassword: [
    { required: true, message: '请输入新密码', trigger: 'blur' },
    { min: 3, message: '密码至少3位', trigger: 'blur' }
  ],
  confirmPassword: [
    { required: true, message: '请确认新密码', trigger: 'blur' },
    { validator: (rule, value, callback) => {
        if (value !== pwdForm.newPassword) callback(new Error('两次密码不一致'))
        else callback()
      }, trigger: 'blur' }
  ]
}

onMounted(() => {
  const user = JSON.parse(localStorage.getItem('user') || '{}')
  adminInfo.value = user
  editForm.name = user.name || ''

  timer = setInterval(() => {
    currentTime.value = new Date().toLocaleString()
  }, 1000)
})

onUnmounted(() => {
  clearInterval(timer)
})

const saveProfile = async () => {
  saving.value = true
  try {
    const res = await request.put('/admin/update', {
      id: adminInfo.value.id,
      name: editForm.name
    })
    if (res && res.code && res.code !== '200') {
      ElMessage.error(res.msg || '保存失败')
      return
    }
    const updated = { ...adminInfo.value, name: editForm.name }
    localStorage.setItem('user', JSON.stringify(updated))
    adminInfo.value = updated
    editMode.value = false
    ElMessage.success('保存成功')
  } catch (e) {
    ElMessage.error('保存失败')
  } finally {
    saving.value = false
  }
}

const changePassword = async () => {
  if (!pwdFormRef.value) return
  await pwdFormRef.value.validate(async (valid) => {
    if (!valid) return
    changingPwd.value = true
    try {
      const res = await request.put('/admin/updatePassword', {
        username: adminInfo.value.username,
        password: pwdForm.password,
        newPassword: pwdForm.newPassword
      })
      if (res && res.code && res.code !== '200') {
        ElMessage.error(res.msg || '修改失败')
        return
      }
      ElMessage.success('密码修改成功，请重新登录')
      localStorage.clear()
      router.push('/login')
    } catch (e) {
      ElMessage.error('修改失败')
    } finally {
      changingPwd.value = false
    }
  })
}

const logout = async () => {
  try {
    await ElMessageBox.confirm('确认退出管理系统？', '提示', {
      confirmButtonText: '确认退出',
      cancelButtonText: '取消',
      type: 'warning'
    })
    localStorage.clear()
    ElMessage.success('已安全退出')
    router.push('/login')
  } catch (e) {}
}
</script>

<style scoped>
.admin-profile {
  padding: 20px;
  background-color: #f5f7fa;
  min-height: calc(100vh - 60px);
}

.row {
  display: flex;
  gap: 20px;
  margin-bottom: 20px;
}

.profile-card {
  width: 300px;
  flex-shrink: 0;
}

.pwd-card {
  flex: 1;
}

.row .profile-card > .card-inner,
.row .pwd-card > .card-inner {
  height: 100%;
  box-sizing: border-box;
}

.card-inner {
  background: #fff;
  border-radius: 12px;
  padding: 24px;
  box-shadow: 0 2px 12px 0 rgba(0, 0, 0, 0.05);
}

.avatar-section {
  display: flex;
  align-items: center;
  gap: 16px;
  padding-bottom: 20px;
  border-bottom: 1px solid #f0f0f0;
}

.user-meta h3 {
  margin: 0 0 8px;
  font-size: 18px;
  color: #303133;
}

.info-list {
  padding-top: 16px;
}

.info-item {
  display: flex;
  justify-content: space-between;
  padding: 10px 0;
  border-bottom: 1px solid #f5f5f5;
}

.info-item:last-child {
  border-bottom: none;
}

.info-item .label {
  color: #909399;
  font-size: 14px;
}

.info-item .value {
  color: #303133;
  font-size: 14px;
  font-weight: 500;
}

.edit-btn {
  width: 100%;
  margin-top: 16px;
}

.section-header {
  font-size: 16px;
  font-weight: 500;
  color: #303133;
  margin-bottom: 20px;
  padding-bottom: 12px;
  border-bottom: 1px solid #f0f0f0;
}

.sys-info-list .sys-info-item {
  display: flex;
  justify-content: space-between;
  padding: 10px 0;
  border-bottom: 1px solid #f5f5f5;
}

.sys-info-list .sys-info-item:last-child {
  border-bottom: none;
}

.sys-info-item .label {
  color: #909399;
  font-size: 14px;
}

.sys-info-item .value {
  color: #303133;
  font-size: 14px;
  font-weight: 600;
}

.logout-card {
  display: flex;
  flex-direction: column;
}

.logout-content {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
}

.logout-tip {
  color: #909399;
  font-size: 14px;
  margin: 0 0 20px;
}

.logout-btn {
  width: 200px;
}
</style>