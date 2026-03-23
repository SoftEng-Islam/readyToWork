import argon2 from 'argon2'
import jwt from 'jsonwebtoken'
import { env } from './env'

export async function hashPassword(password: string) {
  return argon2.hash(password)
}

export async function verifyPassword(hash: string, password: string) {
  return argon2.verify(hash, password)
}

export function signSessionToken(payload: object) {
  return jwt.sign(payload, env.JWT_SECRET, { expiresIn: '7d' })
}
