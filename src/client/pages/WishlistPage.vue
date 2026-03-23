<script setup lang="ts">
import { RouterLink } from 'vue-router'
import SectionHeading from '@/client/components/common/SectionHeading.vue'
import { appRoutes } from '@/shared/constants/routes'
</script>

<template>
  <section class="space-y-6">
    <SectionHeading
      eyebrow="Wishlist"
      title="Saved items"
      description="Keep the wishlist page as its own route so it can grow without touching the catalog."
    />

    <div class="rounded-3xl border border-white/10 bg-white/5 p-8 text-center">
      <p class="text-white">No wishlist items yet.</p>
      <RouterLink
        :to="appRoutes.catalog"
        class="mt-4 inline-flex rounded-full bg-sky-500 px-5 py-3 text-sm font-semibold text-slate-950 transition hover:bg-sky-400"
      >
        Browse products
      </RouterLink>
    </div>
  </section>
</template>
