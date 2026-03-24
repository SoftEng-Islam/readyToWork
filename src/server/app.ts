import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';
import { env } from './config/env';
import { httpStream } from './config/logger';
import { registerGraphQL } from './graphql';
import { paymentsWebhookHandler } from './modules/payments/payments.routes';
import { apiRouter } from './routes';
import { errorHandler } from './middlewares/error-handler';
import { notFound } from './middlewares/not-found';

export async function createApp() {
  const app = express();
  const allowedOrigins = env.CORS_ORIGIN.split(',')
    .map((origin) => origin.trim())
    .filter(Boolean);

  const isLocalDevOrigin = (origin: string) =>
    env.NODE_ENV !== 'production' && /^https?:\/\/(localhost|127\.0\.0\.1)(:\d+)?$/.test(origin);

  app.disable('x-powered-by');
  app.use(helmet());
  app.use(
    cors({
      origin(origin, callback) {
        if (!origin || allowedOrigins.includes(origin) || isLocalDevOrigin(origin)) {
          callback(null, true);
          return;
        }

        callback(new Error(`CORS blocked for origin: ${origin}`));
      },
      credentials: true,
    }),
  );
  app.post(
    `${env.API_PREFIX}/payments/webhook`,
    express.raw({ type: 'application/json' }),
    paymentsWebhookHandler,
  );
  app.use(express.json());
  app.use(express.urlencoded({ extended: true }));
  app.use(morgan(env.NODE_ENV === 'production' ? 'combined' : 'dev', { stream: httpStream }));
  app.use(env.API_PREFIX, apiRouter);

  await registerGraphQL(app);

  app.use(notFound);
  app.use(errorHandler);

  return app;
}
