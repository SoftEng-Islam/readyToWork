<script setup lang="ts">
import SectionHeading from '@/client/components/common/SectionHeading.vue'
</script>

<template>
  <section class="space-y-6">
    <SectionHeading
      eyebrow="Admin"
      title="Admin dashboard"
      description="This route is reserved for product management, orders, stock, and reporting."
    />

    <div class="grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
      <article class="rounded-3xl border border-white/10 bg-white/5 p-5">
        <p class="text-sm text-slate-400">Revenue</p>
        <p class="mt-2 text-2xl font-bold text-white">$24,820</p>
      </article>
      <article class="rounded-3xl border border-white/10 bg-white/5 p-5">
        <p class="text-sm text-slate-400">Orders</p>
        <p class="mt-2 text-2xl font-bold text-white">184</p>
      </article>
      <article class="rounded-3xl border border-white/10 bg-white/5 p-5">
        <p class="text-sm text-slate-400">Low stock</p>
        <p class="mt-2 text-2xl font-bold text-white">7</p>
      </article>
      <article class="rounded-3xl border border-white/10 bg-white/5 p-5">
        <p class="text-sm text-slate-400">Customers</p>
        <p class="mt-2 text-2xl font-bold text-white">1,248</p>
      </article>
    </div>
  </section>
</template>
