#!/bin/bash

# 安装 openapi-to-mcp Go 工具

echo "========================================"
echo "安装 openapi-to-mcp 工具"
echo "========================================"

# 检查 Go
if ! command -v go &> /dev/null; then
    echo "错误: 未找到 Go，请先安装 Go 1.21 或更高版本"
    echo ""
    echo "安装 Go:"
    echo "  macOS:   brew install go"
    echo "  Linux:   https://golang.org/doc/install"
    echo "  Windows: https://golang.org/doc/install"
    exit 1
fi

echo "Go 版本: $(go version)"
echo ""

# 安装工具
echo "正在安装 openapi-to-mcp..."
go install github.com/higress-group/openapi-to-mcpserver/cmd/openapi-to-mcp@latest

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ 安装成功！"
    echo ""
    echo "验证安装:"
    openapi-to-mcp --help
else
    echo ""
    echo "❌ 安装失败"
    exit 1
fi

