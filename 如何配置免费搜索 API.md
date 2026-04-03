# 如何配置免费搜索 API

## 问题现状
当前 `web_search` 工具需要 Brave Search API key，但尚未配置。

## 解决方案

### 方案一：Brave Search API（推荐）⭐

**免费额度**: 2000 次/月  
**需要信用卡**: 否

#### 步骤：

1. **访问注册页面**
   ```
   https://brave.com/search/api/
   ```

2. **点击 "Get an API Key"**

3. **填写注册表单**
   - 邮箱地址
   - 使用场景描述（填：Personal AI Assistant）
   - 同意服务条款

4. **获取 API Key**
   - 注册后会立即显示 API key
   - 格式类似：`BSAxxxxxxxxxxxxxxxxxx`

5. **在 OpenClaw 中配置**
   
   方法 A - 使用配置命令：
   ```bash
   openclaw configure --section web
   # 然后按提示输入 API key
   ```
   
   方法 B - 直接编辑配置文件：
   ```bash
   # 编辑 ~/.openclaw/openclaw.json
   # 在 tools 部分添加：
   "tools": {
     "web": {
       "braveApiKey": "BSAxxxxxxxxxxxxxxxxxx"
     }
   }
   ```

6. **测试**
   ```
   让 AI 执行 web_search 测试
   ```

---

### 方案二：Google Custom Search API

**免费额度**: 100 次/天  
**需要信用卡**: 否

#### 步骤：

1. **创建 Google Cloud 项目**
   ```
   https://console.cloud.google.com/
   ```

2. **启用 Custom Search API**

3. **创建 API Key**

4. **创建 Custom Search Engine**
   ```
   https://cse.google.com/cse/all
   ```

5. **获取 Search Engine ID**

6. **配置到 OpenClaw**（需要自定义工具）

---

### 方案三：使用 web_fetch 替代（临时方案）

如果暂时无法获取 API key，可以使用 `web_fetch` 工具：

- ✅ 无需 API key
- ✅ 可以获取任何 URL 的内容
- ❌ 不能直接搜索，需要知道具体 URL

**使用示例**：
```
web_fetch(url: "https://example.com/article")
```

---

## 快速验证

配置完成后，测试命令：
```bash
# 测试 web_search
让 AI 搜索 "最新 AI 新闻"
```

---

## 注意事项

1. **API key 安全**
   - 不要公开分享 API key
   - OpenClaw 会自动加密存储

2. **使用限制**
   - Brave 免费层级：2000 次/月
   - 平均每天可用约 66 次
   - 超出后需要升级或等待下月

3. **如果遇到问题**
   - 检查 API key 是否正确
   - 确认网络连接正常
   - 查看 OpenClaw 日志

---

## 联系支持

如配置过程中遇到问题：
- OpenClaw 文档：https://docs.openclaw.ai/tools/web
- Discord 社区：https://discord.com/invite/clawd
