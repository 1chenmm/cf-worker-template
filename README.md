# cf-worker-template

Cloudflare Workers **推送即部署**模板。改代码 → `git push` → Cloudflare 自动构建上线，本地不需要装 wrangler，也不需要我这边手动构建。

---

## 一、用模板新建一个项目

在 GitHub 上打开本仓库 → 右上角 **Use this template** → **Create a new repository** → 起个名字 → 创建。

然后把新仓库拉到本地（或直接在网页上改代码），**改一处**：`wrangler.toml` 里的 `name = "my-worker"` 改成你的 Worker 名字（线上唯一标识，小写字母数字连字符）。

## 二、给新仓库配两个密钥（一次性）

Cloudflare 的部署凭证不能公开提交到仓库，要放在 GitHub 的 Secrets 里。两种方式任选：

**方式 A：命令行一条命令**（在仓库目录执行）

```bash
bash scripts/setup-secrets.sh
```

它会读取本机的 `~/.cloudflare-api-token.txt`，自动把 `CLOUDFLARE_API_TOKEN` 和 `CLOUDFLARE_ACCOUNT_ID` 写进当前仓库的 Actions Secrets。

**方式 B：网页手点**

仓库 → Settings → Secrets and variables → Actions → New repository secret，加两条：

| Name | Value |
|---|---|
| `CLOUDFLARE_API_TOKEN` | 你的 Cloudflare API Token（Workers Scripts/KV/Routes/Pages/DNS 编辑权限） |
| `CLOUDFLARE_ACCOUNT_ID` | `87c68849716c6a6f3afb87354f6a1666` |

## 三、推送即上线

```bash
git add -A && git commit -m "init" && git push
```

GitHub → 仓库 **Actions** 标签页可以看构建日志。成功后 Worker 立刻上线，地址形如 `https://<name>.<你的子域>.workers.dev`。

---

## 项目结构

```
.
├── .github/workflows/deploy.yml   # 推送 main 即部署（核心）
├── .github/workflows/pages.yml.example  # Pages 版本，自动部署用不到时留着
├── src/index.js                   # Worker 入口
├── wrangler.toml                  # Worker 配置（名字/KV/绑定/路由）
├── scripts/setup-secrets.sh       # 一键给仓库配密钥
└── package.json
```

## 常用配置改哪里

| 想做的事 | 改哪里 |
|---|---|
| 换 Worker 名字 | `wrangler.toml` 的 `name` |
| 绑定 KV | `wrangler.toml` 加 `[[kv_namespaces]]`（需先在面板建好拿到 id） |
| 绑定 D1 / R2 / 环境变量 | `wrangler.toml` 对应段落 |
| 挂自定义域名 | `wrangler.toml` 加 `[[routes]]` + `custom_domain = true` |
| 静态网站 + Worker 同仓库 | `wrangler.toml` 的 `[assets]` 段指向 `public/` |
| 构建前要 `npm install`/打包 | 在 `deploy.yml` 里 wrangler-action 之前加 `run: npm ci && npm run build` |
| 只部署某个分支 | 改 `deploy.yml` 的 `branches: [main]` |

## Pages 项目怎么办

Pages 用仓库根目录的 `.github/workflows/pages.yml.example`：把后缀去掉改成 `pages.yml`，填好项目名和输出目录即可；同时删掉或暂停 `deploy.yml`（两者不要同时跑）。

## 注意

- 秘密值**永远不要**写进仓库文件，只在 GitHub Secrets 里。
- `wrangler.toml` 里的 KV/D1 的 id 不是秘密，可以提交。
- 这个 token 权限覆盖了他账号下全部 9 个域名，泄露等于整号被改；如怀疑泄露，去 Cloudflare 面板 → My Profile → API Tokens 撤销并按上面的权限重建。
