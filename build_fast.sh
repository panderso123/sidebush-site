#!/bin/bash
# Build a LEAN dist/ (web-compressed images) and deploy to Cloudflare Pages via your login.
set -e
cd "$(dirname "$0")"

echo "▸ Assembling dist/ ..."
rm -rf dist && mkdir -p dist
cp index.html robots.txt sitemap.xml _headers _redirects dist/
cp -R functions dist/functions
cp -R assets dist/assets

# Drop the optional clothing reel video (site still works without it)
rm -f dist/assets/mockups.mp4

echo "▸ Compressing images for web (this is the slow part, ~1 min)..."
find dist/assets -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' \) -print0 \
  | while IFS= read -r -d '' img; do
      sips -Z 1600 -s formatOptions 72 "$img" >/dev/null 2>&1 || true
    done

echo "  dist size now: $(du -sh dist | cut -f1)  ($(find dist -type f | wc -l | tr -d ' ') files)"

# Deploy using your wrangler login (not the old token)
unset CLOUDFLARE_API_TOKEN
export CLOUDFLARE_ACCOUNT_ID=f18697935e53f21611fe66bf4c17c185
echo "▸ Deploying..."
npx --yes wrangler@latest pages deploy dist --project-name sidebush-art --branch main --commit-dirty=true
