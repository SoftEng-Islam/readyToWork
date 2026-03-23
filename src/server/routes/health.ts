import { Router } from 'express'
import asyncHandler from 'express-async-handler'
import { env } from '@/server/config/env'

export const healthRouter = Router()

healthRouter.get(
  '/',
  asyncHandler(async (_req, res) => {
    res.json({
      status: 'ok',
      service: env.APP_NAME,
      uptime: process.uptime(),
    })
  }),
)
