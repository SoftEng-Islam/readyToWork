import { listProducts } from '@/server/modules/products/products.service';
import { env } from '@/server/config/env';
import { getHealthSnapshot } from '@/server/services/health';

export const resolvers = {
  Query: {
    hello: () => 'Hello from ' + env.APP_NAME,
    health: () => getHealthSnapshot(),
    products: () => listProducts(),
  },
};
