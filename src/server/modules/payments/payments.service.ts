import Stripe from 'stripe';
import { env } from '@/server/config/env';
import { logger } from '@/server/config/logger';
import { getProductById } from '@/server/modules/products/products.service';
import { appRoutes } from '@/shared/constants/routes';
import type {
  CreateCheckoutSessionInput,
  StripeCheckoutSession,
  StripeCheckoutSessionSummary,
} from '@/shared/schemas/payments';

function createHttpError(message: string, statusCode: number) {
  return Object.assign(new Error(message), { statusCode });
}

let stripeClient: Stripe | null = null;

function getStripeClient() {
  if (!env.STRIPE_SECRET_KEY) {
    throw createHttpError(
      'Stripe is not configured. Set STRIPE_SECRET_KEY to enable checkout.',
      503,
    );
  }

  if (!stripeClient) {
    stripeClient = new Stripe(env.STRIPE_SECRET_KEY, {
      appInfo: {
        name: env.APP_NAME,
      },
    });
  }

  return stripeClient;
}

function buildCheckoutReturnUrl(result: 'success' | 'cancelled') {
  const url = new URL(appRoutes.checkout, env.FRONTEND_URL);

  url.searchParams.set('checkout', result);

  if (result === 'success') {
    url.searchParams.set('session_id', '{CHECKOUT_SESSION_ID}');
  }

  return url.toString();
}

function mapStripeAmount(amount: number | null | undefined) {
  return (amount ?? 0) / 100;
}

export function getStripeStatus() {
  return {
    provider: 'stripe',
    status: env.STRIPE_SECRET_KEY ? 'configured' : 'not-configured',
    checkoutMode: 'hosted',
    currency: env.STRIPE_CURRENCY,
    frontendUrl: env.FRONTEND_URL,
    webhookStatus: env.STRIPE_WEBHOOK_SECRET ? 'configured' : 'not-configured',
  };
}

export async function createStripeCheckoutSession(
  input: CreateCheckoutSessionInput,
): Promise<StripeCheckoutSession> {
  const stripe = getStripeClient();
  const lineItems: Stripe.Checkout.SessionCreateParams.LineItem[] = input.items.map((item) => {
    const product = getProductById(item.productId);

    if (!product) {
      throw createHttpError(`Unknown product id: ${item.productId}`, 400);
    }

    if (item.quantity > product.stock) {
      throw createHttpError(
        `Requested quantity for "${product.name}" exceeds available stock.`,
        400,
      );
    }

    return {
      quantity: item.quantity,
      price_data: {
        currency: env.STRIPE_CURRENCY,
        unit_amount: Math.round(product.price * 100),
        product_data: {
          name: product.name,
          description: product.description,
          images: [product.imageUrl],
          metadata: {
            productId: product.id,
            slug: product.slug,
            category: product.category,
          },
        },
      },
    };
  });

  const session = await stripe.checkout.sessions.create({
    mode: 'payment',
    success_url: buildCheckoutReturnUrl('success'),
    cancel_url: buildCheckoutReturnUrl('cancelled'),
    customer_email: input.email,
    billing_address_collection: 'auto',
    line_items: lineItems,
    metadata: {
      fullName: input.fullName,
      address: input.address,
      city: input.city,
      country: input.country,
      ...(input.notes ? { notes: input.notes } : {}),
    },
  });

  if (!session.url) {
    throw createHttpError('Stripe did not return a checkout URL.', 502);
  }

  return {
    id: session.id,
    url: session.url,
  };
}

export async function getStripeCheckoutSessionSummary(
  sessionId: string,
): Promise<StripeCheckoutSessionSummary> {
  const stripe = getStripeClient();
  const [session, lineItems] = await Promise.all([
    stripe.checkout.sessions.retrieve(sessionId),
    stripe.checkout.sessions.listLineItems(sessionId),
  ]);

  return {
    id: session.id,
    status: session.status ?? 'open',
    paymentStatus: session.payment_status,
    currency: session.currency ?? env.STRIPE_CURRENCY,
    amountTotal: mapStripeAmount(session.amount_total),
    customerEmail: session.customer_details?.email ?? session.customer_email ?? null,
    customerName: session.customer_details?.name ?? session.metadata?.fullName ?? null,
    lineItems: lineItems.data.map((item) => ({
      description: item.description ?? 'Stripe line item',
      quantity: item.quantity ?? 1,
      amountTotal: mapStripeAmount(item.amount_total),
      currency: item.currency ?? session.currency ?? env.STRIPE_CURRENCY,
    })),
  };
}

export function constructStripeWebhookEvent(payload: Buffer, signature: string | undefined) {
  if (!env.STRIPE_WEBHOOK_SECRET) {
    throw createHttpError(
      'Stripe webhook signing is not configured. Set STRIPE_WEBHOOK_SECRET to verify events.',
      503,
    );
  }

  if (!signature) {
    throw createHttpError('Missing Stripe-Signature header.', 400);
  }

  try {
    return getStripeClient().webhooks.constructEvent(payload, signature, env.STRIPE_WEBHOOK_SECRET);
  } catch (error) {
    throw createHttpError(
      error instanceof Error ? error.message : 'Invalid Stripe webhook payload.',
      400,
    );
  }
}

export async function processStripeWebhookEvent(event: Stripe.Event) {
  switch (event.type) {
    case 'checkout.session.completed':
    case 'checkout.session.async_payment_succeeded': {
      const session = event.data.object as Stripe.Checkout.Session;

      logger.info(
        {
          eventId: event.id,
          type: event.type,
          checkoutSessionId: session.id,
          customerEmail: session.customer_details?.email ?? session.customer_email ?? null,
          paymentStatus: session.payment_status,
        },
        'stripe checkout completed',
      );
      return;
    }

    case 'checkout.session.async_payment_failed':
    case 'checkout.session.expired': {
      const session = event.data.object as Stripe.Checkout.Session;

      logger.warn(
        {
          eventId: event.id,
          type: event.type,
          checkoutSessionId: session.id,
          paymentStatus: session.payment_status,
        },
        'stripe checkout requires attention',
      );
      return;
    }

    default:
      logger.debug({ eventId: event.id, type: event.type }, 'stripe webhook ignored');
  }
}
