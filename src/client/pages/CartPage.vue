<script setup lang="ts">
import { RouterLink } from 'vue-router'
import BaseButton from '@/client/components/ui/BaseButton.vue'
import SectionHeading from '@/client/components/common/SectionHeading.vue'
import { useCartStore } from '@/client/stores/cart'
import { appRoutes } from '@/shared/constants/routes'
import { formatMoney } from '@/shared/utils/money'

const { items, subtotal, updateQuantity, removeItem, clearCart } = useCartStore()
</script>

<template>
  <section class="space-y-6">
    <SectionHeading
      eyebrow="Cart"
      title="Your cart"
      description="Keep cart state in Pinia and persist it with VueUse."
    />

    <div v-if="items.length > 0" class="space-y-4">
      <article
        v-for="item in items"
        :key="item.id"
        class="flex flex-col gap-4 rounded-3xl border border-white/10 bg-white/5 p-4 sm:flex-row sm:items-center"
      >
        <img :src="item.imageUrl" :alt="item.name" class="h-24 w-24 rounded-2xl object-cover" />

        <div class="flex-1">
          <h3 class="text-lg font-semibold text-white">{{ item.name }}</h3>
          <p class="text-sm text-slate-300">{{ formatMoney(item.price) }}</p>
        </div>

        <div class="flex items-center gap-3">
          <button
            type="button"
            class="rounded-full border border-white/10 px-3 py-1 text-white transition hover:bg-white/5"
            @click="updateQuantity(item.id, item.quantity - 1)"
          >
            -
          </button>
          <span class="min-w-8 text-center">{{ item.quantity }}</span>
          <button
            type="button"
            class="rounded-full border border-white/10 px-3 py-1 text-white transition hover:bg-white/5"
            @click="updateQuantity(item.id, item.quantity + 1)"
          >
            +
          </button>
        </div>

        <button
          type="button"
          class="rounded-full border border-white/10 px-4 py-2 text-sm text-white transition hover:bg-white/5"
          @click="removeItem(item.id)"
        >
          Remove
        </button>
      </article>

      <div class="flex flex-col gap-4 rounded-3xl border border-white/10 bg-white/5 p-5 sm:flex-row sm:items-center sm:justify-between">
        <div>
          <p class="text-sm text-slate-400">Subtotal</p>
          <p class="text-2xl font-bold text-white">{{ formatMoney(subtotal) }}</p>
        </div>

        <div class="flex flex-wrap gap-3">
          <BaseButton variant="secondary" @click="clearCart()">Clear cart</BaseButton>
          <RouterLink
            :to="appRoutes.checkout"
            class="rounded-full bg-sky-500 px-4 py-2 text-sm font-semibold text-slate-950 transition hover:bg-sky-400"
          >
            Checkout
          </RouterLink>
        </div>
      </div>
    </div>

    <div v-else class="rounded-3xl border border-white/10 bg-white/5 p-8 text-center">
      <p class="text-lg font-semibold text-white">Your cart is empty.</p>
      <RouterLink
        :to="appRoutes.catalog"
        class="mt-4 inline-flex rounded-full bg-sky-500 px-5 py-3 text-sm font-semibold text-slate-950 transition hover:bg-sky-400"
      >
        Browse products
      </RouterLink>
    </div>
  </section>
</template>
