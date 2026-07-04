# OpenAPI 转 MCP Server 配置工具

🚀 一个将 OpenAPI 规范快速转换为 MCP Server 配置文件的 Web 应用。

## ✨ 项目特性

- 📤 **简单易用**：拖拽上传或选择 OpenAPI 文件
- 🔄 **快速转换**：自动将 OpenAPI 规范转换为 MCP Server 配置
- 🎨 **现代化界面**：美观的响应式 Web 界面
- 🐳 **Docker 部署**：一键部署，无需安装 Go 环境
- 💻 **跨平台支持**：支持 Windows、macOS、Linux
- 🤖 **CI/CD 自动化**：GitHub Actions 自动构建、测试和发布
- 📦 **多架构支持**：支持 amd64 和 arm64 架构

## 📋 项目架构

```
前端界面 (HTML/CSS/JS)
    ↓
Node.js 后端 (Express)
    ↓
Go 命令执行 (openapi-to-mcp)
    ↓
生成 MCP Server 配置文件
```

## 🛠️ 技术栈

- **前端**：HTML5、CSS3、原生 JavaScript
- **后端**：Node.js、Express
- **Go 工具**：[openapi-to-mcpserver](https://github.com/higress-group/openapi-to-mcpserver)
- **容器化**：Docker、Docker Compose

## 📦 快速开始

### 方式一：使用 Docker（推荐）

#### 1. 构建并运行容器

```bash
# 克隆项目
git clone <your-repo-url>
cd node-openapi2mcp

# 使用 Docker Compose 启动
docker-compose up -d
```

#### 2. 访问应用

打开浏览器访问：http://localhost:3000

#### 3. 停止服务

```bash
docker-compose down
```

### 方式二：本地开发

#### 前置要求

- Node.js 18+ 
- Go 1.23+

#### 1. 安装依赖

```bash
# 安装 Node.js 依赖
npm install

# 安装 Go 工具
go install github.com/higress-group/openapi-to-mcpserver/cmd/openapi-to-mcp@latest
```

#### 2. 启动服务

```bash
# 开发模式（支持热重载）
npm run dev

# 生产模式
npm start
```

#### 3. 访问应用

打开浏览器访问：http://localhost:3000

## 📖 使用说明

### 1. 上传 OpenAPI 文件

- 支持 JSON 和 YAML 格式
- 文件大小限制：10MB
- 拖拽文件或点击上传区域选择文件

可使用 Xquik 的公开 OpenAPI 3.1 JSON 作为远程规范示例：

```bash
curl -fsSL https://xquik.com/openapi.json -o xquik-openapi.json
```

该规范包含 `x-api-key` 头部认证和 OAuth bearer 认证声明，适合验证公开 JSON 规范和认证元数据的转换效果。

### 2. 配置转换参数

- **服务器名称**：MCP 服务器的标识名称（必填）
- **工具前缀**：为所有工具添加统一前缀（可选）
- **输出格式**：选择 YAML 或 JSON 格式
- **验证规范**：是否启用严格的 OpenAPI 规范验证

### 3. 转换并下载

- 点击"开始转换"按钮
- 查看生成的配置文件预览
- 可以选择下载文件或复制到剪贴板

## 🔧 API 接口

### POST /api/convert

转换 OpenAPI 规范到 MCP Server 配置

**请求参数：**
- `file`: OpenAPI 文件（multipart/form-data）
- `serverName`: 服务器名称（string）
- `toolPrefix`: 工具前缀（string，可选）
- `format`: 输出格式（yaml/json）
- `validate`: 是否验证（true/false）

**响应示例：**
```json
{
  "success": true,
  "message": "转换成功",
  "data": {
    "filename": "mcp-config-1234567890.yaml",
    "content": "...",
    "format": "yaml"
  }
}
```

### GET /api/download/:filename

下载生成的配置文件

### GET /api/health

健康检查接口

## 🐳 Docker 镜像说明

### 使用预构建镜像（推荐）

```bash
# 拉取最新镜像
docker pull your-username/openapi-to-mcp-server:latest

# 运行容器
docker run -d -p 3000:3000 --name openapi-mcp your-username/openapi-to-mcp-server:latest
```

### 本地构建镜像

```bash
# 构建镜像
docker build -t openapi-to-mcp-server .

# 运行容器
docker run -d -p 3000:3000 --name openapi-mcp openapi-to-mcp-server
```

### 多阶段构建

Dockerfile 使用多阶段构建：
1. **第一阶段**：使用 `golang:1.23-alpine` 构建 Go 工具
2. **第二阶段**：使用 `node:20-alpine` 作为运行时环境

这样可以：
- ✅ 减小镜像体积
- ✅ 提高安全性
- ✅ 包含所需的 Go 和 Node.js 环境

### 环境变量

- `NODE_ENV`: 运行环境（production/development）
- `PORT`: 服务端口（默认 3000）

## 📂 项目结构

```
node-openapi2mcp/
├── src/
│   └── server.js          # Node.js 后端服务
├── public/
│   ├── index.html         # 前端页面
│   ├── styles.css         # 样式文件
│   └── app.js             # 前端逻辑
├── uploads/               # 临时上传目录
├── outputs/               # 输出文件目录
├── Dockerfile             # Docker 镜像配置
├── docker-compose.yml     # Docker Compose 配置
├── package.json           # Node.js 依赖配置
├── .gitignore            # Git 忽略配置
├── .dockerignore         # Docker 忽略配置
└── README.md             # 项目文档
```

## 🚀 发布和版本管理

### 快速发布（自动化）

```bash
# 发布 patch 版本（1.0.0 → 1.0.1）
npm run release:patch

# 发布 minor 版本（1.0.0 → 1.1.0）
npm run release:minor

# 发布 major 版本（1.0.0 → 2.0.0）
npm run release:major
```

这将自动：
1. ✅ 更新版本号
2. ✅ 更新 CHANGELOG
3. ✅ 创建 Git 标签
4. ✅ 推送到 GitHub
5. ✅ 触发 CI/CD 流程
6. ✅ 构建并推送 Docker 镜像

### CI/CD 工作流

项目配置了完整的 GitHub Actions 工作流：

#### 🧪 自动测试 (test.yml)
- 代码质量检查
- Docker 构建测试
- 安全漏洞扫描
- 健康检查测试

#### 🐳 Docker 发布 (docker-publish.yml)
- 多架构构建（amd64, arm64）
- 自动推送到 Docker Hub
- 版本标签自动生成

#### 📦 版本管理 (release.yml)
- 自动更新版本号
- 生成 CHANGELOG
- 创建版本信息文件

**详细配置说明**：查看 [CI-CD配置指南.md](./CI-CD配置指南.md)

### 手动更新版本

```bash
# 只更新版本号（不发布）
npm run version:bump patch
npm run version:bump minor
npm run version:bump major
```

### Docker 操作

```bash
# 构建镜像
npm run docker:build

# 推送镜像（需要配置 DOCKERHUB_USERNAME）
export DOCKERHUB_USERNAME=your-username
npm run docker:push
```

## 🔍 故障排查

### 问题：转换失败

**可能原因：**
- OpenAPI 文件格式不正确
- Go 工具未正确安装

**解决方案：**
1. 检查上传的文件是否符合 OpenAPI 3.0 规范
2. 访问 `/api/health` 检查服务状态
3. 查看容器日志：`docker-compose logs -f`

### 问题：无法访问服务

**解决方案：**
1. 检查端口是否被占用
2. 确认 Docker 容器正在运行：`docker-compose ps`
3. 检查防火墙设置

### 问题：文件上传失败

**可能原因：**
- 文件大小超过限制（10MB）
- 文件格式不支持

**解决方案：**
1. 确保文件为 JSON 或 YAML 格式
2. 压缩文件内容或分割大文件

## 📚 参考资料

- [OpenAPI 规范](https://swagger.io/specification/)
- [MCP 协议介绍](https://modelcontextprotocol.io/)
- [Higress OpenAPI to MCP 工具](https://github.com/higress-group/openapi-to-mcpserver)
- [批量转换 OpenAPI 到 MCP Server](https://higress.ai/blog/bulk-conversion-of-existing-openapi-to-mcp-server)

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

## 📄 许可证

MIT License

## 🙏 致谢

- [Higress](https://higress.io/) - 提供 OpenAPI 到 MCP 转换工具
- [Express](https://expressjs.com/) - Node.js Web 框架
- [Model Context Protocol](https://modelcontextprotocol.io/) - MCP 协议标准
