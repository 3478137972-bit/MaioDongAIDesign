# 邮箱验证码问题测试计划与运维检查清单

## 问题描述
用户反馈：邮箱注册验证码输入后显示过期，但实际操作时间在1分钟内。

---

## 第一阶段：测试用例设计

### 1.1 边界测试用例

#### 1.1.1 验证码有效期边界测试
| 用例ID | 测试点 | 预期结果 | 实际结果 | 状态 |
|--------|--------|----------|----------|------|
| EP001 | 验证码刚生成立即验证 | 应验证成功 | 待测试 | TODO |
| EP002 | 验证码在有效期的最后1秒验证 | 应验证成功 | 待测试 | TODO |
| EP003 | 验证码在有效期expired后立即验证 | 应验证失败 | 待测试 | TODO |
| EP004 | 验证码在有效期expired+1秒验证 | 应验证失败 | 待测试 | TODO |
| EP005 | 跨时区场景（如服务器UTC+8，客户端UTC） | 应验证成功 | 待测试 | TODO |

#### 1.1.2 时效边界测试
| 用例ID | 测试点 | 预期结果 | 实际结果 | 状态 |
|--------|--------|----------|----------|------|
| EP101 | 验证码未过期但自动刷新后旧码验证 | 应验证失败 | 待测试 | TODO |
| EP102 | 同一邮箱连续获取多个验证码 | 仅最新码有效，旧码失效 | 待测试 | TODO |
| EP103 | 网络延迟导致验证请求延迟 | 在服务器时间范围内应验证成功 | 待测试 | TODO |

#### 1.1.3 输入边界测试
| 用例ID | 测试点 | 预期结果 | 实际结果 | 状态 |
|--------|--------|----------|----------|------|
| EP201 | 验证码为空 | 应返回参数错误 | 待测试 | TODO |
| EP202 | 验证码为null | 应返回参数错误 | 待测试 | TODO |
| EP203 | 验证码为随机字符串(非数字) | 应验证失败 | 待测试 | TODO |
| EP204 | 验证码位数不足 | 应返回格式错误 | 待测试 | TODO |
| EP205 | 验证码位数超出 | 应返回格式错误 | 待测试 | TODO |
| EP206 | 验证码包含特殊字符 | 应返回格式错误 | 待测试 | TODO |

### 1.2 并发测试用例

#### 1.2.1 单用户并发请求
| 用例ID | 并发数 | 预期行为 | 实际结果 | 状态 |
|--------|--------|----------|----------|------|
| CP001 | 5个并发请求 | 应生成5个不同验证码，最后一次请求生成的码有效 | 待测试 | TODO |
| CP002 | 10个并发请求 | 应确保数据一致性，无并发冲突 | 待测试 | TODO |
| CP003 | 短时间重复提交（100ms内） | 应防重放攻击，仅首次有效 | 待测试 | TODO |

#### 1.2.2 多用户并发测试
| 用例ID | 用户数 | 预期行为 | 实际结果 | 状态 |
|--------|--------|----------|----------|------|
| CP101 | 100用户并发注册 | 各自验证码独立，互不影响 | 待测试 | TODO |
| CP102 | 1000用户并发注册 | 系统响应时间<2s，成功率>99% | 待测试 | TODO |
| CP103 | 5000用户并发注册 | 系统应降级保护，不崩溃 | 待测试 | TODO |

#### 1.2.3 分布式环境并发
| 用例ID | 测试场景 | 预期行为 | 实际结果 | 状态 |
|--------|----------|----------|----------|------|
| CP201 | 多服务实例负载均衡 | Session/Token共享一致 | 待测试 | TODO |
| CP202 | Redis集群环境 |验证码缓存同步，无丢失 | 待测试 | TODO |
| CP203 | 网络分区模拟 | 应 eventual consistency | 待测试 | TODO |

### 1.3 性能与压力测试
| 用例ID | 测试项 | 预期指标 | 实际结果 | 状态 |
|--------|--------|----------|----------|------|
| PP001 | 验证码生成TPS | ≥1000 QPS | 待测试 | TODO |
| PP002 | 验证码验证TPS | ≥800 QPS | 待测试 | TODO |
| PP003 | 平均响应时间 | <200ms (P95 <500ms) | 待测试 | TODO |
| PP004 | CPU使用率 | 并发1000时 <80% | 待测试 | TODO |
| PP005 | 内存使用 | 稳定无泄漏 | 待测试 | TODO |

---

## 第二阶段：服务器日志检查

### 2.1 日志检查命令清单

#### 2.1.1 查找验证码相关错误日志
```bash
# 查找错误级别日志
grep -i "captcha\|verification\|code.*expire\|code.*invalid" /var/log/app/error.log --color=auto

# 查找超时相关日志
grep -i "timeout\|timeouted\|deadline" /var/log/app/error.log --color=auto

# 查找数据库相关错误
grep -i "sql\|mysql\|redis\|connection" /var/log/app/error.log --color=auto

# 查找最近1小时的验证码相关日志
tail -1000 /var/log/app/error.log | grep -i "captcha\|verification"
```

#### 2.1.2 检查验证码生成和验证日志
```bash
# 查找验证码生成日志
grep -i "generate.*captcha\|send.*email\|email.*send" /var/log/app/access.log

# 查找验证码验证日志
grep -i "verify.*captcha\|check.*code\|code.*verify" /var/log/app/access.log

# 查找失败率分析
grep -i "fail\|error\|reject" /var/log/app/error.log | grep -i "captcha" | tail -50
```

#### 2.1.3 检查Redis/Memcached缓存状态
```bash
# Redis状态检查
redis-cli -h redis-host -p 6379 INFO server
redis-cli -h redis-host -p 6379 INFO memory
redis-cli -h redis-host -p 6379 DBSIZE
redis-cli -h redis-host -p 6379 KEYS "captcha:*" | wc -l

# 查看验证码缓存内容
redis-cli -h redis-host -p 6379 SCAN 0 MATCH "captcha:*" COUNT 100
redis-cli -h redis-host -p 6379 TTL captcha:email:user@example.com

# Redis慢查询
redis-cli -h redis-host -p 6379 SLOWLOG GET 10
```

#### 2.1.4 检查邮件服务日志
```bash
# SMTP相关日志
grep -i "smtp\|mail\|email" /var/log/app/error.log | tail -100

# 邮件发送延迟检查
grep -i "delay\|slow\|timeout" /var/log/app/error.log | grep -i "mail\|email" | tail -50

# 检查邮件队列
mailq
```

#### 2.1.5 数据库检查
```bash
# 检查验证码表记录
mysql -u root -p -e "SELECT COUNT(*) FROM captcha_codes WHERE created_at > DATE_SUB(NOW(), INTERVAL 5 MINUTE);"
mysql -u root -p -e "SELECT COUNT(*) FROM captcha_codes WHERE status = 'expired' AND created_at > DATE_SUB(NOW(), INTERVAL 5 MINUTE);"

# 检查会话表
mysql -u root -p -e "SELECT COUNT(*) FROM user_sessions WHERE created_at > DATE_SUB(NOW(), INTERVAL 5 MINUTE);"
```

---

## 第三阶段：监控系统检查

### 3.1 监控项检查清单

#### 3.1.1 核心监控指标
| 监控项 | 预期值 | 实际值 | 状态 |
|--------|--------|----------|------|
| 验证码生成成功率 | ≥99.9% | 待查询 | TODO |
| 验证码验证成功率 | ≥99% | 待查询 | TODO |
| 平均响应时间 (P95) | <500ms | 待查询 | TODO |
| 缓存命中率 | ≥95% | 待查询 | TODO |
| 错误率 | <1% | 待查询 | TODO |

#### 3.1.2 Redis监控
| 监控项 | 预期值 | 实际值 | 状态 |
|--------|--------|----------|------|
| 内存使用率 | <80% | 待查询 | TODO |
| 连接数 | <100 | 待查询 | TODO |
| 瞬间延迟 (p99) | <10ms | 待查询 | TODO |
| key数量 | <1000万 | 待查询 | TODO |

#### 3.1.3 数据库监控
| 监控项 | 预期值 | 实际值 | 状态 |
|--------|--------|----------|------|
| 连接池使用率 | <80% | 待查询 | TODO |
| 慢查询次数 (>${1}s) | 0 | 待查询 | TODO |
| 死锁次数 | 0 | 待查询 | TODO |

#### 3.1.4 服务健康监控
| 监控项 | 预期值 | 实际值 | 状态 |
|--------|--------|----------|------|
| 服务可用性 | 100% | 待查询 | TODO |
| CPU使用率 | <80% | 待查询 | TODO |
| 内存使用率 | <80% | 待查询 | TODO |
| GC暂停时间 | <100ms | 待查询 | TODO |

---

## 第四阶段：环境配置对比

### 4.1 配置文件对比清单

#### 4.1.1 应用配置对比
| 配置项 | 预期值 | 生产环境 | 测试环境 | 差异说明 |
|--------|--------|----------|----------|----------|
| captchaexpiresin | 300 | 待检查 | 待检查 | TODO |
| captchatimeout | 60 | 待检查 | 待检查 | TODO |
| redis.host | redis-prod | 待检查 | 待检查 | TODO |
| mail.server | smtp-prod | 待检查 | 待检查 | TODO |
| mail.timeout | 30 | 待检查 | 待检查 | TODO |

#### 4.1.2 Redis配置对比
| 配置项 | 预期值 | 生产环境 | 测试环境 | 差异说明 |
|--------|--------|----------|----------|----------|
| maxmemory | 4GB | 待检查 | 待检查 | TODO |
| maxmemory-policy | allkeys-lru | 待检查 | 待检查 | TODO |
| timeout | 0 | 待检查 | 待检查 | TODO |

#### 4.1.3 环境变量对比
```bash
# 生产环境
ssh prod-server 'env | grep -i captcha'

# 测试环境
ssh test-server 'env | grep -i captcha'

# 时间配置对比
diff <(ssh prod-server 'date && timedatectl status') <(ssh test-server 'date && timedatectl status')
```

---

## 第五阶段：复现步骤与回归测试

### 5.1 复现步骤

#### 5.1.1 环境准备
```bash
# 1. 准备测试环境
deploy-test-environment.sh

# 2. 清理历史数据
truncate captcha_codes;
truncate user_sessions;

# 3. 启动监控
enable-debug-logging.sh
```

#### 5.1.2 复现步骤
```
步骤1: 打开注册页面
步骤2: 输入邮箱地址 user@example.com
步骤3: 点击"发送验证码"按钮
步骤4: 记录发送时间 T0
步骤5: 等待接收邮件
步骤6: 记录收到邮件时间 T1
步骤7: 计算延迟: T1 - T0
步骤8: 输入验证码
步骤9: 点击"验证"按钮
步骤10: 记录验证时间 T2
步骤11: 计算总时间: T2 - T0
步骤12: 观察返回结果
```

#### 5.1.3 增加干扰因素
```
干扰因素1: 模拟网络延迟 (tc netem)
干扰因素2: 模拟服务器延迟 (stress-ng)
干扰因素3: 模拟Redis延迟 (redis --latency)
干扰因素4: 时区不一致测试
干扰因素5: 多实例负载均衡切换
```

### 5.2 回归测试方案

#### 5.2.1 单元测试回归
```bash
# 运行验证码模块单元测试
./gradlew test --tests "com.app.captcha.*" --info

# 运行相关接口测试
./gradlew test --tests "*CaptchaApiTest" --info

# 运行边界测试
./gradlew test --tests "*CaptchaBoundaryTest" --info
```

#### 5.2.2 集成测试回归
```bash
# 运行端到端测试
./gradlew test --tests "*CaptchaIntegrationTest" --info

# 运行并发测试
./gradlew test --tests "*CaptchaConcurrencyTest" --info

# 运行性能测试
./gradlew test --tests "*CaptchaPerformanceTest" --info
```

#### 5.2.3 QA回归测试清单
| 测试类型 | 测试项 | 预期结果 | 状态 |
|----------|--------|----------|------|
| 功能测试 | 验证码正确输入 | 验证成功 | TODO |
| 功能测试 | 验证码错误输入 | 验证失败 | TODO |
| 功能测试 | 验证码过期输入 | 验证失败 | TODO |
| 功能测试 | 验证码重复使用 | 验证失败 | TODO |
| 功能测试 | 多邮箱验证码隔离 | 各自独立 | TODO |

#### 5.2.4 性能回归测试
| 测试场景 | 期望TPS | 期望延迟 | 实际结果 | 状态 |
|----------|---------|----------|----------|------|
| 单次验证码生成 | ≥1000 | <50ms | 待测试 | TODO |
| 单次验证码验证 | ≥800 | <100ms | 待测试 | TODO |
| 并发100用户 | ≥500 | <500ms | 待测试 | TODO |
| 并发1000用户 | ≥200 | <1000ms | 待测试 | TODO |

---

## 第六阶段：根本原因分析矩阵

### 6.1 可能原因及验证方法

| 序号 | 可能原因 | 影响级别 | 验证方法 | 优先级 |
|------|----------|----------|----------|--------|
| 1 | Redis key过期时间配置错误 | 高 | 检查redis.conf和代码配置 | P0 |
| 2 | 服务器时间不同步 | 高 | ntpdate对比时间 | P0 |
| 3 | 时区配置不一致 | 中 | 检查系统和应用时区设置 | P1 |
| 4 | 网络延迟导致请求堆积 | 中 | 检查网络监控和队列 | P1 |
| 5 | 缓存命中率低导致读取旧数据 | 中 | 检查Redis命中率 | P2 |
| 6 | 数据库事务超时 | 中 | 检查数据库慢查询 | P2 |
| 7 | 验证码逻辑代码bug | 高 | 代码审查和单元测试 | P0 |
| 8 | 负载均衡导致session丢失 | 高 | 检查负载均衡配置 | P0 |
| 9 | 邮件发送延迟 | 中 | 检查邮件队列 | P2 |
| 10 | CDN缓存问题 | 低 | 检查CDN配置 | P3 |

### 6.2 故障排查流程图
```
用户反馈验证码过期
        ↓
检查用户操作时间线（T0-T2）
        ↓
验证服务器时间同步状态
        ↓
检查Redis缓存实际TTL值
        ↓
查看验证码生成和验证日志
        ↓
对比生产/测试环境配置差异
        ↓
执行复现测试
        ↓
确定根本原因
        ↓
修复措施
        ↓
回归测试
        ↓
发布修复
```

---

## 第七阶段：监控告警配置

### 7.1 关键告警指标
| 告警项 | 阈值 | 告警级别 | 通知方式 |
|--------|------|----------|----------|
| 验证码失败率 >5% | 5% | P0 | 飞书+邮件 |
| 验证码平均响应时间 >500ms | 500ms | P1 | 飞书 |
| Redis缓存命中率 <90% | 90% | P1 | 飞书 |
| 验证码生成失败 | 1次 | P0 | 飞书+邮件 |
| 服务器时间偏差 >10s | 10s | P1 | 飞书 |

### 7.2 日志告警规则
```
# 封装日志分析脚本
cat > /usr/local/bin/captcha-analyzer.sh << 'EOF'
#!/bin/bash
# 验证码日志分析脚本

ERROR_LOG="/var/log/app/error.log"
ACCESS_LOG="/var/log/app/access.log"
REPORT_TIME=$(date '+%Y-%m-%d %H:%M:%S')

# 分析最近1小时的日志
echo "=== 验证码问题分析报告 - $REPORT_TIME ===" >> /var/log/captcha-analyzer.log

# 统计验证码相关错误
echo "1. 验证码错误数量:"
grep -i "captcha\|verification" $ERROR_LOG | tail -100 | grep -c "error\|fail"

# 统计验证码相关超时
echo "2. 验证码超时数量:"
grep -i "captcha\|verification" $ERROR_LOG | tail -100 | grep -c "timeout"

# 统计验证码成功率
echo "3. 验证码成功率统计:"
grep -i "verify.*captcha" $ACCESS_LOG | tail -100 | grep -E "(success|fail)" | sort | uniq -c

EOF
chmod +x /usr/local/bin/captcha-analyzer.sh

# 添加定时任务
crontab -e
# 每小时执行一次
0 * * * * /usr/local/bin/captcha-analyzer.sh >> /var/log/captcha-analyzer-hourly.log 2>&1
```

---

## 第八阶段：Checklist清单

### 8.1 日常运维Checklist
- [ ] 每日检查验证码成功率和失败率
- [ ] 每小时检查Redis缓存命中率
- [ ] 每日检查服务器时间同步状态
- [ ] 每周检查验证码相关日志趋势
- [ ] 每月进行验证码性能压测

### 8.2 变更前Checklist
- [ ] 变更前备份现有配置
- [ ] 变更前运行回归测试
- [ ] 变更后验证验证码功能
- [ ] 变更后检查监控告警
- [ ] 变更后通知相关方

### 8.3 故障应急Checklist
- [ ] 立即检查服务器时间同步
- [ ] 立即检查Redis缓存状态
- [ ] 立即将相关服务加入监控告警
- [ ] 启用降级方案（延长验证码有效期）
- [ ] 收集相关日志和监控数据
- [ ] 启动故障复盘流程

---

## 附件：脚本工具集

### A.1 时间同步检查脚本
```bash
#!/bin/bash
# 时间同步检查脚本

echo "=== 服务器时间同步检查 ==="
echo "本地时间: $(date)"

# 检查NTP状态
if command -v ntpstat &> /dev/null; then
    ntpstat
else
    echo "ntpstat command not found"
fi

# 检查系统时间
timedatectl status | grep -E "Time.*zone|NTP.*synchronized"

# 检查Redis时间
redis-cli -h redis-host -p 6379 TIME
```

### A.2 Redis缓存检查脚本
```bash
#!/bin/bash
# Redis验证码缓存检查脚本

REDIS_HOST=${1:-redis-host}
REDIS_PORT=${2:-6379}

echo "=== Redis缓存检查 ==="
echo "连接: $REDIS_HOST:$REDIS_PORT"

# 检查Redis状态
redis-cli -h $REDIS_HOST -p $REDIS_PORT ping

# 检查验证码key数量
redis-cli -h $REDIS_HOST -p $REDIS_PORT KEYS "captcha:*" | wc -l

# 随机抽查验证码key的TTL
redis-cli -h $REDIS_HOST -p $REDIS_PORT KEYS "captcha:*" | head -5 | while read key; do
    ttl=$(redis-cli -h $REDIS_HOST -p $REDIS_PORT TTL $key)
    echo "$key TTL: ${ttl}s"
done
```

### A.3 日志分析脚本
```bash
#!/bin/bash
# 验证码日志分析脚本

ERROR_LOG="${1:-/var/log/app/error.log}"
HOURS="${2:-1}"

echo "=== 验证码日志分析 (最近${HOURS}小时) ==="

# 统计错误日志
echo "错误日志:"
grep -i "captcha\|verification" $ERROR_LOG | tail -100 | grep -i "error\|fail\|exception"

# 统计超时日志
echo "超时日志:"
grep -i "captcha\|verification" $ERROR_LOG | tail -100 | grep -i "timeout\|deadline"

# 统计慢请求
echo "慢请求 (>&500ms):"
grep -i "captcha\|verification" $ERROR_LOG | tail -1000 | grep -E ">&500ms|Slow"
```

---

## 总结

本测试计划涵盖了：
1. ✅ 完整的边界测试用例设计
2. ✅ 并发测试场景覆盖
3. ✅ 服务器日志检查命令
4. ✅ 监控系统检查清单
5. ✅ 环境配置对比方法
6. ✅ 复现步骤和回归测试方案
7. ✅ 故障排查流程和Checklist

建议按照以下顺序执行：
1. 首先检查时间同步和配置差异（快速排除常见原因）
2. 然后查看服务器日志和监控指标（确认问题现象）
3. 接着执行复现测试（定位问题根因）
4. 最后进行完整的回归测试（确保修复有效）