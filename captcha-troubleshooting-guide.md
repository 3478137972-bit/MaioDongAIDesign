# 邮箱验证码过期问题排查指南

## 问题现象
用户反馈：邮箱注册验证码输入后显示过期，但实际操作时间在1分钟内。

---

## 1. 验证码生成代码排查

### 检查点1.1: 配置参数检查

**Node.js/JavaScript (Redis缓存)**：
```javascript
// 检查代码中的过期时间配置
const captchaCode = generateRandomCode(6);
const expiresIn = 300; // 5分钟 = 300秒

// 常见错误：配置为60秒（1分钟）
const wrongExpiresIn = 60; // ❌ 这会导致验证码1分钟过期

// 正确配置示例
redis.setex(
  `captcha:${email}`,
  300,  // ✅ 5分钟过期时间（300秒）
  JSON.stringify({
    code: captchaCode,
    createdAt: Date.now(),
    email: email
  })
);
```

**Python (Redis缓存)**：
```python
# 检查过期时间配置
import redis
import time

r = redis.Redis(host='localhost', port=6379, db=0)

# 常见错误
r.setex(f'captcha:{email}', 60, captcha_code)  # ❌ 60秒过期

# 正确配置
r.setex(f'captcha:{email}', 300, captcha_code)  # ✅ 300秒过期

# 或使用Pipeline
pipe = r.pipeline()
pipe.set(f'captcha:{email}', captcha_code)
pipe.expire(f'captcha:{email}', 300)  # ✅ 300秒
pipe.execute()
```

### 检查点1.2: 生成时间戳处理

**检查是否使用了错误的时间戳**：
```javascript
// ❌ 错误：使用客户端时间（可能与服务器时间不同步）
const clientTime = Date.now();  // 用户浏览器时间

// ✅ 正确：使用服务器时间
const serverTime = Date.now();  // 服务器时间
```

```python
# ❌ 错误：使用客户端传来的时间
client_timestamp = request.json.get('timestamp')  # 可能不准确

# ✅ 正确：使用服务器时间
server_timestamp = int(time.time())  # 服务器时间戳
```

---

## 2. 服务器时间同步检查

### 2.1 Linux系统时间检查
```bash
# 检查当前时间
date
date -R  # 显示时区信息

# 检查NTP同步状态
ntpstat
timedatectl status

# 手动同步时间
sudo ntpdate -s time.nist.gov
# 或
sudo timedatectl set-ntp true
```

### 2.2 Redis时间检查
```bash
# Redis内部时间（注意：Redis返回的是秒+微秒）
redis-cli TIME
# 返回示例: 1) "1712300000"  2) "123456"

# 对比服务器时间
date +%s
```

### 2.3 检查时区配置
```bash
# 查看时区
timedatectl | grep "Time zone"

# 检查应用时区配置（Node.js）
cat app.js | grep -i "timezone\|utc"

# 检查应用时区配置（Python）
cat app.py | grep -i "timezone\|utc\|pytz"
```

---

## 3. 验证码验证逻辑检查

### 检查点3.1: 验证逻辑Bug

**常见错误：提前标记为已使用**
```javascript
// ❌ 错误：验证前就标记为已使用
async function verifyCaptcha(email, code) {
  const cached = await redis.get(`captcha:${email}`);
  
  // ❌ 这里就标记为已使用了，但验证可能失败
  await redis.set(`captcha:${email}_used`, 'true');
  
  if (!cached) return { success: false, error: '验证码不存在' };
  
  const data = JSON.parse(cached);
  if (data.code !== code) return { success: false, error: '验证码错误' };
  
  return { success: true };
}

// ✅ 正确：验证成功后再标记
async function verifyCaptcha(email, code) {
  const cached = await redis.get(`captcha:${email}`);
  
  if (!cached) return { success: false, error: '验证码不存在' };
  
  const data = JSON.parse(cached);
  if (data.code !== code) return { success: false, error: '验证码错误' };
  
  // ✅ 验证成功后才标记
  await redis.set(`captcha:${email}_used`, 'true');
  return { success: true };
}
```

**常见错误：过期时间计算错误**
```javascript
// ❌ 错误：使用创建时间+配置时间，但忘记处理过期
async function isExpired(createdAt, expiresIn) {
  const now = Date.now();
  const expireTime = createdAt + expiresIn;  // ❌ 单位不一致
  return now > expireTime;
}

// ✅ 正确：统一使用毫秒或秒
async function isExpired(createdAt, expiresInSeconds) {
  const now = Date.now();  // 毫秒
  const expireTime = createdAt + (expiresInSeconds * 1000);  // ✅ 转换为毫秒
  return now > expireTime;
}
```

### 检查点3.2: 并发验证问题

**使用Redis事务防止并发验证**：
```javascript
// ❌ 错误：没有事务保护，可能导致并发验证通过
async function verifyCaptcha(email, code) {
  const cached = await redis.get(`captcha:${email}`);
  
  // ❌ 这里有时间窗，可能被并发请求破坏
  if (!cached) return { success: false, error: '验证码不存在' };
  
  // 检查是否已被使用
  const used = await redis.get(`captcha:${email}_used`);
  if (used) return { success: false, error: '验证码已被使用' };
  
  const data = JSON.parse(cached);
  if (data.code !== code) return { success: false, error: '验证码错误' };
  
  await redis.set(`captcha:${email}_used`, 'true');
  return { success: true };
}

// ✅ 正确：使用Redis事务
async function verifyCaptcha(email, code) {
  const key = `captcha:${email}`;
  const usedKey = `captcha:${email}_used`;
  
  // 使用watch监控key变化
  await redis.watch(key);
  
  const cached = await redis.get(key);
  if (!cached) {
    redis.unwatch();
    return { success: false, error: '验证码不存在' };
  }
  
  const data = JSON.parse(cached);
  
  // 检查是否过期
  const now = Date.now();
  if (now > data.expiresAt) {
    redis.unwatch();
    return { success: false, error: '验证码已过期' };
  }
  
  // 检查是否已被使用
  const used = await redis.get(usedKey);
  if (used) {
    redis.unwatch();
    return { success: false, error: '验证码已被使用' };
  }
  
  // 使用事务
  const transaction = redis.multi();
  transaction.set(usedKey, 'true', 'EX', 300);  // 标记为已使用
  transaction.del(key);  // 删除验证码
  transaction.setnx(`captcha:${email}_verified_at`, now.toString());  // 记录验证时间
  
  try {
    await transaction.exec();
    return { success: true };
  } catch (e) {
    return { success: false, error: '验证码验证冲突，请重试' };
  }
}
```

---

## 4. Redis/缓存过期时间设置检查

### 检查点4.1: Redis配置检查

**检查redis.conf配置**：
```bash
# 查看Redis配置
grep -E "maxmemory|timeout|expire" /etc/redis/redis.conf

# 检查当前Redis内存策略
redis-cli CONFIG GET maxmemory-policy

# 检查Redis的active-expiration配置
redis-cli CONFIG GET activedefrag
```

### 检查点4.2: 代码中的过期时间设置

**JavaScript (ioredis)**：
```javascript
const Redis = require('ioredis');
const redis = new Redis({
  host: 'localhost',
  port: 6379,
  // ⚠️ 注意：Redis的setex/expire使用秒为单位
  // 不是毫秒！
});

// ✅ 正确：使用300秒（5分钟）
await redis.setex(`captcha:${email}`, 300, captchaCode);

// ❌ 错误：如果写成60就只有1分钟
await redis.setex(`captcha:${email}`, 60, captchaCode);  // 仅1分钟
```

**Python (redis-py)**：
```python
import redis

r = redis.Redis(host='localhost', port=6379, db=0)

# ✅ 正确：使用300秒
r.setex(f'captcha:{email}', 300, code)

# ❌ 错误：只设置60秒
r.setex(f'captcha:{email}', 60, code)  # 仅1分钟

# 或使用pipeline
pipe = r.pipeline()
pipe.set(f'captcha:{email}', code)
pipe.expire(f'captcha:{email}', 300)  # ✅ 300秒
pipe.execute()
```

### 检查点4.3: 检查Redisoverhead

```bash
# 检查Redis中验证码key的实际TTL
redis-cli KEYS 'captcha:*' | while read key; do
    ttl=$(redis-cli TTL $key)
    echo "$key TTL: ${ttl}s"
done

# 检查key的内存使用
redis-cli OBJECT encoding "captcha:user@example.com"

# 检查是否存在大量过期key未清理
redis-cli SCAN 0 MATCH "captcha:*" COUNT 1000
```

---

## 5. 并发请求问题检查

### 检查点5.1: 并发生成相同验证码

**问题场景**：多个请求同时生成验证码，可能生成相同的随机码

```javascript
// ❌ 错误：没有防重机制
async function generateCaptcha(email) {
  const code = Math.floor(100000 + Math.random() * 900000);
  await redis.setex(`captcha:${email}`, 300, code);
  return code;
}

// ✅ 正确：使用分布式锁
async function generateCaptcha(email) {
  const lockKey = `captcha:lock:${email}`;
  const lockValue = Date.now().toString();
  
  // 尝试获取锁
  const acquired = await redis.set(lockKey, lockValue, 'NX', 'EX', 5);
  if (!acquired) {
    throw new Error('请勿频繁请求验证码');
  }
  
  try {
    const code = Math.floor(100000 + Math.random() * 900000);
    await redis.setex(`captcha:${email}`, 300, code);
    return code;
  } finally {
    // 释放锁
    if (await redis.get(lockKey) === lockValue) {
      await redis.del(lockKey);
    }
  }
}
```

### 检查点5.2: 并发验证冲突

**问题场景**：同一验证码被多个请求同时验证

```javascript
// ❌ 错误：存在竞态条件
async function verifyCaptcha(email, code) {
  const cached = await redis.get(`captcha:${email}`);
  
  // 竞态条件：两个请求同时读到相同值
  const data = JSON.parse(cached);
  if (data.code !== code) return { success: false };
  
  // 竞态条件：两个请求都通过验证
  await redis.set(`captcha:${email}_used`, 'true');
  return { success: true };
}

// ✅ 正确：使用Redis WATCH实现乐观锁
async function verifyCaptcha(email, code) {
  const key = `captcha:${email}`;
  
  while (true) {
    await redis.watch(key);
    
    const cached = await redis.get(key);
    if (!cached) {
      redis.unwatch();
      return { success: false, error: '验证码不存在' };
    }
    
    const data = JSON.parse(cached);
    
    if (data.code !== code) {
      redis.unwatch();
      return { success: false, error: '验证码错误' };
    }
    
    // 检查过期
    if (Date.now() > data.expiresAt) {
      redis.unwatch();
      return { success: false, error: '验证码已过期' };
    }
    
    // 使用事务
    const transaction = redis.multi();
    transaction.del(key);  // 删除验证码
    transaction.set(`${key}_verified_at`, Date.now().toString());
    
    try {
      await transaction.exec();
      return { success: true };
    } catch (e) {
      // 重试
      continue;
    }
  }
}
```

---

## 6. 综合排查步骤

### 步骤1: 查看Redis中验证码的实际TTL

```bash
# 查看所有验证码key及其TTL
redis-cli KEYS 'captcha:*' | while read key; do
    ttl=$(redis-cli TTL $key)
    echo "$key: TTL=${ttl}s"
done
```

### 步骤2: 检查验证码生成和验证日志

```bash
# 查找验证码相关日志
grep -i "captcha\|verify" /var/log/app/access.log | tail -100

# 查找超时日志
grep -i "timeout\|delay" /var/log/app/error.log | tail -50

# 统计验证码成功率
grep -i "verify.*captcha" /var/log/app/access.log | grep -c "success"
grep -i "verify.*captcha" /var/log/app/access.log | grep -c "fail\|expire"
```

### 步骤3: 检查服务器时间与Redis时间差异

```bash
# 获取系统时间（秒）
date +%s

# 获取Redis时间
redis-cli TIME | head -1

# 计算差异
SYS_TIME=$(date +%s)
REDIS_TIME=$(redis-cli TIME | head -1)
DIFF=$((SYS_TIME - REDIS_TIME))
echo "时间差异: ${DIFF}秒"

# 如果差异超过10秒，需要同步时间
if [ $DIFF -gt 10 ]; then
    echo "⚠️  时间差异过大，建议同步NTP"
    sudo ntpdate -s time.nist.gov
fi
```

### 步骤4: 代码层面验证

**添加调试日志**：
```javascript
// 在生成验证码时添加时间戳
async function generateCaptcha(email) {
  const now = Date.now();
  const code = Math.floor(100000 + Math.random() * 900000);
  
  const data = {
    code: code,
    createdAt: now,  // 添加创建时间
    expiresAt: now + 300000  // 5分钟 = 300000毫秒
  };
  
  await redis.setex(`captcha:${email}`, 300, JSON.stringify(data));
  
  console.log(`[CAPTCHA] 生成验证码: email=${email}, createdAt=${now}`);
  return code;
}

// 在验证验证码时添加详细日志
async function verifyCaptcha(email, code) {
  const cached = await redis.get(`captcha:${email}`);
  
  if (!cached) {
    console.log(`[CAPTCHA] 验证失败: email=${email}, reason=not_found`);
    return { success: false, error: '验证码不存在' };
  }
  
  const data = JSON.parse(cached);
  
  const now = Date.now();
  console.log(`[CAPTCHA] 验证开始: email=${email}, now=${now}, expiresAt=${data.expiresAt}`);
  
  // 检查过期
  if (now > data.expiresAt) {
    console.log(`[CAPTCHA] 验证失败: email=${email}, reason=expired, elapsed=${now - data.createdAt}ms`);
    return { success: false, error: '验证码已过期' };
  }
  
  if (data.code !== code) {
    console.log(`[CAPTCHA] 验证失败: email=${email}, reason=code_mismatch`);
    return { success: false, error: '验证码错误' };
  }
  
  console.log(`[CAPTCHA] 验证成功: email=${email}, elapsed=${now - data.createdAt}ms`);
  return { success: true };
}
```

---

## 7. 修复建议

### 建议1: 统一时间单位

确保所有时间配置使用一致的单位（建议使用毫秒）：

```javascript
// config/captcha.js
module.exports = {
  EXPIRES_IN_MS: 5 * 60 * 1000,  // 5分钟 = 300000毫秒
  
  // Redis的expire使用秒
  EXPIRES_IN_SECONDS: 5 * 60,  // 300秒
};
```

### 建议2: 使用分布式锁

防止并发请求导致的问题：

```javascript
const RedisLock = require('redis-lock');

async function generateCaptcha(email) {
  const lock = new RedisLock(redis, `captcha:lock:${email}`, { timeout: 5000 });
  
  await lock.acquire();
  try {
    const code = Math.floor(100000 + Math.random() * 900000);
    await redis.setex(`captcha:${email}`, 300, code);
    return code;
  } finally {
    lock.release();
  }
}
```

### 建议3: 添加监控告警

```javascript
// 在关键代码处添加监控
const prometheus = require('prom-client');

const captchaGauge = new prometheus.Gauge({
  name: 'captcha_total',
  help: 'Total number of captcha operations',
  labelNames: ['type', 'result']
});

async function verifyCaptcha(email, code) {
  const label = { type: 'verify', result: 'success' };
  
  try {
    // 验证逻辑...
    
    captchaGauge.inc({ ...label, result: 'success' });
    return { success: true };
  } catch (e) {
    captchaGauge.inc({ ...label, result: 'fail' });
    throw e;
  }
}
```

### 建议4: 添加重试机制

```javascript
async function generateCaptchaWithRetry(email, maxRetries = 3) {
  for (let i = 0; i < maxRetries; i++) {
    try {
      const code = await generateCaptcha(email);
      return code;
    } catch (e) {
      if (i === maxRetries - 1) throw e;
      await new Promise(r => setTimeout(r, 100 * (i + 1)));
    }
  }
}
```

---

## 8. 典型问题场景

### 场景1: 配置错误导致1分钟过期

**症状**：所有验证码1分钟内就必须重新获取

**排查**：
```bash
grep -r "setex.*captcha" /app --include="*.js" --include="*.py"
```

**修复**：将60改为300

### 场景2: 服务器时间不同步

**症状**：部分用户验证码过期，部分正常

**排查**：
```bash
date +%s && redis-cli TIME | head -1
```

**修复**：配置NTP同步

### 场景3: 并发验证导致验证冲突

**症状**：用户多次点击验证按钮，后几次验证失败

**排查**：查看日志中是否有"验证码已被使用"错误

**修复**：使用Redis事务或分布式锁

---

## 9. 预防措施

1. **配置管理**：
   - 将过期时间配置到统一配置文件
   - 使用环境变量区分不同环境
   - 添加配置校验

2. **监控告警**：
   - 验证码成功率监控
   - 验证码平均响应时间监控
   - Redis TTL异常告警

3. **日志审计**：
   - 记录验证码生成和验证的时间戳
   - 记录用户操作时间线
   - 定期分析验证码失败原因

4. **压测验证**：
   - 定期进行高并发压测
   - 验证码边界条件测试
   - 分布式环境一致性测试

---

## 附录：快速检查清单

- [ ] Redis中验证码TTL是否设置为300秒（5分钟）
- [ ] 服务器时间是否与Redis时间同步（差异<10秒）
- [ ] 验证码生成时是否记录了正确的创建时间戳
- [ ] 验证逻辑是否使用了正确的过期检查
- [ ] 是否存在并发验证导致的冲突
- [ ] 配置文件中是否有硬编码的过期时间
- [ ] 日志中是否有频繁的"已使用"或"已过期"错误
- [ ] Redis中是否存在大量未清理的验证码key
