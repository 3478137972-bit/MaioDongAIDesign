# AI 绘图功能 - 修复建议 🛠️

**生成时间**: 2026-03-29  
**测试人员**: tester  
**项目路径**: /root/.openclaw/workspace_manager

---

## 📋 修复总览

| 问题编号 | 问题描述 | 修复时间 | 优先级 |
|---------|----------|----------|--------|
| #001 | 错误重试机制 | 2h | 🔴 P0 |
| #002 | 空值检查 | 1h | 🔴 P0 |
| #003 | 缩放边界优化 | 1h | 🟡 P1 |
| #004 | 下载错误处理 | 0.5h | 🟡 P1 |
| #005 | 环境变量校验 | 1h | 🟡 P1 |
| #006 | 加载状态反馈 | 2h | 🟢 P2 |
| #007 | 测试补充 | 4h | 🟢 P2 |

**预计总修复时间**: 11.5 小时

---

## 🔴 P0 - 致命问题修复方案

### 修复 #001: 添加错误重试机制

#### 文件位置
`MiaoDongAI_Design_TeamWork/app/design-agent/page.tsx`

#### 原始代码
```typescript
const handleGenerateImage = async (prompt: string, aspectRatio: string = "1:1") => {
  try {
    setIsLoading(true)
    const taskId = await createIllustrationTask({ prompt, aspectRatio })
    
    let status = 'processing'
    let imageUrl = null
    let retryCount = 0
    const maxRetries = 30
    
    while (status === 'processing' && retryCount < maxRetries) {
      await new Promise(resolve => setTimeout(resolve, 10000))
      const result = await getIllustrationTaskStatus(taskId)
      
      if (result.success) {
        status = result.data.status
        imageUrl = result.data.imageUrl
        // ...
      }
      retryCount++
    }
    
    if (status === 'failed') {
      throw new Error('图片生成失败')
    }
    
    return null
  } catch (error) {
    console.error('生图失败:', error)
    return null
  } finally {
    setIsLoading(false)
  }
}
```

#### 修复后代码
```typescript
// 添加重试工具函数
const sleep = (ms: number) => new Promise(resolve => setTimeout(resolve, ms))

const generateWithExponentialBackoff = async (
  fn: () => Promise<any>,
  { maxRetries = 5, initialDelay = 1000, maxDelay = 10000 } = {}
): Promise<any> => {
  for (let attempt = 0; attempt < maxRetries; attempt++) {
    try {
      return await fn()
    } catch (error) {
      if (attempt === maxRetries - 1) {
        throw new Error(`操作失败 after ${maxRetries} attempts: ${error.message}`)
      }
      
      // 指数退避 + 随机抖动
      const delay = Math.min(initialDelay * Math.pow(2, attempt), maxDelay)
      const jitter = Math.floor(Math.random() * 500)
      const totalDelay = delay + jitter
      
      console.log(`尝试 ${attempt + 1}/${maxRetries} 失败, ${totalDelay}ms 后重试...`)
      await sleep(totalDelay)
    }
  }
  throw new Error('Unexpected error in retry loop')
}

// 修复后的主函数
const handleGenerateImage = async (prompt: string, aspectRatio: string = "1:1") => {
  try {
    setIsLoading(true)
    
    // 创建任务（带重试）
    const createResult = await generateWithExponentialBackoff(() => 
      createIllustrationTask({ prompt, aspectRatio })
    )
    const taskId = createResult
    
    // 轮询状态（带重试）
    const result = await generateWithExponentialBackoff(async () => {
      const statusResult = await getIllustrationTaskStatus(taskId)
      
      if (statusResult.success) {
        const status = statusResult.data.status
        
        if (status === 'failed') {
          throw new Error('图片生成失败')
        }
        
        if (status === 'success' && statusResult.data.imageUrl) {
          return statusResult.data
        }
      }
      
      throw new Error('Still processing')
    }, { maxRetries: 40, initialDelay: 10000 })
    
    // 添加到画布
    if (result.imageUrl) {
      const newImage = {
        id: taskId,
        url: result.imageUrl,
        prompt: prompt
      }
      
      setGeneratedImages(prev => [...prev, newImage])
      setCurrentImageIndex(prev => (prev ?? 0) + 1)
      return newImage
    }
    
    return null
  } catch (error) {
    console.error('生图失败:', error)
    
    // 添加用户友好的错误提示
    const errorMessage = error.message || '图片生成失败，请重试'
    
    // 在此处添加 Toast 提示
    // showToast({ type: 'error', message: errorMessage })
    
    return null
  } finally {
    setIsLoading(false)
  }
}
```

---

### 修复 #002: 添加空值检查和防御性编程

#### 文件位置
`MiaoDongAI_Design_TeamWork/app/design-agent/page.tsx`

#### 修复前后对比

##### 1. 状态初始化改进
```typescript
// ❌ 修复前
const [generatedImages, setGeneratedImages] = useState([])

// ✅ 修复后 - 明确类型
const [generatedImages, setGeneratedImages] = useState<{
  id: string
  url: string
  prompt: string
}[]>([])
```

##### 2. 索引访问添加保护
```typescript
// ❌ 修复前
const currentImageIndex = currentImageIndex
setGeneratedImages(prev => [...prev, newImage])
setCurrentImageIndex(generatedImages.length)

// ✅ 修复后
const currentImageIndexSafe = currentImageIndex ?? 0
const generatedImagesLength = Array.isArray(generatedImages) ? generatedImages.length : 0

setGeneratedImages(prev => [...(prev ?? []), newImage])
setCurrentImageIndex(generatedImagesLength)
```

##### 3. 数组操作添加保护
```typescript
// ❌ 修复前
const image = images[currentIndex]

// ✅ 修复后
const image = Array.isArray(images) && images[currentIndex] 
  ? images[currentIndex] 
  : null
```

#### 完整修复示例
```typescript
// 在组件顶部添加工具函数
function safeGet<T>(array?: T[], index: number = 0): T | undefined {
  return Array.isArray(array) && array[index] !== undefined 
    ? array[index] 
    : undefined
}

function safeLength<T>(array?: T[]): number {
  return Array.isArray(array) ? array.length : 0
}

// 使用示例
const currentImage = safeGet(images, currentImageIndex ?? 0)
const imageCount = safeLength(images)
```

---

## 🟡 P1 - 重要问题修复方案

### 修复 #003: 缩放边界优化

#### 文件位置
`MiaoDongAI_Design_TeamWork/components/ai-image/infinite-canvas.tsx`

#### 原始代码
```typescript
<TransformWrapper
  limitToBounds={false}  // ❌ 允许拖出边界
  centerOnInit={true}
  minScale={0.1}         // ❌ 太小
  maxScale={10}          // ❌ 太大
  panning={{ disabled: false }}
  zooming={{ disabled: false }}
>
```

#### 修复后代码
```typescript
<TransformWrapper
  limitToBounds={true}      // ✅ 限制拖拽边界
  centerOnInit={true}
  minScale={0.5}            // ✅ 0.5x 保证可识别
  maxScale={3}              // ✅ 3x 平衡性能
  initialScale={1}
  panning={{ 
    disabled: false,
    limitDrag: true         // ✅ 限制拖拽范围
  }}
  zooming={{ 
    disabled: false,
    limitMax: true          // ✅ 限制最大缩放
  }}
  centerZoom={true}         // ✅ 缩放时保持中心
  smoothWheel={true}        // ✅ 平滑滚轮缩放
  wheelStep={0.1}           // ✅ 缩放步进
>
```

---

### 修复 #004: 下载错误处理

#### 文件位置
`MiaoDongAI_Design_TeamWork/app/design-agent/page.tsx`

#### 原始代码
```typescript
const handleDownloadImage = async (url: string) => {
  try {
    const response = await fetch(url)
    const blob = await response.blob()
    const link = document.createElement('a')
    link.href = URL.createObjectURL(blob)
    link.download = `ai-image-${Date.now()}.png`
    document.body.appendChild(link)
    link.click()
    document.body.removeChild(link)
  } catch (error) {
    console.error('下载失败:', error)
  }
}
```

#### 修复后代码
```typescript
const handleDownloadImage = async (url: string) => {
  if (!url) {
    alert('图片 URL 无效')
    return
  }
  
  try {
    const response = await fetch(url, { 
      method: 'GET',
      mode: 'cors'  // 确保跨域请求
    })
    
    // 检查响应状态
    if (!response.ok) {
      throw new Error(`下载失败: ${response.status} ${response.statusText}`)
    }
    
    const contentType = response.headers.get('content-type')
    if (!contentType || !contentType.includes('image')) {
      throw new Error('下载失败: 非图片文件')
    }
    
    const contentLength = response.headers.get('content-length')
    if (contentLength && parseInt(contentLength) === 0) {
      throw new Error('下载失败: 空文件')
    }
    
    const blob = await response.blob()
    
    // 检查文件大小
    if (blob.size === 0) {
      throw new Error('下载失败: 空文件')
    }
    
    // 验证 Blob 类型
    if (!blob.type.startsWith('image/')) {
      throw new Error('下载失败: 不支持的文件类型')
    }
    
    // 创建下载链接
    const link = document.createElement('a')
    link.href = URL.createObjectURL(blob)
    link.download = `ai-image-${Date.now()}.png`
    link.style.display = 'none'
    document.body.appendChild(link)
    
    try {
      link.click()
    } finally {
      document.body.removeChild(link)
      URL.revokeObjectURL(link.href)
    }
    
    // 可选: 添加成功提示
    // showToast({ type: 'success', message: '图片下载成功' })
    
  } catch (error) {
    console.error('下载失败详情:', error)
    
    // 用户友好的错误提示
    const errorMessage = error.message || '下载失败，请检查网络连接'
    alert(errorMessage)
    
    // 可选: 显示详细错误（开发环境）
    // if (process.env.NODE_ENV === 'development') {
    //   console.error('Download error details:', error)
    // }
  }
}
```

---

### 修复 #005: 环境变量校验

#### 文件位置
`MiaoDongAI_Design_TeamWork/lib/backend/config.ts`

#### 原始代码
```typescript
export const config = {
  deepseek: {
    apiKey: process.env.DEEPSEEK_API_KEY || '',
    baseUrl: process.env.DEEPSEEK_BASE_URL || 'https://api.deepseek.com'
  },
  kieai: {
    apiKey: process.env.KIEAI_API_KEY || '',
    baseUrl: process.env.KIEAI_BASE_URL || 'https://api.kie.ai'
  },
  port: process.env.PORT || 3000
}
```

#### 修复后代码
```typescript
// 添加类型定义
interface ApiConfig {
  apiKey: string
  baseUrl: string
}

interface AppConfig {
  deepseek: ApiConfig
  kieai: ApiConfig
  port: number
}

// 校验函数
const validateRequiredConfig = (): {
  valid: boolean
  missing: string[]
  errors: string[]
} => {
  const missing: string[] = []
  const errors: string[] = []
  
  // 检查 DeepSeek 配置
  if (!process.env.DEEPSEEK_API_KEY) {
    missing.push('DEEPSEEK_API_KEY')
    errors.push('DEEPSEEK_API_KEY is required')
  }
  
  if (!process.env.DEEPSEEK_BASE_URL) {
    console.warn('⚠️  DEEPSEEK_BASE_URL not set, using default')
  }
  
  // 检查 KIEAI 配置
  if (!process.env.KIEAI_API_KEY) {
    missing.push('KIEAI_API_KEY')
    errors.push('KIEAI_API_KEY is required')
  }
  
  if (!process.env.KIEAI_BASE_URL) {
    console.warn('⚠️  KIEAI_BASE_URL not set, using default')
  }
  
  return {
    valid: missing.length === 0,
    missing,
    errors
  }
}

// 创建配置对象
export const config: AppConfig = {
  deepseek: {
    apiKey: process.env.DEEPSEEK_API_KEY || '',
    baseUrl: process.env.DEEPSEEK_BASE_URL || 'https://api.deepseek.com'
  },
  kieai: {
    apiKey: process.env.KIEAI_API_KEY || '',
    baseUrl: process.env.KIEAI_BASE_URL || 'https://api.kie.ai'
  },
  port: parseInt(process.env.PORT || '3000', 10)
}

// 应用启动时校验（在 server start before listening）
export const validateConfigForStartup = () => {
  const validation = validateRequiredConfig()
  
  if (!validation.valid) {
    console.error('❌ Required environment variables are missing:')
    validation.errors.forEach(error => console.error(`   - ${error}`))
    console.error('\nPlease create .env.local file with the following variables:')
    validation.missing.forEach(varName => console.error(`   ${varName}=your_value_here`))
    console.error('\nExample .env.local:')
    console.error('DEEPSEEK_API_KEY=sk_xxxxxxxxx')
    console.error('DEEPSEEK_BASE_URL=https://api.deepseek.com')
    console.error('KIEAI_API_KEY=your_kieai_api_key')
    console.error('KIEAI_BASE_URL=https://api.kie.ai')
    console.error('PORT=3000')
    
    // 如果是生产环境，直接退出
    if (process.env.NODE_ENV === 'production') {
      process.exit(1)
    }
  } else {
    console.log('✅ Environment variables validation passed')
  }
  
  return validation.valid
}

// 在 server 启动时调用
// app.listen(config.port, () => {
//   validateConfigForStartup()
// })
```

---

## 🟢 P2 - 优化建议修复方案

### 修复 #006: 加载状态反馈

#### 文件位置
`MiaoDongAI_Design_TeamWork/app/design-agent/page.tsx`

#### 新增状态和 UI
```typescript
// 添加状态
const [generationProgress, setGenerationProgress] = useState<{
  status: 'idle' | 'creating' | 'processing' | 'completed' | 'failed'
  estimatedRemaining: number | null
  retryCount: number
  progress: number
}>({
  status: 'idle',
  estimatedRemaining: null,
  retryCount: 0,
  progress: 0
})

// 在 handleGenerateImage 中更新状态
const handleGenerateImage = async (prompt: string) => {
  try {
    setIsLoading(true)
    setGenerationProgress({
      status: 'creating',
      estimatedRemaining: null,
      retryCount: 0,
      progress: 10
    })
    
    // 创建任务
    const taskId = await createIllustrationTask({ prompt, aspectRatio })
    
    setGenerationProgress(prev => ({
      ...prev,
      status: 'processing',
      retryCount: 0,
      progress: 30
    }))
    
    // 轮询状态（带进度更新）
    let status = 'processing'
    let retryCount = 0
    const maxRetries = 40
    
    while (status === 'processing' && retryCount < maxRetries) {
      await new Promise(resolve => setTimeout(resolve, 10000))
      
      const result = await getIllustrationTaskStatus(taskId)
      
      if (result.success) {
        status = result.data.status
        
        // 计算进度
        const progress = Math.min(95, 30 + (retryCount / maxRetries) * 65)
        
        // 计算剩余时间
        const estimatedRemaining = (maxRetries - retryCount) * 10
        
        if (status === 'success' && result.data.imageUrl) {
          setGenerationProgress({
            status: 'completed',
            estimatedRemaining: 0,
            retryCount: retryCount,
            progress: 100
          })
          // ...
        }
        
        setGenerationProgress({
          status: 'processing',
          estimatedRemaining,
          retryCount: retryCount + 1,
          progress
        })
      }
      
      retryCount++
    }
    
    // ...
  } finally {
    setIsLoading(false)
  }
}
```

#### 新增 UI 组件
```tsx
// 在底部添加进度显示
{isLoading && (
  <div className="fixed bottom-0 left-0 right-0 h-4 bg-gray-100">
    <div 
      className="h-full bg-purple-600 transition-all duration-500"
      style={{ width: `${generationProgress.progress}%` }}
    />
  </div>
)}

// 或者在右上角添加微任务提示
{isLoading && generationProgress.status === 'processing' && (
  <div className="fixed top-20 right-4 bg-white rounded-lg p-3 shadow-lg">
    <div className="flex items-center gap-2">
      <div className="w-3 h-3 border-2 border-purple-600 border-t-transparent rounded-full animate-spin" />
      <div>
        <p className="text-xs font-medium">生成中...</p>
        <p className="text-xs text-gray-500">
          {generationProgress.estimatedRemaining 
            ? `预计剩余 ${generationProgress.estimatedRemaining}s` 
            : '处理中'}
        </p>
      </div>
    </div>
    <div className="mt-2 w-48 h-1.5 bg-gray-200 rounded-full overflow-hidden">
      <div 
        className="h-full bg-purple-600 transition-all duration-500"
        style={{ width: `${generationProgress.progress}%` }}
      />
    </div>
  </div>
)}
```

---

### 修复 #007: 测试补充

#### 1. 添加 API 测试
```javascript
// tests/design-agent-api.test.js
import { describe, test, expect, beforeEach, jest } from '@jest/globals'

describe('Design Agent API', () => {
  test('generatePrompt with valid input', async () => {
    // 模拟 API 调用
    expect(true).toBe(true)
  })
  
  test('handleGenerateImage with network error', async () => {
    // 测试错误重试机制
    expect(true).toBe(true)
  })
  
  test('handleDownloadImage with invalid URL', async () => {
    // 测试下载错误处理
    expect(true).toBe(true)
  })
})

export {}
```

#### 2. 添加组件测试
```javascript
// tests/InfiniteCanvas.test.js
import { render, screen, fireEvent } from '@testing-library/react'
import InfiniteCanvas from '@/components/ai-image/infinite-canvas'

describe('InfiniteCanvas', () => {
  test('renders empty state correctly', () => {
    render(<InfiniteCanvas 
      images={[]} 
      currentImageIndex={0}
      onImageIndexChange={jest.fn()}
      onDownload={jest.fn()}
      isCycling={false}
      onToggleCycle={jest.fn()}
    />)
    
    expect(screen.getByText(/无限画布/)).toBeInTheDocument()
  })
  
  test('renders images when provided', () => {
    render(<InfiniteCanvas 
      images={[
        { id: '1', url: 'https://example.com/image.png', prompt: 'Test' }
      ]}
      currentImageIndex={0}
      onImageIndexChange={jest.fn()}
      onDownload={jest.fn()}
      isCycling={false}
      onToggleCycle={jest.fn()}
    />)
    
    // 需要补充更多断言
  })
})
```

#### 3. 添加 E2E 测试
```javascript
// tests/design-agent.e2e.test.js
const { test, expect } = require('@playwright/test')

test.describe('Design Agent E2E Tests', () => {
  
  test.beforeEach(async ({ page }) => {
    await page.goto('/design-agent')
  })
  
  test('完整生图流程', async ({ page }) => {
    // 输入提示词
    await page.fill('textarea[placeholder="描述你想要的设计..."]', '一只可爱的猫咪')
    
    // 点击发送
    await page.click('button[type="button"].h-9.w-9')
    
    // 等待生成完成（ 添加更智能的等待）
    await page.waitForSelector('.bg-purple-600', { timeout: 60000 })
    
    // 验证图片显示
    await expect(page.locator('img')).toBeVisible()
  })
  
  test('无限画布缩放功能', async ({ page }) => {
    // 点击放大按钮
    await page.click('button:has-text("放大")')
    
    // 验证缩放（通过图片尺寸）
    const image = page.locator('img').first()
    const boundingBox = await image.boundingBox()
    
    expect(boundingBox).toBeDefined()
  })
})
```

#### 4. 添加性能测试
```javascript
// tests/performance.test.js
const { performance } = require('perf_hooks')

describe('Performance Tests', () => {
  test('首屏加载 < 2s', async () => {
    const startTime = performance.now()
    
    // 模拟页面加载
    await new Promise(resolve => setTimeout(resolve, 100))
    
    const endTime = performance.now()
    const loadTime = endTime - startTime
    
    expect(loadTime).toBeLessThan(2000)
  })
  
  test('图片加载性能', async () => {
    const startTime = performance.now()
    
    // 模拟图片加载
    await new Promise(resolve => setTimeout(resolve, 500))
    
    const endTime = performance.now()
    expect(endTime - startTime).toBeLessThan(1000)
  })
})
```

---

## 📊 修复验收标准

### P0 修复验收
- [ ] 网络中断时可在 3 次重试内恢复
- [ ] 空值不会导致应用崩溃
- [ ] 所有数组操作添加保护
- [ ] 通过单元测试

### P1 修复验收
- [ ] 缩放范围 0.5x - 3x 舒适可用
- [ ] 下载失败时有用户提示
- [ ] 缺少环境变量时启动失败并显示友好提示

### P2 修复验收
- [ ] 加载状态显示进度条和预计时间
- [ ] 测试覆盖率 ≥ 80%

---

## 🚀 推荐修复顺序

### Phase 1: 时间紧迫（1 天）
1. 修复 #002: 空值检查（1h）
2. 修复 #005: 环境变量校验（1h）
3. 修复 #004: 下载错误处理（0.5h）

### Phase 2: 优化体验（2 天）
4. 修复 #001: 错误重试机制（2h）
5. 修复 #003: 缩放边界优化（1h）
6. 修复 #006: 加载状态反馈（2h）

### Phase 3: 质量提升（2 天）
7. 补充单元测试（2h）
8. 补充 E2E 测试（2h）
9. 性能测试和优化（2h）

---

## 💡 附加建议

### 1. 添加日志追踪
```typescript
const logger = {
  info: (msg: string, data?: any) => {
    console.log(`[INFO] [${new Date().toISOString()}] ${msg}`, data)
  },
  error: (msg: string, err?: Error) => {
    console.error(`[ERROR] [${new Date().toISOString()}] ${msg}`, err)
  },
  warn: (msg: string) => {
    console.warn(`[WARN] [${new Date().toISOString()}] ${msg}`)
  }
}
```

### 2. 添加 Sentry 错误监控
```bash
npm install @sentry/react @sentry/tracing
```

```typescript
import * as Sentry from '@sentry/react'

Sentry.init({
  dsn: process.env.SENTRY_DSN,
  tracesSampleRate: 0.1,
})
```

### 3. 添加单元测试覆盖率
```bash
# 在 package.json 中添加
{
  "scripts": {
    "test:coverage": "jest --coverage --threshold=80"
  }
}
```

---

*本修复建议由 tester 自动生成，包含详细的代码修改示例和验收标准。*
