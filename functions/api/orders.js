// GET /api/orders?token=ADMIN_TOKEN — your private fulfillment queue.
// Lists paid orders (newest first) with the exact Printify reorder list + ship-to address.
// Protected by env.ADMIN_TOKEN. Requires the ORDERS KV binding.
import { json } from "../_stripe.js";

export async function onRequestGet({ request, env }) {
  const token = new URL(request.url).searchParams.get("token") ||
    (request.headers.get("authorization") || "").replace(/^Bearer\s+/i, "");
  if (!env.ADMIN_TOKEN || token !== env.ADMIN_TOKEN) return json({ error: "Unauthorized." }, 401);
  if (!env.ORDERS) return json({ orders: [], note: "No ORDERS KV bound yet." });

  const list = await env.ORDERS.list({ prefix: "order:" });
  const orders = [];
  for (const k of list.keys.reverse()) {
    const v = await env.ORDERS.get(k.name);
    if (v) orders.push({ key: k.name, ...JSON.parse(v) });
  }
  return json({ count: orders.length, orders });
}
