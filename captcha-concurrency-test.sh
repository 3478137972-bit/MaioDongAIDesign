#!/bin/bash
# 验证码高并发测试脚本
# 执行方式: ./captcha-concurrency-test.sh [user_count] [requests_per_user]

USER_COUNT=${1:-10}
REQUESTS_PER_USER=${2:-5}
OUTPUT_DIR="/tmp/captcha-test-$(date +%Y%m%d-%H%M%S)"

mkdir -p $OUTPUT_DIR

echo "=============================================="
echo " 验证码高并发测试"
echo " 用户数: $USER_COUNT"
echo " 每用户请求数: $REQUESTS_PER_USER"
echo " 输出目录: $OUTPUT_DIR"
echo " 时间: $(date '+%Y-%m-%d %H:%M:%S')"
echo "=============================================="
echo ""

# 1. 准备测试数据
echo "[$(date '+%H:%M:%S')] 准备测试数据..."

for i in $(seq 1 $USER_COUNT); do
    echo "user$i@test.com" >> $OUTPUT_DIR/email_list.txt
done

echo "生成 $USER_COUNT 个测试邮箱地址"
echo ""

# 2. 生成验证码
echo "[$(date '+%H:%M:%S')] 生成验证码..."

start_time=$(date +%s.%N)

parallel -j50 "curl -s -X POST http://api.example.com/captcha/generate -d email={}" :::: $OUTPUT_DIR/email_list.txt > $OUTPUT_DIR/generate_results.txt 2>&1

end_time=$(date +%s.%N)
generate_time=$(echo "$end_time - $start_time" | bc)

echo "验证码生成耗时: ${generate_time}s"
echo ""

# 3. 验证码验证
echo "[$(date '+%H:%M:%S')] 验证验证码..."

# 从生成结果中提取验证码
grep -o '"code":"[^"]*"' $OUTPUT_DIR/generate_results.txt | cut -d'"' -f4 > $OUTPUT_DIR/code_list.txt

start_time=$(date +%s.%N)

parallel -j50 "curl -s -X POST http://api.example.com/captcha/verify -d code={}" :::: $OUTPUT_DIR/code_list.txt > $OUTPUT_DIR/verify_results.txt 2>&1

end_time=$(date +%s.%N)
verify_time=$(echo "$end_time - $start_time" | bc)

echo "验证码验证耗时: ${verify_time}s"
echo ""

# 4. 分析结果
echo "[$(date '+%H:%M:%S')] 分析结果..."

total_generate=$(cat $OUTPUT_DIR/generate_results.txt | wc -l)
success_generate=$(grep -c '"success":true' $OUTPUT_DIR/generate_results.txt 2>/dev/null || echo 0)
fail_generate=$((total_generate - success_generate))

total_verify=$(cat $OUTPUT_DIR/verify_results.txt | wc -l)
success_verify=$(grep -c '"success":true' $OUTPUT_DIR/verify_results.txt 2>/dev/null || echo 0)
fail_verify=$((total_verify - success_verify))

# 统计过期错误
expire_errors=$(grep -c '"error":".*expire' $OUTPUT_DIR/verify_results.txt 2>/dev/null || echo 0)

echo "=============================================="
echo " 测试结果摘要"
echo "=============================================="
echo ""
echo "验证码生成:"
echo "  总请求数: $total_generate"
echo "  成功數: $success_generate"
echo "  失败數: $fail_generate"
echo "  成功率: $(echo "scale=2; $success_generate * 100 / $total_generate" | bc 2>/dev/null || echo 'N/A')%"
echo ""

echo "验证码验证:"
echo "  总请求数: $total_verify"
echo "  成功數: $success_verify"
echo "  失敗數: $fail_verify"
echo "  成功率: $(echo "scale=2; $success_verify * 100 / $total_verify" | bc 2>/dev/null || echo 'N/A')%"
echo ""

echo "过期错误数: $expire_errors"
echo ""

# 5. 性能统计
echo "[$(date '+%H:%M:%S')] 性能统计..."

if command -v jq &> /dev/null; then
    echo "平均响应时间:"
    echo "  生成: $(echo "scale=3; $generate_time / $total_generate" | bc 2>/dev/null || echo 'N/A')s"
    echo "  验证: $(echo "scale=3; $verify_time / $total_verify" | bc 2>/dev/null || echo 'N/A')s"
    
    echo "TPS (每秒事务数):"
    echo "  生成: $(echo "scale=2; $total_generate / $generate_time" | bc 2>/dev/null || echo 'N/A')"
    echo "  验证: $(echo "scale=2; $total_verify / $verify_time" | bc 2>/dev/null || echo 'N/A')"
fi

# 6. 异常样本
echo ""
echo "[$(date '+%H:%M:%S')] 异常样本统计..."

echo "随机抽取失败样本 (最多10个):"
grep -v '"success":true' $OUTPUT_DIR/verify_results.txt 2>/dev/null | head -10

echo ""
echo "随机抽取过期错误样本 (最多10个):"
grep '"error":".*expire' $OUTPUT_DIR/verify_results.txt 2>/dev/null | head -10

# 7. 生成报告
echo ""
echo "[$(date '+%H:%M:%S')] 生成测试报告..."

cat > $OUTPUT_DIR/test_report.md << EOF
# 验证码高并发测试报告

## 测试概况
- 测试时间: $(date '+%Y-%m-%d %H:%M:%S')
- 用户数: $USER_COUNT
- 每用户请求数: $REQUESTS_PER_USER

## 结果摘要

### 验证码生成
- 总请求数: $total_generate
- 成功数: $success_generate
- 失败数: $fail_generate
- 成功率: $(echo "scale=2; $success_generate * 100 / $total_generate" | bc 2>/dev/null || echo 'N/A')%

### 验证码验证
- 总请求数: $total_verify
- 成功数: $success_verify
- 失败数: $fail_verify
- 成功率: $(echo "scale=2; $success_verify * 100 / $total_verify" | bc 2>/dev/null || echo 'N/A')%

### 性能指标
- 验证码生成耗时: ${generate_time}s
- 验证码验证耗时: ${verify_time}s
- 生成TPS: $(echo "scale=2; $total_generate / $generate_time" | bc 2>/dev/null || echo 'N/A')
- 验证TPS: $(echo "scale=2; $total_verify / $verify_time" | bc 2>/dev/null || echo 'N/A')

### 异常统计
- 过期错误数: $expire_errors
- 其他错误数: $fail_verify

## 结论
EOF

echo "测试报告已生成: $OUTPUT_DIR/test_report.md"
echo ""

# 8. 清理
echo "[$(date '+%H:%M:%S')] 清理临时文件..."

rm -f $OUTPUT_DIR/email_list.txt
rm -f $OUTPUT_DIR/code_list.txt

echo ""
echo "=============================================="
echo " 测试完成"
echo "=============================================="