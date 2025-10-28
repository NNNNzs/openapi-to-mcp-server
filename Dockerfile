# OpenAPI to MCP Server - Docker 镜像
# 包含 Go 和 Node.js 环境

# 第一阶段：构建 Go 工具
FROM golang:1.21-alpine AS go-builder

# 设置工作目录
WORKDIR /build

# 安装 Git（Go 模块需要）
RUN apk add --no-cache git

# 安装 openapi-to-mcp 工具
RUN go install github.com/higress-group/openapi-to-mcpserver/cmd/openapi-to-mcp@latest

# 第二阶段：运行时环境
FROM node:20-alpine

# 设置工作目录
WORKDIR /app

# 安装必要的系统依赖
RUN apk add --no-cache \
    ca-certificates \
    tzdata

# 从 Go builder 复制编译好的可执行文件
COPY --from=go-builder /go/bin/openapi-to-mcp /usr/local/bin/openapi-to-mcp

# 复制 package.json 和 package-lock.json
COPY package*.json ./

# 安装 Node.js 依赖
RUN npm install --production

# 复制应用代码
COPY src/ ./src/
COPY public/ ./public/

# 创建必要的目录
RUN mkdir -p uploads outputs

# 设置环境变量
ENV NODE_ENV=production
ENV PORT=3000

# 暴露端口
EXPOSE 3000

# 健康检查
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD node -e "require('http').get('http://localhost:3000/api/health', (r) => {process.exit(r.statusCode === 200 ? 0 : 1)})"

# 启动应用
CMD ["npm", "start"]

