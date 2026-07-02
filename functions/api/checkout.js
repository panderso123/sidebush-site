// POST /api/checkout — create a Stripe Checkout Session from a cart.
// Body: { items: [ { id, format, size, qty } ] }
// Returns: { url } to redirect the buyer to Stripe's hosted checkout.
import { CATALOG, getVariant } from "../_catalog.js";
import { stripeRequest, json } from "../_stripe.js";

// Countries you're willing to ship to (Printify supports worldwide; trim as you like).
const SHIP_COUNTRIES = ["US", "CA", "GB", "AU", "DE", "FR", "IE", "NZ", "NL", "SE", "ES", "IT"];

export async function onRequestPost({ request, env }) {
  if (!env.STRIPE_SECRET_KEY) {
    return json({ error: "Checkout not configured yet. Set STRIPE_SECRET_KEY in Cloudflare." }, 501);
  }

  let payload;
  try {
    payload = await request.json();
  } catch {
    return json({ error: "Invalid JSON body." }, 400);
  }

  const items = Array.isArray(payload?.items) ? payload.items : [];
  if (items.length === 0) return json({ error: "Cart is empty." }, 400);

  const origin = new URL(request.url).origin;
  const line_items = [];
  const fulfill = [];

  for (const it of items) {
    const variant = getVariant(it.id, it.format, it.size);
    if (!variant) return json({ error: `Unknown item: ${it.id} ${it.format} ${it.size}` }, 400);
    const qty = Math.max(1, Math.min(20, parseInt(it.qty, 10) || 1));
    const product = CATALOG[it.id];
    const imageUrl = product?.image ? `${origin}/${product.image.replace(/^\//, "")}` : undefined;

    line_items.push({
      quantity: qty,
      price_data: {
        currency: "usd",
        unit_amount: variant.cents,
        product_data: {
          name: `${product.title} — ${variant.label}`,
          description: variant.fulfill, // exactly what to reorder on Printify
          images: imageUrl ? [imageUrl] : undefined,
          metadata: { sku: it.id, format: variant.format, size: variant.size },
        },
      },
    });
    fulfill.push(`${qty}× ${variant.fulfill}`);
  }

  const session = await stripeRequest(env.STRIPE_SECRET_KEY, "checkout/sessions", {
    mode: "payment",
    line_items,
    success_url: `${origin}/?paid=1&session_id={CHECKOUT_SESSION_ID}#home`,
    cancel_url: `${origin}/?canceled=1#home`,
    shipping_address_collection: { allowed_countries: SHIP_COUNTRIES },
    phone_number_collection: { enabled: true },
    billing_address_collection: "auto",
    // Surfaces the exact Printify reorder list in the Stripe Dashboard + your notification email.
    metadata: { fulfill: fulfill.join(" | ").slice(0, 490) },
  });

  return json({ url: session.url });
}
