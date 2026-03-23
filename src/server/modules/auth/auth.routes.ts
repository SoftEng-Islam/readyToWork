import { Router } from 'express'
import asyncHandler from 'express-async-handler'
import { loginSchema } from '@/shared/schemas/auth'
import { createDemoSession } from './auth.service'

export const authRouter = Router()

authRouter.post(
  '/login',
  asyncHandler(async (req, res) => {
    const body = loginSchema.parse(req.body)
    const session = await createDemoSession(body.email, 'Demo Shopper')

    res.json({
      data: session,
      message: 'Demo login completed.',
    })
  }),
)

authRouter.get(
  '/session',
  asyncHandler(async (_req, res) => {
    res.json({
      data: null,
      message: 'No active session in the scaffold yet.',
    })
  }),
)
