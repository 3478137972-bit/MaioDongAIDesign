# 🔐 安全修复指南 - Git Token 泄露应急处理

## 🚨 紧急程度：🔴 极高

**发现时间**: 2026-04-03 17:50  
**问题**: Git 远程 URL 包含明文 Personal Access Token  
**Token 前缀**: [已移除 - 安全处理]

---

## ⚠️ 立即行动（按顺序执行）

### Step 1: 撤销泄露的 Token（5 分钟）🔴

**立即访问并撤销：**
```
https://github.com/settings/tokens
```

**操作步骤：**
1. 登录 GitHub
2. 进入 Settings → Developer settings → Personal access tokens → Tokens (classic)
3. 找到 Token `ghp_fGVj...J4ui`（或名称类似的）
4. 点击 **Delete** 删除

**⏰ 完成时间**: 立即（5 分钟内）

---

### Step 2: 生成新 Token（5 分钟）

**创建新 Token：**
```
https://github.com/settings/tokens/new
```

**推荐配置：**
- **Note**: `MiaoDongAI_Design - $(date)`
- **Expiration**: `90 days`（建议定期轮换）
- **Scopes**（最小权限原则）:
  - ✅ `repo` (Full control of private repositories)
  - ✅ `workflow` (Update GitHub Action workflows)
  - ❌ 不要给 `admin` 或 `delete_repo` 权限

**复制新 Token**（只显示一次！）

**⏰ 完成时间**: 10 分钟内

---

### Step 3: 更新本地 Git 配置（5 分钟）

**推荐使用 SSH 密钥（一劳永逸）：**

```bash
# 1. 生成 SSH 密钥（如已有可跳过）
ssh-keygen -t ed25519 -C "your_email@example.com"

# 2. 添加 SSH 密钥到 GitHub
# 复制公钥
cat ~/.ssh/id_ed25519.pub

# 访问：https://github.com/settings/ssh-keys/new
# 粘贴公钥并保存

# 3. 更新远程 URL 为 SSH 方式
cd /root/.openclaw/workspace_manager
git remote set-url origin git@github.com:3478137972-bit/MaioDongAIDesign.git

# 4. 验证
git remote -v
# 应显示：git@github.com:3478137972-bit/MaioDongAIDesign.git
```

**或使用新 Token：**

```bash
cd /root/.openclaw/workspace_manager
git remote set-url origin https://新Token@github.com/3478137972-bit/MaioDongAIDesign.git
git remote -v
```

**⏰ 完成时间**: 15 分钟内

---

### Step 4: 检查 Git 历史是否包含敏感文件（10 分钟）

```bash
# 检查是否有.env 等文件被提交
cd /root/.openclaw/workspace_manager
git log --all --full-history -- '*.env*' '.env.local' 'memory/*token*' 'memory/*secret*'

# 如有提交记录，需要清理历史
# ⚠️ 警告：这将重写 Git 历史，需要 force push
```

**如发现问题文件：**

```bash
# 使用 BFG Repo-Cleaner（推荐）
# 1. 下载 BFG: https://rtyley.github.io/bfg-repo-cleaner/
# 2. 执行清理
java -jar bfg.jar --delete-files '*.env*' --delete-files '.env.local' .
git reflog expire --expire=now --all
git gc --prune=now --aggressive

# 3. 强制推送
git push --force --all
```

**⏰ 完成时间**: 30 分钟内

---

### Step 5: 通知团队成员（5 分钟）

**如 Token 已分享给团队：**

```
【安全通知】Git Token 已轮换

各位同事：

由于安全审计发现 Git Token 可能泄露，我们已立即撤销并生成新 Token。

请以下人员更新本地配置：
- @xxx @xxx @xxx

新 Token 已通过安全渠道（1Password/私聊）发送。

如有疑问请联系我。

谢谢配合！
```

**⏰ 完成时间**: 35 分钟内

---

### Step 6: 配置 GitHub Secrets（用于 CI/CD）（10 分钟）

**访问：**
```
https://github.com/3478137972-bit/MaioDongAIDesign/settings/secrets/actions
```

**添加以下 Secrets：**
- `VERCEL_TOKEN` - Vercel 部署 Token
- `DEEPSEEK_API_KEY` - DeepSeek API 密钥
- `KIEAI_API_KEY` - KIEAI API 密钥
- `SUPABASE_URL` - Supabase 项目 URL
- `SUPABASE_KEY` - Supabase 密钥

**⏰ 完成时间**: 45 分钟内

---

## ✅ 检查清单

```
[ ] Step 1: 撤销旧 Token ✅ 进行中
[ ] Step 2: 生成新 Token ⏳ 待执行
[ ] Step 3: 更新 Git 配置 ⏳ 待执行
[ ] Step 4: 检查 Git 历史 ⏳ 待执行
[ ] Step 5: 通知团队 ⏳ 待执行（如适用）
[ ] Step 6: 配置 GitHub Secrets ⏳ 待执行
```

---

## 🔒 长期安全措施

### 1. 使用 SSH 密钥认证
```bash
# 一劳永逸，无需管理 Token
ssh-keygen -t ed25519 -C "your_email@example.com"
```

### 2. 使用 GitHub CLI
```bash
# 自动管理 Token
gh auth login
```

### 3. 定期轮换 Token
- 每 90 天更换一次
- 设置日历提醒

### 4. 使用密钥管理服务
- 1Password / Bitwarden（团队共享）
- AWS Secrets Manager（生产环境）
- Doppler（开发环境同步）

### 5. 启用 Git 密钥扫描
```bash
# 安装 git-secrets
git clone https://github.com/awslabs/git-secrets.git
cd git-secrets && sudo make install

# 初始化
git secrets --install
git secrets --register-aws
```

---

## 📞 紧急联系

如有问题，立即联系：
- GitHub 支持：https://support.github.com
- 团队安全负责人：[待填写]

---

**最后更新**: 2026-04-03 17:50  
**状态**: 🔴 执行中
