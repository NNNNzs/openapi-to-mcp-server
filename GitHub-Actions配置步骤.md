# ⚡ GitHub Actions 快速配置步骤

5 分钟完成 CI/CD 配置，实现自动构建和发布！

## 📋 前置准备

- ✅ GitHub 账号
- ✅ Docker Hub 账号（免费即可）
- ✅ 项目已推送到 GitHub

---

## 🔧 配置步骤

### 步骤 1：创建 Docker Hub 访问令牌

1. 访问 [Docker Hub](https://hub.docker.com/)
2. 登录你的账号
3. 点击右上角头像 → **Account Settings**
4. 左侧菜单选择 **Security**
5. 点击 **New Access Token** 按钮
6. 填写信息：
   - **Description**: `github-actions-openapi-mcp`
   - **Access permissions**: 选择 **Read, Write, Delete**
7. 点击 **Generate**
8. **重要**: 复制生成的令牌（只会显示一次！）

---

### 步骤 2：在 GitHub 仓库中添加 Secrets

1. 打开你的 GitHub 仓库页面
2. 点击顶部的 **Settings** 标签
3. 左侧菜单找到 **Secrets and variables** → **Actions**
4. 点击 **New repository secret** 按钮
5. 添加第一个 Secret：
   - **Name**: `DOCKERHUB_USERNAME`
   - **Value**: 你的 Docker Hub 用户名（例如：`zhangsan`）
   - 点击 **Add secret**

6. 再次点击 **New repository secret**
7. 添加第二个 Secret：
   - **Name**: `DOCKERHUB_TOKEN`
   - **Value**: 粘贴步骤 1 中复制的访问令牌
   - 点击 **Add secret**

---

### 步骤 3：更新 package.json 中的仓库地址

编辑 `package.json`，将 `YOUR_USERNAME` 替换为你的 GitHub 用户名：

```json
{
  "repository": {
    "type": "git",
    "url": "https://github.com/YOUR_USERNAME/node-openapi2mcp.git"
  },
  "bugs": {
    "url": "https://github.com/YOUR_USERNAME/node-openapi2mcp/issues"
  },
  "homepage": "https://github.com/YOUR_USERNAME/node-openapi2mcp#readme"
}
```

---

### 步骤 4：推送代码触发工作流

```bash
# 提交更改
git add .
git commit -m "配置 CI/CD 工作流"

# 推送到 GitHub
git push origin main
```

推送后，GitHub Actions 会自动运行测试工作流。

---

### 步骤 5：创建第一个 Release（触发自动发布）

#### 方法 A：使用 GitHub Web 界面

1. 在 GitHub 仓库页面，点击右侧的 **Releases**
2. 点击 **Create a new release**
3. 填写信息：
   - **Choose a tag**: 输入 `v1.0.0` 并选择 **Create new tag**
   - **Release title**: `Release v1.0.0`
   - **Describe this release**: 点击 **Generate release notes**
4. 点击 **Publish release**

#### 方法 B：使用 GitHub CLI（推荐）

```bash
# 安装 GitHub CLI (如果还没有)
# macOS
brew install gh

# 登录
gh auth login

# 创建 Release
gh release create v1.0.0 --title "Release v1.0.0" --generate-notes
```

#### 方法 C：使用脚本（最简单）

```bash
# 自动发布 patch 版本
npm run release:patch

# 或者使用完整脚本
bash scripts/release.sh patch
```

---

## ✅ 验证配置

### 1. 查看 GitHub Actions 运行状态

1. 进入仓库页面
2. 点击顶部的 **Actions** 标签
3. 你应该能看到三个工作流：
   - ✅ **CI Tests** (test.yml)
   - ✅ **Docker Build and Push** (docker-publish.yml)
   - ✅ **Release and Version Update** (release.yml)

### 2. 检查 Docker Hub

1. 访问 `https://hub.docker.com/r/YOUR_USERNAME/openapi-to-mcp-server`
2. 确认镜像已成功推送
3. 应该能看到以下标签：
   - `latest`
   - `1.0.0`
   - `1.0`
   - `1`

### 3. 测试拉取镜像

```bash
# 拉取镜像
docker pull YOUR_USERNAME/openapi-to-mcp-server:latest

# 运行测试
docker run -d -p 3000:3000 YOUR_USERNAME/openapi-to-mcp-server:latest

# 访问测试
curl http://localhost:3000/api/health
```

---

## 🎯 后续使用

配置完成后，每次发布新版本只需要：

### 自动化方式（推荐）

```bash
# Patch 版本（1.0.0 → 1.0.1）
npm run release:patch

# Minor 版本（1.0.0 → 1.1.0）
npm run release:minor

# Major 版本（1.0.0 → 2.0.0）
npm run release:major
```

脚本会自动完成所有操作！

### 手动方式

```bash
# 1. 更新版本号
npm run version:bump patch

# 2. 推送代码和标签
git push origin main
git push origin v1.0.1

# 3. 创建 GitHub Release
gh release create v1.0.1 --generate-notes
```

---

## 🔍 常见问题

### Q1: Actions 失败，显示 "Error: Unable to locate credentials"

**原因**: Docker Hub credentials 未正确配置

**解决**:
1. 检查 Secrets 名称是否完全匹配（大小写敏感）
   - `DOCKERHUB_USERNAME`
   - `DOCKERHUB_TOKEN`
2. 重新生成 Docker Hub Token
3. 确保 Token 权限包含 Write

### Q2: Docker 镜像推送失败

**可能原因**:
- Docker Hub 仓库不存在
- Token 权限不足
- 网络问题

**解决**:
1. 在 Docker Hub 手动创建仓库 `openapi-to-mcp-server`
2. 检查 Token 权限（需要 Read & Write）
3. 查看 Actions 日志获取详细错误

### Q3: 版本号没有自动更新

**原因**: release.yml 工作流未触发或权限不足

**解决**:
1. 确认是通过 GitHub Release 触发的
2. 检查 GITHUB_TOKEN 权限
3. 查看 Actions 日志

### Q4: 工作流中 npm install 失败

**原因**: package.json 或 package-lock.json 有问题

**解决**:
```bash
# 本地重新生成
rm -rf node_modules package-lock.json
npm install
git add package-lock.json
git commit -m "fix: regenerate package-lock.json"
git push
```

---

## 📊 工作流触发条件总结

| 工作流 | 触发条件 | 执行内容 |
|--------|----------|----------|
| **test.yml** | Push/PR 到 main/master | 测试、构建验证 |
| **docker-publish.yml** | Push 到 main，创建 tag，发布 Release | 构建和推送 Docker 镜像 |
| **release.yml** | 发布 Release | 更新版本号和文档 |

---

## 🎉 配置完成

恭喜！你已经成功配置了完整的 CI/CD 流程。

现在你可以：
- ✅ 自动运行测试
- ✅ 自动构建 Docker 镜像
- ✅ 自动推送到 Docker Hub
- ✅ 自动管理版本号
- ✅ 一键发布新版本

---

## 📚 相关文档

- [CI-CD配置指南.md](./CI-CD配置指南.md) - 详细配置说明
- [快速开始指南.md](./快速开始指南.md) - 项目使用指南
- [README.md](./README.md) - 完整项目文档

---

## 🆘 需要帮助？

- 查看 [GitHub Actions 文档](https://docs.github.com/en/actions)
- 查看 [Docker Hub 文档](https://docs.docker.com/docker-hub/)
- 提交 Issue 到项目仓库

**祝你使用愉快！** 🚀

