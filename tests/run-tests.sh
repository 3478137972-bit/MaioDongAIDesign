#!/bin/bash

# AI 绘图智能体 - 测试执行脚本
# 作者：tester (测试运维工程师)
# 版本：2.0
# 日期：2026-03-29

set -e

echo "========================================"
echo "🧪 AI 绘图智能体自动化测试"
echo "========================================"
echo ""

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 当前目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ==================== 前置检查 ====================

echo -e "${BLUE}🔍 正在检查环境...${NC}"

# 检查 Node.js
if ! command -v node &> /dev/null; then
    echo -e "${RED}❌ Node.js 未安装${NC}"
    exit 1
fi

# 检查 npm
if ! command -v npm &> /dev/null; then
    echo -e "${RED}❌ npm 未安装${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Node.js 版本: $(node -v)${NC}"
echo -e "${GREEN}✅ npm 版本: $(npm -v)${NC}"

# 检查测试依赖
if [ ! -d "$SCRIPT_DIR/node_modules" ]; then
    echo -e "${YELLOW}⚠️  依赖未安装，正在安装...${NC}"
    cd "$SCRIPT_DIR"
    npm install
fi

# ==================== 测试执行 ====================

run_tests() {
    local test_file="$1"
    local test_name="$2"
    
    echo ""
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}🚀 开始执行: $test_name${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo ""
    
    if [ ! -f "$test_file" ]; then
        echo -e "${RED}❌ 测试文件不存在: $test_file${NC}"
        return 1
    fi
    
    # 运行 Jest 测试
    cd "$SCRIPT_DIR"
    npm test -- "$test_file" --colors
    local result=$?
    
    if [ $result -eq 0 ]; then
        echo -e "${GREEN}✅ $test_name 测试通过${NC}"
    else
        echo -e "${RED}❌ $test_name 测试失败${NC}"
    fi
    
    return $result
}

run_e2e_tests() {
    echo ""
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}🚀 开始执行 E2E 测试${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo ""
    
    # 检查 Playwright
    if ! command -v npx &> /dev/null; then
        echo -e "${YELLOW}⚠️  Playwright 未安装${NC}"
        echo -e "${YELLOW} posible 运行: npx playwright install${NC}"
        return 0
    fi
    
    # 运行 E2E 测试
    npx playwright test tests/design-agent.e2e.test.js --headed
}

# ==================== 主流程 ====================

main() {
    echo ""
    echo -e "${BLUE}🎮 测试选项${NC}"
    echo "1. 运行所有单元测试"
    echo "2. 运行 AI 绘图功能测试"
    echo "3. 运行设计智能体测试"
    echo "4. 运行 E2E 测试"
    echo "5. 运行所有测试 + 生成覆盖率报告"
    echo "6. 监视模式（开发）"
    echo ""
    
    local choice="${1:-1}"
    
    case $choice in
        1)
            echo -e "${BLUE}▶️  运行所有单元测试...${NC}"
            run_tests "tests/image-viewer.test.js" "图片查看器 MVP"
            run_tests "tests/design-agent.test.js" "AI 绘图智能体"
            ;;
        2)
            echo -e "${BLUE}▶️  运行 AI 绘图功能测试...${NC}"
            run_tests "tests/design-agent.test.js" "AI 绘图智能体"
            ;;
        3)
            echo -e "${BLUE}▶️  运行设计智能体测试...${NC}"
            run_tests "tests/design-agent.test.js" "AI 绘图智能体"
            ;;
        4)
            echo -e "${BLUE}▶️  运行 E2E 测试...${NC}"
            run_e2e_tests
            ;;
        5)
            echo -e "${BLUE}▶️  运行所有测试 + 生成覆盖率报告...${NC}"
            npm run test:coverage
            ;;
        6)
            echo -e "${BLUE}▶️  启动监视模式...${NC}"
            npm run test:watch
            ;;
        *)
            echo -e "${RED}❌ 无效的选项: $choice${NC}"
            echo "用法: $0 [1-6]"
            exit 1
            ;;
    esac
    
    echo ""
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}📊 测试执行完成${NC}"
    echo -e "${BLUE}========================================${NC}"
    
    # 显示覆盖率报告（如果生成了）
    if [ -d "coverage" ]; then
        echo ""
        echo -e "${GREEN}💡 查看覆盖率报告:${NC}"
        echo "   open coverage/index.html"
    fi
}

# ==================== 命令行参数 ====================

case "${1:-}" in
    --help|-h)
        echo "用法: $0 [选项]"
        echo ""
        echo "选项:"
        echo "  1    运行所有单元测试 (默认)"
        echo "  2    运行 AI 绘图功能测试"
        echo "  3    运行设计智能体测试"
        echo "  4    运行 E2E 测试"
        echo "  5    运行所有测试 + 生成覆盖率报告"
        echo "  6    监视模式（开发）"
        echo "  -h, --help  显示帮助"
        echo ""
        echo "示例:"
        echo "  $0 2          # 运行 AI 绘图测试"
        echo "  $0 5          # 运行所有测试并生成报告"
        echo "  $0 6          # 启动监视模式"
        ;;
    *)
        main "$@"
        ;;
esac
