#!/bin/bash
# 环境配置对比脚本
# 用法: ./env-diff.sh [prod_host] [test_host]

PROD_HOST=${1:-prod-server}
TEST_HOST=${2:-test-server}

echo "=============================================="
echo " 环境配置对比"
echo " 生产环境: $PROD_HOST"
echo " 测试环境: $TEST_HOST"
echo " 时间: $(date '+%Y-%m-%d %H:%M:%S')"
echo "=============================================="
echo ""

# 创建临时目录
TEMP_DIR="/tmp/env-diff-$(date +%Y%m%d-%H%M%S)"
mkdir -p $TEMP_DIR

# 1. 时间配置对比
echo "[$(date '+%H:%M:%S')] 1. 时间配置对比..."
echo "----------------------------------------"

# 生产环境时间
ssh $PROD_HOST 'date' 2>/dev/null > $TEMP_DIR/prod_time.txt
ssh $PROD_HOST 'timedatectl status' 2>/dev/null > $TEMP_DIR/prod_timedatectl.txt

# 测试环境时间
ssh $TEST_HOST 'date' 2>/dev/null > $TEMP_DIR/test_time.txt
ssh $TEST_HOST 'timedatectl status' 2>/dev/null > $TEMP_DIR/test_timedatectl.txt

echo "生产环境时间: $(cat $TEMP_DIR/prod_time.txt)"
echo "测试环境时间: $(cat $TEMP_DIR/test_time.txt)"

echo ""
echo "时间同步状态对比:"
diff $TEMP_DIR/prod_timedatectl.txt $TEMP_DIR/test_timedatectl.txt | grep -E "NTP|Time.*zone" || echo "无差异"

echo ""

# 2. Redis配置对比
echo "[$(date '+%H:%M:%S')] 2. Redis配置对比..."
echo "----------------------------------------"

ssh $PROD_HOST 'redis-cli INFO server' 2>/dev/null > $TEMP_DIR/prod_redis_info.txt
ssh $PROD_HOST 'redis-cli CONFIG GET maxmemory' 2>/dev/null > $TEMP_DIR/prod_redis_maxmemory.txt
ssh $PROD_HOST 'redis-cli CONFIG GET timeout' 2>/dev/null > $TEMP_DIR/prod_redis_timeout.txt

ssh $TEST_HOST 'redis-cli INFO server' 2>/dev/null > $TEMP_DIR/test_redis_info.txt
ssh $TEST_HOST 'redis-cli CONFIG GET maxmemory' 2>/dev/null > $TEMP_DIR/test_redis_maxmemory.txt
ssh $TEST_HOST 'redis-cli CONFIG GET timeout' 2>/dev/null > $TEMP_DIR/test_redis_timeout.txt

echo "Redis版本对比:"
echo "  生产环境: $(grep 'redis_version' $TEMP_DIR/prod_redis_info.txt | cut -d: -f2 | tr -d '\r')"
echo "  测试环境: $(grep 'redis_version' $TEMP_DIR/test_redis_info.txt | cut -d: -f2 | tr -d '\r')"

echo ""
echo "Redis配置对比:"
diff $TEMP_DIR/prod_redis_maxmemory.txt $TEMP_DIR/test_redis_maxmemory.txt | grep -E "maxmemory" || echo "延迟: 无差异"

echo ""

# 3. 应用配置文件对比
echo "[$(date '+%H:%M:%S')] 3. 应用配置文件对比..."
echo "----------------------------------------"

APP_CONFIG="/etc/app/config.yaml"

ssh $PROD_HOST "cat $APP_CONFIG" 2>/dev/null > $TEMP_DIR/prod_config.yaml
ssh $TEST_HOST "cat $APP_CONFIG" 2>/dev/null > $TEMP_DIR/test_config.yaml

echo "对比验证码相关配置:"
echo ""
echo "=== 生产环境 ==="
grep -E "captcha|timeout|expire" $TEMP_DIR/prod_config.yaml | head -20

echo ""
echo "=== 测试环境 ==="
grep -E "captcha|timeout|expire" $TEMP_DIR/test_config.yaml | head -20

echo ""
echo "=== 配置差异 ==="
diff -y --suppress-common-lines $TEMP_DIR/prod_config.yaml $TEMP_DIR/test_config.yaml | grep -E "captcha|timeout|expire" | head -20 || echo "无差异"

echo ""

# 4. 环境变量对比
echo "[$(date '+%H:%M:%S')] 4. 环境变量对比..."
echo "----------------------------------------"

ssh $PROD_HOST 'env | grep -iE "captcha|redis|email|timeout"' 2>/dev/null > $TEMP_DIR/prod_env.txt
ssh $TEST_HOST 'env | grep -iE "captcha|redis|email|timeout"' 2>/dev/null > $TEMP_DIR/test_env.txt

echo "环境变量差异:"
diff -y --suppress-common-lines $TEMP_DIR/prod_env.txt $TEMP_DIR/test_env.txt | head -20 || echo "无差异"

echo ""

# 5. 数据库配置对比
echo "[$(date '+%H:%M:%S')] 5. 数据库配置对比..."
echo "----------------------------------------"

ssh $PROD_HOST 'mysql -e "SHOW VARIABLES WHERE Variable_name IN ("max_connections", "wait_timeout", "interactive_timeout");"' 2>/dev/null > $TEMP_DIR/prod_db_config.txt
ssh $TEST_HOST 'mysql -e "SHOW VARIABLES WHERE Variable_name IN ("max_connections", "wait_timeout", "interactive_timeout");"' 2>/dev/null > $TEMP_DIR/test_db_config.txt

echo "数据库配置对比:"
echo ""
echo "=== 生产环境 ==="
cat $TEMP_DIR/prod_db_config.txt

echo ""
echo "=== 测试环境 ==="
cat $TEMP_DIR/test_db_config.txt

echo ""

# 6. 系统资源限制对比
echo "[$(date '+%H:%M:%S')] 6. 系统资源限制对比..."
echo "----------------------------------------"

ssh $PROD_HOST 'ulimit -a' 2>/dev/null > $TEMP_DIR/prod_ulimit.txt
ssh $TEST_HOST 'ulimit -a' 2>/dev/null > $TEMP_DIR/test_ulimit.txt

echo "文件描述符限制:"
echo "  生产环境: $(grep 'open files' $TEMP_DIR/prod_ulimit.txt | awk '{print $4}')"
echo "  测试环境: $(grep 'open files' $TEMP_DIR/test_ulimit.txt | awk '{print $4}')"

echo ""
echo "内存限制:"
echo "  生产环境: $(grep 'max memory size' $TEMP_DIR/prod_ulimit.txt | awk '{print $5}')"
echo "  测试环境: $(grep 'max memory size' $TEMP_DIR/test_ulimit.txt | awk '{print $5}')"

echo ""

# 7. 网络配置对比
echo "[$(date '+%H:%M:%S')] 7. 网络配置对比..."
echo "----------------------------------------"

ssh $PROD_HOST 'cat /etc/hosts' 2>/dev/null > $TEMP_DIR/prod_hosts.txt
ssh $TEST_HOST 'cat /etc/hosts' 2>/dev/null > $TEMP_DIR/test_hosts.txt

echo "主机映射差异:"
diff -y --suppress-common-lines $TEMP_DIR/prod_hosts.txt $TEMP_DIR/test_hosts.txt | head -10 || echo "无差异"

echo ""

# 8. 生成对比报告
echo "[$(date '+%H:%M:%S')] 生成对比报告..."

cat > $TEMP_DIR/env_diff_report.md << EOF
# 环境配置对比报告

## 对比信息
- 对比时间: $(date '+%Y-%m-%d %H:%M:%S')
- 生产环境: $PROD_HOST
- 测试环境: $TEST_HOST

## 时间配置对比
- 生产环境时间: $(cat $TEMP_DIR/prod_time.txt 2>/dev/null || echo 'N/A')
- 测试环境时间: $(cat $TEMP_DIR/test_time.txt 2>/dev/null || echo 'N/A')
- 时间差异: $(( $(date -d "$(cat $TEMP_DIR/test_time.txt 2>/dev/null)" +%s 2>/dev/null) - $(date -d "$(cat $TEMP_DIR/prod_time.txt 2>/dev/null)" +%s 2>/dev/null) ))s

## Redis配置对比
- 生产环境Redis版本: $(grep 'redis_version' $TEMP_DIR/prod_redis_info.txt | cut -d: -f2 | tr -d '\r' 2>/dev/null || echo 'N/A')
- 测试环境Redis版本: $(grep 'redis_version' $TEMP_DIR/test_redis_info.txt | cut -d: -f2 | tr -d '\r' 2>/dev/null || echo 'N/A')
- 生产环境maxmemory: $(cat $TEMP_DIR/prod_redis_maxmemory.txt 2>/dev/null || echo 'N/A')
- 测试环境maxmemory: $(cat $TEMP_DIR/test_redis_maxmemory.txt 2>/dev/null || echo 'N/A')

## 应用配置差异
应用于测试环境的配置存在差异の處:
EOF

# 添加配置差异
diff -y --suppress-common-lines $TEMP_DIR/prod_config.yaml $TEMP_DIR/test_config.yaml 2>/dev/null | grep -E "<|>" | head -20 >> $TEMP_DIR/env_diff_report.md

cat >> $TEMP_DIR/env_diff_report.md << EOF

## 结论
1. 如果存在显著差异，需要同步配置
2. Redis TTL配置不一致可能导致验证码过期问题
3. 时间不同步可能导致验证失败
4. 网络配置差异可能导致API调用异常

## 建议
- 保持生产和测试环境配置一致
- 定期同步配置文件
- 使用配置管理工具(如Ansible, SaltStack)
EOF

echo "报告已生成: $TEMP_DIR/env_diff_report.md"
echo ""

# 9. 清理
echo "[$(date '+%H:%M:%S')] 清理..."
echo ""
echo "=============================================="
echo " 对比完成"
echo "=============================================="
echo ""
echo "临时文件目录: $TEMP_DIR"
echo "使用以下命令查看详细报告:"
echo "  less $TEMP_DIR/env_diff_report.md"