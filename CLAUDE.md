# CLAUDE.md — Sidebush Art (gallery / storefront)

Public storefront + portfolio for **Sidebush Art** (dark gallery aesthetic + gold).
Static `index.html`, deployed to Cloudflare / GitHub Pages. Sells via Printify → Etsy.

## Image-gen focus (Facebook posts · remix · new artwork)

Day-to-day work is image generation: Facebook post images, remixing existing
images, and new gallery pieces. Use the `sidebush-image` agent for these tasks.

**Tool stack (local pipeline first):**
- New masters: local ComfyUI (`sidebush-pipeline/generate.py`).
- Remix-to-painting: Flux Kontext Pro (`sidebush-system/remix_batch.py`).
- Facebook post layouts / on-brand cards: **Canva** (MCP).
- Upscale to print (300 DPI): `sidebush-system/tools/upscale_correct.py`;
  Higgs `upscale_image` as a cloud fallback.
- Grok image tools: browser extension, not wired yet — don't depend on it.

## Key files
- `BRAND_GUIDELINES.md` — brand identity, colors (dark + gold), typography, pricing.
- `FACEBOOK_POST_TEMPLATE.md` — 30-day content calendar, post templates, hashtags.
- `sidebush-products.csv` — 52-product feed for Printify bulk upload.
- `index.html` — the live gallery (TOP 30 collection).

## Sibling repos
- `sidebush-pipeline` — 14-stage art→POD→D2C machine (local ComfyUI generation).
- `sidebush-system` — image toolchain (upscale / seamless / format / color-pop / reels).

## Guardrails
- Originality: composition-original, never copy a living artist.
- Facebook captions: myth → hero → soft CTA. Story over spam.
- Print quality or it doesn't ship.
