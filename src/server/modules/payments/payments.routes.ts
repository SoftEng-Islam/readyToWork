import { Router } from 'express'
import asyncHandler from 'express-async-handler'

export const paymentsRouter = Router()

paymentsRouter.get(
  '/',
  asyncHandler(async (_req, res) => {
    res.json({
      provider: 'stripe',
      status: 'not-configured',
    })
  }),
)
