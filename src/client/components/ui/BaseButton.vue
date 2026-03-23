<script setup lang="ts">
import { computed } from 'vue'

type ButtonVariant = 'primary' | 'secondary' | 'ghost'

const props = withDefaults(
  defineProps<{
    variant?: ButtonVariant
    type?: 'button' | 'submit' | 'reset'
  }>(),
  {
    variant: 'primary',
    type: 'button',
  },
)

const variantClasses: Record<ButtonVariant, string> = {
  primary: 'bg-sky-500 text-slate-950 hover:bg-sky-400',
  secondary: 'border border-white/10 bg-white/5 text-white hover:bg-white/10',
  ghost: 'text-slate-200 hover:bg-white/5',
}

const classes = computed(() => [
  'inline-flex items-center justify-center rounded-full px-4 py-2 text-sm font-medium transition',
  variantClasses[props.variant],
])
</script>

<template>
  <button :type="type" :class="classes">
    <slot />
  </button>
</template>
