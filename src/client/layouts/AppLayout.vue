<script setup lang="ts">
import AppHeader from '@/client/components/layout/AppHeader.vue'
</script>

<template>
  <div class="min-h-screen text-slate-100">
    <AppHeader />
    <main class="mx-auto w-full max-w-7xl px-4 py-6 sm:px-6 lg:px-8">
      <slot />
    </main>
  </div>
</template>
