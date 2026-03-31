# Stripe Checkout

This project now supports hosted Stripe Checkout.

## What Is Implemented Here

The current integration uses Stripe-hosted Checkout, not Stripe Elements.

Flow in this repo:

1. The checkout page validates customer data in the Vue app.
2. The frontend sends the cart item ids and quantities to the backend.
3. The backend creates a Stripe Checkout Session with server-side product data.
4. The browser redirects to the Stripe-hosted payment page.
5. Stripe redirects back to the frontend after success or cancel.
6. The frontend fetches the Checkout Session summary and clears the cart after a paid session.
7. The backend can verify webhook events on `/api/payments/webhook`.

Relevant project files:

- [Checkout page](../src/client/pages/CheckoutPage.vue)
- [Payment routes](../src/server/modules/payments/payments.routes.ts)
- [Payment service](../src/server/modules/payments/payments.service.ts)
- [Payment schemas](../src/shared/schemas/payments.ts)
- [Environment config](../src/server/config/env.ts)

## Endpoints In This Project

Implemented routes:

- `GET /api/payments`
- `POST /api/payments/checkout-session`
- `GET /api/payments/checkout-session/:sessionId`
- `POST /api/payments/webhook`

Behavior:

- `GET /api/payments` reports whether Stripe is configured.
- `POST /api/payments/checkout-session` creates a hosted Checkout Session and returns the redirect URL.
- `GET /api/payments/checkout-session/:sessionId` fetches the Stripe session summary after redirect.
- `POST /api/payments/webhook` verifies Stripe webhook signatures and handles Checkout events.

## Environment Variables

Add these to `.env`:

```env
FRONTEND_URL=http://localhost:3000
STRIPE_SECRET_KEY=sk_test_...
STRIPE_WEBHOOK_SECRET=whsec_...
STRIPE_CURRENCY=usd
```

Meaning:

- `FRONTEND_URL`: where Stripe should send the customer back after checkout
- `STRIPE_SECRET_KEY`: required to create Checkout Sessions and read them back
- `STRIPE_WEBHOOK_SECRET`: required to verify webhook signatures safely
- `STRIPE_CURRENCY`: currency used when this app builds Stripe line items

## How To Run It Locally

1. Start the app:

```bash
pnpm dev
```

2. Put Stripe test keys in `.env`.

3. Add products to the cart from the catalog.

4. Open the checkout page and submit the form.

5. You should be redirected to a Stripe-hosted checkout page.

6. After payment, Stripe redirects back to:

```text
http://localhost:5173/checkout?checkout=success&session_id=...
```

The frontend then calls the backend to load the Checkout Session summary and clears the cart if the payment status is `paid`.

## How Webhooks Work Here

This project verifies webhook signatures using `STRIPE_WEBHOOK_SECRET`.

The webhook handler currently logs these events:

- `checkout.session.completed`
- `checkout.session.async_payment_succeeded`
- `checkout.session.async_payment_failed`
- `checkout.session.expired`

Right now the webhook handler logs and acknowledges the event. That is enough to prove the integration path works and gives you the place to add order fulfillment later.

## Testing Locally With Stripe CLI

Use the Stripe CLI to forward events to your local webhook endpoint:

```bash
stripe listen --events checkout.session.completed,checkout.session.async_payment_succeeded,checkout.session.async_payment_failed,checkout.session.expired --forward-to localhost:3000/api/payments/webhook
```

Stripe prints a signing secret when `stripe listen` starts. Copy that value into:

```env
STRIPE_WEBHOOK_SECRET=whsec_...
```

If you want to inspect logs while testing:

```bash
stripe logs tail
```

## Test Cards

Useful Stripe test cards from the official docs:

- `4242 4242 4242 4242`: successful payment
- `4000 0000 0000 3220`: requires 3D Secure for a successful payment
- `4000 0000 0000 9995`: always declines with `insufficient_funds`

Use any future expiry date and any valid CVC while testing in test mode.

## Important Notes About This Integration

- This project creates Stripe line items from server-side product data, not the raw cart prices from the browser.
- The current product catalog is still seeded demo data, so Stripe prices are built dynamically from that seed list.
- Webhooks are the reliable place to fulfill orders. The success redirect is useful for immediate UX, but it should not be your only fulfillment signal.
- The current implementation does not persist orders yet. It verifies payments and gives you the integration points to add order creation next.

## Recommended Next Steps

- Persist successful Stripe sessions into an `orders` table.
- Save purchased line items and customer details after `checkout.session.completed`.
- Send confirmation emails from the webhook flow.
- Add inventory reservation and release logic around `checkout.session.completed` and `checkout.session.expired`.

## Official Stripe References

Primary sources used for this guide:

- https://docs.stripe.com/checkout/quickstart
- https://docs.stripe.com/payments/checkout
- https://docs.stripe.com/payments/checkout/how-checkout-works
- https://docs.stripe.com/api/checkout/sessions
- https://docs.stripe.com/checkout/fulfillment
- https://docs.stripe.com/stripe-cli/use-cli
- https://docs.stripe.com/testing
