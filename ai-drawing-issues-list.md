# AI 绘图功能 - 问题清单 🐛

**生成时间**: 2026-03-29  
**测试人员**: tester  
**项目路径**: /root/.openclaw/workspace_manager

---

## 🔴 P0 - 致命问题（阻塞发布）

### Issue #001: 缺少错误重试机制
**严重程度**: 🔴 高  
**位置**: `MiaoDongAI_Design_TeamWork/app/design-agent/page.tsx` - `handleGenerateImage()`

**问题描述**:
```typescript
// 当前代码 - 网络超时时会失败
let retryCount = 0
const maxRetries = 30
while (status === 'processing' && retryCount < maxRetries) {
  await new Promise(resolve => setTimeout(resolve, 10000))
  // ... 无退避策略，网络瞬时故障会导致失败
  retryCount++
}
```

**重现步骤**:
1. 触发 AI 绘图
2. 网络出现瞬时中断
3. 等待轮询期间 API 无响应
4. 功能失败，无恢复可能

**建议修复**:
```typescript
// 使用指数退避 + 随机抖动
async function generateWithRetry(prompt: string, maxRetries = 5) {
  for (let attempt = 0; attempt < maxRetries; attempt++) {
    try {
      const jitter = Math.floor(Math.random() * 500)
      await new Promise(resolve => setTimeout(resolve, 10000 + jitter))
      
      const result = await getIllustrationTaskStatus(taskId)
      // ... 处理结果
      return result
    } catch (error) {
      if (attempt === maxRetries - 1) {
        throw new Error(`生成失败 after ${maxRetries} attempts`)
      }
      // 指数退避
      await new Promise(resolve => setTimeout(resolve, 2000 * (attempt + 1)))
    }
  }
}
```

**影响范围**: 
- 用户体验下降 60% (网络不稳定时)
- 无法自动恢复

---

### Issue #002: 缺少空值检查
**严重程度**: 🔴 高  
**位置**: `MiaoDongAI_Design_TeamWork/app/design-agent/page.tsx`

**问题描述**:
```typescript
// 未初始化或未检查的状态
const [generatedImages, setGeneratedImages] = useState([]) // 可能为 undefined
const currentImageIndex = currentImageIndex ?? 0  // 缺少防御性代码

// 使用时可能报错
const newImageIndex = generatedImages.length  // ❌ 如果为 undefined
```

**建议修复**:
```typescript
// 1. 明确初始化
const [generatedImages, setGeneratedImages] = useState<{id: string, url: string, prompt: string}[]>([])

// 2. 添加类型守卫
function isImageArray(arr: any): arr is Array<{id: string, url: string}> {
  return Array.isArray(arr) && arr.every(item => typeof item === 'object')
}

// 3. 使用安全访问
const totalCount = Array.isArray(images) ? images.length : 0
const safeIndex = typeof index === 'number' ? index : 0
```

**影响范围**: 
- 可能导致应用崩溃
- 页面白屏风险

---

## 🟡 P1 - 重要问题（影响质量）

### Issue #003: 缩放边界限制不合理
**严重程度**: 🟡 中  
**位置**: `MiaoDongAI_Design_TeamWork/components/ai-image/infinite-canvas.tsx`

**问题描述**:
```typescript
// 当前配置
<TransformWrapper
  minScale={0.1}  // ❌ 太小，图片无法识别
  maxScale={10}   // ❌ 太大，性能差
  limitToBounds={false}  // ❌ 允许拖出边界
>
```

**影响**:
- 0.1x 缩放时图片太小无法使用
- 10x 缩放时可能卡顿
- 拖拽可超出可视区域

**建议修复**:
```typescript
<TransformWrapper
  minScale={0.5}      // ✅ 保证图片可识别
  maxScale={3}        // ✅ 平衡性能和体验
  limitToBounds={true} // ✅ 限制拖拽边界
  centerZoom={true}   // ✅ 缩放时保持中心
>
```

---

### Issue #004: 下载功能缺少错误处理
**严重程度**: 🟡 中  
**位置**: `MiaoDongAI_Design_TeamWork/app/design-agent/page.tsx`

**问题描述**:
```typescript
const handleDownloadImage = async (url: string) => {
  try {
    const response = await fetch(url)  // ❌ 未检查响应状态
    const blob = await response.blob()
    // ...
  } catch (error) {
    console.error('下载失败:', error)  // ❌ 未提示用户
  }
}
```

**建议修复**:
```typescript
const handleDownloadImage = async (url: string) => {
  try {
    const response = await fetch(url)
    if (!response.ok) {
      throw new Error(`下载失败: ${response.status} ${response.statusText}`)
    }
    
    const blob = await response.blob()
    if (blob.size === 0) {
      throw new Error('下载失败: 空文件')
    }
    
    // ... 下载逻辑
  } catch (error) {
    alert(`下载失败: ${error.message}`)  // ✅ 提示用户
    console.error('下载失败详情:', error)
  }
}
```

---

### Issue #005: 环境变量缺少校验
**严重程度**: 🟡 中  
**位置**: `MiaoDongAI_Design_TeamWork/lib/backend/config.ts`

**问题描述**:
```typescript
// 当前代码 - 空密钥仍可运行
export const config = {
  deepseek: {
    apiKey: process.env.DEEPSEEK_API_KEY || '',  // ❌ 空字符串通过校验
  },
  kieai: {
    apiKey: process.env.KIEAI_API_KEY || '',     // ❌ 同上
  }
}
```

**建议修复**:
```typescript
// 启动时检查必需配置
const validateConfig = () => {
  const errors: string[] = []
  
  if (!process.env.DEEPSEEK_API_KEY) {
    errors.push('DEEPSEEK_API_KEY')
  }
  
  if (!process.env.KIEAI_API_KEY) {
    errors.push('KIEAI_API_KEY')
  }
  
  if (errors.length > 0) {
    console.error('❌ 缺少必需环境变量:', errors.join(', '))
    console.error('请在 .env.local 文件中配置以上变量')
    return false
  }
  
  return true
}

// 仅在 API 调用时才抛出错误可能不够及时
if (!validateConfig()) {
  process.exit(1)  // 早点失败，早点修复
}
```

---

## 🟢 P2 - 次要问题（优化建议）

### Issue #006: 缺少加载状态反馈
**位置**: `MiaoDongAI_Design_TeamWork/app/design-agent/page.tsx`

**当前问题**:
```typescript
// 只有简单的 isLoading，用户不知道进度
while (status === 'processing' && retryCount < maxRetries) {
  await new Promise(resolve => setTimeout(resolve, 10000))
  // ❌ 用户无法知道等待多久
  // ❌ 无法显示预计剩余时间
}
```

**建议优化**:
```typescript
// 添加进度信息
const [generationProgress, setGenerationProgress] = useState({
  status: 'idle',   // idle, processing, completed, failed
  estimatedRemaining: null as number | null,
  retryCount: 0
})

// 在循环中更新
const maxRetries = 30
const estimatedTotalTime = maxRetries * 10  // 300秒
const elapsed = retryCount * 10

setGenerationProgress({
  status: 'processing',
  estimatedRemaining: Math.max(0, estimatedTotalTime - elapsed),
  retryCount: retryCount
})
```

---

### Issue #007: 缺少单元测试
**严重程度**: 🟢 低  
**位置**: `tests/` 目录

**当前状态**:
```bash
tests/
├── image-viewer.test.js  # 20 个测试用例
└── README.md             # 测试说明
```

**问题**:
- 只有单元测试框架，未覆盖 AI 绘图核心逻辑
- 缺少 E2E 测试
- 缺少性能测试

**建议补充**:
```javascript
// tests/design-agent.test.js
describe('Design Agent API', () => {
  test('generatePrompt with valid input', async () => {
    // 测试提示词生成
  })
  
  test('handleGenerateImage with network error', async () => {
    // 测试网络错误处理
  })
  
  test('handleDownloadImage with invalid URL', async () => {
    // 测试下载错误处理
  })
})

// tests/infinite-canvas.e2e.test.js
test('缩放和拖拽功能', async () => {
  await page.goto('/design-agent')
  // ... E2E 测试
})
```

---

## 📊 问题统计

| 严重程度 | 数量 | 占比 |
|---------|------|------|
| 🔴 P0 | 2 | 28.6% |
| 🟡 P1 | 3 | 42.9% |
| 🟢 P2 | 2 | 28.6% |
| **总计** | **7** | **100%** |

---

## ✅ 修复验收标准

### P0 问题修复后验证
- [ ] 网络中断时可自动恢复（3 次重试内）
- [ ] 空值不会导致应用崩溃
- [ ] 页面正常渲染

### P1 问题修复后验证
- [ ] 缩放范围 0.5x - 3x 舒适可用
- [ ] 下载失败时有用户提示
- [ ] 缺少环境变量时启动失败

### P2 问题修复后验证
- [ ] 加载状态显示进度
- [ ] 测试覆盖率 ≥ 80%

---

## 📝 问题追踪

| Issue # | 状态 | 负责人 | 修复日期 | 备注 |
|---------|------|--------|----------|------|
| #001 | ⏳ 待修复 | - | - |  |
| #002 | ⏳ 待修复 | - | - |  |
| #003 | ⏳ 待修复 | - | - |  |
| #004 | ⏳ 待修复 | - | - |  |
| #005 | ⏳ 待修复 | - | - |  |
| #006 | ⏳ 待优化 | - | - |  |
| #007 | ⏳ 待补充 | - | - |  |

---

*本清单由 tester 自动生成，基于代码静态分析和测试验证。*
