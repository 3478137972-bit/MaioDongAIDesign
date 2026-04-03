# 乐乐小程序 - Git 代码拉取说明

**仓库地址：** https://github.com/3478137972-bit/lele-portfolio-miniprogram

**最新提交：** 9c12069 - 移除所有 emoji 符号，使用 CSS 图标类

---

## 📥 拉取代码（3 种方法）

### 方法 1：使用自动脚本（推荐）

**Windows 用户：**
```bash
cd lele-portfolio-miniprogram
git pull origin main
```

**Mac/Linux 用户：**
```bash
cd lele-portfolio-miniprogram
git pull origin main
```

---

### 方法 2：手动命令

```bash
# 1. 进入项目目录
cd lele-portfolio-miniprogram

# 2. 拉取最新代码
git pull origin main

# 3. 查看状态
git status
```

---

### 方法 3：首次克隆

```bash
# 克隆仓库
git clone https://github.com/3478137972-bit/lele-portfolio-miniprogram.git

# 进入目录
cd lele-portfolio-miniprogram

# 打开微信开发者工具导入
```

---

## ⚠️ 如果遇到问题

### 问题 1：本地有修改冲突

```bash
# 放弃本地修改，强制同步
cd lele-portfolio-miniprogram
git reset --hard origin/main
git pull origin main
```

### 问题 2：文件被微信开发者工具占用

1. 关闭微信开发者工具
2. 执行 `git pull origin main`
3. 重新打开微信开发者工具

### 问题 3：网络问题

使用 Git 代理或换个网络环境再试。

---

## 📦 本次更新内容

### 已修复的问题：

1. ✅ **移除所有 emoji 符号**
   - 使用 CSS 图标类替换（icon-student, icon-star 等）
   - 提升专业度和可维护性

2. ✅ **修复 WXML 语法错误**
   - 移除可选链操作符 `?.`
   - 微信小程序不支持 ES6 可选链

3. ✅ **修复图片 500 错误**
   - 作品集每个品牌只有 5 张图（不是 6 张）
   - 修复循环从 1-6 改为 1-5

4. ✅ **案例页面功能完整**
   - 26 张案例图片正常显示
   - 5 个分类筛选功能正常
   - 图片预览功能正常

---

## 📂 项目文件结构

```
lele-portfolio-miniprogram/
├── pages/
│   ├── index/           # 首页
│   ├── portfolio/       # 作品集（4 个品牌 × 5 张图）
│   ├── course/          # 课程页
│   ├── course-detail/   # 课程详情
│   ├── about/           # 关于页
│   ├── contact/         # 联系页
│   └── cases/           # 学员案例（26 张图）
├── static/
│   └── images/
│       ├── works/       # 作品集图片（20 张）
│       ├── cases/       # 案例图片（26 张）
│       └── lele-profile.jpg
├── app.json             # 应用配置
├── project.config.json  # 项目配置
└── PULL_CODE.bat/sh     # 拉取脚本
```

---

## 🚀 下一步操作

1. **拉取代码** - 执行上面的命令
2. **打开微信开发者工具**
3. **导入项目** - 选择 `lele-portfolio-miniprogram` 文件夹
4. **填写 AppID** - 在 `project.config.json` 中
5. **编译运行** - 测试所有功能

---

## ✅ 验证清单

- [ ] 首页正常显示（无 emoji）
- [ ] 作品集页面正常（20 张图）
- [ ] 案例页面正常（26 张图，5 个分类）
- [ ] 无编译错误
- [ ] 无 500 错误
- [ ] 图片预览功能正常

---

**拉取命令：** `git pull origin main`

**仓库地址：** https://github.com/3478137972-bit/lele-portfolio-miniprogram
