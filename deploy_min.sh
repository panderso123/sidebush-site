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
# Account id via env or a local .env (gitignored) — never hardcode it in a public repo.
[ -f .env ] && { set -a; source .env; set +a; }
[ -z "$CLOUDFLARE_ACCOUNT_ID" ] && { echo "Set CLOUDFLARE_ACCOUNT_ID (export it, or put it in a local .env)"; exit 1; }
npx --yes wrangler@latest pages deploy dist --project-name sidebush-art --branch main --commit-dirty=true
