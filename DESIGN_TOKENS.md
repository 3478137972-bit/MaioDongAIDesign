# 乐乐 AI 训练师小程序 - 设计规范文档

## 品牌概述
- **品牌名**: 乐乐 AI 训练师
- **品牌色**: 橙色 #F97316
- **设计风格**: 温暖、专业、亲和、现代

---

## 1. 色彩系统

### 1.1 主色调
| 名称 | 色值 | 用途 |
|------|------|------|
| Primary | `#F97316` | 主按钮、强调色、图标高亮 |
| Primary Light | `#FB923C` | 悬停状态、次要强调 |
| Primary Dark | `#EA580C` | 按下状态、深色强调 |
| Primary Subtle | `#FFF7ED` | 背景色、浅色卡片背景 |

### 1.2 中性色
| 名称 | 色值 | 用途 |
|------|------|------|
| Black | `#1A1A1A` | 主标题、重要文字 |
| Gray-900 | `#374151` | 正文文字 |
| Gray-700 | `#6B7280` | 次要文字、描述 |
| Gray-500 | `#9CA3AF` | 占位文字、禁用 |
| Gray-300 | `#D1D5DB` | 边框、分割线 |
| Gray-100 | `#F3F4F6` | 背景、卡片底色 |
| White | `#FFFFFF` | 纯白背景 |

### 1.3 功能色
| 名称 | 色值 | 用途 |
|------|------|------|
| Success | `#22C55E` | 成功状态、完成标记 |
| Warning | `#F59E0B` | 警告、提醒 |
| Error | `#EF4444` | 错误、删除 |
| Info | `#3B82F6` | 信息提示 |

### 1.4 渐变色
```css
/* 主渐变 - 英雄区背景 */
--gradient-primary: linear-gradient(135deg, #F97316 0%, #FB923C 50%, #FDBA74 100%);

/* 深色渐变 - 卡片遮罩 */
--gradient-dark: linear-gradient(180deg, rgba(0,0,0,0) 0%, rgba(0,0,0,0.6) 100%);

/* 浅色渐变 - 卡片背景 */
--gradient-light: linear-gradient(135deg, #FFF7ED 0%, #FFFFFF 100%);

/* 橙色光晕 */
--gradient-glow: radial-gradient(circle, rgba(249,115,22,0.15) 0%, transparent 70%);
```

---

## 2. 字体系统

### 2.1 字体家族
```css
--font-primary: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'PingFang SC', 'Hiragino Sans GB', 'Microsoft YaHei', sans-serif;
--font-mono: 'SF Mono', Monaco, 'Cascadia Code', monospace;
```

### 2.2 字体层级

| 层级 | 字号 | 字重 | 行高 | 用途 |
|------|------|------|------|------|
| Display | 32px | 700 | 1.2 | 英雄区大标题 |
| H1 | 24px | 700 | 1.3 | 页面标题 |
| H2 | 20px | 600 | 1.4 | 区块标题 |
| H3 | 18px | 600 | 1.4 | 卡片标题 |
| H4 | 16px | 600 | 1.5 | 小标题 |
| Body | 14px | 400 | 1.6 | 正文内容 |
| Caption | 12px | 400 | 1.5 | 辅助说明 |
| Small | 10px | 400 | 1.4 | 标签、时间 |

### 2.3 字体样式
```css
/* 标题样式 */
--text-title: font-size: 24px; font-weight: 700; color: #1A1A1A;
--text-subtitle: font-size: 16px; font-weight: 600; color: #374151;

/* 正文样式 */
--text-body: font-size: 14px; font-weight: 400; color: #374151; line-height: 1.6;
--text-caption: font-size: 12px; font-weight: 400; color: #6B7280;

/* 特殊样式 */
--text-link: font-size: 14px; font-weight: 500; color: #F97316;
--text-price: font-size: 20px; font-weight: 700; color: #F97316;
```

---

## 3. 间距系统

### 3.1 基础单位
以 **8px** 为基准单位，所有间距均为 8 的倍数。

| Token | 值 | 用途 |
|-------|-----|------|
| space-1 | 4px | 极小间距、图标内边距 |
| space-2 | 8px | 紧凑间距、小图标 |
| space-3 | 12px | 标准内边距 |
| space-4 | 16px | 卡片内边距 |
| space-5 | 20px | 中等间距 |
| space-6 | 24px | 区块间距 |
| space-8 | 32px | 大间距 |
| space-10 | 40px | 页面边距 |
| space-12 | 48px | 大区块间距 |

### 3.2 组件间距
```css
/* 页面边距 */
--page-padding: 16px;
--page-padding-lg: 24px;

/* 卡片间距 */
--card-padding: 16px;
--card-gap: 12px;

/* 列表间距 */
--list-gap: 8px;
--list-item-padding: 12px 16px;

/* 表单间距 */
--form-gap: 16px;
--input-padding: 12px 16px;
```

---

## 4. 圆角规范

| Token | 值 | 用途 |
|-------|-----|------|
| radius-none | 0px | 无圆角 |
| radius-sm | 4px | 小标签、输入框 |
| radius-md | 8px | 按钮、小卡片 |
| radius-lg | 12px | 标准卡片 |
| radius-xl | 16px | 大卡片、弹窗 |
| radius-2xl | 24px | 特殊卡片 |
| radius-full | 9999px | 圆形、胶囊按钮 |

### 4.1 组件圆角
```css
--button-radius: 8px;
--card-radius: 12px;
--input-radius: 8px;
--avatar-radius: 50%;
--tag-radius: 4px;
--modal-radius: 16px;
```

---

## 5. 阴影效果

### 5.1 阴影层级
```css
/* 无阴影 */
--shadow-none: none;

/* 小阴影 - 悬停状态 */
--shadow-sm: 0 1px 2px rgba(0, 0, 0, 0.05);

/* 标准阴影 - 卡片 */
--shadow-md: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -2px rgba(0, 0, 0, 0.1);

/* 大阴影 - 浮层 */
--shadow-lg: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -4px rgba(0, 0, 0, 0.1);

/* 特殊阴影 - 模态框 */
--shadow-xl: 0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 8px 10px -6px rgba(0, 0, 0, 0.1);

/* 橙色光晕 */
--shadow-glow: 0 0 20px rgba(249, 115, 22, 0.3);

/* 内阴影 */
--shadow-inner: inset 0 2px 4px rgba(0, 0, 0, 0.05);
```

### 5.2 阴影使用场景
- **Card**: shadow-md
- **Button Hover**: shadow-sm
- **Modal**: shadow-xl
- **Floating Action**: shadow-lg + shadow-glow
- **Input Focus**: shadow-inner + border-primary

---

## 6. 动画规范

### 6.1 过渡时间
```css
--duration-fast: 150ms;
--duration-normal: 300ms;
--duration-slow: 500ms;
```

### 6.2 缓动函数
```css
--ease-default: cubic-bezier(0.4, 0, 0.2, 1);
--ease-in: cubic-bezier(0.4, 0, 1, 1);
--ease-out: cubic-bezier(0, 0, 0.2, 1);
--ease-bounce: cubic-bezier(0.68, -0.55, 0.265, 1.55);
```

### 6.3 常用动画
```css
/* 淡入 */
@keyframes fadeIn {
  from { opacity: 0; }
  to { opacity: 1; }
}

/* 上滑淡入 */
@keyframes slideUp {
  from { opacity: 0; transform: translateY(20px); }
  to { opacity: 1; transform: translateY(0); }
}

/* 缩放弹出 */
@keyframes popIn {
  from { opacity: 0; transform: scale(0.9); }
  to { opacity: 1; transform: scale(1); }
}

/* 脉冲 */
@keyframes pulse {
  0%, 100% { transform: scale(1); }
  50% { transform: scale(1.05); }
}

/* 呼吸 */
@keyframes breathe {
  0%, 100% { opacity: 1; }
  50% { opacity: 0.6; }
}
```

---

## 7. 图标规范

### 7.1 图标尺寸
| 名称 | 尺寸 | 用途 |
|------|------|------|
| xs | 12px | 极小图标 |
| sm | 16px | 行内图标 |
| md | 20px | 按钮图标 |
| lg | 24px | 导航图标 |
| xl | 32px | 功能图标 |
| 2xl | 48px | 大功能图标 |

### 7.2 图标颜色
```css
--icon-primary: #F97316;
--icon-secondary: #6B7280;
--icon-muted: #9CA3AF;
--icon-inverse: #FFFFFF;
```

---

## 8. 断点规范

```css
/* 移动端优先 */
--screen-sm: 375px;   /* 小屏手机 */
--screen-md: 414px;   /* 大屏手机 */
--screen-lg: 768px;   /* 平板 */
--screen-xl: 1024px;  /* 大平板/小桌面 */
```

---

## 9. Z-Index 层级

```css
--z-dropdown: 100;
--z-sticky: 200;
--z-fixed: 300;
--z-modal-backdrop: 400;
--z-modal: 500;
--z-popover: 600;
--z-tooltip: 700;
--z-toast: 800;
```

---

## 10. 组件快速参考

### 10.1 主按钮
```css
background: #F97316;
color: #FFFFFF;
border-radius: 8px;
padding: 12px 24px;
font-size: 16px;
font-weight: 600;
box-shadow: 0 4px 6px -1px rgba(249, 115, 22, 0.3);
```

### 10.2 卡片
```css
background: #FFFFFF;
border-radius: 12px;
padding: 16px;
box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
```

### 10.3 输入框
```css
background: #FFFFFF;
border: 1px solid #D1D5DB;
border-radius: 8px;
padding: 12px 16px;
font-size: 14px;
```

### 10.4 标签
```css
background: #FFF7ED;
color: #F97316;
border-radius: 4px;
padding: 4px 8px;
font-size: 12px;
font-weight: 500;
```

---

*文档版本: v1.0*
*最后更新: 2026-03-23*
*设计师: kimi-k2.5*
