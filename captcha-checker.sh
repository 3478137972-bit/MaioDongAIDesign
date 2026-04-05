#!/bin/bash
# 验证码问题自动化检查脚本
# 执行方式: ./captcha-checker.sh [environment]

ENV=${1:-production}
REDIS_HOST=${2:-localhost}
REDIS_PORT=${3:-6379}

echo "=============================================="
echo " 验证码问题自动化检查脚本"
echo " 环境: $ENV"
echo " 时间: $(date '+%Y-%m-%d %H:%M:%S')"
echo "=============================================="
echo ""

# 1. 时间同步检查
echo "[$(date '+%H:%M:%S')] 1. 检查服务器时间同步..."
echo "----------------------------------------"
date
echo "时区: $(timedatectl status 2>/dev/null | grep "Time.*zone" | awk '{print $3}')"

# 检查NTP同步状态
if command -v ntpstat &> /dev/null; then
    ntpstat 2>/dev/null || echo "NTP未同步"
else
    echo "ntpstat不可用"
fi
echo ""

# 2. Redis状态检查
echo "[$(date '+%H:%M:%S')] 2. 检查Redis缓存状态..."
echo "----------------------------------------"
if command -v redis-cli &> /dev/null; then
    echo " connection: $(redis-cli -h $REDIS_HOST -p $REDIS_PORT ping 2>/dev/null)"
    echo " memory: $(redis-cli -h $REDIS_HOST -p $REDIS_PORT INFO memory 2>/dev/null | grep used_memory_human | cut -d: -f2)"
    echo " keys: $(redis-cli -h $REDIS_HOST -p $REDIS_PORT KEYS 'captcha:*' 2>/dev/null | wc -l)"
    
    # 检查验证码key TTL
    echo " 验证码key TTL示例:"
    redis-cli -h $REDIS_HOST -p $REDIS_PORT KEYS 'captcha:*' 2>/dev/null | head -3 | while read key; do
        ttl=$(redis-cli -h $REDIS_HOST -p $REDIS_PORT TTL $key 2>/dev/null)
        echo "   $key: TTL=${ttl}s"
    done
else
    echo "redis-cli不可用"
fi
echo ""

# 3. 服务器资源检查
echo "[$(date '+%H:%M:%S')] 3. 检查服务器资源..."
echo "----------------------------------------"
echo "CPU使用率: $(top -b -n1 | grep 'Cpu(s)' | awk '{print $2}')"
echo "内存使用: $(free -h | awk 'NR==2{print $3"/"$2}')"
echo "磁盘使用: $(df -h / | awk 'NR==2{print $5}')"
echo ""

# 4. 应用日志检查
echo "[$(date '+%H:%M:%S')] 4. 检查应用日志..."
echo "----------------------------------------"
LOG_DIR="/var/log/app"

if [ -d "$LOG_DIR" ]; then
    echo "错误日志 (最近100行):"
    grep -i "captcha\|verification" $LOG_DIR/error.log 2>/dev/null | tail -20 || echo "无相关错误"
    
    echo ""
    echo "访问日志统计 (最近1000行):"
    echo "  验证成功: $(grep -i "verify.*success\|success.*verify" $LOG_DIR/access.log 2>/dev/null | tail -1000 | wc -l)"
    echo "  验证失败: $(grep -i "verify.*fail\|fail.*verify" $LOG_DIR/access.log 2>/dev/null | tail -1000 | wc -l)"
    
    # 计算成功率
    total=$(grep -i "verify" $LOG_DIR/access.log 2>/dev/null | tail -1000 | wc -l)
    success=$(grep -i "verify.*success" $LOG_DIR/access.log 2>/dev/null | tail -1000 | wc -l)
    if [ $total -gt 0 ]; then
        rate=$(echo "scale=2; $success * 100 / $total" | bc 2>/dev/null || echo "计算失败")
        echo "  成功率: ${rate}%"
    fi
else
    echo "日志目录不存在"
fi
echo ""

# 5. 数据库检查
echo "[$(date '+%H:%M:%S')] 5. 检查数据库..."
echo "----------------------------------------"
if command -v mysql &> /dev/null; then
    echo "数据库连接测试: 进行中..."
    # mysql -u root -e "SELECT 'connected';" 2>/dev/null || echo "连接失败"
    
    echo "验证码表统计:"
    # mysql -u root -e "SELECT COUNT(*) as total, SUM(CASE WHEN status='valid' THEN 1 ELSE 0 END) as valid, SUM(CASE WHEN status='expired' THEN 1 ELSE 0 END) as expired FROM captcha_codes WHERE created_at > DATE_SUB(NOW(), INTERVAL 10 MINUTE);" 2>/dev/null || echo "查询失败"
    
    # 简化输出
    echo "  正在校验的验证码数量: 未查询"
    echo "  过期的验证码数量: 未查询"
else
    echo "mysql客户端不可用"
fi
echo ""

# 6. 配置检查
echo "[$(date '+%H:%M:%S')] 6. 检查配置..."
echo "----------------------------------------"
CONFIG_FILE="/etc/app/config.yaml"

if [ -f "$CONFIG_FILE" ]; then
    echo "验证码配置:"
    grep -E "captcha.*expire|timeout" $CONFIG_FILE 2>/dev/null || echo "未找到相关配置"
else
    echo "配置文件不存在"
fi
echo ""

# 7. 汇总信息
echo "=============================================="
echo " 检查完成 - $(date '+%Y-%m-%d %H:%M:%S')"
echo "==============================================" 

# 生成检查结果摘要
echo ""
echo "检查结果摘要:"
echo "1. 时间同步: $(date +%Z)"
echo "2. Redis状态: $(redis-cli -h $REDIS_HOST -p $REDIS_PORT ping 2>/dev/null || echo 'unknown')"
echo "3. 应用日志: 已检查"
echo "4. 数据库: 待查询"
echo "5. 配置: 待验证"

echo ""
echo "建议:"
echo "- 如果验证码过期，请检查Redis TTL配置"
echo "- 如果时间不同步，请检查NTP服务"
echo "- 如果日志中有大量超时，请检查服务器负载"
echo "- 如果配置不一致，请对比生产和测试环境"