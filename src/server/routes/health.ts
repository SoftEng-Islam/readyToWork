import { Router } from 'express';
import asyncHandler from 'express-async-handler';
import { getHealthSnapshot } from '@/server/services/health';

export const healthRouter = Router();

healthRouter.get(
  '/',
  asyncHandler(async (_req, res) => {
    res.json(getHealthSnapshot());
  }),
);
