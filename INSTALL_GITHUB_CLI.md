# 安装 GitHub CLI 的方法

## 方法 1: 安装 Homebrew（Mac 推荐）

```bash
# 安装 Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 然后安装 GitHub CLI
brew install gh

# 登录
gh auth login
```

## 方法 2: 直接下载 GitHub CLI（无需 Homebrew）

### Mac
```bash
# 下载安装包
curl -L https://github.com/cli/cli/releases/latest/download/gh_*_macOS_amd64.tar.gz -o gh.tar.gz

# 解压并安装
tar -xzf gh.tar.gz
sudo mv gh_*/bin/gh /usr/local/bin/
rm -rf gh_* gh.tar.gz

# 登录
gh auth login
```

或者访问：https://cli.github.com/manual/installation

## 方法 3: 不使用 GitHub CLI（手动创建）

如果不想安装，可以：

1. **在 GitHub 网页上创建新仓库**
   - 访问 https://github.com/new
   - 创建空仓库（不要初始化 README）

2. **运行迁移脚本**
   ```bash
   bash migrate.sh
   ```
   - 输入新仓库地址
   - 自动推送代码

## 推荐

如果只是偶尔使用，**方法 3（手动创建）最简单**，不需要安装任何东西。
