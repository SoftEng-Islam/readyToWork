import axios from 'axios'
import { ref } from 'vue'
import type { Product } from '@/shared/schemas/product'

const api = axios.create({
  baseURL: import.meta.env.VITE_API_BASE_URL ?? '/api',
})

export function useProducts() {
  const products = ref<Product[]>([])
  const product = ref<Product | null>(null)
  const loading = ref(false)
  const error = ref<string | null>(null)

  async function fetchProducts() {
    loading.value = true
    error.value = null

    try {
      const response = await api.get<Product[]>('/products')
      products.value = response.data
    } catch (err) {
      error.value = err instanceof Error ? err.message : 'Unable to load products.'
    } finally {
      loading.value = false
    }
  }

  async function fetchProductBySlug(slug: string) {
    loading.value = true
    error.value = null

    try {
      const response = await api.get<Product>(`/products/${slug}`)
      product.value = response.data
    } catch (err) {
      error.value = err instanceof Error ? err.message : 'Unable to load product details.'
      product.value = null
    } finally {
      loading.value = false
    }
  }

  return {
    products,
    product,
    loading,
    error,
    fetchProducts,
    fetchProductBySlug,
  }
}
