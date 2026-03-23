# 图片查看器自动化测试套件 🧪

**版本**: v1.0  
**创建时间**: 2026-03-20  
**负责人**: tester (测试运维工程师)

---

## 📋 测试清单

本测试套件对应 **20 项核心验收测试**：

| 类别 | 测试项数 | 文件位置 |
|------|----------|----------|
| P0 核心功能 | 12 项 | `image-viewer.test.js` |
| 响应式适配 | 4 项 | `image-viewer.test.js` |
| 性能指标 | 2 项 | `image-viewer.test.js` |
| 兼容性测试 | 2 项 | `image-viewer.test.js` |
| **总计** | **20 项** | - |

详细验收标准见：`../test-acceptance-checklist.md`

---

## 🚀 快速开始

### 1. 安装依赖

```bash
cd tests
npm install
```

### 2. 运行单元测试

```bash
# 运行所有测试
npm test

# 监视模式（开发时使用）
npm run test:watch

# 生成覆盖率报告
npm run test:coverage

# 详细输出
npm run test:verbose
```

### 3. 运行 E2E 测试

```bash
# 安装 Playwright 浏览器
npx playwright install

# 运行 E2E 测试
npm run test:e2e

# 打开 UI 模式
npm run test:e2e:ui

# 查看测试报告
npm run test:e2e:report
```

---

## 📁 文件结构

```
tests/
├── README.md                      # 本文件
├── package.json                   # 依赖配置
├── image-viewer.test.js           # 单元测试（Jest）
├── image-viewer.e2e.test.js       # E2E 测试（Playwright，待创建）
├── fixtures/                      # 测试数据（待创建）
│   └── sample-images.json
└── reports/                       # 测试报告（自动生成）
    ├── coverage/                  # 覆盖率报告
    └── playwright/                # E2E 报告
```

---

## 🧪 测试用例说明

### 单元测试 (Jest + Testing Library)

**文件**: `image-viewer.test.js`

| 测试组 | 测试项 | 描述 |
|--------|--------|------|
| 画廊模式 | 1.1-1.6 | 网格布局、懒加载、点击预览、计数显示 |
| 缩放交互 | 2.1-2.4 | 双击放大/还原、缩放范围、边界反弹 |
| 手势操作 | 3.1-3.5 | 滑动切换、拖拽平移、UI 切换、关闭返回 |
| 响应式适配 | 4.1-4.4 | 手机/平板/桌面适配、横竖屏切换 |
| 性能指标 | 5.1-5.2 | 首屏加载时间、滚动帧率 |
| 兼容性测试 | 6.1-6.3 | Touch 事件、CSS Grid、Intersection Observer |

### E2E 测试 (Playwright)

**文件**: `image-viewer.e2e.test.js` (待创建)

计划测试场景：
- 完整用户流程：浏览 → 预览 → 缩放 → 切换
- 多设备响应式测试
- 真实网络环境性能测试
- 跨浏览器兼容性测试

---

## 📊 测试报告

### 单元测试报告

运行 `npm run test:coverage` 后生成：

```
tests/reports/coverage/
├── index.html          # HTML 报告（浏览器打开）
├── lcov.info           # LCOV 格式（CI 集成）
└── text-summary.txt    # 文本摘要
```

### E2E 测试报告

运行 `npm run test:e2e` 后生成：

```
tests/reports/playwright/
├── index.html          # HTML 报告（带截图）
├── data/               # 测试数据
└── trace/              # 追踪文件
```

---

## 🔧 自定义配置

### 修改测试阈值

编辑 `image-viewer.test.js` 中的 `TEST_CONFIG`：

```javascript
const TEST_CONFIG = {
  performance: {
    firstScreenLoad: 2000,  // 首屏加载阈值 (ms)
    frameRate: 60,          // 最低帧率
    gestureResponse: 100    // 手势响应时间 (ms)
  },
  // ...
};
```

### 添加新测试用例

```javascript
describe('新功能测试', () => {
  test('新功能描述', async () => {
    // 测试代码
    expect(actual).toBe(expected);
  });
});
```

---

## 🎯 验收标准

### 通过标准

- ✅ 所有 P0 测试用例通过（12 项）
- ✅ 响应式测试全部通过（4 项）
- ✅ 性能测试达标（2 项）
- ✅ 兼容性测试通过（2 项）
- ✅ 总体通过率 ≥ 95%

### 失败处理

1. 查看测试报告定位失败用例
2. 分析失败原因（代码问题/测试问题）
3. 修复后重新运行测试
4. 更新验收 checklist 状态

---

## 📝 测试执行记录

| 日期 | 测试人员 | 通过率 | 备注 |
|------|----------|--------|------|
| 2026-03-20 | tester | -% | 初始版本，待执行 |

---

## 🔗 相关文档

- 验收 Checklist: `../test-acceptance-checklist.md`
- UI 设计文档: `../designs/image-viewer-ui-design.md`
- 执行摘要：`../designs/image-viewer-summary.md`
- 交付文档：`../DELIVERY.md`

---

*本测试框架由 tester (测试运维工程师) 创建，覆盖图片查看器 MVP 全部 20 项核心功能测试。*
