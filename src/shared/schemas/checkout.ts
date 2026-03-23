import { z } from 'zod'

export const checkoutSchema = z.object({
  fullName: z.string().min(2),
  email: z.string().email(),
  address: z.string().min(8),
  city: z.string().min(2),
  country: z.string().min(2),
  notes: z.string().max(500).optional().or(z.literal('')),
})

export type CheckoutInput = z.infer<typeof checkoutSchema>
