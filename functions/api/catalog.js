// GET /api/catalog — public product catalog for the storefront (prices + variants).
import { publicCatalog } from "../_catalog.js";
import { json } from "../_stripe.js";

export function onRequestGet() {
  return json(
    { currency: "usd", products: publicCatalog() },
    200,
    { "Cache-Control": "public, max-age=300" }
  );
}
