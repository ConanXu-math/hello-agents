#!/usr/bin/env python3
"""
项目迁移脚本 - 迁移到新的 Git 仓库
使用方法: python migrate.py
"""

import os
import subprocess
import sys

def run_cmd(cmd, check=True):
    """运行命令"""
    try:
        result = subprocess.run(cmd, shell=True, check=check, 
                              capture_output=True, text=True)
        return result.stdout.strip()
    except subprocess.CalledProcessError as e:
        if check:
            print(f"❌ 错误: {e}")
            sys.exit(1)
        return None

def main():
    print("=" * 50)
    print("  项目迁移到新 Git 仓库")
    print("=" * 50)
    print()
    
    # 1. 检查并提交当前更改
    print("📝 检查当前更改...")
    status = run_cmd("git status --porcelain", check=False)
    if status:
        print("发现未提交的更改，是否提交？")
        choice = input("提交更改？(y/n): ").strip().lower()
        if choice == 'y':
            run_cmd("git add -A")
            msg = input("请输入提交信息（默认: Prepare migration）: ").strip()
            msg = msg or "Prepare migration"
            run_cmd(f'git commit -m "{msg}"')
            print("✅ 更改已提交")
    else:
        print("✅ 没有未提交的更改")
    
    print()
    
    # 2. 移除旧远程仓库
    remotes = run_cmd("git remote", check=False)
    if remotes and "origin" in remotes:
        print("🗑️  移除旧远程仓库...")
        old_url = run_cmd("git remote get-url origin", check=False)
        if old_url:
            print(f"  旧地址: {old_url}")
        run_cmd("git remote remove origin", check=False)
        print("✅ 旧远程仓库已移除")
    else:
        print("ℹ️  没有找到远程仓库")
    
    print()
    
    # 3. 添加新远程仓库
    print("请输入新的 Git 仓库地址：")
    print("  示例:")
    print("    - GitHub: https://github.com/username/repo.git")
    print("    - GitLab: https://gitlab.com/username/repo.git")
    print("    - Gitee:  https://gitee.com/username/repo.git")
    print()
    
    new_repo_url = input("新仓库地址: ").strip()
    
    if not new_repo_url:
        print("❌ 仓库地址不能为空")
        sys.exit(1)
    
    print()
    print("🔗 添加新远程仓库...")
    run_cmd(f'git remote add origin "{new_repo_url}"')
    print(f"✅ 新远程仓库已添加: {new_repo_url}")
    
    print()
    
    # 4. 获取当前分支
    current_branch = run_cmd("git branch --show-current", check=False) or "main"
    if not current_branch:
        run_cmd("git checkout -b main", check=False)
        current_branch = "main"
    
    print(f"📍 当前分支: {current_branch}")
    
    print()
    
    # 5. 询问是否推送
    push_choice = input("是否立即推送到新仓库？(y/n): ").strip().lower()
    if push_choice == 'y':
        print()
        print("🚀 推送到新仓库...")
        result = run_cmd(f"git push -u origin {current_branch}", check=False)
        if result is not None:
            print("✅ 代码已成功推送到新仓库")
        else:
            print("⚠️  推送失败，可能的原因：")
            print("   1. 新仓库还未创建，请先在平台创建空仓库")
            print("   2. 认证失败，请检查权限")
            print()
            print("手动推送命令:")
            print(f"   git push -u origin {current_branch}")
    else:
        print()
        print("💡 稍后可以手动推送:")
        print(f"   git push -u origin {current_branch}")
    
    print()
    print("=" * 50)
    print("  迁移完成！")
    print("=" * 50)
    print()
    print(f"✅ 新远程仓库: {new_repo_url}")
    print(f"✅ 当前分支: {current_branch}")
    print()
    print("常用命令:")
    print("  - 查看远程: git remote -v")
    print("  - 推送代码: git push")
    print("  - 拉取代码: git pull")
    print()

if __name__ == "__main__":
    main()
