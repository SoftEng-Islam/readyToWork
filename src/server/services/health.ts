import { env } from '@/server/config/env';
import { getMongoHealth } from '@/server/db/mongo';

export function getHealthSnapshot() {
  return {
    status: 'ok',
    service: env.APP_NAME,
    uptime: process.uptime(),
    mongo: getMongoHealth(),
  };
}
