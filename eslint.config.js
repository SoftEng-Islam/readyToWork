import pluginVue from 'eslint-plugin-vue'
import { defineConfigWithVueTs, vueTsConfigs } from '@vue/eslint-config-typescript'
import skipFormatting from '@vue/eslint-config-prettier/skip-formatting'

export default defineConfigWithVueTs(
  {
    ignores: ['dist/**', 'coverage/**', 'node_modules/**'],
  },
  {
    name: 'commerce/app',
    files: ['src/**/*.{ts,vue}', 'vite.config.ts', 'drizzle.config.ts'],
    extends: [pluginVue.configs['flat/recommended'], vueTsConfigs.recommended],
    rules: {
      'vue/multi-word-component-names': 'off',
      '@typescript-eslint/consistent-type-imports': 'error',
    },
  },
  skipFormatting,
)
