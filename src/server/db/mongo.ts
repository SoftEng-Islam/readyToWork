import mongoose from 'mongoose';
import { env } from '@/server/config/env';

const mongoStateMap = {
  0: 'disconnected',
  1: 'connected',
  2: 'connecting',
  3: 'disconnecting',
} as const;

let mongoConnectPromise: Promise<typeof mongoose> | null = null;

export type MongoConnectionState =
  | 'disabled'
  | (typeof mongoStateMap)[keyof typeof mongoStateMap]
  | 'unknown';

export type MongoHealth = {
  enabled: boolean;
  state: MongoConnectionState;
  host: string | null;
  name: string | null;
};

export async function connectMongo() {
  if (!env.MONGODB_URI) {
    return null;
  }

  if (mongoose.connection.readyState === 1) {
    return mongoose.connection;
  }

  if (!mongoConnectPromise) {
    mongoConnectPromise = mongoose.connect(env.MONGODB_URI, {
      serverSelectionTimeoutMS: 5000,
    });
  }

  try {
    await mongoConnectPromise;
    return mongoose.connection;
  } catch (error) {
    mongoConnectPromise = null;
    throw error;
  }
}

export async function disconnectMongo() {
  mongoConnectPromise = null;

  if (mongoose.connection.readyState === 0) {
    return;
  }

  await mongoose.disconnect();
}

export function getMongoHealth(): MongoHealth {
  const isEnabled = Boolean(env.MONGODB_URI);

  return {
    enabled: isEnabled,
    state: isEnabled
      ? (mongoStateMap[mongoose.connection.readyState as keyof typeof mongoStateMap] ?? 'unknown')
      : 'disabled',
    host: mongoose.connection.host || null,
    name: mongoose.connection.name || null,
  };
}
