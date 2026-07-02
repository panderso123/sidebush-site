#!/bin/bash
# Minimal diagnostic deploy: page + functions only, NO assets.
# Proves whether the upload pipeline works at all.
set -e
cd "$(dirname "$0")"
rm -rf dist && mkdir -p dist
cp index.html robots.txt sitemap.xml _headers _redirects dist/
cp -R functions dist/functions
echo "dist has $(find dist -type f | wc -l | tr -d ' ') files, $(du -sh dist | cut -f1)"
unset CLOUDFLARE_API_TOKEN
export CLOUDFLARE_ACCOUNT_ID=f18697935e53f21611fe66bf4c17c185
npx --yes wrangler@latest pages deploy dist --project-name sidebush-art --branch main --commit-dirty=true
