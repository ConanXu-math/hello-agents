# 迁移到新 Git 仓库的命令

## 步骤 1: 提交当前更改
```bash
git add -A
git commit -m "Add setup scripts and migration tools"
```

## 步骤 2: 移除旧远程仓库
```bash
git remote remove origin
```

## 步骤 3: 添加新远程仓库（替换为你的仓库地址）
```bash
git remote add origin https://github.com/yourusername/your-repo.git
```

## 步骤 4: 检查当前分支并推送
```bash
# 查看当前分支
git branch --show-current

# 推送到新仓库（如果是 main 分支）
git push -u origin main

# 或者如果是 master 分支
git push -u origin master
```

## 一键执行（复制粘贴）
```bash
git add -A && \
git commit -m "Add setup scripts and migration tools" && \
git remote remove origin && \
git remote add origin https://github.com/yourusername/your-repo.git && \
git push -u origin $(git branch --show-current || echo "main")
```

**注意：记得把 `https://github.com/yourusername/your-repo.git` 替换成你的实际仓库地址！**
