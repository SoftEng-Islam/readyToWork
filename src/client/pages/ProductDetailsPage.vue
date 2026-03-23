<script setup lang="ts">
import { computed, onMounted } from 'vue'
import { useRoute, RouterLink } from 'vue-router'
import BaseButton from '@/client/components/ui/BaseButton.vue'
import SectionHeading from '@/client/components/common/SectionHeading.vue'
import { useCartStore } from '@/client/stores/cart'
import { useProducts } from '@/client/composables/useProducts'
import { appRoutes } from '@/shared/constants/routes'
import { formatMoney } from '@/shared/utils/money'

const route = useRoute()
const cart = useCartStore()
const { product, loading, error, fetchProductBySlug } = useProducts()

const slug = computed(() => String(route.params.slug ?? ''))

onMounted(() => {
  void fetchProductBySlug(slug.value)
})

function addToCart() {
  if (!product.value) {
    return
  }

  cart.addItem({
    id: product.value.id,
    name: product.value.name,
    price: product.value.price,
    quantity: 1,
    imageUrl: product.value.imageUrl,
  })
}
</script>

<template>
  <section class="space-y-6">
    <SectionHeading eyebrow="Product" title="Product details" />

    <p v-if="loading" class="text-sm text-slate-400">Loading product...</p>
    <p v-else-if="error" class="text-sm text-red-300">{{ error }}</p>

    <article
      v-else-if="product"
      class="grid gap-6 overflow-hidden rounded-3xl border border-white/10 bg-white/5 lg:grid-cols-[1.2fr_0.8fr]"
    >
      <img
        :src="product.imageUrl"
        :alt="product.name"
        class="h-full min-h-[24rem] w-full object-cover"
      />

      <div class="space-y-5 p-6">
        <p class="text-xs uppercase tracking-[0.3em] text-sky-400">{{ product.category }}</p>
        <h1 class="text-3xl font-semibold text-white">{{ product.name }}</h1>
        <p class="text-slate-300">{{ product.description }}</p>

        <div class="flex items-center gap-3">
          <span class="text-2xl font-bold text-white">{{ formatMoney(product.price) }}</span>
          <span class="rounded-full border border-white/10 px-3 py-1 text-xs text-slate-300">
            Stock: {{ product.stock }}
          </span>
        </div>

        <div class="flex flex-wrap gap-3">
          <BaseButton @click="addToCart">Add to cart</BaseButton>
          <RouterLink
            :to="appRoutes.cart"
            class="rounded-full border border-white/10 px-4 py-2 text-sm font-medium text-white transition hover:bg-white/5"
          >
            View cart
          </RouterLink>
        </div>
      </div>
    </article>
  </section>
</template>
