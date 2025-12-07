#!/bin/bash

set -eou pipefail

# 发布 Helm Chart 到 GitHub Pages 的脚本

CHART_DIR="weaviate"
REPO_URL="https://varfly.github.io/weaviate-helm"
GITHUB_REPO="varfly/weaviate-helm"

echo "📦 开始发布 Helm Chart..."

# 检查是否在正确的目录
if [ ! -d "$CHART_DIR" ]; then
    echo "❌ 错误: 找不到 $CHART_DIR 目录"
    exit 1
fi

# 检查 Helm 是否安装
if ! command -v helm &> /dev/null; then
    echo "❌ 错误: 未安装 Helm"
    exit 1
fi

# 获取版本号
VERSION=$(grep '^version:' "$CHART_DIR/Chart.yaml" | awk '{ print $2 }')
echo "📌 Chart 版本: $VERSION"

# 打包 Chart
echo "📦 打包 Chart..."
cd "$CHART_DIR"
helm dependencies build
helm lint .
helm package .

# 检查是否成功打包
CHART_FILE="weaviate-${VERSION}.tgz"
if [ ! -f "$CHART_FILE" ]; then
    echo "❌ 错误: 打包失败，找不到 $CHART_FILE"
    exit 1
fi

echo "✅ Chart 打包成功: $CHART_FILE"

# 创建临时目录用于构建 gh-pages
cd ..
TEMP_DIR=$(mktemp -d)
echo "📁 使用临时目录: $TEMP_DIR"

# 克隆 gh-pages 分支（如果存在）
if git ls-remote --heads origin gh-pages | grep -q gh-pages; then
    echo "📥 克隆现有的 gh-pages 分支..."
    git clone --branch gh-pages --single-branch "https://github.com/${GITHUB_REPO}.git" "$TEMP_DIR/gh-pages"
else
    echo "📝 创建新的 gh-pages 分支..."
    mkdir -p "$TEMP_DIR/gh-pages"
    cd "$TEMP_DIR/gh-pages"
    git init
    git checkout -b gh-pages
    cd - > /dev/null
fi

# 复制 chart 文件
cp "$CHART_DIR/$CHART_FILE" "$TEMP_DIR/gh-pages/"

# 生成或更新 index.yaml
cd "$TEMP_DIR/gh-pages"
if [ -f "index.yaml" ]; then
    echo "🔄 更新现有的 index.yaml..."
    helm repo index . --url "$REPO_URL" --merge index.yaml
else
    echo "📝 创建新的 index.yaml..."
    helm repo index . --url "$REPO_URL"
fi

# 显示变更
echo ""
echo "📋 变更内容:"
git status --short || echo "  (新仓库)"

echo ""
echo "⚠️  接下来的步骤:"
echo "1. 检查临时目录: $TEMP_DIR/gh-pages"
echo "2. 如果一切正常，执行以下命令提交:"
echo ""
echo "   cd $TEMP_DIR/gh-pages"
echo "   git add ."
echo "   git commit -m 'Release chart version $VERSION'"
echo "   git remote add origin https://github.com/${GITHUB_REPO}.git"
echo "   git push -u origin gh-pages"
echo ""
echo "或者，如果你想自动提交，取消下面这行的注释:"
echo "# git add . && git commit -m 'Release chart version $VERSION' && git push origin gh-pages"

