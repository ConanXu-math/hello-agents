#!/bin/bash

# 自动创建新仓库并推送当前项目
# 使用方法: bash create_repo.sh

set -e

echo "=========================================="
echo "  自动创建新仓库并推送项目"
echo "=========================================="
echo ""

PROJECT_NAME=$(basename "$(pwd)")

# 1. 检查 GitHub CLI
if command -v gh &> /dev/null; then
    echo "✅ 检测到 GitHub CLI"
    
    # 检查是否已登录
    if gh auth status &> /dev/null; then
        echo "✅ GitHub 已登录"
        
        # 提交当前更改
        if [ -n "$(git status --porcelain)" ]; then
            echo ""
            echo "📝 提交当前更改..."
            git add -A
            git commit -m "Initial commit" || true
        fi
        
        # 移除旧远程
        if git remote | grep -q "^origin$"; then
            echo ""
            echo "🗑️  移除旧远程仓库..."
            git remote remove origin
        fi
        
        echo ""
        read -p "请输入新仓库名称（默认: $PROJECT_NAME）: " repo_name
        repo_name="${repo_name:-$PROJECT_NAME}"
        
        read -p "仓库描述（可选）: " repo_desc
        
        echo ""
        read -p "是否创建私有仓库？(y/n，默认n): " is_private
        if [ "$is_private" = "y" ] || [ "$is_private" = "Y" ]; then
            visibility="--private"
        else
            visibility="--public"
        fi
        
        echo ""
        echo "🚀 正在创建 GitHub 仓库并推送代码..."
        
        # 创建仓库并推送
        if [ -n "$repo_desc" ]; then
            gh repo create "$repo_name" $visibility \
                --description "$repo_desc" \
                --source=. \
                --remote=origin \
                --push
        else
            gh repo create "$repo_name" $visibility \
                --source=. \
                --remote=origin \
                --push
        fi
        
        REPO_URL=$(gh repo view "$repo_name" --json url -q .url)
        
        echo ""
        echo "=========================================="
        echo "  ✅ 仓库创建成功！"
        echo "=========================================="
        echo ""
        echo "📍 仓库地址: $REPO_URL"
        echo ""
        echo "常用命令:"
        echo "  - 查看远程: git remote -v"
        echo "  - 推送代码: git push"
        echo "  - 拉取代码: git pull"
        echo ""
        exit 0
    else
        echo "⚠️  GitHub 未登录"
        echo "   正在登录..."
        gh auth login
        # 重新运行脚本
        exec "$0"
    fi
fi

# 2. 如果没有 GitHub CLI，提供手动步骤
echo "⚠️  未检测到 GitHub CLI"
echo ""
echo "有两种方式创建仓库："
echo ""
echo "方式 1: 安装 GitHub CLI（推荐）"
echo "  Mac: brew install gh"
echo "  然后运行: gh auth login"
echo "  再运行此脚本"
echo ""
echo "方式 2: 手动创建（当前可用）"
echo "  1. 在 GitHub 网页上创建新仓库"
echo "  2. 运行迁移脚本: bash migrate.sh"
echo ""
read -p "是否现在运行迁移脚本？(y/n): " run_migrate
if [ "$run_migrate" = "y" ] || [ "$run_migrate" = "Y" ]; then
    bash migrate.sh
fi
