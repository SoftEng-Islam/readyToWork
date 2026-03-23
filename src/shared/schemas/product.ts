import { z } from 'zod'

export const productSchema = z.object({
  id: z.string(),
  slug: z.string(),
  name: z.string().min(1),
  description: z.string().min(1),
  price: z.number().nonnegative(),
  imageUrl: z.string().url(),
  category: z.string().min(1),
  stock: z.number().int().nonnegative(),
  isFeatured: z.boolean(),
  createdAt: z.string(),
})

export const createProductSchema = productSchema.omit({
  id: true,
  slug: true,
  createdAt: true,
})

export type Product = z.infer<typeof productSchema>
export type CreateProductInput = z.infer<typeof createProductSchema>
