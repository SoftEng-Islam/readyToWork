<script setup lang="ts">
import { RouterLink } from 'vue-router'
import { appRoutes } from '@/shared/constants/routes'
import { useAuthStore } from '@/client/stores/auth'
import { useCartStore } from '@/client/stores/cart'
import { useUiStore } from '@/client/stores/ui'

const { session, isSignedIn } = useAuthStore()
const { totalItems } = useCartStore()
const ui = useUiStore();

const brandName = import.meta.env.VITE_APP_NAME ?? 'Commerce Starter'
</script>

<template>
  <header class="border-b border-white/10 bg-slate-950/80 backdrop-blur">
    <div class="mx-auto flex w-full max-w-7xl items-center justify-between gap-4 px-4 py-4 sm:px-6 lg:px-8">
      <RouterLink :to="appRoutes.home" class="text-lg font-semibold tracking-wide text-white">
        {{ brandName }}
      </RouterLink>

      <nav class="flex flex-wrap items-center gap-4 text-sm text-slate-300">
        <RouterLink :to="appRoutes.catalog" class="transition hover:text-white">
          Catalog
        </RouterLink>
        <RouterLink :to="appRoutes.wishlist" class="transition hover:text-white">
          Wishlist
        </RouterLink>
        <RouterLink :to="appRoutes.cart" class="transition hover:text-white">
          Cart ({{ totalItems }})
        </RouterLink>
        <RouterLink :to="appRoutes.orders" class="transition hover:text-white">
          Orders
        </RouterLink>
        <RouterLink :to="appRoutes.account" class="transition hover:text-white">
          {{ isSignedIn ? 'Account' : 'Sign in' }}
        </RouterLink>
        <RouterLink v-if="session.user?.role === 'admin'" :to="appRoutes.admin" class="transition hover:text-white">
          Admin
        </RouterLink>
        <button type="button" class="rounded-full border border-white/10 px-3 py-1 transition hover:bg-white/5" @click="ui.toggleTheme()">
          {{ ui.themeToggleLabel }}
        </button>
      </nav>
    </div>
  </header>
</template>
