# 🚀 CI/CD 配置指南

本项目已配置完整的 CI/CD 自动化流程，包括自动构建、测试、发布和 Docker 镜像推送。

## 📋 目录

1. [GitHub Secrets 配置](#github-secrets-配置)
2. [自动化工作流说明](#自动化工作流说明)
3. [本地发布流程](#本地发布流程)
4. [版本管理](#版本管理)
5. [Docker Hub 配置](#docker-hub-配置)

---

## 🔐 GitHub Secrets 配置

### 1. 创建 Docker Hub 访问令牌

1. 登录 [Docker Hub](https://hub.docker.com/)
2. 点击右上角头像 → **Account Settings**
3. 选择 **Security** → **New Access Token**
4. 输入描述（如 `github-actions`）
5. 复制生成的访问令牌（只显示一次）

### 2. 在 GitHub 仓库中添加 Secrets

1. 进入你的 GitHub 仓库
2. 点击 **Settings** → **Secrets and variables** → **Actions**
3. 点击 **New repository secret**
4. 添加以下两个 secrets：

| Secret 名称 | 说明 | 示例值 |
|------------|------|--------|
| `DOCKERHUB_USERNAME` | Docker Hub 用户名 | `your-username` |
| `DOCKERHUB_TOKEN` | Docker Hub 访问令牌 | `dckr_pat_xxx...` |

### 3. 验证配置

配置完成后，推送代码或创建 Release 时会自动触发工作流。

---

## 🤖 自动化工作流说明

项目包含三个 GitHub Actions 工作流：

### 1. CI 测试 (test.yml)

**触发条件：**
- Push 到 `main`、`master`、`develop` 分支
- Pull Request 到 `main`、`master` 分支

**执行内容：**
- ✅ 代码质量检查
- ✅ Docker 镜像构建测试
- ✅ 安全漏洞扫描
- ✅ 健康检查接口测试

### 2. Docker 构建和推送 (docker-publish.yml)

**触发条件：**
- Push 到 `main` 或 `master` 分支
- 创建 tag（格式：`v*.*.*`）
- 创建 GitHub Release

**执行内容：**
- 🏗️ 构建多架构 Docker 镜像（amd64, arm64）
- 📤 推送到 Docker Hub
- 🏷️ 自动生成镜像标签

**镜像标签策略：**
```
# 主分支推送
your-username/openapi-to-mcp-server:main
your-username/openapi-to-mcp-server:latest

# 发布版本 v1.2.3
your-username/openapi-to-mcp-server:1.2.3
your-username/openapi-to-mcp-server:1.2
your-username/openapi-to-mcp-server:1
your-username/openapi-to-mcp-server:latest
```

### 3. 版本发布 (release.yml)

**触发条件：**
- 创建 GitHub Release
- 手动触发（workflow_dispatch）

**执行内容：**
- 📦 更新 `package.json` 版本号
- 📝 更新 `CHANGELOG.md`
- 🏷️ 创建版本信息文件
- 📤 自动提交到主分支

---

## 💻 本地发布流程

### 方式一：完整自动化发布（推荐）

```bash
# 发布 patch 版本（1.0.0 → 1.0.1）
bash scripts/release.sh patch

# 发布 minor 版本（1.0.0 → 1.1.0）
bash scripts/release.sh minor

# 发布 major 版本（1.0.0 → 2.0.0）
bash scripts/release.sh major
```

这个脚本会自动执行：
1. ✅ 更新版本号
2. ✅ 更新 CHANGELOG
3. ✅ 创建 Git 标签
4. ✅ 推送到 GitHub
5. ✅ 创建 GitHub Release
6. ✅ 构建并推送 Docker 镜像

### 方式二：分步执行

#### 步骤 1：更新版本号

```bash
# 更新为 patch 版本
bash scripts/bump-version.sh patch

# 更新为 minor 版本
bash scripts/bump-version.sh minor

# 更新为 major 版本
bash scripts/bump-version.sh major

# 或指定版本号
bash scripts/bump-version.sh 2.0.0
```

#### 步骤 2：推送到 GitHub

```bash
# 推送代码和标签
git push origin main
git push origin v1.0.1
```

#### 步骤 3：创建 GitHub Release

使用 GitHub CLI：
```bash
gh release create v1.0.1 --generate-notes
```

或手动在 GitHub 网站创建。

#### 步骤 4：推送 Docker 镜像

```bash
# 设置 Docker Hub 用户名
export DOCKERHUB_USERNAME=your-username

# 推送镜像
bash scripts/docker-push.sh
```

---

## 📦 版本管理

### 版本号规范

遵循 [语义化版本](https://semver.org/lang/zh-CN/) 规范：

```
主版本号.次版本号.修订号 (MAJOR.MINOR.PATCH)
```

- **MAJOR**: 不兼容的 API 修改
- **MINOR**: 向下兼容的功能性新增
- **PATCH**: 向下兼容的问题修正

### 版本更新示例

```bash
# Bug 修复：1.0.0 → 1.0.1
bash scripts/bump-version.sh patch

# 新功能：1.0.1 → 1.1.0
bash scripts/bump-version.sh minor

# 重大更新：1.1.0 → 2.0.0
bash scripts/bump-version.sh major

# 指定版本：2.0.0-beta.1
bash scripts/bump-version.sh 2.0.0-beta.1
```

### 自动生成的文件

版本更新后会自动生成/更新：

1. **package.json** - Node.js 版本配置
2. **CHANGELOG.md** - 版本变更日志
3. **public/version.json** - 版本信息（供前端展示）

**version.json 示例：**
```json
{
  "version": "1.0.1",
  "buildDate": "2025-10-28",
  "commitSha": "a1b2c3d",
  "gitTag": "v1.0.1"
}
```

---

## 🐳 Docker Hub 配置

### 创建仓库

1. 登录 [Docker Hub](https://hub.docker.com/)
2. 点击 **Create Repository**
3. 填写信息：
   - **Name**: `openapi-to-mcp-server`
   - **Visibility**: Public 或 Private
   - **Description**: OpenAPI 转 MCP Server 配置工具

### 查看镜像

推送成功后，可以在以下位置查看：
```
https://hub.docker.com/r/YOUR-USERNAME/openapi-to-mcp-server
```

### 使用 Docker 镜像

```bash
# 拉取最新版本
docker pull your-username/openapi-to-mcp-server:latest

# 拉取指定版本
docker pull your-username/openapi-to-mcp-server:1.0.1

# 运行容器
docker run -d \
  -p 3000:3000 \
  --name openapi-mcp \
  your-username/openapi-to-mcp-server:latest
```

---

## 🔄 工作流程图

### 自动发布流程

```
创建 GitHub Release (v1.0.1)
    ↓
触发 release.yml
    ↓
自动更新版本号和文档
    ↓
提交到主分支 [skip ci]
    ↓
触发 docker-publish.yml
    ↓
构建多架构镜像
    ↓
推送到 Docker Hub
    ↓
完成！✅
```

### 本地手动流程

```
运行 release.sh
    ↓
bump-version.sh (更新版本)
    ↓
推送到 GitHub
    ↓
创建 GitHub Release
    ↓
docker-push.sh (推送镜像)
    ↓
完成！✅
```

---

## 🛠️ 高级配置

### 自定义镜像名称

编辑 `.github/workflows/docker-publish.yml`：

```yaml
env:
  IMAGE_NAME: ${{ secrets.DOCKERHUB_USERNAME }}/your-custom-name
```

### 添加更多架构支持

在 `docker-publish.yml` 中修改：

```yaml
platforms: linux/amd64,linux/arm64,linux/arm/v7
```

### 配置镜像缓存

项目已配置 GitHub Actions 缓存，加速构建：

```yaml
cache-from: type=gha
cache-to: type=gha,mode=max
```

### 跳过 CI

在提交信息中添加 `[skip ci]`：

```bash
git commit -m "docs: update README [skip ci]"
```

---

## 📝 常见问题

### Q1: GitHub Actions 失败，提示 Docker Hub 认证错误

**A:** 检查 Secrets 配置：
1. 确认 `DOCKERHUB_USERNAME` 和 `DOCKERHUB_TOKEN` 已正确设置
2. 确认 Token 没有过期
3. 检查 Token 权限（需要 Read & Write 权限）

### Q2: 版本号没有自动更新

**A:** 检查以下几点：
1. `release.yml` 工作流是否正确触发
2. GitHub Token 是否有 `contents: write` 权限
3. 查看 Actions 日志查找错误

### Q3: 本地脚本执行权限错误

**A:** 添加执行权限：
```bash
chmod +x scripts/*.sh
```

### Q4: Docker 镜像推送超时

**A:** 可能原因：
1. 网络问题，使用 VPN 或代理
2. 镜像过大，优化 Dockerfile
3. Docker Hub 服务问题，稍后重试

### Q5: 如何撤回已发布的版本？

**A:** 
```bash
# 删除 Git 标签
git tag -d v1.0.1
git push origin :refs/tags/v1.0.1

# 删除 GitHub Release
gh release delete v1.0.1

# 删除 Docker 镜像（在 Docker Hub 网站操作）
```

---

## 📚 参考资料

- [GitHub Actions 文档](https://docs.github.com/en/actions)
- [Docker Hub 文档](https://docs.docker.com/docker-hub/)
- [语义化版本规范](https://semver.org/lang/zh-CN/)
- [Docker 多架构构建](https://docs.docker.com/build/building/multi-platform/)

---

## 🆘 获取帮助

如遇到问题：

1. 查看 GitHub Actions 日志
2. 查看本文档的常见问题部分
3. 提交 Issue 到项目仓库

**配置成功后，你只需要创建 GitHub Release，其他一切都会自动完成！** 🎉

