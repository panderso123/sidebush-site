#!/bin/bash
# Sidebush Art — build a clean dist/ and deploy to Cloudflare Pages.
# NOTE: with the repo connected to Cloudflare Pages via Git integration
# (production branch: master, output dir: /), pushes deploy automatically and
# this script is only needed for manual/local deploys.
set -e
cd "$(dirname "$0")"

# --- Auth: token via environment or a local .env (gitignored) ---
if [ -z "$CLOUDFLARE_API_TOKEN" ] && [ -f .env ]; then
  set -a; source .env; set +a
fi
[ -z "$CLOUDFLARE_API_TOKEN" ] && { echo "❌ Set CLOUDFLARE_API_TOKEN (export it, or put it in a local .env)"; exit 1; }

# Use CLOUDFLARE_ACCOUNT_ID if you set it; otherwise look it up (needs Account:Read).
if [ -z "$CLOUDFLARE_ACCOUNT_ID" ]; then
  RESP=$(curl -s -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
    https://api.cloudflare.com/client/v4/accounts)
  ACCOUNT_ID=$(printf '%s' "$RESP" | python3 -c "import sys,json
d=json.load(sys.stdin); r=d.get('result') or []
print(r[0]['id'] if r else '')" 2>/dev/null)
  if [ -z "$ACCOUNT_ID" ]; then
    echo "❌ Could not read your Cloudflare account. The API replied:"
    printf '%s\n' "$RESP" | python3 -m json.tool 2>/dev/null || printf '%s\n' "$RESP"
    echo ""
    echo "Fix one of these, then re-run ./deploy.sh:"
    echo "  • Token missing permissions → create a token with 'Account:Read' + 'Cloudflare Pages:Edit'"
    echo "  • Or set your account id directly:  export CLOUDFLARE_ACCOUNT_ID=xxxxxxxx  (from the dashboard URL)"
    exit 1
  fi
  export CLOUDFLARE_ACCOUNT_ID="$ACCOUNT_ID"
fi
export CLOUDFLARE_API_TOKEN

# --- Build dist/ (only what should be public) ---
echo "▸ Assembling dist/ ..."
rm -rf dist && mkdir -p dist
cp index.html robots.txt sitemap.xml _headers _redirects dist/
cp -R assets dist/assets
cp -R functions dist/functions
# Safety: fail if any file exceeds Cloudflare's 25 MB limit
BIG=$(find dist -type f -size +25M)
[ -n "$BIG" ] && { echo "❌ Files over 25MB in dist:"; echo "$BIG"; exit 1; }
echo "  $(find dist -type f | wc -l | tr -d ' ') files, $(du -sh dist | cut -f1) total"

# --- Deploy ---
npx --yes wrangler@latest pages project create sidebush-art --production-branch=master 2>&1 | tail -2 || true
npx --yes wrangler@latest pages deploy dist --project-name=sidebush-art --branch=master --commit-dirty=true
echo "✅ Deployed. Remember to set secrets (see SETUP.md) if you haven't."
