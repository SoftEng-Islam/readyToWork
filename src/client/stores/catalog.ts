import { ref } from 'vue'

const search = ref('')
const category = ref('all')

export function useCatalogStore() {
  function reset() {
    search.value = ''
    category.value = 'all'
  }

  return {
    search,
    category,
    reset,
  }
}
