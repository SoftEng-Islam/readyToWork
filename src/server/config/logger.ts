import pino from 'pino'
import { env } from './env'

const transport =
  env.NODE_ENV === 'production'
    ? undefined
    : {
        target: 'pino-pretty',
        options: {
          colorize: true,
        },
      }

export const logger = pino({
  level: env.NODE_ENV === 'production' ? 'info' : 'debug',
  ...(transport ? { transport } : {}),
})

export const httpStream = {
  write(message: string) {
    logger.info(message.trim())
  },
}
