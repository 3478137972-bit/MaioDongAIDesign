# 验证码问题复现与回归测试方案

## 1. 复现步骤

### 1.1 前置条件
```
1. 准备测试环境 (docker-compose -f docker-compose.test.yml up -d)
2. 清理历史数据 (truncate captcha_codes; truncate user_sessions;)
3. 启动调试日志 (enable-debug-logging.sh)
4. 启动流量监控 (tcpdump -i any -n port 8080 -w /tmp/captcha_traffic.pcap)
```

### 1.2 基础复现流程

```
Step 1: 打开注册页面
        URL: https://example.com/register
        检查页面加载时间 < 2s

Step 2: 输入注册邮箱
        Email: test-user-123@example.com
        验证格式: 用户名-时间戳@example.com

Step 3: 点击"发送验证码"按钮
        记录发送时间戳: T0 = $(date +%s%3N)
        检查返回: {"status": "success", "message": "验证码已发送"}

Step 4: 接收验证码邮件
        检查邮箱: test-user-123@example.com
        记录收到时间: T1 = $(date +%s%3N)
        计算延迟: delay = T1 - T0

Step 5: 输入验证码
        提取邮件中的6位数字验证码
        输入表单字段: captcha_code
        记录输入时间: T2 = $(date +%s%3N)

Step 6: 点击"验证"按钮
        记录验证时间: T3 = $(date +%s%3N)
        计算总耗时: total_time = T3 - T0

Step 7: 观察返回结果
        期望结果: {"success": true, "message": "验证成功"}
        实际结果: 待观察
```

### 1.3 时间线分析

```
时间线示例 (假设验证码有效期5分钟):
T0 = 10:00:00.000 (发送验证码请求)
T1 = 10:00:02.500 (收到邮件，延迟2.5s)
T2 = 10:00:03.000 (输入验证码)
T3 = 10:00:03.200 (提交验证)

总耗时: T3 - T0 = 3.2s
验证码创建时间: 10:00:00.000
验证码过期时间: 10:05:00.000 (假设有效期5分钟)
验证时间: 10:00:03.200 < 10:05:00.000 ✓ 应验证通过
```

### 1.4 增加干扰因素

#### 干扰1: 模拟网络延迟
```bash
# 在客户端模拟网络延迟
tc qdisc add dev eth0 root handle 1: htb default 10
tc class add dev eth0 parent 1: classid 1:1 htb rate 1mbit
tc filter add dev eth0 protocol ip parent 1:0 prio 1 u32 \
  flowid 1:1 action mirred egress redirect dev ifb0
tc qdisc add dev ifb0 root handle 1: htb default 10
tc class add dev ifb0 parent 1: classid 1:1 htb rate 1mbit
tc filter add dev ifb0 protocol ip parent 1:0 prio 1 u32 \
  match ip dst 192.168.1.100 flowid 1:1 action netem delay 500ms
```

#### 干扰2: 模拟服务器负载
```bash
# 在服务器上模拟高负载
stress-ng --cpu 4 --vm 2 --hdd 1 --timeout 60s &
```

#### 干扰3: 模拟Redis延迟
```bash
# 使用Redis延迟模式
redis-cli --latency -h redis-host -p 6379
```

#### 干扰4: 时区不一致测试
```bash
# 修改测试客户端时区
export TZ=America/New_York
# 或
timedatectl set-timezone America/New_York
```

#### 干扰5: 多实例负载均衡
```bash
# 在多个服务实例间切换
for i in {1..10}; do
    curl -s http:// load-balancer.example.com/captcha/generate
done
```

### 1.5 边界条件复现

#### 条件1: 刚好过期边界
```
1. 发送验证码: T0
2. 等待直到 T0 + expiry_time - 100ms
3. 输入验证码并验证
4. 期望: 验证成功
```

#### 条件2: 略微过期
```
1. 发送验证码: T0
2. 等待 T0 + expiry_time + 1s
3. 输入验证码并验证
4. 期望: 验证失败，返回"验证码已过期"
```

#### 条件3: 服务重启
```
1. 发送验证码: T0
2. 在T0+30s时重启服务
3. 在T0+60s时验证验证码
4. 期望: 如果缓存丢失则失败，如果持久化则成功
```

#### 条件4: 分布式场景
```
1. 发送验证码请求到实例A (T0)
2. 在实例B (T1) 上验证验证码
3. 期望: 如果session共享则成功，否则失败
```

## 2. 回归测试方案

### 2.1 单元测试回归

#### 2.1.1 验证码生成测试
```java
@Test
public void testGenerateCaptcha_Success() {
    String email = "test@example.com";
    CaptchaResult result = captchaService.generate(email);
    
    assertNotNull(result.getCode());
    assertEquals(email, result.getEmail());
    assertTrue(result.getExpireAt() > System.currentTimeMillis());
}

@Test
public void testGenerateCaptcha_Refresh() {
    String email = "test@example.com";
    String firstCode = captchaService.generate(email).getCode();
    
    // 5秒后重新生成
    Thread.sleep(5000);
    String secondCode = captchaService.generate(email).getCode();
    
    assertNotEquals(firstCode, secondCode);
}

@Test
public void testGenerateCaptcha_ValidFor() {
    String email = "test@example.com";
    CaptchaResult result = captchaService.generate(email);
    
    long expectedExpire = System.currentTimeMillis() + 5 * 60 * 1000; // 5 minutes
    assertTrue(result.getExpireAt() <= expectedExpire + 1000);
}
```

#### 2.1.2 验证码验证测试
```java
@Test
public void testVerifyCaptcha_Success() {
    String email = "test@example.com";
    String code = captchaService.generate(email).getCode();
    
    boolean result = captchaService.verify(email, code);
    assertTrue(result);
}

@Test
public void testVerifyCaptcha_Expired() {
    // 模拟过期验证码
    String email = "test@example.com";
    String code = "123456";
    
    // 在测试环境中直接设置过期时间
    captchaRepository.save(new CaptchaRecord(email, code, 
        System.currentTimeMillis() - 1000));
    
    boolean result = captchaService.verify(email, code);
    assertFalse(result);
}

@Test
public void testVerifyCaptcha_InvalidCode() {
    String email = "test@example.com";
    String code = "000000"; // 无效验证码
    
    boolean result = captchaService.verify(email, code);
    assertFalse(result);
}

@Test
public void testVerifyCaptcha_Reuse() {
    String email = "test@example.com";
    String code = captchaService.generate(email).getCode();
    
    // 第一次验证
    captchaService.verify(email, code);
    
    // 第二次验证（已使用）
    boolean result = captchaService.verify(email, code);
    assertFalse(result);
}
```

#### 2.1.3 边界条件测试
```java
@Test
public void testVerifyCaptcha_AtBoundary() {
    String email = "test@example.com";
    CaptchaResult result = captchaService.generate(email);
    
    long expireTime = result.getExpireAt();
    long currentTime = System.currentTimeMillis();
    
    // 在过期前最后一刻验证
    if (expireTime - currentTime < 100) {
        Thread.sleep(expireTime - currentTime);
    }
    
    boolean verifyResult = captchaService.verify(email, result.getCode());
    assertTrue(verifyResult);
}

@Test
public void testVerifyCaptcha_OverBoundary() {
    String email = "test@example.com";
    String code = captchaService.generate(email).getCode();
    
    // 强制设置过期时间为过去
    captchaRepository.updateExpireTime(email, System.currentTimeMillis() - 1000);
    
    boolean result = captchaService.verify(email, code);
    assertFalse(result);
}
```

### 2.2 集成测试回归

#### 2.2.1 API集成测试
```java
@Test
public void testCaptchaGenerateAPI() {
    // Simulate HTTP request
    MockHttpServletRequest request = new MockHttpServletRequest();
    request.setParameter("email", "test@example.com");
    
    CaptchaController controller = new CaptchaController();
    ResponseEntity response = controller.generate(request);
    
    assertEquals(HttpStatus.OK, response.getStatusCode());
    CaptchaResult result = (CaptchaResult) response.getBody();
    assertNotNull(result.getCode());
}

@Test
public void testCaptchaVerifyAPI_Success() {
    String email = "test@example.com";
    String code = captchaService.generate(email).getCode();
    
    MockHttpServletRequest request = new MockHttpServletRequest();
    request.setParameter("email", email);
    request.setParameter("code", code);
    
    CaptchaController controller = new CaptchaController();
    ResponseEntity response = controller.verify(request);
    
    assertEquals(HttpStatus.OK, response.getStatusCode());
    VerifyResult result = (VerifyResult) response.getBody();
    assertTrue(result.getSuccess());
}

@Test
public void testCaptchaVerifyAPI_Expired() {
    String email = "test@example.com";
    String code = "123456";
    
    // Manually expired
    captchaRepository.updateExpireTime(email, System.currentTimeMillis() - 1000);
    
    MockHttpServletRequest request = new MockHttpServletRequest();
    request.setParameter("email", email);
    request.setParameter("code", code);
    
    CaptchaController controller = new CaptchaController();
    ResponseEntity response = controller.verify(request);
    
    assertEquals(HttpStatus.OK, response.getStatusCode());
    VerifyResult result = (VerifyResult) response.getBody();
    assertFalse(result.getSuccess());
    assertEquals("expired", result.getMessage());
}
```

#### 2.2.2 Redis集成测试
```java
@Test
public void testCaptchaRedisIntegration() {
    String email = "test@example.com";
    String code = "123456";
    long expireTime = System.currentTimeMillis() + 5 * 60 * 1000;
    
    // Save to Redis
    redisTemplate.opsForValue().set(
        "captcha:" + email,
        code,
        5, TimeUnit.MINUTES
    );
    
    // Retrieve from Redis
    String storedCode = redisTemplate.opsForValue().get("captcha:" + email);
    Long ttl = redisTemplate.getExpire("captcha:" + email);
    
    assertEquals(code, storedCode);
    assertTrue(ttl > 0 && ttl <= 300);
}

@Test
public void testCaptchaRedisExpiry() {
    String email = "test@example.com";
    
    // Set with short TTL
    redisTemplate.opsForValue().set(
        "captcha:" + email,
        "123456",
        1, TimeUnit.SECONDS
    );
    
    // Wait for expiry
    Thread.sleep(1500);
    
    // Check if expired
    String code = redisTemplate.opsForValue().get("captcha:" + email);
    assertNull(code);
}
```

### 2.3 端到端测试回归

#### 2.3.1 完整注册流程
```javascript
// Puppeteer E2E Test
const puppeteer = require('puppeteer');

test('完整注册流程', async () => {
    const browser = await puppeteer.launch();
    const page = await browser.newPage();
    
    // Step 1: Navigate to register page
    await page.goto('https://example.com/register');
    await page.waitForSelector('#email');
    
    // Step 2: Enter email
    const email = `test-${Date.now()}@example.com`;
    await page.type('#email', email);
    
    // Step 3: Click send captcha
    await page.click('#send-captcha');
    await page.waitForSelector('#captcha-input');
    
    // Step 4: Get captcha from email
    const captcha = await getEmailCaptcha(email);
    
    // Step 5: Enter captcha
    await page.type('#captcha-input', captcha);
    
    // Step 6: Submit
    await page.click('#submit');
    await page.waitForSelector('.success-message');
    
    // Verify success
    const successText = await page.$eval('.success-message', el => el.textContent);
    expect(successText).toContain('注册成功');
    
    await browser.close();
}, 30000);
```

#### 2.3.2 高并发注册测试
```javascript
// concurrent-registration-test.js
const puppeteer = require('puppeteer');
const pLimit = require('p-limit');

async function concurrentRegister(userId) {
    const browser = await puppeteer.launch();
    const page = await browser.newPage();
    
    const email = `user${userId}@example.com`;
    
    try {
        await page.goto('https://example.com/register');
        await page.type('#email', email);
        await page.click('#send-captcha');
        
        const captcha = await getEmailCaptcha(email);
        await page.type('#captcha-input', captcha);
        await page.click('#submit');
        
        await page.waitForSelector('.success-message', {timeout: 10000});
        
        await browser.close();
        return {userId, success: true};
    } catch (error) {
        await browser.close();
        return {userId, success: false, error: error.message};
    }
}

async function testConcurrentRegistration() {
    const limit = pLimit(10); // 10 concurrent users
    const tasks = Array.from({length: 100}, (_, i) => 
        limit(() => concurrentRegister(i))
    );
    
    const results = await Promise.all(tasks);
    
    const successCount = results.filter(r => r.success).length;
    const failCount = results.filter(r => !r.success).length;
    
    console.log(`Total: 100`);
    console.log(`Success: ${successCount}`);
    console.log(`Failed: ${failCount}`);
    console.log(`Success Rate: ${(successCount/100*100).toFixed(2)}%`);
}

testConcurrentRegistration();
```

### 2.4 性能回归测试

#### 2.4.1 JMeter测试脚本
```xml
<?xml version="1.0" encoding="UTF-8"?>
<jmeterTestPlan version="1.2">
    <hashTree>
        <TestPlan guiclass="TestPlanGui" testclass="TestPlan" testname="验证码性能测试">
            <stringProp name="TestPlan.arguments"></stringProp>
            <stringProp name="TestPlan.user_defined_variables"></stringProp>
            <boolProp name="TestPlan.serialize_threadgroups">false</boolProp>
            <elementProp name="TestPlan.user_defined_variables" elementType="Arguments"/>
        </TestPlan>
        
        <hashTree>
            <ThreadGroup guiclass="ThreadGroupGui" testclass="ThreadGroup" testname="并发用户组">
                <stringProp name="ThreadGroup.num_threads">100</stringProp>
                <stringProp name="ThreadGroup.ramp_time">10</stringProp>
                <longProp name="ThreadGroup.duration">60</longProp>
            </ThreadGroup>
            
            <hashTree>
                <HTTPSamplerProxy guiclass="HttpTestSampleGui" testclass="HTTPSamplerProxy" testname="生成验证码">
                    <stringProp name="HTTPSampler.domain">api.example.com</stringProp>
                    <stringProp name="HTTPSampler.port">80</stringProp>
                    <stringProp name="HTTPSampler.method">POST</stringProp>
                    <stringProp name="HTTPSampler.path">/captcha/generate</stringProp>
                    <stringProp name="HTTPSampler.content_encoding">UTF-8</stringProp>
                    <elementProp name="HTTPsampler.Arguments" elementType="Arguments">
                        <elementProp name="email" elementType="HTTPArgument">
                            <stringProp name="Argument.name">email</stringProp>
                            <stringProp name="Argument.value">${__RandomString(10,abcdefghijklmnopqrstuvwxyz)}</stringProp>
                            <boolProp name="HTTPArgument.always_encode">false</boolProp>
                        </elementProp>
                    </elementProp>
                </HTTPSamplerProxy>
                
                <HTTPSamplerProxy guiclass="HttpTestSampleGui" testclass="HTTPSamplerProxy" testname="验证验证码">
                    <stringProp name="HTTPSampler.domain">api.example.com</stringProp>
                    <stringProp name="HTTPSampler.port">80</stringProp>
                    <stringProp name="HTTPSampler.method">POST</stringProp>
                    <stringProp name="HTTPSampler.path">/captcha/verify</stringProp>
                    <elementProp name="HTTPsampler.Arguments" elementType="Arguments">
                        <elementProp name="email" elementType="HTTPArgument">
                            <stringProp name="Argument.name">email</stringProp>
                            <stringProp name="Argument.value">${email}</stringProp>
                        </elementProp>
                        <elementProp name="code" elementType="HTTPArgument">
                            <stringProp name="Argument.name">code</stringProp>
                            <stringProp name="Argument.value">${code}</stringProp>
                        </elementProp>
                    </elementProp>
                </HTTPSamplerProxy>
            </hashTree>
        </hashTree>
    </hashTree>
</jmeterTestPlan>
```

#### 2.4.2 性能测试指标
```
Test: 验证码API性能测试
Duration: 5分钟
Users: 100并发

Expected Metrics:
- Requests per second: >= 1000
- Average response time: < 200ms
- P95 response time: < 500ms
- P99 response time: < 1000ms
- Error rate: < 1%
- Success rate: >= 99%
```

### 2.5 回归测试执行清单

#### 2.5.1 预回归检查
- [ ] 代码已提交到feature分支
- [ ] 单元测试全部通过
- [ ] 集成测试全部通过
- [ ] 性能测试无明显回归
- [ ] 代码审查通过
- [ ] 测试环境部署成功

#### 2.5.2 回归测试执行
- [ ] 运行所有单元测试 (`./gradlew test`)
- [ ] 运行所有集成测试 (`./gradlew integrationTest`)
- [ ] 运行端到端测试 (`npm run test:e2e`)
- [ ] 运行性能测试 (`jmeter -n -t captcha.jmx -l result.jtl`)
- [ ] 运行安全测试 (`npm run test:security`)

#### 2.5.3 回归测试报告
```markdown
# 回归测试报告

## 测试信息
- 测试时间: 2026-04-05 10:00:00
- 测试分支: feature/captcha-fix
- 测试环境: test-01.example.com
- 测试版本: v2.3.1

## 测试结果

### 单元测试
- 通过: 45/45 ✓
- 失败: 0
- 跳过: 0

### 集成测试
- 通过: 12/12 ✓
- 失败: 0
- 跳过: 0

### 端到端测试
- 通过: 5/5 ✓
- 失败: 0
- 跳过: 0

### 性能测试
- TPS: 1250 (期望: >= 1000) ✓
- P95: 180ms (期望: < 500ms) ✓
- P99: 450ms (期望: < 1000ms) ✓
- 错误率: 0.1% (期望: < 1%) ✓

## 结论
所有回归测试通过，可以发布到生产环境。

## 风险评估
- 无严重风险
- 无性能回归
- 无功能回归
```

## 3. 故障恢复方案

### 3.1 临时降级方案
```java
// 如果验证码验证失败，临时延长有效期
public boolean verify(String email, String code) {
    CaptchaRecord record = captchaRepository.findByEmail(email);
    
    if (record == null) {
        return false;
    }
    
    // 临时方案：延长有效期1分钟
    long adjustedExpire = record.getExpireAt() + 60 * 1000;
    
    if (System.currentTimeMillis() > adjustedExpire) {
        return false;
    }
    
    if (!record.getCode().equals(code)) {
        return false;
    }
    
    // 标记为已使用
    record.setUsed(true);
    captchaRepository.save(record);
    
    return true;
}
```

### 3.2 缓存预热
```bash
# 验证码服务启动后预热Redis
curl -s http://api.example.com/captcha/init | parallel -j10
```

### 3.3 数据库主从切换
```bash
# 如果Redis故障，降级到数据库
sed -i 's/cache.type=redis/cache.type=database/' /etc/app/config.yaml
systemctl restart app-service
```

### 3.4 通知用户
```java
// 如果验证码有问题，通知用户重试
public ResponseEntity<VerifyResult> verify(String email, String code) {
    VerifyResult result = captchaService.verify(email, code);
    
    if (!result.getSuccess() && "expired".equals(result.getMessage())) {
        // 重新发送验证码
        captchaService.generate(email);
        result.setMessage("验证码已过期，新验证码已发送，请检查邮箱");
    }
    
    return ResponseEntity.ok(result);
}
```

## 4. 监控告警

### 4.1 关键指标监控
```
# 验证码相关指标
|\ms{captcha Generate| success_rate| failure_rate| avg_latency | p95_latency | 
| p99_latency| 
|2026-04-05 10:00|99.5%| 0.5%| 150ms| 300ms| 500ms
|2026-04-05 11:00|99.2%| 0.8%| 180ms| 350ms| 600ms
|2026-04-05 12:00|98.5%| 1.5%| 220ms| 400ms| 700ms
```

### 4.2 告警规则
```
rule: 验证码失败率 > 5%
condition: success_rate < 95%
duration: 5分钟
severity: P0
notification: 飞书+邮件+电话

rule: 验证码平均响应时间 > 500ms
condition: avg_latency > 500
duration: 10分钟
severity: P1
notification: 飞书+邮件

rule: Redis连接失败
condition: redis_connected = 0
duration: 1分钟
severity: P0
notification: 飞书+邮件+电话
```

### 4.3 告警响应流程
```
告警触发 → 通知运维工程师 → 登录服务器检查 → 确定原因 → 执行恢复 → 验证成功 → 关闭告警
    ↓
如果是配置问题 → 修正配置 → 重启服务 → 验证
    ↓
如果是代码问题 → 回滚版本 → 验证
    ↓
如果是服务器问题 → 重启服务器 → 验证
```