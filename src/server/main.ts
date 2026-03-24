import type { Server } from 'node:http';
import { createApp } from './app';
import { env } from './config/env';
import { logger } from './config/logger';
import { pool } from './db/client';
import { connectMongo, disconnectMongo } from './db/mongo';

function closeServer(server: Server) {
  return new Promise<void>((resolve, reject) => {
    server.close((error) => {
      if (error) {
        reject(error);
        return;
      }

      resolve();
    });
  });
}

async function bootstrap() {
  const mongoConnection = await connectMongo();
  const app = await createApp();
  const server = app.listen(env.PORT, env.HOST, () => {
    logger.info(
      {
        port: env.PORT,
        host: env.HOST,
        mongo: mongoConnection
          ? {
              host: mongoConnection.host,
              name: mongoConnection.name,
            }
          : {
              enabled: false,
            },
      },
      'server started',
    );
  });
  let isShuttingDown = false;

  const shutdown = async (signal: NodeJS.Signals) => {
    if (isShuttingDown) {
      return;
    }

    isShuttingDown = true;
    logger.info({ signal }, 'shutdown requested');

    try {
      await closeServer(server);
      await Promise.allSettled([pool.end(), disconnectMongo()]);
      process.exit(0);
    } catch (error) {
      logger.error(error, 'graceful shutdown failed');
      process.exit(1);
    }
  };

  process.once('SIGINT', () => {
    void shutdown('SIGINT');
  });

  process.once('SIGTERM', () => {
    void shutdown('SIGTERM');
  });
}

void bootstrap().catch((error) => {
  logger.error(error, 'failed to start server');
  process.exit(1);
});
