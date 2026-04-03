# AI 绘图和无限画布功能部署指南

**文档版本**: 1.0  
**更新时间**: 2026-03-29  
**适用项目**: AI 设计工具平台 - AI 绘图和无限画布功能

---

## 📋 目录

1. [部署前准备](#1-部署前准备)
2. [环境变量配置](#2-环境变量配置)
3. [本地部署](#3-本地部署)
4. [生产环境部署](#4-生产环境部署)
5. [验证部署](#5-验证部署)
6. [故障排查](#6-故障排查)
7. [安全建议](#7-安全建议)

---

## 1. 部署前准备

### 1.1 系统要求

| 项目 | 最低要求 | 推荐配置 |
|------|---------|---------|
| **Node.js** | v18.0.0+ | v20.0.0+ |
| **npm** | v9.0.0+ | v10.0.0+ |
| **内存** | 4GB | 8GB+ |
| **磁盘空间** | 2GB | 10GB+ |
| **操作系统** | Linux/macOS/Windows | Linux (Ubuntu 20.04+) |

### 1.2 必需的服务

| 服务 | 用途 | 获取方式 |
|------|------|---------|
| **DeepSeek API** | 提示词生成 | [DeepSeek 官网](https://platform.deepseek.com/) |
| **KIEAI API** | 图像生成 | [KIEAI 官网](https://kie.ai/) |

### 1.3 项目结构

```
/root/.openclaw/workspace_manager/
├── MiaoDongAI_Design_TeamWork/     # 主项目目录
│   ├── .env.local                  # 本地环境变量
│   ├── .env.example                # 环境变量示例
│   ├── app/
│   │   └── design-agent/
│   │       └── page.tsx            # 主页面组件
│   ├── components/
│   │   └── ai-image/
│   │       └── infinite-canvas.tsx # 无限画布组件
│   ├── lib/
│   │   └── backend/
│   │       └── config.ts           # 配置文件
│   └── package.json
├── tests/                          # 测试目录
└── docs/                           # 文档目录
```

---

## 2. 环境变量配置

### 2.1 必需的环境变量

| 变量名 | 说明 | 获取方式 |
|--------|------|---------|
| `DEEPSEEK_API_KEY` | DeepSeek API 密钥 | [DeepSeek 控制台](https://platform.deepseek.com/) |
| `KIEAI_API_KEY` | KIEAI API 密钥 | [KIEAI 控制台](https://kie.ai/) |

### 2.2 可选的环境变量

| 变量名 | 默认值 | 说明 |
|--------|--------|------|
| `DEEPSEEK_BASE_URL` | `https://api.deepseek.com` | DeepSeek API 基础 URL |
| `KIEAI_BASE_URL` | `https://api.kie.ai` | KIEAI API 基础 URL |
| `PORT` | `3000` | 应用端口 |
| `NODE_ENV` | `development` | 运行环境 |

### 2.3 配置步骤

#### 步骤 1：复制示例文件

```bash
cd /root/.openclaw/workspace_manager/MiaoDongAI_Design_TeamWork

# 如果 .env.example 存在
cp .env.example .env.local

# 如果不存在，手动创建
touch .env.local
```

#### 步骤 2：编辑配置文件

使用文本编辑器打开 `.env.local` 文件：

```bash
# 使用 vim
vim .env.local

# 或使用 nano
nano .env.local
```

#### 步骤 3：添加环境变量

在文件中添加以下内容：

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

> ⚠️ **重要**：请将 `sk_your_deepseek_api_key_here` 和 `your_kieai_api_key_here` 替换为您实际的 API 密钥。

### 2.4 获取 API 密钥

#### DeepSeek API

1. 访问 [DeepSeek API Console](https://platform.deepseek.com/)
2. 注册账号并登录
3. 进入「API Keys」页面
4. 点击「创建 API Key」
5. 复制密钥并妥善保存

#### KIEAI API

1. 访问 [KIEAI Platform](https://kie.ai/)
2. 注册账号并登录
3. 进入「开发者中心」或「API Keys」页面
4. 创建新的 API Key
5. 复制密钥并妥善保存

---

## 3. 本地部署

### 3.1 安装依赖

```bash
cd /root/.openclaw/workspace_manager/MiaoDongAI_Design_TeamWork

# 安装项目依赖
npm install
```

### 3.2 启动开发服务器

```bash
# 方式 1：使用 npm 脚本
npm run dev

# 方式 2：直接使用 next
npx next dev -p 3000
```

### 3.3 验证启动

启动成功后会看到以下输出：

```
✅ Environment variables validation passed
ready - started server on 0.0.0.0:3000
info  - Ready on http://localhost:3000
```

### 3.4 访问应用

打开浏览器访问：`http://localhost:3000/design-agent`

---

## 4. 生产环境部署

### 4.1 构建项目

```bash
cd /root/.openclaw/workspace_manager/MiaoDongAI_Design_TeamWork

# 设置生产环境变量
export NODE_ENV=production

# 构建项目
npm run build
```

### 4.2 启动生产服务器

```bash
# 方式 1：使用 npm 脚本
npm start

# 方式 2：使用 PM2 (推荐)
npm install -g pm2
pm2 start npm --name "ai-drawing" -- start
```

### 4.3 Docker 部署（可选）

#### 创建 Dockerfile

```dockerfile
# Dockerfile
FROM node:20-alpine

WORKDIR /app

# 复制 package 文件
COPY package*.json ./

# 安装依赖
RUN npm ci --only=production

# 复制源码
COPY . .

# 构建项目
RUN npm run build

# 暴露端口
EXPOSE 3000

# 启动命令
CMD ["npm", "start"]
```

#### 构建和运行

```bash
# 构建镜像
docker build -t ai-drawing:latest .

# 运行容器
docker run -d \
  --name ai-drawing \
  -p 3000:3000 \
  -e DEEPSEEK_API_KEY=your_key \
  -e KIEAI_API_KEY=your_key \
  ai-drawing:latest
```

### 4.4 Nginx 配置（可选）

如果您使用 Nginx 作为反向代理：

```nginx
server {
    listen 80;
    server_name your-domain.com;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
```

---

## 5. 验证部署

### 5.1 基本验证

#### 检查服务状态

```bash
# 检查端口是否在监听
lsof -i :3000

# 或使用 netstat
netstat -tlnp | grep 3000
```

#### 测试 API 接口

```bash
# 测试对话接口
curl -X POST http://localhost:3000/api/design-agent/chat \
  -H "Content-Type: application/json" \
  -d '{"message": "测试"}'
```

### 5.2 功能验证清单

| 验证项 | 预期结果 | 检查方法 |
|--------|---------|---------|
| 页面加载 | 正常显示 | 浏览器访问 |
| 模型选择 | 下拉框可用 | 点击选择 |
| 发送消息 | 无报错 | 发送测试消息 |
| 图像生成 | 返回图像 URL | 查看响应 |
| 无限画布 | 可缩放拖拽 | 操作画布 |
| 图片下载 | 可保存文件 | 点击下载 |

### 5.3 性能验证

| 指标 | 目标值 | 测量方法 |
|------|--------|---------|
| 首次加载 | < 3秒 | Chrome DevTools |
| 页面响应 | < 200ms | Network 面板 |
| 图像生成 | < 60秒 | 计时测试 |

---

## 6. 故障排查

### 6.1 常见问题

#### 问题 1：服务无法启动

**错误信息**：
```
Error: listen EADDRINUSE: address already in use 0.0.0.0:3000
```

**解决方法**：
```bash
# 查找占用端口的进程
lsof -i :3000

# 终止进程
kill -9 <PID>

# 或者更换端口
export PORT=3001
npm run dev
```

#### 问题 2：API 密钥错误

**错误信息**：
```
Error: Invalid API key
```

**解决方法**：
1. 检查 `.env.local` 文件中的密钥是否正确
2. 确认密钥没有多余的空格或换行
3. 重新获取 API 密钥并更新配置
4. 重启服务：`npm run dev`

#### 问题 3：环境变量未加载

**错误信息**：
```
❌ Required environment variables are missing
```

**解决方法**：
```bash
# 确认 .env.local 文件存在
ls -la .env.local

# 确认内容正确
cat .env.local

# 重新加载环境变量
source .env.local

# 重启服务
```

#### 问题 4：网络超时

**错误信息**：
```
Error: Network request failed
```

**解决方法**：
1. 检查网络连接
2. 尝试 ping API 服务器：
   ```bash
   ping api.deepseek.com
   ping api.kie.ai
   ```
3. 检查防火墙设置
4. 增加超时时间（如果代码支持）

#### 问题 5：图像无法显示

**可能原因**：
- 图像 URL 过期
- CDN 问题
- 生成失败

**解决方法**：
1. 检查浏览器控制台错误
2. 确认图像 URL 是否可访问
3. 重新生成图像

### 6.2 日志分析

#### 查看 Next.js 日志

```bash
# 开发模式
npm run dev

# 生产模式
pm2 logs ai-drawing
# 或
docker logs ai-drawing
```

#### 日志级别设置

可以通过环境变量控制日志级别：

```env
# 可选值: debug, info, warn, error
LOG_LEVEL=info
```

### 6.3 调试技巧

#### 使用 Chrome DevTools

1. 打开开发者工具（F12）
2. 查看 Console 控制台错误
3. 查看 Network 面板的请求响应
4. 检查 Application 面板的存储

#### 启用调试模式

```bash
# 开发模式详细日志
DEBUG=* npm run dev

# 或设置环境变量
export DEBUG=true
export NODE_ENV=development
```

---

## 7. 安全建议

### 7.1 API 密钥保护

#### 永远不要提交到 Git

```bash
# 确保 .env.local 在 .gitignore 中
echo ".env.local" >> .gitignore
echo ".env.*.local" >> .gitignore
echo "node_modules/" >> .gitignore
```

#### 使用密钥管理服务

**生产环境推荐**：
- AWS Secrets Manager
- HashiCorp Vault
- Kubernetes Secrets

### 7.2 网络安全

#### 使用 HTTPS

```bash
# 使用 Let's Encrypt（免费）
sudo apt install certbot python3-certbot-nginx
sudo certbot --nginx -d your-domain.com
```

#### 防火墙配置

```bash
# 允许 HTTP/HTTPS
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# 限制 SSH
sudo ufw allow 22/tcp

# 启用防火墙
sudo ufw enable
```

### 7.3 应用安全

#### 设置安全响应头

在 `next.config.js` 中配置：

```javascript
// next.config.js
async headers() {
  return [
    {
      source: '/(.*)',
      headers: [
        { key: 'X-Frame-Options', value: 'DENY' },
        { key: 'X-Content-Type-Options', value: 'nosniff' },
        { key: 'Referrer-Policy', value: 'origin-when-cross-origin' },
      ],
    },
  ];
}
```

### 7.4 监控和告警

#### 错误监控

推荐集成 Sentry：

```bash
npm install @sentry/nextjs
```

配置 `sentry.client.config.js` 和 `sentry.server.config.js`。

#### 健康检查

```bash
# 创建健康检查端点
# app/api/health/route.ts
export async function GET() {
  return Response.json({ status: 'ok', timestamp: Date.now() });
}
```

---

## 📋 部署检查清单

### 部署前

- [ ] Node.js 版本符合要求（v18+）
- [ ] 已获取 DeepSeek API 密钥
- [ ] 已获取 KIEAI API 密钥
- [ ] 项目依赖已安装

### 部署中

- [ ] 环境变量已正确配置
- [ ] `.env.local` 文件已创建
- [ ] 服务可以正常启动
- [ ] 端口未被占用

### 部署后

- [ ] 页面可正常访问
- [ ] API 接口可正常调用
- [ ] 图像生成功能正常
- [ ] 无限画布功能正常
- [ ] 错误日志正常记录
- [ ] 安全配置已应用

---

## 📞 技术支持

如果遇到无法解决的问题，请收集以下信息并联系技术支持：

1. 完整的错误信息
2. 环境变量配置（隐藏密钥）
3. 日志输出
4. 复现步骤

---

*文档最后更新：2026-03-29*