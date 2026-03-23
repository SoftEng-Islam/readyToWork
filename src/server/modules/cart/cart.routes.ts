import { Router } from 'express'
import asyncHandler from 'express-async-handler'

export const cartRouter = Router()

cartRouter.get(
  '/',
  asyncHandler(async (_req, res) => {
    res.json({
      items: [],
      message: 'Cart persistence can be added here.',
    })
  }),
)
