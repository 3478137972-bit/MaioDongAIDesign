# Vercel 自动部署配置指南

## 🚀 快速开始（5 分钟完成）

### 方案：GitHub + Vercel 自动部署

**优势：**
- ✅ 零配置 - Vercel 自动检测 Next.js 项目
- ✅ 免费 - 个人项目完全免费
- ✅ 自动 HTTPS - 无需配置证书
- ✅ 全球 CDN - 自动加速
- ✅ 预览部署 - 每个 PR 自动生成预览链接

---

## 📋 配置步骤

### Step 1: 在 Vercel 连接 GitHub 仓库

**访问：**
```
https://vercel.com/new
```

**操作步骤：**
1. 登录 Vercel（使用 GitHub 账号）
2. 点击 **"Add New Project"**
3. 选择 **"Import Git Repository"**
4. 找到 `MiaoDongAI_Design` 仓库
5. 点击 **"Import"**

**⏰ 时间**: 2 分钟

---

### Step 2: 配置环境变量

**在 Vercel 项目设置中：**
```
https://vercel.com/你的用户名/miaodong-ai-design/settings/environment-variables
```

**添加以下变量：**

| 变量名 | 值 | 环境 |
|--------|-----|------|
| `DEEPSEEK_API_KEY` | 你的 DeepSeek 密钥 | Production + Preview |
| `KIEAI_API_KEY` | 你的 KIEAI 密钥 | Production + Preview |
| `SUPABASE_URL` | Supabase 项目 URL | Production + Preview |
| `SUPABASE_KEY` | Supabase 密钥 | Production + Preview |

**⏰ 时间**: 3 分钟

---

### Step 3: 部署！

**点击 "Deploy" 按钮**

Vercel 将自动：
1. 克隆你的 GitHub 仓库
2. 安装依赖（pnpm/npm）
3. 构建项目（Next.js）
4. 部署到全球 CDN

**部署完成后你会得到：**
- 生产环境 URL: `https://miaodong-ai-design.vercel.app`
- 预览环境 URL: `https://miaodong-ai-design-git-branchname.vercel.app`

**⏰ 时间**: 构建约 1-2 分钟

---

## 🔄 自动部署流程

### 推送到 main 分支
```
git push origin main
    ↓
GitHub 接收推送
    ↓
Vercel 检测到变更
    ↓
自动构建 + 部署
    ↓
生产环境更新完成！
```

### 创建新分支/PR
```
git checkout -b feature/new-feature
git push origin feature/new-feature
    ↓
Vercel 创建预览部署
    ↓
生成预览链接（可在 PR 中查看）
```

---

## 🛠️ 高级配置（可选）

### vercel.json 配置示例

```json
{
  "framework": "nextjs",
  "buildCommand": "pnpm build",
  "devCommand": "pnpm dev",
  "installCommand": "pnpm install",
  "outputDirectory": ".next",
  "regions": ["hnd1"],  // 东京区域，亚洲访问更快
  "env": {
    "NODE_ENV": "production"
  }
}
```

### 自动分配域名

**在 Vercel 项目设置中：**
```
Settings → Domains
```

- 免费域名：`your-project.vercel.app`
- 自定义域名：添加你自己的域名（需配置 DNS）

---

## 📊 监控和分析

### Vercel Analytics

**访问：**
```
https://vercel.com/你的用户名/miaodong-ai-design/analytics
```

**可查看：**
- 页面浏览量
- 访问量
- 性能指标（Core Web Vitals）
- 地理位置分布

### 部署日志

**访问：**
```
https://vercel.com/你的用户名/miaodong-ai-design/deployments
```

**可查看：**
- 每次部署详情
- 构建日志
- 错误信息

---

## 🔧 常见问题

### Q1: 部署失败怎么办？
**检查：**
1. 构建日志中的错误信息
2. 环境变量是否正确配置
3. `package.json` 中的 build 脚本

### Q2: 如何回滚到之前的版本？
**操作：**
1. 访问 Deployments 页面
2. 找到想要回滚的版本
3. 点击 "..." → "Promote to Production"

### Q3: 如何查看部署预览？
**每个 PR 会自动创建预览链接：**
- GitHub PR 页面会显示 Vercel 部署状态
- 点击 "Preview" 查看实时预览

---

## 📈 下一步优化

### 1. 启用 Vercel Analytics
```bash
# 安装分析包
pnpm add @vercel/analytics
```

### 2. 配置速度洞察
```bash
pnpm add @vercel/speed-insights
```

### 3. 设置自动预览评论
在 GitHub PR 中自动评论部署链接

---

## 🎯 完成检查清单

```
[ ] Vercel 账号已登录
[ ] GitHub 仓库已连接
[ ] 环境变量已配置
[ ] 首次部署成功
[ ] 生产 URL 可访问
[ ] 自动部署已启用
```

---

**预计总时间**: 10 分钟  
**难度**: ⭐ 简单

**完成后，每次 git push 都会自动部署！** 🚀
