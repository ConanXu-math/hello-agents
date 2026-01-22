# 环境配置脚本使用说明

提供了两个自动化配置脚本，可以一键完成从 API 配置到 conda 环境激活的整个流程。

## 脚本功能

- ✅ 检查 conda 是否安装
- ✅ 自动创建/检查 conda 环境
- ✅ 自动安装依赖包
- ✅ 交互式配置 .env 文件（API keys）
- ✅ 显示配置摘要

## 使用方法

### 方法 1: Python 脚本（推荐）

```bash
python setup_env.py
```

### 方法 2: Bash 脚本

```bash
bash setup_env.sh
# 或者
./setup_env.sh
```

## 配置项说明

脚本会引导你配置以下内容：

1. **LLM_MODEL_ID**: 模型名称（例如: `qwen2.5:1.5b`）
2. **LLM_API_KEY**: API 密钥
3. **LLM_BASE_URL**: API 地址（例如: `http://127.0.0.1:11434/v1`）
4. **SERPAPI_API_KEY**: SerpAPI 密钥（可选，用于搜索功能）

## 示例

### 使用本地 Ollama

```bash
python setup_env.py
# 输入配置：
# LLM_MODEL_ID: qwen2.5:1.5b
# LLM_API_KEY: ollama  # 本地 ollama 可以填任意值
# LLM_BASE_URL: http://127.0.0.1:11434/v1
# SERPAPI_API_KEY: (可选，直接回车跳过)
```

### 使用 OpenAI API

```bash
python setup_env.py
# 输入配置：
# LLM_MODEL_ID: gpt-4
# LLM_API_KEY: sk-xxxxx  # 你的 OpenAI API key
# LLM_BASE_URL: https://api.openai.com/v1
# SERPAPI_API_KEY: (可选)
```

## 后续操作

配置完成后：

1. **激活环境**:
   ```bash
   conda activate hello-agents
   ```

2. **测试配置**:
   ```bash
   python llm_client.py
   ```

3. **修改配置**:
   编辑 `.env` 文件即可

## 注意事项

- 如果 `.env` 文件已存在，脚本会询问是否重新配置
- 脚本会自动安装基础依赖（openai, python-dotenv, serpapi）
- 如果有 `requirements.txt`，会优先使用它安装依赖
