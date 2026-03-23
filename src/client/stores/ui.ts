import { useDark, useToggle } from '@vueuse/core'

export function useUiStore() {
  const isDark = useDark()
  const toggleTheme = useToggle(isDark)

  return {
    isDark,
    toggleTheme,
  }
}
