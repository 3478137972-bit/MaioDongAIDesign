# 课程页面代码实现指南

**对应设计文档：** `course-page-redesign.md`  
**目标文件：** `src/pages/course.astro`  
**实现优先级：** P0 → P1 → P2

---

## 📦 新增组件清单

### 需要创建的新组件

```
src/
├── components/
│   ├── course/
│   │   ├── InstructorCard.astro      # 讲师介绍卡片
│   │   ├── TestimonialCard.astro     # 学员评价卡片
│   │   ├── TestimonialSlider.astro   # 评价轮播组件
│   │   ├── PriceCard.astro           # 价格信息卡片
│   │   ├── CountdownTimer.astro      # 倒计时组件
│   │   ├── FAQItem.astro             # FAQ 单个问题
│   │   ├── FAQSection.astro          # FAQ 列表
│   │   ├── ModuleAccordion.astro     # 课程大纲手风琴
│   │   └── BottomCTA.astro           # 底部 CTA
│   └── ui/
│       ├── StarRating.astro          # 星级评分
│       └── SectionHeading.astro      # 模块标题
```

---

## 🎯 P0 实现（必须上线前完成）

### 1. Hero Section 优化

**修改位置：** `src/pages/course.astro` Hero Section

**新增内容：**
- 讲师简介卡片
- 评分展示
- 学员数量
- 强化 CTA 按钮

**代码示例：**
```astro
<!-- 在现有标题下方添加 -->
<div class="mt-6 p-4 bg-white rounded-xl border border-orange-100 shadow-sm">
  <div class="flex items-center gap-4">
    <img 
      src="/images/instructor/avatar.jpg" 
      alt="讲师头像"
      class="w-16 h-16 rounded-full object-cover border-2 border-orange-200"
    />
    <div>
      <div class="font-semibold text-gray-900">XXX</div>
      <div class="text-sm text-gray-600">前 XX 公司 AI 负责人</div>
      <div class="text-sm text-gray-500 mt-1">
        10 年经验 · 5000+ 学员 · 50+ 企业
      </div>
    </div>
  </div>
</div>

<!-- 评分和学员数 -->
<div class="mt-6 flex items-center gap-6">
  <div class="flex items-center gap-2">
    <div class="flex text-yellow-400">
      <!-- 5 个星星 SVG -->
      <svg class="w-5 h-5" fill="currentColor">⭐</svg>
      <svg class="w-5 h-5" fill="currentColor">⭐</svg>
      <svg class="w-5 h-5" fill="currentColor">⭐</svg>
      <svg class="w-5 h-5" fill="currentColor">⭐</svg>
      <svg class="w-5 h-5" fill="currentColor">⭐</svg>
    </div>
    <span class="font-semibold text-gray-900">4.9</span>
    <span class="text-gray-500 text-sm">(2,341 人评价)</span>
  </div>
  <div class="flex items-center gap-2 text-gray-600">
    <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z" />
    </svg>
    <span>12,580 人已学习</span>
  </div>
</div>

<!-- 强化 CTA 按钮 -->
<div class="mt-8">
  <a 
    href="#price"
    class="inline-block bg-gradient-to-r from-orange-500 to-orange-600 text-white px-8 py-4 rounded-full text-lg font-bold shadow-lg hover:shadow-xl hover:scale-105 transition-all"
  >
    立即报名 - ¥1999
  </a>
  <div class="mt-2 text-sm text-orange-600 font-medium">
    🔥 限时优惠 · 仅剩 3 天
  </div>
</div>
```

---

### 2. 课程亮点卡片优化

**修改位置：** `src/pages/course.astro` 4 个系统卡片

**优化内容：**
- 增加详细描述
- 添加可量化收益
- 增强 hover 效果

**代码示例：**
```astro
<!-- 获客系统卡片 -->
<div class="bg-gradient-to-br from-orange-50 to-orange-100 border-2 border-orange-200 rounded-2xl p-6 hover:border-orange-400 hover:shadow-lg hover:-translate-y-1 transition-all duration-300">
  <div class="w-14 h-14 bg-orange-500 rounded-xl flex items-center justify-center mb-4 shadow-md">
    <svg class="w-7 h-7 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z" />
    </svg>
  </div>
  <h3 class="text-xl font-bold text-gray-900 mb-2">获客系统</h3>
  <ul class="space-y-2 mb-4">
    <li class="flex items-start gap-2 text-gray-600">
      <span class="text-orange-500 font-bold mt-0.5">✓</span>
      <span>自动引流系统搭建</span>
    </li>
    <li class="flex items-start gap-2 text-gray-600">
      <span class="text-orange-500 font-bold mt-0.5">✓</span>
      <span>精准客户定位方法</span>
    </li>
    <li class="flex items-start gap-2 text-gray-600">
      <span class="text-orange-500 font-bold mt-0.5">✓</span>
      <span>流量转化漏斗设计</span>
    </li>
  </ul>
  <div class="bg-white/60 rounded-lg p-3 border border-orange-100">
    <div class="flex items-start gap-2">
      <span class="text-lg">💡</span>
      <div class="text-sm text-gray-700">
        <span class="font-semibold">学完你能：</span>
        让精准客户主动找上门，获客成本降低 70%
      </div>
    </div>
  </div>
</div>
```

---

### 3. 价格信息模块（新增）

**创建文件：** `src/components/course/PriceCard.astro`

```astro
---
interface Props {
  originalPrice: number;
  discountPrice: number;
  endTime?: string;
}

const { originalPrice = 3999, discountPrice = 1999, endTime } = Astro.props;
const savings = originalPrice - discountPrice;
---

<section id="price" class="py-20 bg-gradient-to-br from-orange-50 to-white">
  <div class="max-w-4xl mx-auto px-6">
    <div class="text-center mb-8">
      <div class="inline-block bg-orange-100 text-orange-700 px-4 py-2 rounded-full text-sm font-semibold mb-4">
        🎉 限时优惠 · 仅剩 3 天
      </div>
      <h2 class="text-3xl md:text-4xl font-bold text-gray-900">立即加入 AI 实战营</h2>
    </div>

    <div class="bg-white rounded-3xl shadow-2xl overflow-hidden border-2 border-orange-200">
      <div class="p-8 md:p-12">
        <!-- 价格 -->
        <div class="text-center mb-8">
          <div class="text-gray-400 text-lg line-through mb-2">原价：¥{originalPrice}</div>
          <div class="text-5xl md:text-6xl font-bold text-orange-500 mb-2">¥{discountPrice}</div>
          <div class="text-green-600 font-semibold text-lg">💰 立省 ¥{savings}</div>
        </div>

        <!-- 包含内容 -->
        <div class="bg-orange-50 rounded-2xl p-6 mb-8">
          <h3 class="font-bold text-gray-900 mb-4 text-center">课程包含</h3>
          <div class="grid md:grid-cols-2 gap-3">
            <div class="flex items-center gap-2 text-gray-700">
              <span class="text-green-500 font-bold">✓</span>
              <span>4 大系统完整教学</span>
            </div>
            <div class="flex items-center gap-2 text-gray-700">
              <span class="text-green-500 font-bold">✓</span>
              <span>24 节视频课程</span>
            </div>
            <div class="flex items-center gap-2 text-gray-700">
              <span class="text-green-500 font-bold">✓</span>
              <span>社群答疑服务</span>
            </div>
            <div class="flex items-center gap-2 text-gray-700">
              <span class="text-green-500 font-bold">✓</span>
              <span>作业批改指导</span>
            </div>
            <div class="flex items-center gap-2 text-gray-700">
              <span class="text-green-500 font-bold">✓</span>
              <span>永久回放</span>
            </div>
            <div class="flex items-center gap-2 text-gray-700">
              <span class="text-green-500 font-bold">✓</span>
              <span>课程资料包</span>
            </div>
          </div>
        </div>

        <!-- 信任标识 -->
        <div class="text-center mb-8">
          <div class="flex items-center justify-center gap-4 text-sm text-gray-500">
            <span class="flex items-center gap-1">
              <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z" />
              </svg>
              安全支付
            </span>
            <span class="flex items-center gap-1">
              <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
              </svg>
              7 天无理由退款
            </span>
          </div>
        </div>

        <!-- CTA 按钮 -->
        <div class="text-center mb-8">
          <a 
            href="https://wx.qq.com"
            target="_blank"
            class="inline-block bg-gradient-to-r from-orange-500 to-orange-600 text-white px-12 py-4 rounded-full text-xl font-bold shadow-lg hover:shadow-xl hover:scale-105 transition-all"
          >
            立即报名
          </a>
        </div>

        <!-- 二维码 -->
        <div class="text-center">
          <p class="text-gray-600 mb-4 font-medium">或扫描下方二维码添加微信</p>
          <div class="inline-block bg-orange-50 p-4 rounded-2xl">
            <img 
              src="/images/qrcode/wechat.jpg" 
              alt="微信二维码" 
              class="w-48 h-48 rounded-xl shadow-md"
            />
          </div>
          <p class="mt-3 text-lg font-semibold text-gray-900">微信：m347820705</p>
        </div>
      </div>
    </div>

    <!-- 倒计时 -->
    {endTime && (
      <div class="text-center mt-8">
        <CountdownTimer endTime={endTime} />
      </div>
    )}
  </div>
</section>
```

---

### 4. 学员评价模块（新增）

**创建文件：** `src/components/course/TestimonialSlider.astro`

```astro
---
interface Testimonial {
  avatar: string;
  name: string;
  role: string;
  rating: number;
  content: string;
}

const testimonials: Testimonial[] = [
  {
    avatar: '/images/testimonials/user1.jpg',
    name: '张三',
    role: 'XX 公司 CEO',
    rating: 5,
    content: '学完课程后，我的获客成本降低了 70%，团队效率提升了 3 倍。这门课的投资回报率太高了！'
  },
  {
    avatar: '/images/testimonials/user2.jpg',
    name: '李四',
    role: '自由创业者',
    rating: 5,
    content: '老师讲得非常清楚，实战性很强。每节课都有具体的操作步骤，学完就能用。'
  },
  {
    avatar: '/images/testimonials/user3.jpg',
    name: '王五',
    role: '营销总监',
    rating: 5,
    content: '这个价格真的太值了，已经推荐给朋友了。课程内容系统全面，老师也很负责。'
  }
];
---

<section class="py-20 bg-white">
  <div class="max-w-6xl mx-auto px-6">
    <div class="text-center mb-12">
      <h2 class="text-3xl md:text-4xl font-bold text-gray-900 mb-4">学员怎么说</h2>
      <div class="flex items-center justify-center gap-2">
        <div class="flex text-yellow-400">
          {Array(5).fill(0).map(() => (
            <svg class="w-6 h-6" fill="currentColor" viewBox="0 0 20 20">
              <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z" />
            </svg>
          ))}
        </div>
        <span class="text-gray-600 font-medium">4.9/5.0</span>
        <span class="text-gray-400">(2,341 条评价)</span>
      </div>
    </div>

    <div class="grid md:grid-cols-3 gap-6">
      {testimonials.map((testimonial) => (
        <div class="bg-gray-50 rounded-2xl p-6 border border-gray-100 hover:shadow-lg transition-shadow">
          <div class="flex items-center gap-4 mb-4">
            <img 
              src={testimonial.avatar} 
              alt={testimonial.name}
              class="w-14 h-14 rounded-full object-cover"
            />
            <div>
              <div class="font-semibold text-gray-900">{testimonial.name}</div>
              <div class="text-sm text-gray-500">{testimonial.role}</div>
            </div>
          </div>
          <div class="flex text-yellow-400 mb-3">
            {Array(testimonial.rating).fill(0).map(() => (
              <svg class="w-5 h-5" fill="currentColor" viewBox="0 0 20 20">
                <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z" />
              </svg>
            ))}
          </div>
          <p class="text-gray-600 leading-relaxed">"{testimonial.content}"</p>
        </div>
      ))}
    </div>
  </div>
</section>
```

---

## 🎯 P1 实现（首版后迭代）

### 5. 课程大纲手风琴

**创建文件：** `src/components/course/ModuleAccordion.astro`

```astro
---
interface Module {
  title: string;
  lessons: Lesson[];
}

interface Lesson {
  title: string;
  duration: string;
  isFree?: boolean;
}

const modules: Module[] = [
  {
    title: 'Module 1: AI 获客系统',
    lessons: [
      { title: '精准客户定位方法', duration: '25 分钟', isFree: true },
      { title: '自动引流系统搭建', duration: '35 分钟' },
      { title: '流量转化漏斗设计', duration: '30 分钟' }
    ]
  },
  // ... 其他模块
];
---

<section class="py-20 bg-gray-50">
  <div class="max-w-4xl mx-auto px-6">
    <div class="text-center mb-12">
      <h2 class="text-3xl md:text-4xl font-bold text-gray-900 mb-4">课程大纲</h2>
      <p class="text-gray-600">4 大模块 · 24 课时 · 12 小时内容</p>
    </div>

    <div class="space-y-4">
      {modules.map((module, index) => (
        <details 
          class="group bg-white rounded-2xl border-2 border-orange-200 overflow-hidden"
          open={index === 0}
        >
          <summary class="flex items-center justify-between p-6 cursor-pointer hover:bg-orange-50 transition-colors">
            <div class="flex items-center gap-4">
              <div class="w-12 h-12 bg-orange-500 text-white rounded-xl flex items-center justify-center font-bold text-lg">
                {index + 1}
              </div>
              <div>
                <h3 class="text-xl font-bold text-gray-900">{module.title}</h3>
                <p class="text-sm text-gray-500">{module.lessons.length} 课时</p>
              </div>
            </div>
            <svg 
              class="w-6 h-6 text-orange-500 transform group-open:rotate-180 transition-transform" 
              fill="none" 
              stroke="currentColor" 
              viewBox="0 0 24 24"
            >
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
            </svg>
          </summary>
          <div class="border-t border-orange-100">
            <ul class="divide-y divide-orange-50">
              {module.lessons.map((lesson) => (
                <li class="flex items-center justify-between p-4 hover:bg-orange-50 transition-colors">
                  <div class="flex items-center gap-3">
                    {lesson.isFree && (
                      <span class="bg-green-100 text-green-700 text-xs px-2 py-1 rounded-full font-medium">
                        免费试听
                      </span>
                    )}
                    <span class="text-gray-700">{lesson.title}</span>
                  </div>
                  <span class="text-sm text-gray-500">{lesson.duration}</span>
                </li>
              ))}
            </ul>
          </div>
        </details>
      ))}
    </div>
  </div>
</section>
```

---

### 6. FAQ 模块

**创建文件：** `src/components/course/FAQSection.astro`

```astro
---
interface FAQ {
  question: string;
  answer: string;
}

const faqs: FAQ[] = [
  {
    question: '课程适合什么人群？',
    answer: '本课程适合：1) 想要用 AI 提升工作效率的职场人士；2) 想要搭建 AI 获客系统的创业者；3) 想要学习 AI 实战技能的学生。不需要编程基础，有电脑即可学习。'
  },
  {
    question: '课程学习周期是多久？',
    answer: '课程共 24 节课，每节课 25-40 分钟。建议每天学习 1-2 节课，2-3 周可以完成全部学习。课程永久回放，可以根据自己的节奏安排。'
  },
  {
    question: '学不会可以退款吗？',
    answer: '可以的。我们提供 7 天无理由退款保证。学习 7 天内，如果觉得课程不适合你，可以申请全额退款。'
  },
  {
    question: '课程有回放吗？',
    answer: '有的。所有课程视频都可以永久回放，包括后续更新的内容。你可以随时复习，也可以学习新增的课时。'
  },
  {
    question: '有社群服务吗？',
    answer: '有的。报名后会邀请你加入学员社群，里面有来自各行各业的同学，大家可以互相交流、分享资源。'
  },
  {
    question: '课后有问题可以咨询吗？',
    answer: '可以的。课程提供社群答疑服务，老师会在社群里解答大家的问题。复杂问题也可以预约一对一咨询。'
  }
];
---

<section class="py-20 bg-white">
  <div class="max-w-3xl mx-auto px-6">
    <div class="text-center mb-12">
      <h2 class="text-3xl md:text-4xl font-bold text-gray-900 mb-4">常见问题</h2>
    </div>

    <div class="space-y-4">
      {faqs.map((faq) => (
        <details class="group bg-gray-50 rounded-2xl overflow-hidden">
          <summary class="flex items-center justify-between p-6 cursor-pointer hover:bg-gray-100 transition-colors">
            <h3 class="text-lg font-semibold text-gray-900 pr-4">{faq.question}</h3>
            <svg 
              class="w-5 h-5 text-gray-400 transform group-open:rotate-180 transition-transform flex-shrink-0" 
              fill="none" 
              stroke="currentColor" 
              viewBox="0 0 24 24"
            >
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
            </svg>
          </summary>
          <div class="px-6 pb-6 text-gray-600 leading-relaxed">
            {faq.answer}
          </div>
        </details>
      ))}
    </div>
  </div>
</section>
```

---

### 7. 倒计时组件

**创建文件：** `src/components/course/CountdownTimer.astro`

```astro
---
interface Props {
  endTime: string; // ISO 格式：'2026-03-23T23:59:59'
}

const { endTime } = Astro.props;
---

<div class="flex items-center justify-center gap-4 text-lg">
  <span class="text-gray-600">⏰ 优惠倒计时：</span>
  <div 
    id="countdown"
    class="flex items-center gap-2 font-mono font-bold text-orange-500"
    data-end={endTime}
  >
    <span class="bg-orange-100 px-3 py-2 rounded-lg" id="days">00</span>天
    <span class="bg-orange-100 px-3 py-2 rounded-lg" id="hours">00</span>时
    <span class="bg-orange-100 px-3 py-2 rounded-lg" id="minutes">00</span>分
    <span class="bg-orange-100 px-3 py-2 rounded-lg" id="seconds">00</span>秒
  </div>
</div>

<script>
  function updateCountdown() {
    const end = new Date(document.getElementById('countdown')?.dataset.end || '').getTime();
    const now = Date.now();
    const diff = end - now;

    if (diff <= 0) {
      document.getElementById('countdown')!.innerHTML = '<span class="text-red-500">优惠已结束</span>';
      return;
    }

    const days = Math.floor(diff / (1000 * 60 * 60 * 24));
    const hours = Math.floor((diff % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
    const minutes = Math.floor((diff % (1000 * 60 * 60)) / (1000 * 60));
    const seconds = Math.floor((diff % (1000 * 60)) / 1000);

    document.getElementById('days')!.textContent = String(days).padStart(2, '0');
    document.getElementById('hours')!.textContent = String(hours).padStart(2, '0');
    document.getElementById('minutes')!.textContent = String(minutes).padStart(2, '0');
    document.getElementById('seconds')!.textContent = String(seconds).padStart(2, '0');

    // 最后 1 小时变红色
    if (diff < 1000 * 60 * 60) {
      document.getElementById('countdown')!.classList.add('animate-pulse');
    }
  }

  updateCountdown();
  setInterval(updateCountdown, 1000);
</script>
```

---

### 8. 底部 CTA

**创建文件：** `src/components/course/BottomCTA.astro`

```astro
---
---

<section class="py-16 bg-gradient-to-r from-orange-500 to-orange-600">
  <div class="max-w-4xl mx-auto px-6 text-center">
    <h2 class="text-3xl md:text-4xl font-bold text-white mb-4">
      🚀 立即加入 AI 实战营，开启你的 AI 商业之旅
    </h2>
    <p class="text-orange-100 text-lg mb-8">
      ⏰ 限时优惠仅剩 3 天 · 已有 12,580 人加入
    </p>
    <a 
      href="#price"
      class="inline-block bg-white text-orange-600 px-12 py-4 rounded-full text-xl font-bold shadow-lg hover:shadow-xl hover:scale-105 transition-all"
    >
      立即报名 - ¥1999
    </a>
    <p class="text-orange-100 mt-6">
      或联系微信：m347820705
    </p>
  </div>
</section>
```

---

## 📋 完整页面组装

**修改文件：** `src/pages/course.astro`

```astro
---
import BaseLayout from '../layouts/BaseLayout.astro';
import '../styles/global.css';

// 导入新组件
import ModuleAccordion from '../components/course/ModuleAccordion.astro';
import TestimonialSlider from '../components/course/TestimonialSlider.astro';
import PriceCard from '../components/course/PriceCard.astro';
import FAQSection from '../components/course/FAQSection.astro';
import BottomCTA from '../components/course/BottomCTA.astro';
---

<BaseLayout title="AI 实战营 - 课程">
  <!-- 1. Hero Section (优化版) -->
  <section>...</section>

  <!-- 2. 课程亮点 (优化版) -->
  <section>...</section>

  <!-- 3. 讲师介绍 (新增) -->
  <section>...</section>

  <!-- 4. 课程大纲 (优化版) -->
  <ModuleAccordion />

  <!-- 5. 学员评价 (新增) -->
  <TestimonialSlider />

  <!-- 6. 价格信息 (新增) -->
  <PriceCard endTime="2026-03-23T23:59:59" />

  <!-- 7. FAQ (新增) -->
  <FAQSection />

  <!-- 8. 底部 CTA (新增) -->
  <BottomCTA />
</BaseLayout>
```

---

## ✅ 检查清单

### P0 检查项
- [ ] Hero 区域添加讲师介绍
- [ ] Hero 区域添加评分和学员数
- [ ] Hero 区域 CTA 按钮强化
- [ ] 4 个系统卡片优化（详细描述 + 收益）
- [ ] 价格信息模块
- [ ] 学员评价模块
- [ ] 微信二维码保留

### P1 检查项
- [ ] 课程大纲手风琴交互
- [ ] FAQ 模块
- [ ] 倒计时功能
- [ ] 底部 CTA

### 响应式检查
- [ ] 移动端布局正常
- [ ] 平板布局正常
- [ ] 桌面布局正常
- [ ] 所有按钮可点击（最小 44x44px）
- [ ] 文字大小合适（不小于 14px）

### 性能检查
- [ ] 图片懒加载
- [ ] 图片 WebP 格式
- [ ] JavaScript 按需加载
- [ ] 首屏加载时间 < 3s

---

**实现完成时间预估：**
- P0: 4-6 小时
- P1: 3-4 小时
- 响应式适配：2-3 小时
- 测试优化：2 小时

**总计：** 11-15 小时
