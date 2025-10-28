/**
 * OpenAPI 转 MCP Server 的 Node.js 后端服务
 * 封装 Go 命令执行，提供 RESTful API
 */
const express = require('express');
const multer = require('multer');
const cors = require('cors');
const { exec } = require('child_process');
const fs = require('fs').promises;
const path = require('path');
const yaml = require('js-yaml');

const app = express();
const PORT = process.env.PORT || 3000;

// 配置文件上传
const upload = multer({
  dest: 'uploads/',
  limits: {
    fileSize: 10 * 1024 * 1024 // 限制 10MB
  },
  fileFilter: (req, file, cb) => {
    const allowedTypes = ['.json', '.yaml', '.yml'];
    const ext = path.extname(file.originalname).toLowerCase();
    if (allowedTypes.includes(ext)) {
      cb(null, true);
    } else {
      cb(new Error('只支持 JSON 和 YAML 文件格式'));
    }
  }
});

// 中间件
app.use(cors());
app.use(express.json());
app.use(express.static('public'));

// 确保必要的目录存在
async function ensureDirectories() {
  const dirs = ['uploads', 'outputs', 'public'];
  for (const dir of dirs) {
    try {
      await fs.mkdir(dir, { recursive: true });
    } catch (error) {
      console.error(`创建目录 ${dir} 失败:`, error);
    }
  }
}

/**
 * 执行 Go 命令
 * @param {Object} options - 转换选项
 * @returns {Promise<Object>} 执行结果
 */
async function executeGoCommand(options) {
  const {
    inputPath,
    outputPath,
    serverName = 'openapi-server',
    toolPrefix = '',
    format = 'yaml',
    validate = false
  } = options;

  // 构建命令
  let command = `openapi-to-mcp --input "${inputPath}" --output "${outputPath}"`;
  
  if (serverName) {
    command += ` --server-name "${serverName}"`;
  }
  
  if (toolPrefix) {
    command += ` --tool-prefix "${toolPrefix}"`;
  }
  
  if (format) {
    command += ` --format ${format}`;
  }
  
  if (validate) {
    command += ' --validate';
  }

  console.log('执行命令:', command);

  return new Promise((resolve, reject) => {
    exec(command, { maxBuffer: 10 * 1024 * 1024 }, (error, stdout, stderr) => {
      if (error) {
        console.error('命令执行错误:', error);
        console.error('stderr:', stderr);
        reject({
          success: false,
          error: error.message,
          stderr: stderr
        });
        return;
      }

      console.log('命令执行成功');
      if (stdout) console.log('stdout:', stdout);

      resolve({
        success: true,
        stdout: stdout,
        stderr: stderr
      });
    });
  });
}

/**
 * POST /api/convert
 * 转换 OpenAPI 规范到 MCP Server 配置
 */
app.post('/api/convert', upload.single('file'), async (req, res) => {
  let inputPath = null;
  let outputPath = null;

  try {
    if (!req.file) {
      return res.status(400).json({
        success: false,
        error: '请上传 OpenAPI 规范文件'
      });
    }

    inputPath = req.file.path;
    const {
      serverName = 'openapi-server',
      toolPrefix = '',
      format = 'yaml',
      validate = 'false'
    } = req.body;

    // 生成输出文件路径
    const timestamp = Date.now();
    const outputFileName = `mcp-config-${timestamp}.${format}`;
    outputPath = path.join('outputs', outputFileName);

    // 执行转换
    const result = await executeGoCommand({
      inputPath,
      outputPath,
      serverName,
      toolPrefix,
      format,
      validate: validate === 'true'
    });

    if (!result.success) {
      return res.status(500).json(result);
    }

    // 读取生成的文件内容
    const outputContent = await fs.readFile(outputPath, 'utf-8');

    // 返回结果
    res.json({
      success: true,
      message: '转换成功',
      data: {
        filename: outputFileName,
        content: outputContent,
        format: format
      }
    });

  } catch (error) {
    console.error('转换过程出错:', error);
    res.status(500).json({
      success: false,
      error: error.message || '转换失败'
    });
  } finally {
    // 清理临时文件
    if (inputPath) {
      try {
        await fs.unlink(inputPath);
      } catch (error) {
        console.error('删除临时文件失败:', error);
      }
    }
  }
});

/**
 * GET /api/download/:filename
 * 下载生成的配置文件
 */
app.get('/api/download/:filename', async (req, res) => {
  try {
    const filename = req.params.filename;
    const filePath = path.join('outputs', filename);

    // 检查文件是否存在
    await fs.access(filePath);

    res.download(filePath, filename, (error) => {
      if (error) {
        console.error('下载文件失败:', error);
        res.status(500).json({
          success: false,
          error: '下载失败'
        });
      }
    });
  } catch (error) {
    res.status(404).json({
      success: false,
      error: '文件不存在'
    });
  }
});

/**
 * GET /api/health
 * 健康检查接口
 */
app.get('/api/health', async (req, res) => {
  try {
    // 检查 Go 命令是否可用
    await new Promise((resolve, reject) => {
      exec('openapi-to-mcp --help', (error) => {
        if (error) {
          reject(error);
        } else {
          resolve();
        }
      });
    });

    res.json({
      success: true,
      status: 'healthy',
      message: 'OpenAPI to MCP 服务运行正常'
    });
  } catch (error) {
    res.status(503).json({
      success: false,
      status: 'unhealthy',
      error: 'Go 命令不可用，请确保已安装 openapi-to-mcp'
    });
  }
});

/**
 * 启动服务器
 */
async function startServer() {
  await ensureDirectories();
  
  app.listen(PORT, () => {
    console.log(`
========================================
OpenAPI to MCP Server 服务已启动
端口: ${PORT}
访问地址: http://localhost:${PORT}
========================================
    `);
  });
}

// 错误处理中间件
app.use((error, req, res, next) => {
  console.error('服务器错误:', error);
  res.status(500).json({
    success: false,
    error: error.message || '服务器内部错误'
  });
});

startServer();

