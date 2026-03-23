import 'animate.css'
import 'vue-toastification/dist/index.css'
import './styles/main.css'

import { MotionPlugin } from '@vueuse/motion'
import { createApp } from 'vue'
import Toast from 'vue-toastification'
import { createPinia } from 'pinia'
import App from './App.vue'
import router from './router'

document.title = import.meta.env.VITE_APP_NAME ?? 'Commerce Starter'

const app = createApp(App)

app.use(createPinia())
app.use(router)
app.use(MotionPlugin)
app.use(Toast, {
  timeout: 2500,
  position: 'top-right',
})

app.mount('#app')
