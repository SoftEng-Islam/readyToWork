<script setup lang="ts">
import { computed, onMounted, ref } from 'vue';
import { autoAnimate } from '@formkit/auto-animate';
import { RouterLink } from 'vue-router';
import SectionHeading from '@/client/components/common/SectionHeading.vue';
import { useCatalogStore } from '@/client/stores/catalog';
import { useProducts } from '@/client/composables/useProducts';
import { formatMoney } from '@/shared/utils/money';

const listRef = ref<HTMLElement | null>(null);
const catalog = useCatalogStore();
const { products, loading, error, fetchProducts } = useProducts();

const categories = computed(() => [
  'all',
  ...new Set(products.value.map((product) => product.category)),
]);

const filteredProducts = computed(() =>
  products.value.filter((product) => {
    const searchTerm = catalog.search.value.trim().toLowerCase();
    const matchesSearch =
      searchTerm.length === 0 ||
      product.name.toLowerCase().includes(searchTerm) ||
      product.description.toLowerCase().includes(searchTerm);
    const matchesCategory =
      catalog.category.value === 'all' || product.category === catalog.category.value;

    return matchesSearch && matchesCategory;
  }),
);

onMounted(async () => {
  if (listRef.value) {
    autoAnimate(listRef.value);
  }

  await fetchProducts();
});
</script>

<template>
  <section class="space-y-6">
    <SectionHeading
      eyebrow="Catalog"
      title="Products"
      description="Browse the store catalog, filter by search, and open any product detail page."
    />

    <div class="grid gap-4 md:grid-cols-2">
      <label class="space-y-2">
        <span class="text-sm text-slate-300">Search</span>
        <input
          v-model="catalog.search"
          type="search"
          placeholder="Search products"
          class="w-full rounded-2xl border border-white/10 bg-white/5 px-4 py-3 text-white ring-0 outline-none placeholder:text-slate-500"
        />
      </label>

      <label class="space-y-2">
        <span class="text-sm text-slate-300">Category</span>
        <select
          v-model="catalog.category"
          class="w-full rounded-2xl border border-white/10 bg-white/5 px-4 py-3 text-white ring-0 outline-none"
        >
          <option v-for="category in categories" :key="category" :value="category">
            {{ category }}
          </option>
        </select>
      </label>
    </div>

    <p v-if="loading" class="text-sm text-slate-400">Loading products...</p>
    <p v-else-if="error" class="text-sm text-red-300">{{ error }}</p>

    <div ref="listRef" class="grid gap-4 md:grid-cols-2 xl:grid-cols-3">
      <article
        v-for="product in filteredProducts"
        :key="product.id"
        class="overflow-hidden rounded-3xl border border-white/10 bg-white/5 shadow-lg"
      >
        <img :src="product.imageUrl" :alt="product.name" class="h-56 w-full object-cover" />
        <div class="space-y-4 p-5">
          <div class="space-y-2">
            <p class="text-xs tracking-[0.3em] text-sky-400 uppercase">{{ product.category }}</p>
            <h3 class="text-xl font-semibold text-white">{{ product.name }}</h3>
            <p class="text-sm text-slate-300">{{ product.description }}</p>
          </div>
          <div class="flex items-center justify-between gap-3">
            <span class="text-lg font-bold text-white">{{ formatMoney(product.price) }}</span>
            <RouterLink
              :to="{ name: 'product-details', params: { slug: product.slug } }"
              class="rounded-full border border-white/10 px-4 py-2 text-sm font-medium text-white transition hover:bg-white/5"
            >
              View
            </RouterLink>
          </div>
        </div>
      </article>
    </div>
  </section>
</template>
