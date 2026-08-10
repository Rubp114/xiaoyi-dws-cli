#!/bin/bash
# dws 二进制构建脚本
#
# 用法:
#   bash scripts/build-dws.sh

set -eu

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
SKILL_DIR="$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)"
SOURCE_DIR="$(CDPATH= cd -- "$SKILL_DIR/.." && pwd)"

echo "=== 源代码: $SOURCE_DIR"
echo "=== 输出:    $SKILL_DIR/dws"

cd "$SOURCE_DIR"
CGO_ENABLED=0 GOOS=linux GOARCH=amd64 \
    go build -ldflags="-s -w" -o "$SKILL_DIR/dws" ./cmd

echo "✅ 编译成功: $SKILL_DIR/dws"
