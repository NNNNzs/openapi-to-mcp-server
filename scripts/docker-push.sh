#!/bin/bash

# Docker 推送到 Docker Hub 脚本

set -e

# 配置
DOCKER_USERNAME="${DOCKERHUB_USERNAME:-your-username}"
IMAGE_NAME="openapi-to-mcp-server"
VERSION=$(node -p "require('./package.json').version")

echo "========================================"
echo "Docker 镜像推送工具"
echo "========================================"
echo ""

# 检查是否设置了 DOCKERHUB_USERNAME
if [ "$DOCKER_USERNAME" = "your-username" ]; then
    echo "请设置 DOCKERHUB_USERNAME 环境变量"
    echo ""
    echo "方式一: 导出环境变量"
    echo "  export DOCKERHUB_USERNAME=your-dockerhub-username"
    echo ""
    echo "方式二: 作为参数传递"
    echo "  DOCKERHUB_USERNAME=your-dockerhub-username ./scripts/docker-push.sh"
    echo ""
    exit 1
fi

FULL_IMAGE_NAME="${DOCKER_USERNAME}/${IMAGE_NAME}"

echo "📦 镜像名称: $FULL_IMAGE_NAME"
echo "🏷️  版本号: $VERSION"
echo ""

# 检查 Docker 是否运行
if ! docker info > /dev/null 2>&1; then
    echo "❌ 错误: Docker 未运行，请先启动 Docker"
    exit 1
fi

# 登录 Docker Hub
echo "🔐 登录 Docker Hub..."
if ! docker login; then
    echo "❌ Docker Hub 登录失败"
    exit 1
fi
echo ""

# 构建镜像
echo "🔨 构建 Docker 镜像..."
docker build -t "${FULL_IMAGE_NAME}:${VERSION}" -t "${FULL_IMAGE_NAME}:latest" .

if [ $? -ne 0 ]; then
    echo "❌ 镜像构建失败"
    exit 1
fi
echo "✅ 镜像构建成功"
echo ""

# 推送镜像
echo "📤 推送镜像到 Docker Hub..."
echo "   推送 ${FULL_IMAGE_NAME}:${VERSION}"
docker push "${FULL_IMAGE_NAME}:${VERSION}"

echo "   推送 ${FULL_IMAGE_NAME}:latest"
docker push "${FULL_IMAGE_NAME}:latest"

if [ $? -eq 0 ]; then
    echo ""
    echo "========================================"
    echo "✅ 镜像推送成功！"
    echo "========================================"
    echo ""
    echo "📋 镜像信息:"
    echo "   版本镜像: ${FULL_IMAGE_NAME}:${VERSION}"
    echo "   最新镜像: ${FULL_IMAGE_NAME}:latest"
    echo ""
    echo "💡 使用方法:"
    echo ""
    echo "   # 拉取指定版本"
    echo "   docker pull ${FULL_IMAGE_NAME}:${VERSION}"
    echo ""
    echo "   # 拉取最新版本"
    echo "   docker pull ${FULL_IMAGE_NAME}:latest"
    echo ""
    echo "   # 运行容器"
    echo "   docker run -d -p 3000:3000 ${FULL_IMAGE_NAME}:latest"
    echo ""
else
    echo "❌ 镜像推送失败"
    exit 1
fi

