import { createApp } from './app'
import { env } from './config/env'
import { logger } from './config/logger'

async function bootstrap() {
  const app = await createApp()

  app.listen(env.PORT, env.HOST, () => {
    logger.info(
      {
        port: env.PORT,
        host: env.HOST,
      },
      'server started',
    )
  })
}

void bootstrap().catch((error) => {
  logger.error(error, 'failed to start server')
  process.exit(1)
})
