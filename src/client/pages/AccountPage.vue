<script setup lang="ts">
import BaseButton from '@/client/components/ui/BaseButton.vue'
import SectionHeading from '@/client/components/common/SectionHeading.vue'
import { useAuthStore } from '@/client/stores/auth'

const { session, isSignedIn, signIn, signOut } = useAuthStore()

function signInDemo() {
  signIn(
    {
      id: 'demo-user',
      name: 'Demo Shopper',
      email: 'demo@store.dev',
      role: 'customer',
    },
    'demo-token',
  )
}
</script>

<template>
  <section class="space-y-6">
    <SectionHeading
      eyebrow="Account"
      title="Account"
      description="A lightweight session store that can later be wired to Better Auth or JWT flows."
    />

    <div v-if="isSignedIn" class="space-y-4 rounded-3xl border border-white/10 bg-white/5 p-6">
      <p class="text-white">
        Signed in as <strong>{{ session.user?.name }}</strong>
      </p>
      <p class="text-sm text-slate-300">{{ session.user?.email }}</p>
      <BaseButton variant="secondary" @click="signOut()">Sign out</BaseButton>
    </div>

    <div v-else class="space-y-4 rounded-3xl border border-white/10 bg-white/5 p-6">
      <p class="text-white">This scaffold uses a demo session to show the account flow.</p>
      <BaseButton @click="signInDemo">Sign in as demo user</BaseButton>
    </div>
  </section>
</template>
