# 秒懂 AI 超级员工 - WEB 端技术方案

## 一、当前项目分析

### 1.1 技术栈现状
- 前端框架：React 18 + TypeScript
- UI 框架：TailwindCSS
- 框架：Next.js 14
- 部署平台：Vercel
- 部署地址：https://miaodong-ai-employee.vercel.app

### 1.2 移动端优先架构的局限性

作为移动端优先的 SPA 应用，在 WEB 端会面临以下问题：

#### 1.2.1 布局问题
- **垂直滚动主导**：移动端单列布局在桌面端会显得过于瘦长
- **触控交互依赖**：大量使用触摸手势、底部导航栏等移动端交互模式
- **视口未充分利用**：桌面大屏幕空间利用率低，造成大量空白区域
- **字体大小不适配**：移动端字体在桌面端可能过小或过大

#### 1.2.2 交互体验问题
- **缺少鼠标交互优化**：hover 效果缺失或不明显
- **无快捷键支持**：所有功能都依赖点击操作
- **缺少多标签支持**：WEB 端用户期望多页面同时开启
- **缺少拖拽功能**：桌面端常见的拖拽排序、文件拖入等未支持

#### 1.2.3 性能问题
- **SEO 不友好**：移动端优先架构可能在服务端渲染优化不足
- **图片懒加载缺失**：影响页面加载速度
- **代码分割不充分**：可能未充分利用 Next.js 的动态导入
- **CSS Bundle 过大**：未充分使用 Tailwind 的 purge 功能

#### 1.2.4 功能缺失
- **缺少桌面端特有功能**：全局搜索、快捷键、通知中心等
- **缺少状态持久化**：桌面端用户期望记住布局、偏好设置
- **缺少主题切换**：桌面端用户更关注深色/浅色主题
- **缺少多员工协作视图**：桌面端更适合多任务并行

#### 1.2.5 代码结构问题
- **组件耦合度高**：移动端单一视图导致组件职责不清晰
- **布局逻辑散乱**：响应式断点逻辑分散在各组件中
- **缺少布局容器抽象**：没有明确的 DesktopLayout/MobileLayout 概念
- **状态管理混乱**：移动端+桌面端状态未分离

---

## 二、WEB 端技术方案

### 2.1 响应式布局方案

#### 2.1.1 Tailwind 断点配置优化

在 `tailwind.config.js` 中自定义断点：

```javascript
/** @type {import('tailwindcss').Config} */
module.exports = {
  theme: {
    extend: {
      screens: {
        // 移动端优先（默认）
        'mobile': '0px',      // < 640px
        // 平板端
        'tablet': '768px',    // ≥ 640px && < 1024px
        // 小屏幕桌面端
        'small-laptop': '1024px', // ≥ 1024px && < 1280px
        // 标准桌面端
        'desktop': '1280px',  // ≥ 1280px && < 1536px
        // 大屏桌面端
        'large-desktop': '1536px', // ≥ 1536px
        // 超大屏
        '4k': '1920px',       // ≥ 1920px
      },
      // 定义布局容器宽度
      containers: {
        '2xl': '1400px',
        '3xl': '1600px',
        '4xl': '1920px',
      }
    }
  }
}
```

#### 2.1.2 响应式布局模式

```typescript
// types/responsive.ts
export type Breakpoint = 'mobile' | 'tablet' | 'small-laptop' | 'desktop' | 'large-desktop' | '4k';

export interface ResponsiveContext {
  breakpoint: Breakpoint;
  isMobile: boolean;
  isTablet: boolean;
  isSmallLaptop: boolean;
  isDesktop: boolean;
  isLargeDesktop: boolean;
  is4k: boolean;
  columns: number; // 对应栅格列数
  containerWidth: string;
}

// hooks/useResponsive.ts
import { useState, useEffect } from 'react';

export const useResponsive = (): ResponsiveContext => {
  const [breakpoint, setBreakpoint] = useState<Breakpoint>('mobile');

  useEffect(() => {
    const handleResize = () => {
      const width = window.innerWidth;
      
      if (width >= 1920) setBreakpoint('4k');
      else if (width >= 1536) setBreakpoint('large-desktop');
      else if (width >= 1280) setBreakpoint('desktop');
      else if (width >= 1024) setBreakpoint('small-laptop');
      else if (width >= 768) setBreakpoint('tablet');
      else setBreakpoint('mobile');
    };

    // 初始化
    handleResize();
    
    // 监听窗口变化
    window.addEventListener('resize', handleResize);
    return () => window.removeEventListener('resize', handleResize);
  }, []);

  return {
    breakpoint,
    isMobile: breakpoint === 'mobile',
    isTablet: breakpoint === 'tablet',
    isSmallLaptop: breakpoint === 'small-laptop',
    isDesktop: breakpoint === 'desktop',
    isLargeDesktop: breakpoint === 'large-desktop',
    is4k: breakpoint === '4k',
    columns: breakpoint === 'mobile' ? 4 : breakpoint === 'tablet' ? 8 : 12,
    containerWidth: breakpoint === '4k' ? '1920px' : breakpoint === 'large-desktop' ? '1536px' : '1280px',
  };
};
```

#### 2.1.3 响应式布局容器组件

```typescript
// components/layout/ResponsiveContainer.tsx
import { ReactNode } from 'react';
import { useResponsive } from '@/hooks/useResponsive';

interface ResponsiveContainerProps {
  children: ReactNode;
  className?: string;
}

export const ResponsiveContainer = ({ children, className = '' }: ResponsiveContainerProps) => {
  const { containerWidth, breakpoint } = useResponsive();

  return (
    <div
      className={`mx-auto px-4 sm:px-6 lg:px-8 ${className} ${
        breakpoint === 'mobile' ? 'max-w-full' : 'max-w-7xl'
      }`}
      style={{ maxWidth: containerWidth }}
    >
      {children}
    </div>
  );
};
```

#### 2.1.4 响应式栅格系统

```typescript
// components/layout/Grid.tsx
import { ReactNode } from 'react';
import { useResponsive } from '@/hooks/useResponsive';

interface GridProps {
  children: ReactNode;
  columns?: {
    mobile?: number;
    tablet?: number;
    desktop?: number;
  };
  gap?: 'small' | 'medium' | 'large';
  className?: string;
}

export const Grid = ({ 
  children, 
  columns = { mobile: 1, tablet: 2, desktop: 3 },
  gap = 'medium',
  className = ''
}: GridProps) => {
  const { isMobile, isTablet } = useResponsive();
  
  const getColumns = () => {
    if (isMobile) return columns.mobile;
    if (isTablet) return columns.tablet;
    return columns.desktop;
  };

  const getGapClass = () => {
    switch (gap) {
      case 'small': return 'gap-2 sm:gap-3';
      case 'large': return 'gap-6 sm:gap-8';
      default: return 'gap-4 sm:gap-6';
    }
  };

  return (
    <div 
      className={`grid grid-cols-${getColumns()} ${getGapClass()} ${className}`}
      style={{ gridTemplateColumns: `repeat(${getColumns()}, minmax(0, 1fr))` }}
    >
      {children}
    </div>
  );
};
```

---

### 2.2 组件重构建议

#### 2.2.1 组件分类与重构策略

| 组件类型 | 移动端特点 | WEB 端改造方向 | 优先级 |
|---------|-----------|--------------|--------|
| 布局组件 | 单列垂直布局 | 添加侧边栏、顶部导航栏 | ⭐⭐⭐⭐⭐ |
| 导航组件 | 底部导航栏 | 侧边栏导航 + 顶部面包屑 | ⭐⭐⭐⭐ |
| 内容展示 | 卡片堆叠 | 卡片网格 + 列表视图切换 | ⭐⭐⭐⭐ |
| 交互组件 | 触摸交互 | 添加 hover 效果 + 快捷键 | ⭐⭐⭐⭐⭐ |
| 表单组件 | 全屏表单 | 内联表单 + 弹窗表单 | ⭐⭐⭐ |

#### 2.2.2 核心布局组件重构

**1. 响应式导航栏组件**

```typescript
// components/layout/ResponsiveNavbar.tsx
'use client';

import { useState, useEffect } from 'react';
import Link from 'next/link';
import { useResponsive } from '@/hooks/useResponsive';

interface NavItem {
  label: string;
  href: string;
  icon?: React.FC<{ className?: string }>;
}

const navItems: NavItem[] = [
  { label: '首页', href: '/' },
  { label: '员工池', href: '/employees' },
  { label: '工作台', href: '/workspace' },
  { label: '知识库', href: '/knowledge' },
  { label: '设置', href: '/settings' },
];

export const ResponsiveNavbar = () => {
  const { isMobile, isDesktop, isLargeDesktop } = useResponsive();
  const [isMenuOpen, setIsMenuOpen] = useState(false);
  const [isScrolled, setIsScrolled] = useState(false);
  const [activeTab, setActiveTab] = useState('/');

  useEffect(() => {
    const handleScroll = () => {
      setIsScrolled(window.scrollY > 20);
    };
    window.addEventListener('scroll', handleScroll);
    return () => window.removeEventListener('scroll', handleScroll);
  }, []);

  useEffect(() => {
    setIsMenuOpen(false);
  }, [isMobile]);

  if (isMobile) {
    return (
      <nav className="fixed bottom-0 left-0 right-0 z-50 bg-white border-t border-gray-200 dark:bg-gray-900 dark:border-gray-800">
        <div className="flex justify-around items-center h-16">
          {navItems.map((item) => (
            <Link
              key={item.href}
              href={item.href}
              className={`flex flex-col items-center justify-center w-full h-full ${
                activeTab === item.href ? 'text-blue-600' : 'text-gray-500'
              }`}
              onClick={() => setActiveTab(item.href)}
            >
              {item.icon && <item.icon className="w-6 h-6 mb-1" />}
              <span className="text-xs">{item.label}</span>
            </Link>
          ))}
        </div>
      </nav>
    );
  }

  // 桌面端布局
  return (
    <nav 
      className={`fixed top-0 left-0 right-0 z-50 transition-all duration-300 ${
        isScrolled ? 'bg-white/90 dark:bg-gray-900/90 backdrop-blur-md shadow-sm' : 'bg-white dark:bg-gray-900'
      }`}
    >
      <div className="flex items-center justify-between h-16 px-6">
        {/* Logo */}
        <Link href="/" className="flex items-center space-x-2">
          <div className="w-8 h-8 bg-blue-600 rounded-lg flex items-center justify-center">
            <span className="text-white font-bold text-xl">AI</span>
          </div>
          <span className="text-xl font-bold text-gray-900 dark:text-white">
            秒懂 AI 超级员工
          </span>
        </Link>

        {/* Desktop Menu */}
        {isDesktop && (
          <div className="flex space-x-1">
            {navItems.map((item) => (
              <Link
                key={item.href}
                href={item.href}
                className={`px-3 py-2 rounded-lg text-sm font-medium transition-colors ${
                  activeTab === item.href
                    ? 'bg-blue-50 text-blue-700 dark:bg-blue-900/20 dark:text-blue-300'
                    : 'text-gray-700 hover:bg-gray-50 dark:text-gray-300 dark:hover:bg-gray-800'
                }`}
                onClick={() => setActiveTab(item.href)}
              >
                {item.label}
              </Link>
            ))}
          </div>
        )}

        {/* Right Actions */}
        <div className="flex items-center space-x-4">
          {/* Search */}
          <div className="hidden lg:block relative">
            <input
              type="text"
              placeholder="搜索员工..."
              className="w-64 px-4 py-2 rounded-lg border border-gray-300 dark:border-gray-700 dark:bg-gray-800 dark:text-white focus:outline-none focus:ring-2 focus:ring-blue-500"
              onKeyDown={(e) => {
                if (e.key === 'Enter' && e.currentTarget.value) {
                  // 触发搜索
                }
              }}
            />
            <kbd className="absolute right-3 top-2.5 text-xs text-gray-400 hidden md:block">
              ⌘K
            </kbd>
          </div>

          {/* Notifications */}
          <button className="relative p-2 rounded-lg hover:bg-gray-100 dark:hover:bg-gray-800">
            <span className="absolute top-1 right-1 w-2 h-2 bg-red-500 rounded-full"></span>
            <svg className="w-6 h-6 text-gray-600 dark:text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9" />
            </svg>
          </button>

          {/* User Profile */}
          <button className="flex items-center space-x-2 hover:opacity-80">
            <img 
              src="/avatar.png" 
              alt="User" 
              className="w-8 h-8 rounded-full border-2 border-blue-500"
            />
            <span className="hidden xl:block text-sm font-medium text-gray-700 dark:text-white">
              管理员
            </span>
          </button>
        </div>
      </div>
    </nav>
  );
};
```

**2. 响应式侧边栏组件**

```typescript
// components/layout/ResponsiveSidebar.tsx
'use client';

import { useState, useEffect } from 'react';
import Link from 'next/link';
import { useResponsive } from '@/hooks/useResponsive';

interface SidebarItem {
  label: string;
  href: string;
  icon: React.FC<{ className?: string }>;
  children?: SidebarItem[];
}

const sidebarItems: SidebarItem[] = [
  {
    label: '仪表盘',
    href: '/dashboard',
    icon: (props) => (
      <svg {...props} fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 6a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2H6a2 2 0 01-2-2V6zM14 6a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2h-2a2 2 0 01-2-2V6zM4 16a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2h-2a2 2 0 01-2-2v-2zM14 16a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2h-2a2 2 0 01-2-2v-2z" />
      </svg>
    )
  },
  {
    label: '员工管理',
    href: '/employees',
    icon: (props) => (
      <svg {...props} fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z" />
      </svg>
    )
  },
  {
    label: '工作空间',
    href: '/workspace',
    icon: (props) => (
      <svg {...props} fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M8 14v3m4-3v3m4-3v3M3 21h18M3 10h18M3 7l9-4 9 4M4 10h16v11H4V10z" />
      </svg>
    )
  },
  {
    label: '知识库',
    href: '/knowledge',
    icon: (props) => (
      <svg {...props} fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.747 0 3.332.477 4.5 1.253v13C19.832 18.477 18.247 18 16.5 18c-1.746 0-3.332.477-4.5 1.253" />
      </svg>
    )
  },
];

export const ResponsiveSidebar = ({ 
  isOpen, 
  onClose 
}: { 
  isOpen: boolean; 
  onClose?: () => void;
}) => {
  const { isDesktop, isTablet } = useResponsive();
  const [expandedItems, setExpandedItems] = useState<Set<string>>(new Set());

  const toggleItem = (label: string) => {
    const newExpanded = new Set(expandedItems);
    if (newExpanded.has(label)) {
      newExpanded.delete(label);
    } else {
      newExpanded.add(label);
    }
    setExpandedItems(newExpanded);
  };

  if (isDesktop) {
    return (
      <aside className="fixed left-0 top-16 h-[calc(100vh-4rem)] w-64 bg-white dark:bg-gray-900 border-r border-gray-200 dark:border-gray-800 transition-all duration-300 transform translate-x-0">
        <div className="p-4 space-y-2">
          {sidebarItems.map((item) => (
            <div key={item.label}>
              <button
                className={`w-full flex items-center justify-between px-3 py-2 rounded-lg text-sm font-medium transition-colors ${
                  item.children 
                    ? 'text-gray-700 hover:bg-gray-100 dark:text-gray-300 dark:hover:bg-gray-800'
                    : 'text-gray-700 hover:bg-gray-100 dark:text-gray-300 dark:hover:bg-gray-800'
                }`}
                onClick={() => item.children && toggleItem(item.label)}
              >
                <div className="flex items-center space-x-3">
                  <item.icon className="w-5 h-5" />
                  <span>{item.label}</span>
                </div>
                {item.children && (
                  <svg 
                    className={`w-4 h-4 transform transition-transform ${expandedItems.has(item.label) ? 'rotate-90' : ''}`}
                    fill="none" 
                    stroke="currentColor" 
                    viewBox="0 0 24 24"
                  >
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5l7 7-7 7" />
                  </svg>
                )}
              </button>
              {item.children && expandedItems.has(item.label) && (
                <div className="ml-4 mt-1 space-y-1 border-l border-gray-200 dark:border-gray-700 pl-3">
                  {item.children.map((child) => (
                    <Link
                      key={child.href}
                      href={child.href}
                      className="block px-3 py-2 rounded-md text-sm text-gray-600 hover:bg-gray-100 dark:text-gray-400 dark:hover:bg-gray-800"
                    >
                      {child.label}
                    </Link>
                  ))}
                </div>
              )}
              {!item.children && (
                <Link
                  href={item.href}
                  className="block px-3 py-2 rounded-lg text-sm text-gray-600 hover:bg-gray-100 dark:text-gray-400 dark:hover:bg-gray-800 ml-1"
                >
                  {item.label}
                </Link>
              )}
            </div>
          ))}
        </div>
      </aside>
    );
  }

  // 移动端和 Tablet 响应式侧边栏
  if (isTablet) {
    return (
      <>
        {/* Mobile Sidebar Overlay */}
        {isOpen && (
          <div 
            className="fixed inset-0 bg-black bg-opacity-50 z-40 lg:hidden"
            onClick={onClose}
          />
        )}
        
        {/* Mobile Sidebar */}
        <aside 
          className={`fixed left-0 top-0 h-full w-64 bg-white dark:bg-gray-900 z-50 transform transition-transform duration-300 ease-in-out ${
            isOpen ? 'translate-x-0' : '-translate-x-full'
          } lg:hidden`}
        >
          <div className="p-4 border-b border-gray-200 dark:border-gray-800 flex justify-between items-center">
            <span className="font-bold text-lg">导航菜单</span>
            <button onClick={onClose} className="p-1 rounded-lg hover:bg-gray-100 dark:hover:bg-gray-800">
              <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
              </svg>
            </button>
          </div>
          
          <div className="p-4 space-y-2">
            {sidebarItems.map((item) => (
              <div key={item.label}>
                <button
                  className={`w-full flex items-center justify-between px-3 py-3 rounded-lg text-sm font-medium transition-colors ${
                    item.children 
                      ? 'text-gray-700 hover:bg-gray-100 dark:text-gray-300 dark:hover:bg-gray-800'
                      : 'text-gray-700 hover:bg-gray-100 dark:text-gray-300 dark:hover:bg-gray-800'
                  }`}
                  onClick={() => item.children ? toggleItem(item.label) : onClose?.()}
                >
                  <div className="flex items-center space-x-3">
                    <item.icon className="w-5 h-5" />
                    <span>{item.label}</span>
                  </div>
                  {item.children && (
                    <svg 
                      className={`w-4 h-4 transform transition-transform ${expandedItems.has(item.label) ? 'rotate-90' : ''}`}
                      fill="none" 
                      stroke="currentColor" 
                      viewBox="0 0 24 24"
                    >
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5l7 7-7 7" />
                    </svg>
                  )}
                </button>
                {item.children && expandedItems.has(item.label) && (
                  <div className="ml-4 mt-1 space-y-1 border-l border-gray-200 dark:border-gray-700 pl-3">
                    {item.children.map((child) => (
                      <Link
                        key={child.href}
                        href={child.href}
                        className="block px-3 py-2 rounded-md text-sm text-gray-600 hover:bg-gray-100 dark:text-gray-400 dark:hover:bg-gray-800"
                        onClick={onClose}
                      >
                        {child.label}
                      </Link>
                    ))}
                  </div>
                )}
              </div>
            ))}
          </div>
        </aside>
      </>
    );
  }

  return null;
};
```

**3. 响应式卡片组件重构**

```typescript
// components/common/Card.tsx
'use client';

import { ReactNode } from 'react';
import { useResponsive } from '@/hooks/useResponsive';

interface CardProps {
  title?: ReactNode;
  subtitle?: ReactNode;
  icon?: ReactNode;
  action?: ReactNode;
  children: ReactNode;
  className?: string;
  hoverEffect?: boolean;
  onClick?: () => void;
}

export const Card = ({ 
  title, 
  subtitle, 
  icon, 
  action, 
  children, 
  className = '',
  hoverEffect = true,
  onClick
}: CardProps) => {
  const { isMobile, isDesktop } = useResponsive();

  // 移动端：简单卡片
  if (isMobile) {
    return (
      <div 
        onClick={onClick}
        className={`bg-white dark:bg-gray-800 rounded-xl p-4 shadow-sm border border-gray-200 dark:border-gray-700 ${className} ${onClick ? 'cursor-pointer active:scale-[0.98] transition-transform' : ''}`}
      >
        {(icon || title) && (
          <div className="flex items-start space-x-3 mb-3">
            {icon && <div className="flex-shrink-0">{icon}</div>}
            <div className="flex-1 min-w-0">
              {title && <h3 className="text-base font-semibold text-gray-900 dark:text-white truncate">{title}</h3>}
              {subtitle && <p className="text-sm text-gray-500 dark:text-gray-400 truncate">{subtitle}</p>}
            </div>
          </div>
        )}
        <div className={title || subtitle ? 'mt-2' : ''}>{children}</div>
      </div>
    );
  }

  // 桌面端：支持 hover 效果和右侧操作
  return (
    <div 
      onClick={onClick}
      className={`bg-white dark:bg-gray-800 rounded-lg shadow-sm hover:shadow-md transition-all duration-200 border border-gray-200 dark:border-gray-700 flex flex-col ${className} ${onClick ? 'cursor-pointer' : ''}`}
    >
      {(title || subtitle || icon || action) && (
        <div className={`px-5 py-4 ${action || icon ? 'flex items-start justify-between' : ''}`}>
          <div className="flex-1 min-w-0">
            {icon && <div className="mb-2">{icon}</div>}
            {title && <h3 className="text-lg font-semibold text-gray-900 dark:text-white">{title}</h3>}
            {subtitle && <p className="text-sm text-gray-500 dark:text-gray-400 mt-1">{subtitle}</p>}
          </div>
          {action}
        </div>
      )}
      <div className={`p-5 flex-1 ${title ? 'border-t border-gray-100 dark:border-gray-700/50' : ''}`}>
        {children}
      </div>
    </div>
  );
};
```

**4. 响应式员工卡片组件**

```typescript
// components/employee/EmployeeCard.tsx
'use client';

import { useState } from 'react';
import Image from 'next/image';
import { useResponsive } from '@/hooks/useResponsive';
import { Card } from '@/components/common/Card';

interface Employee {
  id: string;
  name: string;
  role: string;
  avatar: string;
  skills: string[];
  status: 'available' | 'busy' | 'offline';
  rating: number;
  completedTasks: number;
}

export const EmployeeCard = ({ employee }: { employee: Employee }) => {
  const { isMobile, isDesktop } = useResponsive();
  const [showDetails, setShowDetails] = useState(false);

  // 移动端：垂直布局
  if (isMobile) {
    return (
      <Card 
        title={employee.name}
        subtitle={employee.role}
        onClick={() => setShowDetails(!showDetails)}
      >
        <div className="flex items-center space-x-3 mb-3">
          <div className="relative w-10 h-10 rounded-full overflow-hidden">
            <Image
              src={employee.avatar}
              alt={employee.name}
              fill
              className="object-cover"
            />
          </div>
          <div className="flex-1">
            <div className="flex items-center space-x-2">
              <span className={`w-2 h-2 rounded-full ${
                employee.status === 'available' ? 'bg-green-500' :
                employee.status === 'busy' ? 'bg-red-500' : 'bg-gray-500'
              }`}></span>
              <span className="text-xs text-gray-600 dark:text-gray-400 capitalize">
                {employee.status}
              </span>
            </div>
            <div className="flex items-center mt-1">
              <span className="text-xs text-yellow-500 mr-1">
                {Array(5).fill(0).map((_, i) => 
                  i < Math.round(employee.rating) ? '★' : '☆'
                )}
              </span>
              <span className="text-xs text-gray-500">({employee.completedTasks})</span>
            </div>
          </div>
        </div>

        {showDetails && (
          <div className="mt-3">
            <div className="flex flex-wrap gap-1 mb-2">
              {employee.skills.slice(0, 3).map((skill, i) => (
                <span key={i} className="px-2 py-1 bg-blue-50 dark:bg-blue-900/20 text-blue-600 dark:text-blue-300 text-xs rounded">
                  {skill}
                </span>
              ))}
              {employee.skills.length > 3 && (
                <span className="px-2 py-1 bg-gray-50 dark:bg-gray-700 text-gray-500 dark:text-gray-400 text-xs rounded">
                  +{employee.skills.length - 3} 其他
                </span>
              )}
            </div>
            
            <div className="grid grid-cols-2 gap-2">
              <div className="p-2 bg-gray-50 dark:bg-gray-700/50 rounded-lg text-center">
                <div className="text-xs text-gray-500 dark:text-gray-400">可用性</div>
                <div className="font-semibold text-sm">95%</div>
              </div>
              <div className="p-2 bg-gray-50 dark:bg-gray-700/50 rounded-lg text-center">
                <div className="text-xs text-gray-500 dark:text-gray-400">响应时间</div>
                <div className="font-semibold text-sm">2.3s</div>
              </div>
            </div>
          </div>
        )}
      </Card>
    );
  }

  // 桌面端：卡片网格布局
  return (
    <Card hoverEffect className="group">
      <div className="flex items-start space-x-4">
        <div className="relative w-16 h-16 flex-shrink-0">
          <div className="absolute -inset-1 bg-gradient-to-r from-blue-400 to-purple-600 rounded-full opacity-0 group-hover:opacity-20 transition-opacity"></div>
          <div className="relative w-full h-full rounded-full overflow-hidden border-2 border-white dark:border-gray-700 shadow-sm">
            <Image
              src={employee.avatar}
              alt={employee.name}
              fill
              className="object-cover group-hover:scale-110 transition-transform duration-300"
            />
          </div>
          <div className={`absolute -bottom-1 -right-1 w-5 h-5 rounded-full border-2 border-white dark:border-gray-800 ${
            employee.status === 'available' ? 'bg-green-500' :
            employee.status === 'busy' ? 'bg-red-500' : 'bg-gray-500'
          }`}></div>
        </div>

        <div className="flex-1 min-w-0">
          <h3 className="text-lg font-semibold text-gray-900 dark:text-white truncate">
            {employee.name}
          </h3>
          <p className="text-sm text-gray-500 dark:text-gray-400 truncate">
            {employee.role}
          </p>
          
          <div className="flex items-center mt-2">
            <span className="text-sm text-yellow-500 mr-1">
              {Array(5).fill(0).map((_, i) => 
                i < Math.round(employee.rating) ? '★' : '☆'
              )}
            </span>
            <span className="text-sm text-gray-500 ml-1">
              ({employee.completedTasks} 任务)
            </span>
          </div>

          <div className="mt-3">
            <div className="flex flex-wrap gap-2">
              {employee.skills.slice(0, 4).map((