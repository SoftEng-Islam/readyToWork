import type { RequestHandler } from 'express';
import { Router } from 'express';
import asyncHandler from 'express-async-handler';
import { createCheckoutSessionSchema } from '@/shared/schemas/payments';
import {
  constructStripeWebhookEvent,
  createStripeCheckoutSession,
  getStripeCheckoutSessionSummary,
  getStripeStatus,
  processStripeWebhookEvent,
} from './payments.service';

export const paymentsRouter = Router();

paymentsRouter.get(
  '/',
  asyncHandler(async (_req, res) => {
    res.json(getStripeStatus());
  }),
);

paymentsRouter.post(
  '/checkout-session',
  asyncHandler(async (req, res) => {
    const body = createCheckoutSessionSchema.parse(req.body);
    const session = await createStripeCheckoutSession(body);

    res.status(201).json({
      data: session,
      message: 'Stripe checkout session created.',
    });
  }),
);

paymentsRouter.get(
  '/checkout-session/:sessionId',
  asyncHandler(async (req, res) => {
    const sessionId = Array.isArray(req.params.sessionId)
      ? req.params.sessionId[0]
      : req.params.sessionId;

    if (!sessionId) {
      res.status(400).json({
        message: 'Checkout session id is required.',
      });
      return;
    }

    const session = await getStripeCheckoutSessionSummary(sessionId);

    res.json({
      data: session,
      message: 'Stripe checkout session retrieved.',
    });
  }),
);

export const paymentsWebhookHandler: RequestHandler = asyncHandler(async (req, res) => {
  if (!Buffer.isBuffer(req.body)) {
    res.status(400).json({
      message: 'Stripe webhook requires the raw request body.',
    });
    return;
  }

  const event = constructStripeWebhookEvent(req.body, req.header('stripe-signature') ?? undefined);

  await processStripeWebhookEvent(event);

  res.json({ received: true });
});
