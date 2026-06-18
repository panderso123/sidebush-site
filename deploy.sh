#!/bin/bash
# Sidebush Art — deploy to Cloudflare Pages
set -e
ENV_FILE="/Users/travisgough/Projects/creative-conquest/.env"
[ -f "$ENV_FILE" ] && { set -a; source "$ENV_FILE"; set +a; }
[ -z "$CLOUDFLARE_API_TOKEN" ] && { echo "no CLOUDFLARE_API_TOKEN"; exit 1; }

ACCOUNT_ID=$(/usr/bin/curl -s -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" https://api.cloudflare.com/client/v4/accounts | /usr/bin/python3 -c "import sys,json;d=json.load(sys.stdin);print(d['result'][0]['id'])")
export CLOUDFLARE_ACCOUNT_ID="$ACCOUNT_ID" CLOUDFLARE_API_TOKEN
cd "$(dirname "$0")"
npx --yes wrangler@latest pages project create sidebush-art --production-branch=main 2>&1 | tail -3 || true
npx --yes wrangler@latest pages deploy . --project-name=sidebush-art --branch=main --commit-dirty=true
