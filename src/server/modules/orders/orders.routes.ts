import { Router } from 'express'
import asyncHandler from 'express-async-handler'

export const ordersRouter = Router()

ordersRouter.get(
  '/',
  asyncHandler(async (_req, res) => {
    res.json([
      {
        id: 'order-1024',
        status: 'delivered',
        total: 218.0,
      },
      {
        id: 'order-1025',
        status: 'processing',
        total: 89.0,
      },
    ])
  }),
)
