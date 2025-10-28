#!/bin/bash

# Docker 构建脚本

IMAGE_NAME="openapi-to-mcp-server"
IMAGE_TAG="latest"

echo "========================================"
echo "构建 Docker 镜像"
echo "========================================"

# 构建镜像
echo "正在构建镜像: ${IMAGE_NAME}:${IMAGE_TAG}"
docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ 镜像构建成功！"
    echo ""
    echo "运行容器:"
    echo "  docker run -d -p 3000:3000 --name openapi-mcp ${IMAGE_NAME}:${IMAGE_TAG}"
    echo ""
    echo "使用 Docker Compose:"
    echo "  docker-compose up -d"
else
    echo ""
    echo "❌ 镜像构建失败"
    exit 1
fi

