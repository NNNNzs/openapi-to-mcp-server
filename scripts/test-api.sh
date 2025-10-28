#!/bin/bash

# API 测试脚本

BASE_URL="http://localhost:3000"
EXAMPLE_FILE="../examples/petstore.json"

echo "========================================"
echo "OpenAPI to MCP Server - API 测试"
echo "========================================"
echo ""

# 1. 健康检查
echo "1️⃣ 测试健康检查接口..."
curl -s "${BASE_URL}/api/health" | python3 -m json.tool
echo ""
echo ""

# 2. 测试转换接口
if [ -f "$EXAMPLE_FILE" ]; then
    echo "2️⃣ 测试转换接口（使用示例文件）..."
    echo "上传文件: $EXAMPLE_FILE"
    
    curl -s -X POST "${BASE_URL}/api/convert" \
        -F "file=@${EXAMPLE_FILE}" \
        -F "serverName=petstore" \
        -F "toolPrefix=api_" \
        -F "format=yaml" \
        -F "validate=false" | python3 -m json.tool
    
    echo ""
    echo "✅ 测试完成！"
else
    echo "❌ 示例文件不存在: $EXAMPLE_FILE"
    echo "请确保在项目根目录运行此脚本"
fi

echo ""
echo "========================================"
echo "如果看到成功响应，说明服务运行正常！"
echo "========================================"

