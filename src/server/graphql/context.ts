import type { Request, Response } from 'express'
import { db } from '@/server/db/client'

export type GraphQLContext = {
  req: Request
  res: Response
  db: typeof db
}

export function createGraphQLContext(req: Request, res: Response): GraphQLContext {
  return {
    req,
    res,
    db,
  }
}
