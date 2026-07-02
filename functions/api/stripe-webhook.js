// POST /api/stripe-webhook — receives Stripe events.
// On a completed payment it logs a fulfillment ticket (what to reorder on Printify
// + where to ship) to KV, so you have a clean queue. Fulfillment stays MANUAL:
// nothing is auto-ordered — you place the Printify order yourself to protect margin.
//
// Requires env.STRIPE_WEBHOOK_SECRET. KV binding ORDERS is OPTIONAL — without it,
// the event is still verified and acknowledged (you'd read orders in the Stripe Dashboard).
import { verifyStripeSignature, json } from "../_stripe.js";

export async function onRequestPost({ request, env }) {
  const raw = await request.text();
  const sig = request.headers.get("stripe-signature");

  if (!env.STRIPE_WEBHOOK_SECRET) return json({ error: "Webhook secret not set." }, 501);
  const ok = await verifyStripeSignature(raw, sig, env.STRIPE_WEBHOOK_SECRET);
  if (!ok) return json({ error: "Invalid signature." }, 400);

  let event;
  try { event = JSON.parse(raw); } catch { return json({ error: "Bad payload." }, 400); }

  if (event.type === "checkout.session.completed") {
    const s = event.data.object;
    const ship = s.shipping_details || s.customer_details || {};
    const record = {
      status: "pending",
      session_id: s.id,
      created: new Date((s.created || Date.now() / 1000) * 1000).toISOString(),
      amount_total: s.amount_total,
      currency: s.currency,
      email: s.customer_details?.email || null,
      name: ship.name || s.customer_details?.name || null,
      phone: s.customer_details?.phone || null,
      ship_to: ship.address || null,
      fulfill: s.metadata?.fulfill || "(see Stripe Dashboard line items)",
    };
    if (env.ORDERS) {
      const key = `order:${Date.now()}:${s.id}`;
      await env.ORDERS.put(key, JSON.stringify(record));
    }
  }

  return json({ received: true });
}
