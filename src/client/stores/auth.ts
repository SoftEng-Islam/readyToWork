import { computed } from 'vue'
import { useStorage } from '@vueuse/core'

type AuthUser = {
  id: string
  name: string
  email: string
  role: 'customer' | 'admin'
}

type AuthSession = {
  token: string | null
  user: AuthUser | null
}

const session = useStorage<AuthSession>('commerce-session', {
  token: null,
  user: null,
})

export function useAuthStore() {
  const isSignedIn = computed(() => Boolean(session.value.token))

  function signIn(user: AuthUser, token: string) {
    session.value = { user, token }
  }

  function signOut() {
    session.value = { user: null, token: null }
  }

  return {
    session,
    isSignedIn,
    signIn,
    signOut,
  }
}
