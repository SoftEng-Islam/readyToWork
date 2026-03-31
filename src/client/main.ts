import 'animate.css'
import 'vue-toastification/dist/index.css'
import './styles/main.css'

import { MotionPlugin } from '@vueuse/motion'
import { createApp } from 'vue'
import Toast from 'vue-toastification'
import { createPinia } from 'pinia'
import App from './App.vue'
import router from './router'
import { useUiStore } from './stores/ui'

document.title = import.meta.env.VITE_APP_NAME ?? 'Commerce Starter'

const app = createApp(App)
const pinia = createPinia()

app.use(pinia)
app.use(router)
app.use(MotionPlugin)
app.use(Toast, {
  timeout: 2500,
  position: 'top-right',
})

useUiStore(pinia).initializeTheme()

app.mount('#app')
