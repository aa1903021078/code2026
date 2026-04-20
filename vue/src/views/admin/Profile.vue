<template>
  <div class="admin-profile">
    <!-- 个人信息卡片 -->
    <el-card>
      <template #header>
        <div class="header">
          <span>👤 个人信息</span>
          <el-button type="primary" size="small" @click="editMode = !editMode">
            {{ editMode ? '取消编辑' : '编辑信息' }}
          </el-button>
        </div>
      </template>

      <div class="profile-content">
        <div class="avatar-section">
          <el-avatar :size="100" :src="adminInfo.avatar || defaultAvatar" />
          <h3>{{ adminInfo.name || '管理员' }}</h3>
          <el-tag type="success">{{ adminInfo.role || '超级管理员' }}</el-tag>
        </div>

        <!-- 只读模式 -->
        <el-descriptions v-if="!editMode" :column="2" border style="margin-top: 20px;">
          <el-descriptions-item label="用户名">{{ adminInfo.username }}</el-descriptions-item>
          <el-descriptions-item label="姓名">{{ adminInfo.name }}</el-descriptions-item>
          <el-descriptions-item label="手机号">{{ adminInfo.phone || '未设置' }}</el-descriptions-item>
          <el-descriptions-item label="邮箱">{{ adminInfo.email || '未设置' }}</el-descriptions-item>
        </el-descriptions>

        <!-- 编辑模式 -->
        <el-form v-else :model="editForm" label-width="80px" style="margin-top: 20px; max-width: 500px; margin-left: auto; margin-right: auto;">
          <el-form-item label="姓名">
            <el-input v-model="editForm.name" />
          </el-form-item>
          <el-form-item label="手机号">
            <el-input v-model="editForm.phone" />
          </el-form-item>
          <el-form-item label="邮箱">
            <el-input v-model="editForm.email" />
          </el-form-item>
          <el-form-item>
            <el-button type="primary" @click="saveProfile" :loading="saving">保存</el-button>
          </el-form-item>
        </el-form>
      </div>
    </el-card>

    <!-- 修改密码 -->
    <el-card style="margin-top: 20px;">
      <template #header>
        <span>🔒 修改密码</span>
      </template>
      <el-form :model="pwdForm" :rules="pwdRules" ref="pwdFormRef" label-width="100px" style="max-width: 500px; margin: 0 auto;">
        <el-form-item label="原密码" prop="password">
          <el-input v-model="pwdForm.password" type="password" show-password />
        </el-form-item>
        <el-form-item label="新密码" prop="newPassword">
          <el-input v-model="pwdForm.newPassword" type="password" show-password />
        </el-form-item>
        <el-form-item label="确认新密码" prop="confirmPassword">
          <el-input v-model="pwdForm.confirmPassword" type="password" show-password />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="changePassword" :loading="changingPwd">确认修改</el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <!-- 系统信息 -->
    <el-card style="margin-top: 20px;">
      <template #header>
        <span>ℹ️ 系统信息</span>
      </template>
      <el-descriptions :column="2">
        <el-descriptions-item label="系统版本">v2.0.0</el-descriptions-item>
        <el-descriptions-item label="运行环境">Production</el-descriptions-item>
        <el-descriptions-item label="当前时间">{{ currentTime }}</el-descriptions-item>
      </el-descriptions>
    </el-card>

    <!-- 退出登录 -->
    <div style="text-align: center; margin-top: 30px;">
      <el-button type="danger" size="large" @click="logout" style="width: 200px;">
        <el-icon><SwitchButton /></el-icon>
        退出登录
      </el-button>
    </div>
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

const editForm = reactive({ name: '', phone: '', email: '' })

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
  editForm.phone = user.phone || ''
  editForm.email = user.email || ''

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
      name: editForm.name,
      phone: editForm.phone,
      email: editForm.email
    })
    if (res && res.code && res.code !== '200') {
      ElMessage.error(res.msg || '保存失败')
      return
    }
    const updated = { ...adminInfo.value, name: editForm.name, phone: editForm.phone, email: editForm.email }
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

<style scoped lang="scss">
.admin-profile {
  max-width: 800px;
  margin: 0 auto;

  .header {
    display: flex;
    justify-content: space-between;
    align-items: center;
  }

  .profile-content {
    .avatar-section {
      text-align: center;
      margin-bottom: 10px;

      h3 {
        margin: 15px 0 8px;
        font-size: 20px;
        color: #262626;
      }
    }
  }
}
</style>