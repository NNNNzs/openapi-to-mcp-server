#!/bin/bash

# 版本号自动更新脚本
# 用法: ./bump-version.sh [major|minor|patch|版本号]

set -e

VERSION_TYPE="${1:-patch}"

echo "========================================"
echo "版本号更新工具"
echo "========================================"
echo ""

# 检查是否在 Git 仓库中
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "❌ 错误: 当前目录不是 Git 仓库"
    exit 1
fi

# 检查工作区是否干净
if ! git diff-index --quiet HEAD --; then
    echo "⚠️  警告: 工作区有未提交的更改"
    read -p "是否继续? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# 获取当前版本
CURRENT_VERSION=$(node -p "require('./package.json').version")
echo "📦 当前版本: $CURRENT_VERSION"

# 计算新版本
if [[ "$VERSION_TYPE" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    # 如果是完整的版本号
    NEW_VERSION="$VERSION_TYPE"
else
    # 使用 npm version 计算
    NEW_VERSION=$(npm version $VERSION_TYPE --no-git-tag-version | sed 's/v//')
fi

echo "🚀 新版本: $NEW_VERSION"
echo ""

# 更新 CHANGELOG.md
DATE=$(date +%Y-%m-%d)
CHANGELOG_ENTRY="## [$NEW_VERSION] - $DATE

### 更新内容
- 版本更新为 $NEW_VERSION

"

# 在 CHANGELOG.md 的第一个 ## 之前插入新内容
if [ -f CHANGELOG.md ]; then
    # 创建临时文件
    TEMP_FILE=$(mktemp)
    
    # 读取文件，在第一个版本号之前插入新内容
    awk -v entry="$CHANGELOG_ENTRY" '
        !inserted && /^## \[/ {
            print entry
            inserted=1
        }
        {print}
    ' CHANGELOG.md > "$TEMP_FILE"
    
    mv "$TEMP_FILE" CHANGELOG.md
    echo "✅ CHANGELOG.md 已更新"
fi

# 创建版本信息文件
mkdir -p public
cat > public/version.json << EOF
{
  "version": "$NEW_VERSION",
  "buildDate": "$DATE",
  "commitSha": "$(git rev-parse --short HEAD)",
  "gitTag": "v$NEW_VERSION"
}
EOF
echo "✅ 版本信息文件已创建"

# Git 提交
echo ""
echo "📝 准备提交更改..."
git add package.json CHANGELOG.md public/version.json

if git diff --staged --quiet; then
    echo "⚠️  没有需要提交的更改"
else
    git commit -m "chore: bump version to $NEW_VERSION"
    echo "✅ 更改已提交"
    
    # 创建 Git 标签
    git tag -a "v$NEW_VERSION" -m "Release version $NEW_VERSION"
    echo "✅ Git 标签 v$NEW_VERSION 已创建"
fi

echo ""
echo "========================================"
echo "✨ 版本更新完成！"
echo "========================================"
echo ""
echo "📌 下一步操作:"
echo ""
echo "1. 查看更改:"
echo "   git log -1"
echo "   git show v$NEW_VERSION"
echo ""
echo "2. 推送到远程仓库:"
echo "   git push origin main"
echo "   git push origin v$NEW_VERSION"
echo ""
echo "3. 创建 GitHub Release:"
echo "   gh release create v$NEW_VERSION --generate-notes"
echo ""
echo "或者使用以下命令一键推送:"
echo "   git push origin main && git push origin v$NEW_VERSION"
echo ""

