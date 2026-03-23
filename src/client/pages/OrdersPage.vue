<script setup lang="ts">
import SectionHeading from '@/client/components/common/SectionHeading.vue'
</script>

<template>
  <section class="space-y-6">
    <SectionHeading
      eyebrow="Orders"
      title="Order history"
      description="This page is ready for order timelines, invoices, and return flows."
    />

    <div class="grid gap-4 md:grid-cols-2">
      <article class="rounded-3xl border border-white/10 bg-white/5 p-6">
        <h3 class="text-lg font-semibold text-white">Sample order #1024</h3>
        <p class="mt-2 text-sm text-slate-300">Delivered, 3 items, paid by card.</p>
      </article>
      <article class="rounded-3xl border border-white/10 bg-white/5 p-6">
        <h3 class="text-lg font-semibold text-white">Sample order #1025</h3>
        <p class="mt-2 text-sm text-slate-300">Processing, 1 item, awaiting shipment.</p>
      </article>
    </div>
  </section>
</template>
