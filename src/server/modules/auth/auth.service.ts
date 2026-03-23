import { randomUUID } from 'node:crypto'
import { hashPassword, signSessionToken, verifyPassword } from '@/server/config/auth'

export type AuthSession = {
  token: string
  user: {
    id: string
    name: string
    email: string
    role: 'customer' | 'admin'
  }
}

export async function createDemoSession(email: string, name = 'Demo Shopper'): Promise<AuthSession> {
  const user = {
    id: randomUUID(),
    name,
    email,
    role: 'customer' as const,
  }

  return {
    token: signSessionToken({ sub: user.id, email: user.email, role: user.role }),
    user,
  }
}

export async function createPasswordRecord(password: string) {
  return hashPassword(password)
}

export async function verifyPasswordRecord(hash: string, password: string) {
  return verifyPassword(hash, password)
}
