# Helm Chart 发布指南

## 发布步骤

### 方法 1: 使用 chartpress（推荐，自动化）

1. **确保已安装 chartpress**:
   ```bash
   pip install chartpress
   ```

2. **更新 Chart.yaml 版本号**:
   - 编辑 `weaviate/Chart.yaml`，增加 `version` 字段

3. **创建并推送 Git 标签**:
   ```bash
   git add weaviate/Chart.yaml
   git commit -m "Bump chart version to X.X.X"
   git tag v17.7.1  # 使用 Chart.yaml 中的版本号，前缀 v
   git push origin main
   git push origin --tags
   ```

4. **GitHub Actions 会自动**:
   - 运行测试
   - 打包 chart
   - 发布到 GitHub Pages
   - 创建 GitHub Release

### 方法 2: 手动发布

1. **打包 Chart**:
   ```bash
   cd weaviate
   helm package .
   ```

2. **创建或更新 index.yaml**:
   ```bash
   helm repo index . --url https://varfly.github.io/weaviate-helm
   ```

3. **提交到 gh-pages 分支**:
   ```bash
   git checkout -b gh-pages
   git add weaviate-*.tgz index.yaml
   git commit -m "Release chart version X.X.X"
   git push origin gh-pages
   ```

## 使用你的 Helm Repo

用户可以通过以下方式使用你的 Helm repo:

```bash
# 添加 repo
helm repo add varfly-weaviate https://varfly.github.io/weaviate-helm

# 更新 repo
helm repo update

# 安装 chart
helm install my-weaviate varfly-weaviate/weaviate
```

## 注意事项

1. **GitHub Pages 设置**:
   - 确保在 GitHub 仓库设置中启用了 GitHub Pages
   - 选择 `gh-pages` 分支作为源

2. **Deploy Key**:
   - 如果使用 chartpress，需要配置 deploy key
   - 生成 SSH key pair: `ssh-keygen -t ed25519 -C "varfly/weaviate-helm" -f ./deploy_key`
   - 将私钥添加到 GitHub Secrets: `WEAVIATE_HELM_CHART_DEPLOY_KEY`
   - 将公钥添加到仓库的 Deploy Keys（需要写权限）

3. **版本号**:
   - 每次发布前都要更新 `Chart.yaml` 中的版本号
   - 遵循语义化版本控制（Semantic Versioning）

