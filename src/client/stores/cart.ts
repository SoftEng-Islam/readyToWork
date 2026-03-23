import { computed } from 'vue'
import { useStorage } from '@vueuse/core'
import { formatMoney } from '@/shared/utils/money'

type CartItem = {
  id: string
  name: string
  price: number
  quantity: number
  imageUrl: string
}

const items = useStorage<CartItem[]>('commerce-cart', [])

export function useCartStore() {
  const totalItems = computed(() => items.value.reduce((sum, item) => sum + item.quantity, 0))
  const subtotal = computed(() =>
    items.value.reduce((sum, item) => sum + item.price * item.quantity, 0),
  )
  const subtotalLabel = computed(() => formatMoney(subtotal.value))

  function addItem(item: CartItem) {
    const existingItem = items.value.find((entry) => entry.id === item.id)

    if (existingItem) {
      existingItem.quantity += item.quantity
      return
    }

    items.value.push(item)
  }

  function updateQuantity(id: string, quantity: number) {
    const index = items.value.findIndex((item) => item.id === id)

    if (index === -1) {
      return
    }

    if (quantity <= 0) {
      items.value.splice(index, 1)
      return
    }

    const item = items.value[index]

    if (!item) {
      return
    }

    item.quantity = quantity
  }

  function removeItem(id: string) {
    items.value = items.value.filter((item) => item.id !== id)
  }

  function clearCart() {
    items.value = []
  }

  return {
    items,
    totalItems,
    subtotal,
    subtotalLabel,
    addItem,
    updateQuantity,
    removeItem,
    clearCart,
  }
}
