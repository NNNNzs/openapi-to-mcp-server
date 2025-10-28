#!/bin/bash

# OpenAPI to MCP Server 启动脚本

echo "========================================"
echo "OpenAPI to MCP Server"
echo "========================================"

# 检查 Node.js
if ! command -v node &> /dev/null; then
    echo "错误: 未找到 Node.js，请先安装 Node.js"
    exit 1
fi

# 检查 npm
if ! command -v npm &> /dev/null; then
    echo "错误: 未找到 npm，请先安装 npm"
    exit 1
fi

# 检查 Go
if ! command -v go &> /dev/null; then
    echo "警告: 未找到 Go，将尝试使用已安装的 openapi-to-mcp 工具"
fi

# 检查 openapi-to-mcp
if ! command -v openapi-to-mcp &> /dev/null; then
    echo "错误: 未找到 openapi-to-mcp 工具"
    echo "请运行: go install github.com/higress-group/openapi-to-mcpserver/cmd/openapi-to-mcp@latest"
    exit 1
fi

# 检查依赖
if [ ! -d "node_modules" ]; then
    echo "安装依赖..."
    npm install
fi

# 创建必要的目录
mkdir -p uploads outputs

# 启动服务
echo "启动服务..."
npm start

