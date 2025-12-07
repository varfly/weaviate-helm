# 快速发布指南

## 前提条件

1. 确保已安装 Helm: `helm version`
2. 确保已安装 Git
3. 确保有 GitHub 仓库的写权限

## 快速发布（使用脚本）

```bash
# 1. 更新 Chart 版本（如果需要）
# 编辑 weaviate/Chart.yaml，更新 version 字段

# 2. 运行发布脚本
./publish.sh

# 3. 按照脚本提示完成发布
```

## 手动发布步骤

### 1. 打包 Chart

```bash
cd weaviate
helm dependencies build
helm lint .
helm package .
cd ..
```

### 2. 准备 gh-pages 分支

```bash
# 克隆仓库（如果还没有）
git clone git@github.com:varfly/weaviate-helm.git
cd weaviate-helm

# 创建或切换到 gh-pages 分支
git checkout -b gh-pages 2>/dev/null || git checkout gh-pages

# 复制打包好的 chart
cp weaviate/weaviate-*.tgz .

# 生成或更新 index.yaml
helm repo index . --url https://varfly.github.io/weaviate-helm

# 提交并推送
git add .
git commit -m "Release chart version $(grep '^version:' weaviate/Chart.yaml | awk '{print $2}')"
git push origin gh-pages
```

### 3. 启用 GitHub Pages

1. 访问仓库设置: https://github.com/varfly/weaviate-helm/settings/pages
2. 选择 `gh-pages` 分支作为源
3. 保存设置

### 4. 验证发布

等待几分钟让 GitHub Pages 生效，然后测试:

```bash
helm repo add varfly-weaviate https://varfly.github.io/weaviate-helm
helm repo update
helm search repo varfly-weaviate
```

## 使用 GitHub Actions 自动发布

如果你已经配置了 GitHub Actions（见 `.github/workflows/main.yaml`），只需要:

1. 更新 `weaviate/Chart.yaml` 中的版本号
2. 创建并推送标签:
   ```bash
   git add weaviate/Chart.yaml
   git commit -m "Bump chart version to X.X.X"
   git tag v17.7.1  # 使用 Chart.yaml 中的版本号
   git push origin main
   git push origin --tags
   ```

GitHub Actions 会自动:
- 运行测试
- 打包 chart
- 发布到 GitHub Pages
- 创建 GitHub Release

## 多实例部署示例

```bash
# 安装第一个实例
helm install weaviate-prod varfly-weaviate/weaviate \
  --set replicas=3

# 安装第二个实例（不会冲突）
helm install weaviate-dev varfly-weaviate/weaviate \
  --set replicas=1 \
  --namespace default
```

## 故障排查

### GitHub Pages 不工作

1. 检查 `gh-pages` 分支是否存在
2. 检查仓库设置中是否启用了 GitHub Pages
3. 等待几分钟让更改生效
4. 检查 `index.yaml` 文件格式是否正确

### Chart 无法下载

1. 确认 GitHub Pages URL 可访问: `curl https://varfly.github.io/weaviate-helm/index.yaml`
2. 检查 `index.yaml` 中的 URL 是否正确
3. 尝试清除 Helm 缓存: `helm repo remove varfly-weaviate && helm repo add varfly-weaviate https://varfly.github.io/weaviate-helm`

