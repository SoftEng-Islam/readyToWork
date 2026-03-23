import type { Request, Response, NextFunction } from 'express';

export function errorHandler(error: unknown, _req: Request, res: Response, next: NextFunction) {
  void next;
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
