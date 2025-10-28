/**
 * OpenAPI to MCP Server - 前端交互逻辑
 */

// API 基础地址
const API_BASE_URL = '';

// DOM 元素
const uploadArea = document.getElementById('uploadArea');
const fileInput = document.getElementById('fileInput');
const fileInfo = document.getElementById('fileInfo');
const removeFileBtn = document.getElementById('removeFile');
const uploadForm = document.getElementById('uploadForm');
const convertBtn = document.getElementById('convertBtn');
const resultSection = document.getElementById('resultSection');
const resultCode = document.getElementById('resultCode');
const downloadBtn = document.getElementById('downloadBtn');
const copyBtn = document.getElementById('copyBtn');
const errorMessage = document.getElementById('errorMessage');
const successMessage = document.getElementById('successMessage');
const previewTitle = document.getElementById('previewTitle');
const codeLang = document.getElementById('codeLang');

// 当前上传的文件
let currentFile = null;
let currentFilename = null;

/**
 * 初始化事件监听
 */
function initializeEventListeners() {
    // 点击上传区域
    uploadArea.addEventListener('click', () => {
        fileInput.click();
    });

    // 文件选择
    fileInput.addEventListener('change', handleFileSelect);

    // 移除文件
    removeFileBtn.addEventListener('click', removeFile);

    // 拖拽上传
    uploadArea.addEventListener('dragover', handleDragOver);
    uploadArea.addEventListener('dragleave', handleDragLeave);
    uploadArea.addEventListener('drop', handleDrop);

    // 表单提交
    uploadForm.addEventListener('submit', handleFormSubmit);

    // 下载按钮
    downloadBtn.addEventListener('click', handleDownload);

    // 复制按钮
    copyBtn.addEventListener('click', handleCopy);
}

/**
 * 处理文件选择
 */
function handleFileSelect(event) {
    const file = event.target.files[0];
    if (file) {
        setFile(file);
    }
}

/**
 * 处理拖拽悬停
 */
function handleDragOver(event) {
    event.preventDefault();
    uploadArea.classList.add('drag-over');
}

/**
 * 处理拖拽离开
 */
function handleDragLeave(event) {
    event.preventDefault();
    uploadArea.classList.remove('drag-over');
}

/**
 * 处理文件拖放
 */
function handleDrop(event) {
    event.preventDefault();
    uploadArea.classList.remove('drag-over');
    
    const file = event.dataTransfer.files[0];
    if (file) {
        // 验证文件类型
        const validTypes = ['.json', '.yaml', '.yml'];
        const ext = '.' + file.name.split('.').pop().toLowerCase();
        
        if (validTypes.includes(ext)) {
            setFile(file);
        } else {
            showError('请上传 JSON 或 YAML 格式的文件');
        }
    }
}

/**
 * 设置当前文件
 */
function setFile(file) {
    currentFile = file;
    
    // 显示文件信息
    uploadArea.style.display = 'none';
    fileInfo.style.display = 'flex';
    fileInfo.querySelector('.file-name').textContent = file.name;
    
    // 重置结果区域
    resultSection.style.display = 'none';
    hideMessages();
}

/**
 * 移除文件
 */
function removeFile() {
    currentFile = null;
    fileInput.value = '';
    
    uploadArea.style.display = 'flex';
    fileInfo.style.display = 'none';
    
    hideMessages();
}

/**
 * 处理表单提交
 */
async function handleFormSubmit(event) {
    event.preventDefault();
    
    if (!currentFile) {
        showError('请先上传文件');
        return;
    }

    // 显示加载状态
    setLoading(true);
    hideMessages();
    resultSection.style.display = 'none';

    // 构建表单数据
    const formData = new FormData();
    formData.append('file', currentFile);
    formData.append('serverName', document.getElementById('serverName').value);
    formData.append('toolPrefix', document.getElementById('toolPrefix').value);
    formData.append('format', document.getElementById('format').value);
    formData.append('validate', document.getElementById('validate').checked ? 'true' : 'false');

    try {
        const response = await fetch(`${API_BASE_URL}/api/convert`, {
            method: 'POST',
            body: formData
        });

        const result = await response.json();

        if (result.success) {
            // 显示转换结果
            showResult(result.data);
            showSuccess('转换成功！');
        } else {
            showError(result.error || '转换失败，请检查文件格式');
        }
    } catch (error) {
        console.error('转换出错:', error);
        showError('网络错误或服务器异常');
    } finally {
        setLoading(false);
    }
}

/**
 * 显示转换结果
 */
function showResult(data) {
    currentFilename = data.filename;
    
    // 更新代码预览
    resultCode.textContent = data.content;
    
    // 更新文件名和语言标签
    previewTitle.textContent = data.filename;
    codeLang.textContent = data.format.toUpperCase();
    
    // 显示结果区域
    resultSection.style.display = 'block';
    
    // 滚动到结果区域
    resultSection.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
}

/**
 * 处理下载
 */
async function handleDownload() {
    if (!currentFilename) return;
    
    try {
        const response = await fetch(`${API_BASE_URL}/api/download/${currentFilename}`);
        
        if (response.ok) {
            const blob = await response.blob();
            const url = window.URL.createObjectURL(blob);
            const a = document.createElement('a');
            a.href = url;
            a.download = currentFilename;
            document.body.appendChild(a);
            a.click();
            window.URL.revokeObjectURL(url);
            document.body.removeChild(a);
            
            showSuccess('文件下载成功！');
        } else {
            showError('下载失败，请重试');
        }
    } catch (error) {
        console.error('下载出错:', error);
        showError('下载失败，请重试');
    }
}

/**
 * 处理复制到剪贴板
 */
async function handleCopy() {
    const content = resultCode.textContent;
    
    try {
        await navigator.clipboard.writeText(content);
        showSuccess('内容已复制到剪贴板！');
    } catch (error) {
        console.error('复制失败:', error);
        
        // 备用方案：使用 textarea
        const textarea = document.createElement('textarea');
        textarea.value = content;
        textarea.style.position = 'fixed';
        textarea.style.opacity = '0';
        document.body.appendChild(textarea);
        textarea.select();
        
        try {
            document.execCommand('copy');
            showSuccess('内容已复制到剪贴板！');
        } catch (err) {
            showError('复制失败，请手动复制');
        }
        
        document.body.removeChild(textarea);
    }
}

/**
 * 设置加载状态
 */
function setLoading(isLoading) {
    const btnText = convertBtn.querySelector('.btn-text');
    const btnLoading = convertBtn.querySelector('.btn-loading');
    
    if (isLoading) {
        btnText.style.display = 'none';
        btnLoading.style.display = 'flex';
        convertBtn.disabled = true;
    } else {
        btnText.style.display = 'block';
        btnLoading.style.display = 'none';
        convertBtn.disabled = false;
    }
}

/**
 * 显示错误消息
 */
function showError(message) {
    errorMessage.textContent = '❌ ' + message;
    errorMessage.style.display = 'block';
    successMessage.style.display = 'none';
    
    // 3秒后自动隐藏
    setTimeout(() => {
        errorMessage.style.display = 'none';
    }, 5000);
}

/**
 * 显示成功消息
 */
function showSuccess(message) {
    successMessage.textContent = '✅ ' + message;
    successMessage.style.display = 'block';
    errorMessage.style.display = 'none';
    
    // 3秒后自动隐藏
    setTimeout(() => {
        successMessage.style.display = 'none';
    }, 3000);
}

/**
 * 隐藏所有消息
 */
function hideMessages() {
    errorMessage.style.display = 'none';
    successMessage.style.display = 'none';
}

/**
 * 检查服务健康状态
 */
async function checkHealth() {
    try {
        const response = await fetch(`${API_BASE_URL}/api/health`);
        const result = await response.json();
        
        if (!result.success) {
            console.warn('服务健康检查失败:', result.error);
        }
    } catch (error) {
        console.error('无法连接到服务器:', error);
    }
}

// 页面加载完成后初始化
document.addEventListener('DOMContentLoaded', () => {
    initializeEventListeners();
    checkHealth();
});

