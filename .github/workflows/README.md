# GitHub Actions 工作流说明

本目录包含项目的 CI/CD 自动化工作流配置。

## 📋 工作流列表

### 1. test.yml - CI 测试
**触发条件：**
- Push 到 `main`、`master`、`develop` 分支
- Pull Request 到 `main`、`master` 分支

**执行任务：**
- 代码质量检查
- Docker 镜像构建测试
- 安全漏洞扫描（Trivy）
- 健康检查接口测试

### 2. docker-publish.yml - Docker 构建和推送
**触发条件：**
- Push 到 `main` 或 `master` 分支
- 创建 tag（格式：`v*.*.*`）
- 发布 GitHub Release

**执行任务：**
- 构建多架构 Docker 镜像（amd64, arm64）
- 推送镜像到 Docker Hub
- 自动生成版本标签

**镜像标签：**
- `latest` - 最新版本
- `1.0.0` - 完整版本号
- `1.0` - 主版本.次版本
- `1` - 主版本

### 3. release.yml - 版本发布
**触发条件：**
- 发布 GitHub Release
- 手动触发（workflow_dispatch）

**执行任务：**
- 更新 package.json 版本号
- 更新 CHANGELOG.md
- 创建版本信息文件（public/version.json）
- 自动提交到主分支

## 🔐 所需 Secrets

在 GitHub 仓库的 Settings → Secrets and variables → Actions 中配置：

| Secret 名称 | 说明 | 获取方式 |
|------------|------|---------|
| `DOCKERHUB_USERNAME` | Docker Hub 用户名 | Docker Hub 账号用户名 |
| `DOCKERHUB_TOKEN` | Docker Hub 访问令牌 | Docker Hub → Account Settings → Security → New Access Token |

## 🚀 使用方法

### 自动触发

1. **代码推送** - 自动运行测试
```bash
git push origin main
```

2. **创建 Release** - 自动构建和发布
```bash
gh release create v1.0.0 --generate-notes
```

3. **创建 Tag** - 自动构建 Docker 镜像
```bash
git tag v1.0.0
git push origin v1.0.0
```

### 手动触发

在 GitHub Actions 页面可以手动触发 release.yml 工作流。

## 📊 工作流状态

在项目 README 中添加状态徽章：

```markdown
![CI Tests](https://github.com/YOUR_USERNAME/node-openapi2mcp/workflows/CI%20Tests/badge.svg)
![Docker Build](https://github.com/YOUR_USERNAME/node-openapi2mcp/workflows/Docker%20Build%20and%20Push/badge.svg)
```

## 🔍 调试

查看工作流日志：
1. 进入 GitHub 仓库
2. 点击 **Actions** 标签
3. 选择工作流运行记录
4. 查看详细日志

## 📚 更多信息

详细配置说明请查看：[CI-CD配置指南.md](../../CI-CD配置指南.md)

