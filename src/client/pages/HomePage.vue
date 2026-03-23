<script setup lang="ts">
import { RouterLink } from 'vue-router'
import SectionHeading from '@/client/components/common/SectionHeading.vue'
import { appRoutes } from '@/shared/constants/routes'
</script>

<template>
  <section class="grid gap-8 lg:grid-cols-2 lg:items-center">
    <div class="space-y-6">
      <p class="text-sm uppercase tracking-[0.35em] text-sky-400">
        E-commerce starter
      </p>
      <h1 class="text-4xl font-semibold leading-tight text-white sm:text-6xl">
        Build storefronts, checkouts, and dashboards without starting from zero.
      </h1>
      <p class="max-w-xl text-slate-300">
        Vue 3, Express 5, GraphQL, Drizzle, Tailwind, DaisyUI, Better Auth, and the pieces you
        actually need for a real shop.
      </p>
      <div class="flex flex-wrap gap-3">
        <RouterLink
          :to="appRoutes.catalog"
          class="rounded-full bg-sky-500 px-5 py-3 text-sm font-semibold text-slate-950 transition hover:bg-sky-400"
        >
          Browse catalog
        </RouterLink>
        <RouterLink
          :to="appRoutes.checkout"
          class="rounded-full border border-white/10 px-5 py-3 text-sm font-semibold text-white transition hover:bg-white/5"
        >
          Go to checkout
        </RouterLink>
      </div>
    </div>

    <div class="rounded-3xl border border-white/10 bg-white/5 p-6 backdrop-blur">
      <SectionHeading
        eyebrow="Included"
        title="A practical e-commerce baseline"
        description="Client pages, server modules, database schema, shared validation, and a scaffold script that can generate the same structure anywhere."
      />
      <ul class="mt-6 grid gap-3 text-sm text-slate-300 sm:grid-cols-2">
        <li class="rounded-2xl border border-white/10 p-4">Product catalog and detail pages</li>
        <li class="rounded-2xl border border-white/10 p-4">Cart and checkout flow</li>
        <li class="rounded-2xl border border-white/10 p-4">Express API and GraphQL</li>
        <li class="rounded-2xl border border-white/10 p-4">Drizzle + PostgreSQL schema</li>
      </ul>
    </div>
  </section>
</template>
