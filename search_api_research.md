# 免费搜索 API 调研

## 目标
为 OpenClaw 配置免费的 web_search 功能

## 候选方案

### 1. Brave Search API
- **免费额度**: 2000 次/月
- **需要信用卡**: 否（免费层级无需）
- **注册**: https://brave.com/search/api/
- **状态**: OpenClaw 原生支持

### 2. Google Custom Search JSON API
- **免费额度**: 100 次/天
- **需要信用卡**: 否
- **注册**: https://developers.google.com/custom-search/v1/overview
- **状态**: 需要配置

### 3. SerpApi
- **免费额度**: 100 次/月
- **需要信用卡**: 否
- **注册**: https://serpapi.com/
- **状态**: 第三方服务

### 4. DuckDuckGo (非官方)
- **免费额度**: 无限（但有速率限制）
- **需要信用卡**: 否
- **注册**: 无需
- **状态**: 需要自己实现

### 5. Bing Search API
- **免费额度**: 1000 次/月 (F0 层级)
- **需要信用卡**: 是（但免费层级不收费）
- **注册**: https://www.microsoft.com/en-us/bing/apis/bing-web-search-api
- **状态**: 需要 Azure 账户

## 推荐方案

**Brave Search API** - 最佳选择
- ✅ OpenClaw 原生支持
- ✅ 2000 次/月免费额度
- ✅ 无需信用卡
- ✅ 隐私友好
- ✅ 搜索结果质量好

## 下一步
1. 注册 Brave Search API 获取 key
2. 使用 `openclaw configure --section web` 配置
3. 测试 web_search 功能
