# AI 绘图和无限画布功能 API 文档

**文档版本**: 1.0  
**更新时间**: 2026-03-29  
**适用项目**: AI 设计工具平台 - AI 绘图和无限画布功能

---

## 📋 目录

1. [概述](#1-概述)
2. [接口说明](#2-接口说明)
3. [请求格式](#3-请求格式)
4. [响应格式](#4-响应格式)
5. [错误码](#5-错误码)
6. [示例](#6-示例)

---

## 1. 概述

### 1.1 API 基础信息

| 项目 | 说明 |
|------|------|
| **基础 URL** | `/api/design-agent` |
| **协议** | HTTP/HTTPS |
| **请求方法** | POST |
| **数据格式** | JSON |
| **认证方式** | API Key（环境变量） |

### 1.2 可用接口

| 接口 | 方法 | 路径 | 描述 |
|------|------|------|------|
| 对话交互 | POST | `/api/design-agent/chat` | 发送消息并获取 AI 响应 |
| 图像生成 | POST | `/api/design-agent/generate` | 根据提示词生成图像 |

---

## 2. 接口说明

### 2.1 对话交互接口

用于发送用户消息并获取 AI 响应。AI 可能返回问题来澄清需求，或者直接返回生成结果。

**接口地址**: `POST /api/design-agent/chat`

#### 请求头

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| Content-Type | string | 是 | 固定值：`application/json` |

#### 请求体

```typescript
interface ChatRequest {
  // 用户消息内容
  message: string;
  
  // 当有pending questions时的回答
  answers?: Record<string, string>;
}
```

#### 请求体字段说明

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| message | string | 是 | 用户的创作需求描述 |
| answers | object | 否 | 用户对 AI 问题的回答，key 为问题标识，value 为用户选择的答案 |

#### 响应体 - 需要追问

```typescript
interface ChatResponseNeedMoreInfo {
  // 响应类型：需要更多信息
  type: "need_more_info";
  
  // 响应消息
  message: string;
  
  // 需要用户回答的问题列表
  questions: Array<{
    // 问题标识
    key: string;
    // 问题内容
    question: string;
    // 选项列表（如果有）
    options?: string[];
  }>;
}
```

#### 响应体 - 生成结果

```typescript
interface ChatResponseResult {
  // 响应类型：生成结果
  type: "result";
  
  // 响应消息
  message: string;
  
  // 生成结果
  result: {
    // 生成的图像 ID
    id: string;
    // 图像 URL
    url: string;
    // 使用的提示词
    prompt: string;
    // 图像宽度
    width: number;
    // 图像高度
    height: number;
    // 模型名称
    model: string;
    // 宽高比
    aspect_ratio: string;
  };
}
```

#### 响应体 - 错误

```typescript
interface ChatResponseError {
  // 响应类型：错误
  type: "error";
  
  // 错误消息
  message: string;
  
  // 错误代码
  error_code?: string;
}
```

---

### 2.2 图像生成接口

用于直接生成图像，不需要对话流程。

**接口地址**: `POST /api/design-agent/generate`

#### 请求头

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| Content-Type | string | 是 | 固定值：`application/json` |

#### 请求体

```typescript
interface GenerateRequest {
  // 图像描述提示词
  prompt: string;
  
  // 图像模型 (nano-banana-pro | nano-banana | seedream4.5)
  model: string;
  
  // 宽高比 (1:1 | 2:3 | 3:2 | 16:9 | 9:16 等)
  aspect_ratio: string;
  
  // 分辨率 (2k | 4k) - 仅部分模型支持
  resolution?: string;
}
```

#### 请求体字段说明

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| prompt | string | 是 | 图像描述文本，长度建议 10-500 字符 |
| model | string | 是 | 图像生成模型 |
| aspect_ratio | string | 是 | 宽高比 |
| resolution | string | 否 | 分辨率，不支持该参数的模型会自动忽略 |

#### 响应体

```typescript
interface GenerateResponse {
  // 响应状态
  success: boolean;
  
  // 生成的图像信息
  data?: {
    // 图像 ID
    id: string;
    // 图像 URL
    url: string;
    // 提示词
    prompt: string;
    // 宽度
    width: number;
    // 高度
    height: number;
    // 模型
    model: string;
    // 宽高比
    aspect_ratio: string;
  };
  
  // 错误信息（失败时）
  error?: {
    // 错误代码
    code: string;
    // 错误消息
    message: string;
  };
}
```

---

## 3. 请求格式

### 3.1 对话接口请求示例

#### 首次对话（无需回答问题）

```bash
curl -X POST https://your-domain.com/api/design-agent/chat \
  -H "Content-Type: application/json" \
  -d '{
    "message": "一只可爱的橘猫坐在窗台上，窗外是黄昏的夕阳"
  }'
```

#### 回答 AI 的问题

```bash
curl -X POST https://your-domain.com/api/design-agent/chat \
  -H "Content-Type: application/json" \
  -d '{
    "message": "一只可爱的橘猫坐在窗台上",
    "answers": {
      "style": "写实",
      "color": "暖色",
      "ratio": "横版"
    }
  }'
```

### 3.2 图像生成接口请求示例

```bash
curl -X POST https://your-domain.com/api/design-agent/generate \
  -H "Content-Type: application/json" \
  -d '{
    "prompt": "一只可爱的橘猫坐在窗台上，窗外是黄昏的夕阳",
    "model": "nano-banana-pro",
    "aspect_ratio": "16:9",
    "resolution": "2k"
  }'
```

---

## 4. 响应格式

### 4.1 成功响应

#### 需要更多信息（需要追问）

```json
{
  "type": "need_more_info",
  "message": "为了生成更精准的图像，请帮我补充以下信息：",
  "questions": [
    {
      "key": "style",
      "question": "图片风格？",
      "options": ["写实", "卡通", "抽象", "水彩"]
    },
    {
      "key": "color",
      "question": "颜色基调？",
      "options": ["暖色", "冷色", "中性"]
    },
    {
      "key": "ratio",
      "question": "画面比例？",
      "options": ["横版", "竖版", "正方形"]
    }
  ]
}
```

#### 生成成功

```json
{
  "type": "result",
  "message": "图像生成成功！",
  "result": {
    "id": "img_1234567890",
    "url": "https://cdn.example.com/images/img_1234567890.png",
    "prompt": "一只可爱的橘猫坐在窗台上，窗外是黄昏的夕阳，温暖的金色光线",
    "width": 1920,
    "height": 1080,
    "model": "nano-banana-pro",
    "aspect_ratio": "16:9"
  }
}
```

### 4.2 错误响应

```json
{
  "type": "error",
  "message": "抱歉，发生了错误：网络连接超时",
  "error_code": "NETWORK_ERROR"
}
```

---

## 5. 错误码

### 5.1 错误码列表

| 错误码 | HTTP 状态码 | 说明 | 解决方法 |
|--------|------------|------|---------|
| `INVALID_REQUEST` | 400 | 请求格式不正确 | 检查请求体格式 |
| `MISSING_MESSAGE` | 400 | 缺少 message 字段 | 确保 message 字段存在 |
| `INVALID_MODEL` | 400 | 无效的模型名称 | 使用支持的模型 |
| `INVALID_ASPECT_RATIO` | 400 | 无效的宽高比 | 使用支持的宽高比 |
| `MISSING_API_KEY` | 401 | 缺少 API 密钥 | 配置环境变量 |
| `INVALID_API_KEY` | 401 | API 密钥无效 | 检查 API 密钥配置 |
| `API_QUOTA_EXCEEDED` | 403 | API 配额已用完 | 联系管理员 |
| `NETWORK_ERROR` | 500 | 网络错误 | 检查网络连接 |
| `API_ERROR` | 500 | 上游 API 错误 | 稍后重试 |
| `SERVER_ERROR` | 500 | 服务器内部错误 | 联系技术支持 |
| `TIMEOUT` | 504 | 请求超时 | 增加超时时间后重试 |

### 5.2 错误响应格式

```json
{
  "success": false,
  "error": {
    "code": "INVALID_API_KEY",
    "message": "API 密钥无效，请检查配置"
  }
}
```

---

## 6. 示例

### 6.1 完整对话流程示例

#### Step 1: 用户发送初始请求

**请求**:
```bash
curl -X POST /api/design-agent/chat \
  -H "Content-Type: application/json" \
  -d '{"message": "帮我画一幅夜景"}'
```

**响应**:
```json
{
  "type": "need_more_info",
  "message": "为了生成更精准的图像，请帮我补充以下信息：",
  "questions": [
    {"key": "style", "question": "图片风格？", "options": ["写实", "卡通", "抽象", "水彩"]},
    {"key": "color", "question": "颜色基调？", "options": ["暖色", "冷色", "中性"]},
    {"key": "ratio", "question": "画面比例？", "options": ["横版", "竖版", "正方形"]}
  ]
}
```

#### Step 2: 用户回答问题

**请求**:
```bash
curl -X POST /api/design-agent/chat \
  -H "Content-Type: application/json" \
  -d '{
    "message": "帮我画一幅夜景",
    "answers": {
      "style": "写实",
      "color": "冷色",
      "ratio": "横版"
    }
  }'
```

**响应**:
```json
{
  "type": "result",
  "message": "图像生成成功！",
  "result": {
    "id": "img_1700000001",
    "url": "https://cdn.example.com/images/img_1700000001.png",
    "prompt": "城市夜景，霓虹灯闪烁，写实风格，冷色调",
    "width": 1920,
    "height": 1080,
    "model": "nano-banana-pro",
    "aspect_ratio": "16:9"
  }
}
```

### 6.2 直接生成图像示例

**请求**:
```bash
curl -X POST /api/design-agent/generate \
  -H "Content-Type: application/json" \
  -d '{
    "prompt": "未来科技感的城市夜景，霓虹灯闪烁",
    "model": "nano-banana-pro",
    "aspect_ratio": "16:9",
    "resolution": "2k"
  }'
```

**成功响应**:
```json
{
  "success": true,
  "data": {
    "id": "img_1700000002",
    "url": "https://cdn.example.com/images/img_1700000002.png",
    "prompt": "未来科技感的城市夜景，霓虹灯闪烁",
    "width": 2560,
    "height": 1440,
    "model": "nano-banana-pro",
    "aspect_ratio": "16:9"
  }
}
```

**失败响应**:
```json
{
  "success": false,
  "error": {
    "code": "API_QUOTA_EXCEEDED",
    "message": "API 配额已用完，请联系管理员"
  }
}
```

### 6.3 JavaScript/TypeScript 调用示例

```typescript
// 对话接口调用示例
async function sendChat(message: string, answers?: Record<string, string>) {
  const response = await fetch('/api/design-agent/chat', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      message,
      ...(answers && { answers }),
    }),
  });
  
  return response.json();
}

// 图像生成接口调用示例
async function generateImage(
  prompt: string,
  model: string,
  aspectRatio: string,
  resolution?: string
) {
  const response = await fetch('/api/design-agent/generate', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      prompt,
      model,
      aspect_ratio: aspectRatio,
      ...(resolution && { resolution }),
    }),
  });
  
  return response.json();
}
```

### 6.4 Python 调用示例

```python
import requests

def send_chat(message: str, answers: dict = None):
    """发送对话请求"""
    url = "https://your-domain.com/api/design-agent/chat"
    payload = {"message": message}
    
    if answers:
        payload["answers"] = answers
    
    response = requests.post(url, json=payload)
    return response.json()

def generate_image(
    prompt: str,
    model: str,
    aspect_ratio: str,
    resolution: str = None
):
    """发送图像生成请求"""
    url = "https://your-domain.com/api/design-agent/generate"
    payload = {
        "prompt": prompt,
        "model": model,
        "aspect_ratio": aspect_ratio
    }
    
    if resolution:
        payload["resolution"] = resolution
    
    response = requests.post(url, json=payload)
    return response.json()
```

---

## 📊 附录

### A. 支持的模型和参数

| 模型 | 支持的宽高比 | 支持的分辨率 |
|------|------------|-------------|
| nano-banana-pro | 1:1, 2:3, 3:2, 3:4, 4:3, 4:5, 5:4, 9:16, 16:9, 21:9, auto | 2k, 4k |
| nano-banana | 1:1, 2:3, 3:2, 3:4, 4:3, 4:5, 5:4, 9:16, 16:9, 21:9, auto | 默认 |
| seedream4.5 | 1:1, 4:3, 3:4, 16:9, 9:16, 2:3, 3:2, 21:9 | 默认 |

### B. 请求超时配置

| 场景 | 推荐超时时间 |
|------|------------|
| 对话交互 | 30 秒 |
| 图像生成 | 120 秒 |

---

*文档最后更新：2026-03-29*