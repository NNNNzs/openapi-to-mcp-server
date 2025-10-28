#!/bin/bash

# 完整的发布流程脚本
# 包括: 版本更新 -> Git 推送 -> Docker 构建推送

set -e

VERSION_TYPE="${1:-patch}"

echo "========================================"
echo "🚀 完整发布流程"
echo "========================================"
echo ""

# 1. 更新版本号
echo "📦 步骤 1/4: 更新版本号..."
bash scripts/bump-version.sh "$VERSION_TYPE"
echo ""

# 获取新版本号
NEW_VERSION=$(node -p "require('./package.json').version")

# 2. 推送到 Git
echo "📤 步骤 2/4: 推送到 Git 仓库..."
git push origin main 2>/dev/null || git push origin master 2>/dev/null || echo "推送主分支完成"
git push origin "v$NEW_VERSION"
echo "✅ Git 推送完成"
echo ""

# 3. 创建 GitHub Release（如果安装了 gh cli）
if command -v gh &> /dev/null; then
    echo "📝 步骤 3/4: 创建 GitHub Release..."
    read -p "是否创建 GitHub Release? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        gh release create "v$NEW_VERSION" \
            --title "Release v$NEW_VERSION" \
            --generate-notes
        echo "✅ GitHub Release 已创建"
    else
        echo "⏭️  跳过 GitHub Release"
    fi
else
    echo "⚠️  未安装 GitHub CLI (gh)，跳过 GitHub Release"
    echo "   可以手动创建: https://github.com/YOUR_USERNAME/YOUR_REPO/releases/new"
fi
echo ""

# 4. 构建并推送 Docker 镜像
echo "🐳 步骤 4/4: 构建并推送 Docker 镜像..."
read -p "是否推送 Docker 镜像到 Docker Hub? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    if [ -z "$DOCKERHUB_USERNAME" ]; then
        read -p "请输入 Docker Hub 用户名: " DOCKERHUB_USERNAME
        export DOCKERHUB_USERNAME
    fi
    
    bash scripts/docker-push.sh
else
    echo "⏭️  跳过 Docker 推送"
fi
echo ""

echo "========================================"
echo "🎉 发布完成！"
echo "========================================"
echo ""
echo "📋 发布信息:"
echo "   版本: v$NEW_VERSION"
echo "   Git 标签: v$NEW_VERSION"
if [ ! -z "$DOCKERHUB_USERNAME" ]; then
    echo "   Docker 镜像: ${DOCKERHUB_USERNAME}/openapi-to-mcp-server:$NEW_VERSION"
fi
echo ""
echo "🔗 相关链接:"
echo "   GitHub: https://github.com/YOUR_USERNAME/YOUR_REPO"
echo "   Releases: https://github.com/YOUR_USERNAME/YOUR_REPO/releases"
if [ ! -z "$DOCKERHUB_USERNAME" ]; then
    echo "   Docker Hub: https://hub.docker.com/r/${DOCKERHUB_USERNAME}/openapi-to-mcp-server"
fi
echo ""

