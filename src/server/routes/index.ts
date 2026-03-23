import { Router } from 'express'
import { healthRouter } from './health'
import { authRouter } from '@/server/modules/auth/auth.routes'
import { productsRouter } from '@/server/modules/products/products.routes'
import { cartRouter } from '@/server/modules/cart/cart.routes'
import { ordersRouter } from '@/server/modules/orders/orders.routes'
import { paymentsRouter } from '@/server/modules/payments/payments.routes'

export const apiRouter = Router()

apiRouter.use('/health', healthRouter)
apiRouter.use('/auth', authRouter)
apiRouter.use('/products', productsRouter)
apiRouter.use('/cart', cartRouter)
apiRouter.use('/orders', ordersRouter)
apiRouter.use('/payments', paymentsRouter)
