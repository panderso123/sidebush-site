# Sidebush Art — Store Setup (Cloudflare Pages + Stripe)

The site is a static storefront with a **custom Stripe checkout** running on Cloudflare
Pages Functions. Payment is collected by Stripe (hosted checkout — you never handle card
data). **Fulfillment is manual:** each paid order shows up in your Stripe Dashboard with the
customer's shipping address and the exact item to reorder on Printify, so you keep the margin.

## Architecture
```
index.html ──▶ /api/catalog        products + prices (from functions/_catalog.js)
   │
   └─ buy ──▶ /api/checkout         creates a Stripe Checkout Session → redirects buyer
                     │
   Stripe ──────────┴──▶ /api/stripe-webhook   verifies payment, logs a fulfillment
                                                ticket to KV (optional). Nothing auto-orders.
   /api/orders?token=…              your private fulfillment queue (needs KV + ADMIN_TOKEN)
```

## 1. Set your real prices
Open `functions/_catalog.js` and adjust the numbers in each variant's `cents`
(e.g. `3900` = $39.00). These are **retail** prices — set them above your Printify cost.

## 2. Deploy
```bash
./deploy.sh          # builds dist/ (excludes big zips/video) and deploys to Pages
```
First deploy creates the `sidebush-art` Pages project.

## 3. Add Stripe keys (Cloudflare secrets)
Get keys from the Stripe Dashboard → Developers → API keys.
```bash
npx wrangler pages secret put STRIPE_SECRET_KEY --project-name sidebush-art
# paste sk_live_...  (use sk_test_... while testing)
```

## 4. Add the Stripe webhook
1. Stripe Dashboard → Developers → Webhooks → Add endpoint
2. URL: `https://sidebushart.com/api/stripe-webhook`
3. Event: `checkout.session.completed`
4. Copy the **Signing secret** (`whsec_...`) and store it:
```bash
npx wrangler pages secret put STRIPE_WEBHOOK_SECRET --project-name sidebush-art
```

## 5. (Optional) Fulfillment queue at /api/orders
```bash
npx wrangler kv namespace create ORDERS      # paste the id into wrangler.toml, uncomment the block
npx wrangler pages secret put ADMIN_TOKEN --project-name sidebush-art   # any long random string
```
Then view paid orders at `https://sidebushart.com/api/orders?token=YOUR_ADMIN_TOKEN`.
Without KV, you simply read orders in the Stripe Dashboard — the webhook still verifies payments.

## 6. Connect the domain
Cloudflare Dashboard → Workers & Pages → sidebush-art → Custom domains →
add `sidebushart.com` (and `www`). Works once the domain transfer/DNS is active.

## Your fulfillment flow per sale
1. Stripe emails you + shows the order (item, size, ship-to).
2. Reorder that exact item on Printify, ship to the customer's address.
3. Margin = your Stripe price − Printify cost.

## Test checklist
- `sk_test_` key + a `4242 4242 4242 4242` test card → completes checkout.
- Order appears in Stripe test Dashboard with shipping address + `fulfill` metadata.
- `?paid=1` returns to the site, cart clears, "Thank you" toast shows.
