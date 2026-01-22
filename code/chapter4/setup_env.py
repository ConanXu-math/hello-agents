#!/usr/bin/env python3
"""
自动化配置脚本：从 API 配置到 conda 环境激活
使用方法: python setup_env.py
"""

import os
import sys
import subprocess
from pathlib import Path

def run_command(cmd, check=True):
    """运行 shell 命令"""
    try:
        result = subprocess.run(cmd, shell=True, check=check, capture_output=True, text=True)
        return result.stdout.strip()
    except subprocess.CalledProcessError as e:
        if check:
            print(f"❌ 错误: {e}")
            sys.exit(1)
        return None

def check_conda():
    """检查 conda 是否安装"""
    if not run_command("which conda", check=False):
        print("❌ 错误: 未找到 conda，请先安装 Anaconda 或 Miniconda")
        sys.exit(1)
    print("✅ Conda 已安装")

def setup_conda_env(env_name="hello-agents"):
    """设置 conda 环境"""
    print(f"\n📦 检查 conda 环境: {env_name}")
    
    # 检查环境是否存在
    envs = run_command("conda env list", check=False)
    if env_name in envs:
        print(f"✅ Conda 环境 '{env_name}' 已存在")
    else:
        print(f"📦 创建新的 conda 环境: {env_name}")
        run_command(f"conda create -n {env_name} python=3.10 -y")
        print("✅ 环境创建完成")
    
    return env_name

def install_dependencies(script_dir):
    """安装依赖"""
    print("\n📦 检查并安装依赖...")
    
    requirements_file = Path(script_dir) / "requirements.txt"
    if requirements_file.exists():
        print(f"📄 找到 requirements.txt")
        run_command(f"pip install -r {requirements_file}")
    else:
        print("⚠️  未找到 requirements.txt")
        print("   安装基础依赖...")
        run_command("pip install openai python-dotenv serpapi -q")
    
    print("✅ 依赖安装完成")

def setup_env_file(script_dir):
    """配置 .env 文件"""
    env_file = Path(script_dir) / ".env"
    
    print(f"\n🔧 配置 .env 文件...")
    
    if env_file.exists():
        print("📄 .env 文件已存在")
        reconfigure = input("是否要重新配置？(y/n): ").strip().lower()
        if reconfigure != 'y':
            print("✅ 使用现有配置")
            return
    
    # 交互式配置
    print("\n请输入以下 API 配置信息（直接回车跳过）:")
    print()
    
    llm_model_id = input("LLM_MODEL_ID (例如: qwen2.5:1.5b): ").strip()
    llm_api_key = input("LLM_API_KEY: ").strip()
    llm_base_url = input("LLM_BASE_URL (例如: http://127.0.0.1:11434/v1): ").strip()
    serpapi_key = input("SERPAPI_API_KEY (可选): ").strip()
    
    # 写入 .env 文件
    env_content = f"""# LLM 配置
LLM_MODEL_ID="{llm_model_id or 'YOUR-MODEL'}"
LLM_API_KEY="{llm_api_key or 'YOUR-API-KEY'}"
LLM_BASE_URL="{llm_base_url or 'YOUR-URL'}"
LLM_TIMEOUT=60

# 搜索 API 配置
SERPAPI_API_KEY="{serpapi_key or 'YOUR_SERPAPI_API_KEY'}"
"""
    
    env_file.write_text(env_content)
    print(f"\n✅ .env 文件已创建/更新: {env_file}")
    
    return {
        'LLM_MODEL_ID': llm_model_id,
        'LLM_BASE_URL': llm_base_url,
        'SERPAPI_API_KEY': serpapi_key
    }

def setup_ollama(model_id=None):
    """检查并启动 Ollama 服务"""
    print("\n🔍 检查 Ollama 服务...")
    
    # 检查 ollama 命令是否存在
    if not run_command("which ollama", check=False):
        print("⚠️  未找到 ollama 命令")
        print("   如果使用本地 Ollama，请先安装: https://ollama.ai")
        print("   或者使用其他 LLM 服务（OpenAI 等）")
        return
    
    # 检查 ollama 是否在运行
    try:
        from urllib.request import urlopen
        from urllib.error import URLError
        try:
            response = urlopen("http://127.0.0.1:11434/api/tags", timeout=2)
            if response.getcode() == 200:
                print("✅ Ollama 服务已在运行")
            else:
                raise Exception("服务未响应")
        except URLError:
            raise Exception("服务未运行")
    except:
        print("🚀 启动 Ollama 服务...")
        # 在后台启动 ollama
        import subprocess
        subprocess.Popen(["ollama", "serve"], 
                        stdout=subprocess.DEVNULL, 
                        stderr=subprocess.DEVNULL)
        
        # 等待服务启动
        import time
        time.sleep(2)
        
        # 再次检查
        try:
            from urllib.request import urlopen
            from urllib.error import URLError
            response = urlopen("http://127.0.0.1:11434/api/tags", timeout=2)
            if response.getcode() == 200:
                print("✅ Ollama 服务已启动")
            else:
                print("⚠️  Ollama 启动可能失败，请手动运行: ollama serve")
        except:
            print("⚠️  Ollama 启动可能失败，请手动运行: ollama serve")
    
    # 如果配置了模型，检查模型是否已下载
    if model_id and model_id != 'YOUR-MODEL':
        print(f"📦 检查模型: {model_id}")
        models = run_command("ollama list", check=False)
        if models and model_id in models:
            print("✅ 模型已下载")
        else:
            print("📥 模型未找到，是否现在下载？")
            download = input(f"下载模型 {model_id}? (y/n): ").strip().lower()
            if download == 'y':
                print("📥 正在下载模型（这可能需要一些时间）...")
                run_command(f"ollama pull {model_id}")
                print("✅ 模型下载完成")
            else:
                print(f"⚠️  模型未下载，稍后可以运行: ollama pull {model_id}")

def main():
    """主函数"""
    print("=" * 50)
    print("  Hello Agents 环境配置脚本")
    print("=" * 50)
    
    # 获取脚本目录
    script_dir = Path(__file__).parent.absolute()
    print(f"\n📍 工作目录: {script_dir}")
    
    # 1. 检查 conda
    check_conda()
    
    # 2. 设置 conda 环境
    env_name = setup_conda_env()
    
    # 3. 安装依赖
    install_dependencies(script_dir)
    
    # 4. 配置 .env 文件
    config = setup_env_file(script_dir)
    
    # 5. 检查并启动 Ollama
    setup_ollama(config.get('LLM_MODEL_ID') if config else None)
    
    # 6. 显示摘要
    print("\n" + "=" * 50)
    print("  配置完成！")
    print("=" * 50)
    print(f"\n✅ Conda 环境: {env_name}")
    print(f"✅ .env 文件: {script_dir / '.env'}")
    print("\n💡 提示:")
    print(f"  1. 激活环境: conda activate {env_name}")
    print(f"  2. 编辑配置: 修改 {script_dir / '.env'}")
    print(f"  3. 运行测试: python {script_dir / 'llm_client.py'}")
    print(f"  4. Ollama 服务已在后台运行（如果已配置）")
    print()

if __name__ == "__main__":
    main()
