import { Router } from 'express'
import asyncHandler from 'express-async-handler'
import { getProductBySlug, listProducts } from './products.service'

export const productsRouter = Router()

productsRouter.get(
  '/',
  asyncHandler(async (_req, res) => {
    res.json(listProducts())
  }),
)

productsRouter.get(
  '/:slug',
  asyncHandler(async (req, res) => {
    const slug = Array.isArray(req.params.slug) ? req.params.slug[0] : req.params.slug

    if (!slug) {
      res.status(400).json({
        message: 'Product slug is required',
      })
      return
    }

    const product = getProductBySlug(slug)

    if (!product) {
      res.status(404).json({
        message: 'Product not found',
      })
      return
    }

    res.json(product)
  }),
)
