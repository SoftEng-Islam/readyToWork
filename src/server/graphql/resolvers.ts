import { env } from '@/server/config/env'
import { listProducts } from '@/server/modules/products/products.service'

export const resolvers = {
  Query: {
    hello: () => 'Hello from ' + env.APP_NAME,
    health: () => ({
      status: 'ok',
      uptime: process.uptime(),
    }),
    products: () => listProducts(),
  },
}
