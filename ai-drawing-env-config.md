# 📋 环境变量配置指南

**生成时间**: 2026-03-29  
**项目**: AI 绘图和无限画布功能  
**配置文件**: `MiaoDongAI_Design_TeamWork/.env.local`

---

## 🚀 快速开始

### 1. 复制示例文件
```bash
cd /root/.openclaw/workspace_manager/MiaoDongAI_Design_TeamWork
cp .env.example .env.local
```

### 2. 编辑配置文件
```bash
# 编辑 .env.local 文件
vim .env.local
# 或使用任何文本编辑器
```

### 3. 添加必需的环境变量
```env
# DeepSeek API 配置
DEEPSEEK_API_KEY=sk_your_deepseek_api_key_here
DEEPSEEK_BASE_URL=https://api.deepseek.com

# KIEAI API 配置
KIEAI_API_KEY=your_kieai_api_key_here
KIEAI_BASE_URL=https://api.kie.ai

# 应用配置
PORT=3000
NODE_ENV=development
```

### 4. 验证配置
```bash
# 启动服务器验证配置
npm run dev
```

---

## 📝 环境变量详解

### 🔑 必需的环境变量

| 变量名 | 说明 | 示例值 | 是否必需 |
|--------|------|--------|----------|
| `DEEPSEEK_API_KEY` | DeepSeek API 密钥 | `sk-xxxxxxxxxxxxxxxx` | ✅ 是 |
| `KIEAI_API_KEY` | KIEAI API 密钥 | `your_kieai_key_12345` | ✅ 是 |

### 🛠️ 可选的环境变量

| 变量名 | 默认值 | 说明 |
|--------|--------|------|
| `DEEPSEEK_BASE_URL` | `https://api.deepseek.com` | DeepSeek API 基础 URL |
| `KIEAI_BASE_URL` | `https://api.kie.ai` | KIEAI API 基础 URL |
| `PORT` | `3000` | 应用端口 |
| `NODE_ENV` | `development` | 运行环境 |

---

## 🔧 如何获取 API 密钥

### DeepSeek API

1. 访问 [DeepSeek API Console](https://platform.deepseek.com/)
2. 注册账号并登录
3. 进入 API Keys 页面
4. 创建新的 API Key
5. 复制密钥并保存到 `.env.local`

### KIEAI API

1. 访问 [KIEAI Platform](https://kie.ai/)
2. 注册账号并登录
3. 进入 API Keys 或开发者中心
4. 创建新的 API Key
5. 复制密钥并保存到 `.env.local`

---

## ✅ 配置验证

### 方法 1: 启动验证
```bash
cd /root/.openclaw/workspace_manager/MiaoDongAI_Design_TeamWork
npm run dev
```

**预期输出**:
```
✅ Environment variables validation passed
ready - started server on 0.0.0.0:3000
```

### 方法 2: 手动验证
```bash
# 检查 DeepSeek API 密钥
echo $DEEPSEEK_API_KEY

# 检查 KIEAI API 密钥
echo $KIEAI_API_KEY
```

### 方法 3: 代码验证
```typescript
// lib/backend/config.ts
const validateConfigForStartup = () => {
  // 如果缺少必需变量，会输出详细错误信息
}
```

---

## ⚠️ 常见问题

### 问题 1: 缺少环境变量

**错误提示**:
```
❌ Required environment variables are missing:
   - DEEPSEEK_API_KEY
   - KIEAI_API_KEY
```

**解决方案**:
```bash
# 1. 创建环境变量文件
cat > .env.local << EOF
DEEPSEEK_API_KEY=sk_your_key_here
KIEAI_API_KEY=your_key_here
EOF

# 2. 重启服务器
npm run dev
```

### 问题 2: API 密钥无效

**错误提示**:
```
Error: Invalid API key
```

**解决方案**:
1. 检查密钥是否复制正确
2. 验证密钥是否过期
3. 重新生成 API 密钥
4. 更新 `.env.local` 文件
5. 重启服务器

### 问题 3: 端口被占用

**错误提示**:
```
Error: listen EADDRINUSE: address already in use 0.0.0.0:3000
```

**解决方案**:
```bash
# 选项 1: 更改端口
echo "PORT=3001" >> .env.local

# 选项 2: 停止占用进程
lsof -i :3000 | awk 'NR==2 {print $2}' | xargs kill -9
```

---

## 🛡️ 安全建议

### 1. 永远不要提交 API 密钥到 Git
```bash
# 确保 .env.local 在 .gitignore 中
echo ".env.local" >> .gitignore
echo "node_modules/" >> .gitignore
```

### 2. 使用环境变量管理工具
```bash
# 推荐使用 direnv 自动加载环境变量
brew install direnv  # macOS
# 或
sudo apt install direnv  # Linux

# 在项目根目录创建 .envrc
echo "export DEEPSEEK_API_KEY=sk_xxx" > .envrc
echo "export KIEAI_API_KEY=yyy" >> .envrc

# 允许 direnv
direnv allow
```

### 3. 生产环境使用更安全的方式
```bash
# 使用 Docker Secrets
echo "deepseek_api_key: your_key" > docker-secrets.txt

# 或使用 Kubernetes Secrets
kubectl create secret generic api-keys \
  --from-literal=DEEPSEEK_API_KEY=sk_xxx \
  --from-literal=KIEAI_API_KEY=yyy
```

---

## 📊 生产环境配置

### .env.production 示例
```env
# DeepSeek API
DEEPSEEK_API_KEY=sk_production_key_here
DEEPSEEK_BASE_URL=https://api.deepseek.com

# KIEAI API
KIEAI_API_KEY=production_key_here
KIEAI_BASE_URL=https://api.kie.ai

# 应用配置
PORT=3000
NODE_ENV=production
```

### 部署命令
```bash
# 1. 上传配置文件（不提交到 Git）
scp .env.production user@server:/path/to/app/

# 2. SSH 登录到服务器
ssh user@server

# 3. 启动应用
cd /path/to/app
npm run build
npm start
```

---

## 🔍 验证 API 连接

### 测试 DeepSeek API
```bash
curl -X POST https://api.deepseek.com/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $DEEPSEEK_API_KEY" \
  -d '{
    "model": "deepseek-chat",
    "messages": [{"role": "user", "content": "Hello"}]
  }'
```

### 测试 KIEAI API
```bash
curl -X POST https://api.kie.ai/v1/illustrations \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $KIEAI_API_KEY" \
  -d '{
    "prompt": "test image",
    "aspect_ratio": "1:1"
  }'
```

---

## 📝 配置检查清单

在启动生产环境前，请确认以下检查项：

- [ ] `DEEPSEEK_API_KEY` 已设置
- [ ] `KIEAI_API_KEY` 已设置
- [ ] API 密钥具有足够的额度
- [ ] `.env.local` 不在 Git 中（`.gitignore` 已配置）
- [ ] `NODE_ENV=production` 用于生产环境
- [ ] `PORT` 未被其他服务占用
- [ ] 防火墙允许端口访问
- [ ] SSL 证书已配置（HTTPS）
- [ ] 日志级别已配置
- [ ] 错误监控已集成（Sentry）

---

## 🎯 成功配置标志

启动成功后，你应该看到以下输出：
```bash
$ npm run dev

✅ Environment variables validation passed
warn  - You have enabled experimental feature(s).
ready - started server on 0.0.0.0:3000
info  - using beta app directory (app/)
info  - using experimental image component
info  - compiled successfully in 3.5s
```

---

## 📞 支持

如果遇到问题：
1. 检查环境变量是否正确设置
2. 验证 API 密钥是否有效
3. 查看详细错误日志
4. 参考 API 文档

---

*本配置指南由 tester 自动生成，适用于 AI 绘图和无限画布功能项目的环境变量配置。*
