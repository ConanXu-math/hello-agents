#!/bin/bash

# 项目迁移脚本 - 迁移到新的 Git 仓库
# 使用方法: bash migrate.sh

echo "=========================================="
echo "  项目迁移到新 Git 仓库"
echo "=========================================="
echo ""

# 1. 检查并提交当前更改
echo "📝 检查当前更改..."
if [ -n "$(git status --porcelain)" ]; then
    echo "发现未提交的更改，是否提交？"
    read -p "提交更改？(y/n): " commit_choice
    if [ "$commit_choice" = "y" ] || [ "$commit_choice" = "Y" ]; then
        git add -A
        read -p "请输入提交信息（默认: Prepare migration）: " commit_msg
        commit_msg="${commit_msg:-Prepare migration}"
        git commit -m "$commit_msg"
        echo "✅ 更改已提交"
    fi
else
    echo "✅ 没有未提交的更改"
fi

echo ""

# 2. 移除旧远程仓库
if git remote | grep -q "^origin$"; then
    echo "🗑️  移除旧远程仓库..."
    OLD_REMOTE=$(git remote get-url origin)
    echo "  旧地址: $OLD_REMOTE"
    git remote remove origin
    echo "✅ 旧远程仓库已移除"
else
    echo "ℹ️  没有找到远程仓库"
fi

echo ""

# 3. 添加新远程仓库
echo "请输入新的 Git 仓库地址："
echo "  示例:"
echo "    - GitHub: https://github.com/username/repo.git"
echo "    - GitLab: https://gitlab.com/username/repo.git"
echo "    - Gitee:  https://gitee.com/username/repo.git"
echo ""
read -p "新仓库地址: " NEW_REPO_URL

if [ -z "$NEW_REPO_URL" ]; then
    echo "❌ 仓库地址不能为空"
    exit 1
fi

echo ""
echo "🔗 添加新远程仓库..."
git remote add origin "$NEW_REPO_URL"
echo "✅ 新远程仓库已添加: $NEW_REPO_URL"

echo ""

# 4. 获取当前分支
CURRENT_BRANCH=$(git branch --show-current 2>/dev/null || echo "main")
if [ -z "$CURRENT_BRANCH" ]; then
    CURRENT_BRANCH="main"
    git checkout -b main 2>/dev/null || true
fi

echo "📍 当前分支: $CURRENT_BRANCH"

echo ""

# 5. 询问是否推送
read -p "是否立即推送到新仓库？(y/n): " push_choice
if [ "$push_choice" = "y" ] || [ "$push_choice" = "Y" ]; then
    echo ""
    echo "🚀 推送到新仓库..."
    if git push -u origin "$CURRENT_BRANCH" 2>&1; then
        echo "✅ 代码已成功推送到新仓库"
    else
        echo "⚠️  推送失败，可能的原因："
        echo "   1. 新仓库还未创建，请先在平台创建空仓库"
        echo "   2. 认证失败，请检查权限"
        echo ""
        echo "手动推送命令:"
        echo "   git push -u origin $CURRENT_BRANCH"
    fi
else
    echo ""
    echo "💡 稍后可以手动推送:"
    echo "   git push -u origin $CURRENT_BRANCH"
fi

echo ""
echo "=========================================="
echo "  迁移完成！"
echo "=========================================="
echo ""
echo "✅ 新远程仓库: $NEW_REPO_URL"
echo "✅ 当前分支: $CURRENT_BRANCH"
echo ""
echo "常用命令:"
echo "  - 查看远程: git remote -v"
echo "  - 推送代码: git push"
echo "  - 拉取代码: git pull"
echo ""
