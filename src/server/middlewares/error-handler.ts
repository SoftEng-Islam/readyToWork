import type { NextFunction, Request, Response } from 'express';
import { ZodError } from 'zod';

export function errorHandler(error: unknown, _req: Request, res: Response, next: NextFunction) {
  void next;

  if (error instanceof ZodError) {
    res.status(400).json({
      message: 'Validation failed',
      issues: error.flatten(),
    });
    return;
  }

  const message = error instanceof Error ? error.message : 'Unexpected server error';
  const errorStatusCode =
    error && typeof error === 'object' && 'statusCode' in error
      ? (error as { statusCode?: unknown }).statusCode
      : undefined;
  const statusCode = typeof errorStatusCode === 'number' ? errorStatusCode : 500;

  res.status(statusCode).json({
    message,
  });
}
