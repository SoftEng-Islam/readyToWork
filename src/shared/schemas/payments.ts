import { z } from 'zod';
import { checkoutSchema } from './checkout';

export const checkoutCartItemSchema = z.object({
  productId: z.string().min(1),
  quantity: z.coerce.number().int().positive().max(99),
});

export const createCheckoutSessionSchema = checkoutSchema.extend({
  items: z.array(checkoutCartItemSchema).min(1),
});

export const stripeCheckoutSessionLineItemSchema = z.object({
  description: z.string(),
  quantity: z.number().int().positive(),
  amountTotal: z.number().nonnegative(),
  currency: z.string(),
});

export const stripeCheckoutSessionSchema = z.object({
  id: z.string(),
  url: z.string().url(),
});

export const stripeCheckoutSessionSummarySchema = z.object({
  id: z.string(),
  status: z.string(),
  paymentStatus: z.string(),
  currency: z.string(),
  amountTotal: z.number().nonnegative(),
  customerEmail: z.string().email().nullable(),
  customerName: z.string().nullable(),
  lineItems: z.array(stripeCheckoutSessionLineItemSchema),
});

export type CheckoutCartItem = z.infer<typeof checkoutCartItemSchema>;
export type CreateCheckoutSessionInput = z.infer<typeof createCheckoutSessionSchema>;
export type StripeCheckoutSession = z.infer<typeof stripeCheckoutSessionSchema>;
export type StripeCheckoutSessionSummary = z.infer<typeof stripeCheckoutSessionSummarySchema>;
