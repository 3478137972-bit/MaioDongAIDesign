const Redis = require('ioredis');

async function testCaptchaTTL() {
    const redis = new Redis({
        host: process.env.REDIS_HOST || '127.0.0.1',
        port: process.env.REDIS_PORT || 6379,
        lazyConnect: true
    });

    try {
        await redis.connect();
        console.log('✅ Redis 连接成功');
        
        // 测试 1: 检查当前验证码 key 的 TTL
        console.log('\n--- 测试 1: Redis TTL 验证 ---');
        const keys = await redis.keys('captcha:*');
        console.log(`发现 ${keys.length} 个验证码 keys`);
        
        if (keys.length > 0) {
            for (const key of keys.slice(0, 5)) {
                const ttl = await redis.ttl(key);
                console.log(`${key}: TTL = ${ttl}s (目标: 300s)`);
            }
        } else {
            // 没有现有 keys，创建测试 key
            console.log('没有现有验证码 keys，创建测试 key...');
            const testKey = 'captcha:test:manual@攵入';
            await redis.setex(testKey, 300, '123456');
            const ttl = await redis.ttl(testKey);
            console.log(`${testKey}: TTL = ${ttl}s (目标: 300s)`);
            
            // 清理
            await redis.del(testKey);
        }
        
        // 测试 2: TTL 边界测试
        console.log('\n--- 测试 2: TTL 边界测试 ---');
        const boundaryKey = 'captcha:boundary:test';
        
        // 设置 305 秒 TTL（略高于 300）
        await redis.setex(boundaryKey, 305, '123456');
        let currentTTL = await redis.ttl(boundaryKey);
        console.log(`设置 305s TTL 后实际 TTL: ${currentTTL}s`);
        
        // 等待大约 300 秒，模拟边界情况
        console.log('⏳ 模拟边界测试 (等待 300s)...');
        await new Promise(resolve => setTimeout(resolve, 300000)); // 300秒
        
        currentTTL = await redis.ttl(boundaryKey);
        console.log(`300秒后 TTL: ${currentTTL}s`);
        
        // 验证是否过期
        const value = await redis.get(boundaryKey);
        console.log(`Key 值: ${value || '已过期/不存在'}`);
        
        await redis.del(boundaryKey);
        
        // 测试 3: 并发测试
        console.log('\n--- 测试 3: 并发测试 (同一邮箱多次请求) ---');
        const concurrentKey = 'captcha:concurrent:test@example.com';
        const concurrentRequests = 10;
        const promises = [];
        
        for (let i = 0; i < concurrentRequests; i++) {
            promises.push(
                redis.setex(concurrentKey, 300, Math.floor(Math.random() * 900000 + 100000))
            );
        }
        
        const results = await Promise.all(promises);
        console.log(`并发请求成功数: ${results.length}/${concurrentRequests}`);
        
        // 测试 4: 邮件发送延迟测试
        console.log('\n--- 测试 4: 邮件发送延迟测试 (30秒后输入) ---');
        const delayKey = 'captcha:delay:test@-delay.com';
        const delayPassword = '888888';
        await redis.setex(delayKey, 300, delayPassword);
        console.log(`设置验证码，等待 30 秒模拟延迟...`);
        
        await new Promise(resolve => setTimeout(resolve, 30000)); // 30秒
        
        const delayValue = await redis.get(delayKey);
        console.log(`30秒后验证码: ${delayValue || '已过期'}`);
        console.log(`验证码状态: ${delayValue ? '有效 ✅' : '过期 ❌'}`);
        
        await redis.del(delayKey);
        
        console.log('\n=== 所有测试完成 ===');
        
    } catch (error) {
        console.error('测试失败:', error.message);
    } finally {
        await redis.quit();
    }
}

testCaptchaTTL();
