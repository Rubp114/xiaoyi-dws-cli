#!/bin/bash
# dws 二进制构建脚本
# 在有 Go 1.25+ 的机器上运行，编译纯静态 dws 二进制
#
# 用法:
#   bash scripts/build-dws.sh
#
# 或者手动编译:
#   CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -ldflags="-s -w" -o dws ./cmd
#
# 产物: dws（纯静态 Linux amd64 二进制）

set -eu

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
SKILL_DIR="$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)"
SOURCE_DIR=""

# 1. 查找源代码目录
# 优先使用环境变量 DWS_SOURCE_DIR
if [ -n "${DWS_SOURCE_DIR:-}" ] && [ -f "$DWS_SOURCE_DIR/go.mod" ]; then
    SOURCE_DIR="$DWS_SOURCE_DIR"
elif [ -f "$SKILL_DIR/../go.mod" ]; then
    SOURCE_DIR="$(CDPATH= cd -- "$SKILL_DIR/.." && pwd)"
elif [ -f "$HOME/dingtalk-workspace-cli/go.mod" ]; then
    SOURCE_DIR="$HOME/dingtalk-workspace-cli"
else
    echo "未找到 dws 源代码目录。请设置 DWS_SOURCE_DIR 环境变量指向包含 go.mod 的目录。"
    echo ""
    echo "克隆源代码:"
    echo "  git clone https://github.com/DingTalk-Real-AI/dingtalk-workspace-cli.git"
    echo ""
    echo "然后重新运行:"
    echo "  DWS_SOURCE_DIR=/path/to/dingtalk-workspace-cli bash scripts/build-dws.sh"
    exit 1
fi

echo "=== 源代码: $SOURCE_DIR"
echo "=== 输出:    $SKILL_DIR/dws"

# 2. 检查 Go 版本
if ! command -v go &>/dev/null; then
    echo "❌ 未找到 Go 编译器。请安装 Go 1.25+。"
    echo "   https://go.dev/dl/"
    exit 1
fi

GO_VERSION=$(go version | grep -oP 'go\K[0-9]+\.[0-9]+' | head -1 || echo "0.0")
echo "=== Go 版本: $(go version)"

# 3. 编译
cd "$SOURCE_DIR"
echo "=== 编译中..."

CGO_ENABLED=0 GOOS=linux GOARCH=amd64 \
    go build -ldflags="-s -w" -o "$SKILL_DIR/dws" ./cmd

# 带 fallback 的编译
if [ $? -ne 0 ]; then
    echo "⚠️  ldflags 编译失败，尝试基础编译..."
    CGO_ENABLED=0 GOOS=linux GOARCH=amd64 \
        go build -o "$SKILL_DIR/dws" ./cmd
fi

# 4. 验证
if [ -f "$SKILL_DIR/dws" ]; then
    chmod +x "$SKILL_DIR/dws"
    SIZE=$(du -h "$SKILL_DIR/dws" | cut -f1)
    echo ""
    echo "✅ 编译成功！"
    echo "   文件: $SKILL_DIR/dws"
    echo "   大小: $SIZE"
    echo ""
    echo "验证:"
    file "$SKILL_DIR/dws"
else
    echo "❌ 编译失败：未生成 dws 二进制"
    exit 1
fi
