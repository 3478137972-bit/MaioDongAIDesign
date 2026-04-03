# 测试框架使用指南

**版本**: 2.0  
**日期**: 2026-03-29  
**维护者**: tester (测试运维工程师)

---

## 📦 项目结构

```
tests/
├── image-viewer.test.js      # 图片查看器 MVP 测试 (已更新 v2.0)
├── design-agent.test.js       # AI 绘图智能体测试 (新增 v2.0)
├── design-agent.e2e.test.js   # E2E 测试示例 (新增)
├── README.md                  # 详细测试文档
├── run-tests.sh              # 测试执行脚本
└── package.json              # 依赖配置
```

---

## 🎯 测试范围

### 1. 图片查看器 MVP (image-viewer.test.js)

| 功能模块 | 测试项 | 状态 |
|---------|--------|------|
| 画廊模式 | 6 项 | ✅ |
| 缩放交互 | 4 项 | ✅ |
| 手势操作 | 5 项 | ✅ |
| 响应式适配 | 4 项 | ✅ |
| 性能指标 | 2 项 | ✅ |
| 兼容性测试 | 2 项 | ✅ |
| **小计** | **23 项** | ✅ |

### 2. AI 绘图智能体 (design-agent.test.js)

| 功能模块 | 测试项 | 状态 |
|---------|--------|------|
| AI 绘图流程 | 5 项 | ✅ |
| 错误处理 | 5 项 | ✅ |
| 无限画布 | 5 项 | ✅ |
| 响应式适配 | 3 项 | ✅ |
| 性能指标 | 3 项 | ✅ |
| UI 交互 | 2 项 | ✅ |
| 安全性 | 3 项 | ✅ |
| **小计** | **26 项** | ✅ |

### 3. E2E 测试 (design-agent.e2e.test.js)

| 功能模块 | 测试项 | 状态 |
|---------|--------|------|
| 完整用户流程 | 1 项 | ✅ |
| 无限画布轮播 | 1 项 | ✅ |
| 错误处理 | 1 项 | ✅ |
| 性能 E2E | 2 项 | ✅ |
| **小计** | **5 项** | ✅ |

---

## 🚀 快速开始

### 1. 安装依赖

```bash
cd /root/.openclaw/workspace_manager/tests
npm install
```

### 2. 运行测试

```bash
# 方式 1: 使用脚本 (推荐)
./run-tests.sh

# 方式 2: 使用 npm
npm test

# 方式 3: 运行特定测试
npm test design-agent.test.js
```

### 3. 生成覆盖率报告

```bash
npm run test:coverage
open coverage/index.html
```

---

## 📊 测试统计

### 测试覆盖

```
总测试数: 54 项
├── 图片查看器 MVP: 23 项
├── AI 绘图智能体: 26 项
└── E2E 测试: 5 项

通过率目标: ≥ 95%
覆盖率目标: ≥ 80%
```

### 优先级分布

```
P0 (致命): 12 项  (必须通过)
P1 (重要): 32 项  (建议通过)
P2 (次要): 10 项  (可选通过)
```

---

## 🔧 测试配置

### 环境变量

```bash
# 可选: 在 tests/.env.local 中配置 API 密钥
DEEPSEEK_API_KEY=your_key_here
KIEAI_API_KEY=your_key_here
```

### 测试参数

```bash
# 超时设置 (毫秒)
TEST_TIMEOUT=30000

# 轮询间隔 (毫秒)
POLL_INTERVAL=10000

# 最大重试次数
MAX_RETRIES=30
```

---

## 📝 测试脚本说明

### run-tests.sh

```bash
用法: ./run-tests.sh [选项]

选项:
  1    运行所有单元测试 (默认)
  2    运行 AI 绘图功能测试
  3    运行设计智能体测试
  4    运行 E2E 测试
  5    运行所有测试 + 生成覆盖率报告
  6    监视模式（开发）
  -h   显示帮助
```

### npm 命令

```bash
# 运行测试
npm test                    # 运行所有测试
npm test:watch             # 监视模式
npm test:coverage          # 生成覆盖率报告
npm test:verbose           # 详细输出

# E2E 测试
npm run test:e2e           # 运行 E2E 测试
npm run test:e2e:ui        # UI 模式
npm run test:e2e:report    # 查看报告
```

---

## 🐛 常见问题

### 1. 测试超时

```bash
# 解决方案
npm test -- --timeout=60000
```

### 2. 网络错误

```bash
# 检查网络连接
ping example.com

# 检查 API 配置
cat tests/.env.local
```

### 3. Playwright 未安装

```bash
# 安装 Playwright
npm install -D @playwright/test
npx playwright install
```

### 4. 覆盖率报告为空

```bash
# 运行覆盖率测试
npm run test:coverage
```

---

## ✅ 测试通过标准

### 单元测试

- [ ] P0 测试通过率 ≥ 100%
- [ ] P1 测试通过率 ≥ 95%
- [ ] P2 测试通过率 ≥ 90%
- [ ] 总体通过率 ≥ 95%

### E2E 测试

- [ ] 主要用户流程通过 ≥ 95%
- [ ] 性能测试达标

### 覆盖率

- [ ] 代码覆盖率 ≥ 80%
- [ ] 关键路径覆盖率 100%

---

## 📈 下一步改进

### 短期

- [ ] 补充 E2E 测试用例
- [ ] 添加性能测试脚本
- [ ] 集成 CI/CD 流水线

### 中期

- [ ] 实现自动化测试报告推送
- [ ] 添加截图对比测试
- [ ] 实现测试数据持续集成

---

## 📞 支持

**测试作者**: tester  
**测试模型**: qwen3-coder-next  
**最后更新**: 2026-03-29  

**问题反馈**: 
- 飞书: #测试团队
- 邮件: tester@example.com

---

## 📜 更新日志

### v2.0 (2026-03-29)

- ✅ 新增 AI 绘图智能体测试套件 (26 项测试)
- ✅ 新增 E2E 测试示例 (5 项测试)
- ✅ 更新图片查看器测试以适配新代码
- ✅ 新增测试执行脚本
- ✅ 新增详细测试文档
- ✅ 新增故障排查指南

### v1.0 (2026-03-20)

- ✅ 初始版本
- ✅ 图片查看器 MVP 测试 (23 项)

---

*本文档由 tester 自动生成，基于测试框架 v2.0*
