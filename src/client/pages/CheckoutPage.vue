<script setup lang="ts">
import { useToast } from 'vue-toastification'
import { useForm } from 'vee-validate'
import SectionHeading from '@/client/components/common/SectionHeading.vue'
import BaseButton from '@/client/components/ui/BaseButton.vue'
import { useCartStore } from '@/client/stores/cart'
import { checkoutSchema } from '@/shared/schemas/checkout'
import { formatMoney } from '@/shared/utils/money'

const { items, subtotalLabel, clearCart } = useCartStore()
const toast = useToast()

const initialValues = {
  fullName: '',
  email: '',
  address: '',
  city: '',
  country: '',
  notes: '',
}

const checkoutFieldSchemas = checkoutSchema.shape

type CheckoutFieldName = keyof typeof initialValues

const validateCheckoutField = (field: CheckoutFieldName) => (value: string) => {
  const result = checkoutFieldSchemas[field].safeParse(value)
  return result.success ? true : result.error.issues[0]?.message ?? 'Invalid value'
}

const { handleSubmit, defineField, errors, resetForm } = useForm({
  validationSchema: {
    fullName: validateCheckoutField('fullName'),
    email: validateCheckoutField('email'),
    address: validateCheckoutField('address'),
    city: validateCheckoutField('city'),
    country: validateCheckoutField('country'),
    notes: validateCheckoutField('notes'),
  },
  initialValues,
})

const [fullName, fullNameAttrs] = defineField('fullName')
const [email, emailAttrs] = defineField('email')
const [address, addressAttrs] = defineField('address')
const [city, cityAttrs] = defineField('city')
const [country, countryAttrs] = defineField('country')
const [notes, notesAttrs] = defineField('notes')

const submitCheckout = handleSubmit((values) => {
  toast.success(`Checkout ready for ${values.fullName}. Connect your payment provider next.`)
  clearCart()
  resetForm()
})
</script>

<template>
  <section class="space-y-6">
    <SectionHeading
      eyebrow="Checkout"
      title="Checkout"
      description="A form validation example using VeeValidate and Zod."
    />

    <div v-if="items.length === 0" class="rounded-3xl border border-white/10 bg-white/5 p-8 text-center">
      <p class="text-white">Add items to your cart before checking out.</p>
    </div>

    <form v-else class="grid gap-6 lg:grid-cols-[1.2fr_0.8fr]" @submit.prevent="submitCheckout">
      <div class="space-y-4 rounded-3xl border border-white/10 bg-white/5 p-6">
        <div class="grid gap-4 md:grid-cols-2">
          <label class="space-y-2">
            <span class="text-sm text-slate-300">Full name</span>
            <input
              v-model="fullName"
              v-bind="fullNameAttrs"
              class="w-full rounded-2xl border border-white/10 bg-slate-950/60 px-4 py-3 text-white outline-none placeholder:text-slate-500"
              type="text"
              placeholder="Jane Doe"
            />
            <p class="text-sm text-red-300">{{ errors.fullName }}</p>
          </label>

          <label class="space-y-2">
            <span class="text-sm text-slate-300">Email</span>
            <input
              v-model="email"
              v-bind="emailAttrs"
              class="w-full rounded-2xl border border-white/10 bg-slate-950/60 px-4 py-3 text-white outline-none placeholder:text-slate-500"
              type="email"
              placeholder="jane@example.com"
            />
            <p class="text-sm text-red-300">{{ errors.email }}</p>
          </label>
        </div>

        <label class="space-y-2">
          <span class="text-sm text-slate-300">Address</span>
          <input
            v-model="address"
            v-bind="addressAttrs"
            class="w-full rounded-2xl border border-white/10 bg-slate-950/60 px-4 py-3 text-white outline-none placeholder:text-slate-500"
            type="text"
            placeholder="123 Market Street"
          />
          <p class="text-sm text-red-300">{{ errors.address }}</p>
        </label>

        <div class="grid gap-4 md:grid-cols-2">
          <label class="space-y-2">
            <span class="text-sm text-slate-300">City</span>
            <input
              v-model="city"
              v-bind="cityAttrs"
              class="w-full rounded-2xl border border-white/10 bg-slate-950/60 px-4 py-3 text-white outline-none placeholder:text-slate-500"
              type="text"
              placeholder="Cairo"
            />
            <p class="text-sm text-red-300">{{ errors.city }}</p>
          </label>

          <label class="space-y-2">
            <span class="text-sm text-slate-300">Country</span>
            <input
              v-model="country"
              v-bind="countryAttrs"
              class="w-full rounded-2xl border border-white/10 bg-slate-950/60 px-4 py-3 text-white outline-none placeholder:text-slate-500"
              type="text"
              placeholder="Egypt"
            />
            <p class="text-sm text-red-300">{{ errors.country }}</p>
          </label>
        </div>

        <label class="space-y-2">
          <span class="text-sm text-slate-300">Notes</span>
          <textarea
            v-model="notes"
            v-bind="notesAttrs"
            rows="4"
            class="w-full rounded-2xl border border-white/10 bg-slate-950/60 px-4 py-3 text-white outline-none placeholder:text-slate-500"
            placeholder="Delivery instructions or special requests"
          />
        </label>
      </div>

      <aside class="space-y-4 rounded-3xl border border-white/10 bg-white/5 p-6">
        <h3 class="text-lg font-semibold text-white">Order summary</h3>
        <ul class="space-y-3 text-sm text-slate-300">
          <li v-for="item in items" :key="item.id" class="flex items-center justify-between gap-3">
            <span>{{ item.name }} x{{ item.quantity }}</span>
            <span>{{ formatMoney(item.price * item.quantity) }}</span>
          </li>
        </ul>
        <div class="border-t border-white/10 pt-4">
          <p class="text-sm text-slate-400">Total</p>
          <p class="text-2xl font-bold text-white">{{ subtotalLabel }}</p>
        </div>
        <BaseButton type="submit" class="w-full">Place order</BaseButton>
      </aside>
    </form>
  </section>
</template>
