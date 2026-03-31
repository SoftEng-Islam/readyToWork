import express from 'express';
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

  app.disable('x-powered-by');
  app.use(helmet());
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

  app.use(env.API_PREFIX, notFound);
  app.use(errorHandler);

  return app;
}
