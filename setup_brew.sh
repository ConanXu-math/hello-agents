#!/bin/bash

# 配置 Homebrew 并安装 GitHub CLI

echo "=========================================="
echo "  配置 Homebrew 并安装 GitHub CLI"
echo "=========================================="
echo ""

# 1. 配置 Homebrew PATH
echo "📝 配置 Homebrew PATH..."
echo >> ~/.zprofile
echo 'eval "$(/opt/homebrew/bin/brew shellenv zsh)"' >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv zsh)"

echo "✅ Homebrew PATH 已配置"
echo ""

# 2. 安装 GitHub CLI
echo "📦 安装 GitHub CLI..."
brew install gh

echo ""
echo "✅ GitHub CLI 安装完成"
echo ""

# 3. 登录 GitHub
echo "🔐 登录 GitHub..."
echo "   请按照提示完成登录"
gh auth login

echo ""
echo "=========================================="
echo "  配置完成！"
echo "=========================================="
echo ""
echo "现在可以运行: bash create_repo.sh"
echo ""
