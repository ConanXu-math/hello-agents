## 本地 Ollama 连接失败纠错记录

### 现象
- Notebook/脚本调用模型时反复报错：`Connection error` 或 `502`
- 进入循环后一直无法解析 `Action` 字段

### 排查与结论
- 终端 `curl http://127.0.0.1:11434` 在 **unset 代理后** 才能访问
- 原因：环境变量 `http_proxy/https_proxy/all_proxy` 导致本地请求被代理拦截
- Notebook 中 `BASE_URL` 需要明确配置为 `http://localhost:11434/v1`

### 修复步骤
1. 在运行前关闭代理或设置本地直连：
   - `unset http_proxy https_proxy all_proxy`
   - `export NO_PROXY=localhost,127.0.0.1`
2. 在 `FirstAgentTest.ipynb` 里加入兜底：
   - `os.environ.setdefault("NO_PROXY", "localhost,127.0.0.1")`
3. 检查配置是否生效：
   - 打印 `API_KEY / BASE_URL / MODEL_ID`
4. 若 `BASE_URL` 为空，则直接抛错提示：
   - `BASE_URL 未配置，请设置为 http://localhost:11434/v1`

### 当前可用配置
- `API_KEY=ollama`
- `BASE_URL=http://localhost:11434/v1`
- `MODEL_ID=qwen2.5:1.5b`

