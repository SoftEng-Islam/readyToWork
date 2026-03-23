<script setup lang="ts">
defineProps<{
  eyebrow?: string
  title: string
  description?: string
}>()
</script>

<template>
  <div class="space-y-2">
    <p v-if="eyebrow" class="text-xs uppercase tracking-[0.35em] text-sky-400">
      {{ eyebrow }}
    </p>
    <h2 class="text-2xl font-semibold text-white sm:text-3xl">
      {{ title }}
    </h2>
    <p v-if="description" class="max-w-2xl text-sm text-slate-300">
      {{ description }}
    </p>
  </div>
</template>
