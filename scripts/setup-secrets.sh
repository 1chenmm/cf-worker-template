#!/usr/bin/env bash
# 一键给当前仓库配好 GitHub Actions 部署密钥。
# 用法：在仓库目录执行 bash scripts/setup-secrets.sh
set -euo pipefail

TOKEN_FILE="${HOME}/.cloudflare-api-token.txt"

command -v gh >/dev/null || { echo "缺少 gh（GitHub CLI），先装：apt install gh"; exit 1; }
gh auth status >/dev/null 2>&1 || { echo "gh 未登录，先执行 gh auth login"; exit 1; }

if [ -f "$TOKEN_FILE" ]; then
  # shellcheck disable=SC1090
  . "$TOKEN_FILE"
else
  echo "没找到 $TOKEN_FILE"
  read -r -p "粘贴 Cloudflare API Token: " CF_API_TOKEN
  read -r -p "Cloudflare Account ID [87c68849716c6a6f3afb87354f6a1666]: " CF_ACCOUNT_ID
  CF_ACCOUNT_ID="${CF_ACCOUNT_ID:-87c68849716c6a6f3afb87354f6a1666}"
fi

[ -n "${CF_API_TOKEN:-}" ] || { echo "Token 为空，退出"; exit 1; }

gh secret set CLOUDFLARE_API_TOKEN --body "$CF_API_TOKEN"
gh secret set CLOUDFLARE_ACCOUNT_ID --body "$CF_ACCOUNT_ID"
echo "✅ 已完成：$(gh repo view --json nameWithOwner -q .nameWithOwner) 的部署密钥配好了"
echo "   下次 git push 就会自动部署。"
