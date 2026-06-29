#!/bin/bash
# Sidebush Art — deploy to Cloudflare Pages
set -e
cd "$(dirname "$0")"

# Provide your Cloudflare API token via the environment, or a local .env file
# (gitignored). Create the token at: Cloudflare dashboard → My Profile → API
# Tokens → Create Token → "Cloudflare Pages: Edit" template.
if [ -z "$CLOUDFLARE_API_TOKEN" ] && [ -f .env ]; then
  set -a; source .env; set +a
fi
[ -z "$CLOUDFLARE_API_TOKEN" ] && { echo "Set CLOUDFLARE_API_TOKEN (export it, or put it in a local .env)"; exit 1; }

ACCOUNT_ID=$(curl -s -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" https://api.cloudflare.com/client/v4/accounts | python3 -c "import sys,json;d=json.load(sys.stdin);print(d['result'][0]['id'])")
export CLOUDFLARE_ACCOUNT_ID="$ACCOUNT_ID" CLOUDFLARE_API_TOKEN

npx --yes wrangler@latest pages project create sidebush-art --production-branch=master 2>&1 | tail -3 || true
npx --yes wrangler@latest pages deploy . --project-name=sidebush-art --branch=master --commit-dirty=true
