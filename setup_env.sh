#!/bin/bash

# 自动化配置脚本：从 API 配置到 conda 环境激活
# 使用方法: bash setup_env.sh

set -e  # 遇到错误立即退出

echo "=========================================="
echo "  Hello Agents 环境配置脚本"
echo "=========================================="
echo ""

# 1. 检查 conda 是否安装
if ! command -v conda &> /dev/null; then
    echo "❌ 错误: 未找到 conda，请先安装 Anaconda 或 Miniconda"
    exit 1
fi

# 2. 设置环境名称（可以根据需要修改）
ENV_NAME="hello-agents"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="$SCRIPT_DIR/.env"

echo "📍 工作目录: $SCRIPT_DIR"
echo "📍 环境名称: $ENV_NAME"
echo ""

# 3. 检查 conda 环境是否存在，不存在则创建
if conda env list | grep -q "^${ENV_NAME} "; then
    echo "✅ Conda 环境 '$ENV_NAME' 已存在"
else
    echo "📦 创建新的 conda 环境: $ENV_NAME"
    conda create -n $ENV_NAME python=3.10 -y
    echo "✅ 环境创建完成"
fi

# 4. 激活 conda 环境
echo ""
echo "🔄 激活 conda 环境..."
# 注意：在脚本中激活 conda 环境需要使用 conda activate
eval "$(conda shell.bash hook)"
conda activate $ENV_NAME

# 5. 安装依赖
echo ""
echo "📦 检查并安装依赖..."
if [ -f "$SCRIPT_DIR/requirements.txt" ]; then
    pip install -r "$SCRIPT_DIR/requirements.txt"
    echo "✅ 依赖安装完成"
else
    echo "⚠️  未找到 requirements.txt，跳过依赖安装"
    echo "   安装常用依赖..."
    pip install openai python-dotenv serpapi -q
    echo "✅ 基础依赖安装完成"
fi

# 6. 配置 .env 文件
echo ""
echo "🔧 配置 .env 文件..."

if [ -f "$ENV_FILE" ]; then
    echo "📄 .env 文件已存在"
    read -p "是否要重新配置？(y/n): " reconfigure
    if [ "$reconfigure" != "y" ] && [ "$reconfigure" != "Y" ]; then
        echo "✅ 使用现有配置"
        echo ""
        echo "=========================================="
        echo "  配置完成！"
        echo "=========================================="
        echo ""
        echo "当前环境: $ENV_NAME"
        echo ".env 文件位置: $ENV_FILE"
        echo ""
        echo "要激活环境，请运行:"
        echo "  conda activate $ENV_NAME"
        echo ""
        exit 0
    fi
fi

# 7. 交互式配置 API keys
echo ""
echo "请输入以下 API 配置信息（直接回车跳过）:"
echo ""

# LLM 配置
read -p "LLM_MODEL_ID (例如: qwen2.5:1.5b): " LLM_MODEL_ID
read -p "LLM_API_KEY: " LLM_API_KEY
read -p "LLM_BASE_URL (例如: http://127.0.0.1:11434/v1): " LLM_BASE_URL

# SerpAPI 配置
read -p "SERPAPI_API_KEY (可选): " SERPAPI_API_KEY

# 8. 写入 .env 文件
echo ""
echo "📝 写入 .env 文件..."

cat > "$ENV_FILE" << EOF
# LLM 配置
LLM_MODEL_ID="${LLM_MODEL_ID:-YOUR-MODEL}"
LLM_API_KEY="${LLM_API_KEY:-YOUR-API-KEY}"
LLM_BASE_URL="${LLM_BASE_URL:-YOUR-URL}"
LLM_TIMEOUT=60

# 搜索 API 配置
SERPAPI_API_KEY="${SERPAPI_API_KEY:-YOUR_SERPAPI_API_KEY}"
EOF

echo "✅ .env 文件已创建/更新: $ENV_FILE"
echo ""

# 9. 检查并启动 Ollama
echo "🔍 检查 Ollama 服务..."
if command -v ollama &> /dev/null; then
    # 检查 ollama 是否在运行
    if curl -s http://127.0.0.1:11434/api/tags &> /dev/null; then
        echo "✅ Ollama 服务已在运行"
    else
        echo "🚀 启动 Ollama 服务..."
        # 尝试启动 ollama（在后台）
        ollama serve > /dev/null 2>&1 &
        sleep 2  # 等待服务启动
        
        # 再次检查
        if curl -s http://127.0.0.1:11434/api/tags &> /dev/null; then
            echo "✅ Ollama 服务已启动"
        else
            echo "⚠️  Ollama 启动可能失败，请手动运行: ollama serve"
        fi
    fi
    
    # 如果配置了模型，检查模型是否已下载
    if [ -n "$LLM_MODEL_ID" ] && [ "$LLM_MODEL_ID" != "YOUR-MODEL" ]; then
        echo "📦 检查模型: $LLM_MODEL_ID"
        if ollama list | grep -q "$LLM_MODEL_ID"; then
            echo "✅ 模型已下载"
        else
            echo "📥 模型未找到，是否现在下载？"
            read -p "下载模型 $LLM_MODEL_ID? (y/n): " download_model
            if [ "$download_model" = "y" ] || [ "$download_model" = "Y" ]; then
                echo "📥 正在下载模型（这可能需要一些时间）..."
                ollama pull "$LLM_MODEL_ID"
                echo "✅ 模型下载完成"
            else
                echo "⚠️  模型未下载，稍后可以运行: ollama pull $LLM_MODEL_ID"
            fi
        fi
    fi
else
    echo "⚠️  未找到 ollama 命令"
    echo "   如果使用本地 Ollama，请先安装: https://ollama.ai"
    echo "   或者使用其他 LLM 服务（OpenAI 等）"
fi
echo ""

# 10. 显示配置摘要
echo "=========================================="
echo "  配置完成！"
echo "=========================================="
echo ""
echo "✅ Conda 环境: $ENV_NAME (已激活)"
echo "✅ .env 文件: $ENV_FILE"
echo ""
echo "当前配置摘要:"
echo "  - LLM_MODEL_ID: ${LLM_MODEL_ID:-未设置}"
echo "  - LLM_BASE_URL: ${LLM_BASE_URL:-未设置}"
echo "  - SERPAPI_API_KEY: ${SERPAPI_API_KEY:+已设置}${SERPAPI_API_KEY:-未设置}"
echo ""
echo "💡 提示:"
echo "  1. 如果环境未激活，请运行: conda activate $ENV_NAME"
echo "  2. 编辑 .env 文件可以修改配置"
echo "  3. 运行测试: python llm_client.py"
echo "  4. Ollama 服务已在后台运行（如果已配置）"
echo ""
