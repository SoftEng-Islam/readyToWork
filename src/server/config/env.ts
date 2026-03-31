import 'dotenv/config';
import { z } from 'zod';

const envSchema = z.object({
  NODE_ENV: z.enum(['development', 'test', 'production']).default('development'),
  PORT: z.coerce.number().int().positive().default(3000),
  HOST: z.string().default('0.0.0.0'),
  APP_NAME: z.string().default('Commerce Starter'),
  FRONTEND_URL: z.string().url().default('http://localhost:3000'),
  API_PREFIX: z.string().default('/api'),
  GRAPHQL_PATH: z.string().default('/graphql'),
  DATABASE_URL: z.string().min(1).default('postgresql://postgres:postgres@localhost:5432/commerce'),
  BETTER_AUTH_SECRET: z.string().min(16).default('change-me-in-production'),
  BETTER_AUTH_URL: z.string().url().default('http://localhost:3000'),
  JWT_SECRET: z.string().min(16).default('change-me-in-production'),
  REDIS_URL: z.string().optional(),
  MONGODB_URI: z.string().optional(),
  STRIPE_SECRET_KEY: z.string().min(1).optional(),
  STRIPE_WEBHOOK_SECRET: z.string().min(1).optional(),
  STRIPE_CURRENCY: z.string().default('usd'),
});

export const env = envSchema.parse(process.env);
