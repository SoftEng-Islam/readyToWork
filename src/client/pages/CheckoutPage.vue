<script setup lang="ts">
import axios from 'axios';
import { computed, onMounted, ref } from 'vue';
import { RouterLink, useRoute } from 'vue-router';
import { useToast } from 'vue-toastification';
import { useForm } from 'vee-validate';
import SectionHeading from '@/client/components/common/SectionHeading.vue';
import BaseButton from '@/client/components/ui/BaseButton.vue';
import { useCartStore } from '@/client/stores/cart';
import { appRoutes } from '@/shared/constants/routes';
import { checkoutSchema } from '@/shared/schemas/checkout';
import type {
  CreateCheckoutSessionInput,
  StripeCheckoutSession,
  StripeCheckoutSessionSummary,
} from '@/shared/schemas/payments';
import type { ApiResponse } from '@/shared/types';
import { formatMoney } from '@/shared/utils/money';

const { items, subtotalLabel, clearCart } = useCartStore();
const toast = useToast();
const route = useRoute();
const api = axios.create({
  baseURL: import.meta.env.VITE_API_BASE_URL ?? '/api',
});
const isRedirecting = ref(false);
const checkoutSummary = ref<StripeCheckoutSessionSummary | null>(null);
const isLoadingSummary = ref(false);

const initialValues = {
  fullName: '',
  email: '',
  address: '',
  city: '',
  country: '',
  notes: '',
};

const checkoutFieldSchemas = checkoutSchema.shape;

type CheckoutFieldName = keyof typeof initialValues;
type CheckoutResult = 'success' | 'cancelled' | null;

const validateCheckoutField = (field: CheckoutFieldName) => (value: string) => {
  const result = checkoutFieldSchemas[field].safeParse(value);
  return result.success ? true : (result.error.issues[0]?.message ?? 'Invalid value');
};

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
});

const [fullName, fullNameAttrs] = defineField('fullName');
const [email, emailAttrs] = defineField('email');
const [address, addressAttrs] = defineField('address');
const [city, cityAttrs] = defineField('city');
const [country, countryAttrs] = defineField('country');
const [notes, notesAttrs] = defineField('notes');

const checkoutResult = computed<CheckoutResult>(() => {
  const value = route.query.checkout;
  return value === 'success' || value === 'cancelled' ? value : null;
});

const checkoutSessionId = computed(() => {
  const value = route.query.session_id;
  return typeof value === 'string' ? value : null;
});

const isSuccessfulCheckout = computed(
  () => checkoutResult.value === 'success' && checkoutSummary.value?.paymentStatus === 'paid',
);

async function loadCheckoutSummary(sessionId: string) {
  isLoadingSummary.value = true;

  try {
    const response = await api.get<ApiResponse<StripeCheckoutSessionSummary>>(
      `/payments/checkout-session/${sessionId}`,
    );

    checkoutSummary.value = response.data.data;

    if (response.data.data.paymentStatus === 'paid') {
      clearCart();
      resetForm();
      toast.success(`Payment received for ${response.data.data.customerEmail ?? 'your order'}.`);
    }
  } catch (error) {
    const message =
      axios.isAxiosError(error) && error.response?.data?.message
        ? String(error.response.data.message)
        : error instanceof Error
          ? error.message
          : 'Unable to confirm your Stripe checkout session.';

    toast.error(message);
  } finally {
    isLoadingSummary.value = false;
  }
}

onMounted(() => {
  if (checkoutResult.value === 'success' && checkoutSessionId.value) {
    void loadCheckoutSummary(checkoutSessionId.value);
    return;
  }

  if (checkoutResult.value === 'cancelled') {
    toast.info('Stripe checkout was cancelled. Your cart is still available.');
  }
});

const submitCheckout = handleSubmit(async (values) => {
  if (items.value.length === 0) {
    toast.error('Add items to your cart before starting checkout.');
    return;
  }

  isRedirecting.value = true;

  const payload: CreateCheckoutSessionInput = {
    ...values,
    items: items.value.map((item) => ({
      productId: item.id,
      quantity: item.quantity,
    })),
  };

  try {
    const response = await api.post<ApiResponse<StripeCheckoutSession>>(
      '/payments/checkout-session',
      payload,
    );

    window.location.assign(response.data.data.url);
  } catch (error) {
    const message =
      axios.isAxiosError(error) && error.response?.data?.message
        ? String(error.response.data.message)
        : error instanceof Error
          ? error.message
          : 'Unable to start Stripe checkout.';

    toast.error(message);
    isRedirecting.value = false;
  }
});
</script>

<template>
  <section class="space-y-6">
    <SectionHeading
      eyebrow="Checkout"
      title="Checkout"
      description="Submit validated checkout details, create a Stripe Checkout Session, and redirect to the hosted payment page."
    />

    <div
      v-if="checkoutResult === 'cancelled'"
      class="rounded-3xl border border-amber-400/20 bg-amber-500/10 p-5"
    >
      <p class="font-semibold text-amber-200">Checkout cancelled</p>
      <p class="mt-1 text-sm text-amber-100/80">
        Stripe returned you to the app before payment was completed. You can review the cart and try
        again.
      </p>
    </div>

    <div
      v-if="checkoutResult === 'success' && isLoadingSummary"
      class="rounded-3xl border border-white/10 bg-white/5 p-8 text-center"
    >
      <p class="text-white">Confirming your Stripe checkout session...</p>
    </div>

    <div
      v-else-if="isSuccessfulCheckout && checkoutSummary"
      class="space-y-5 rounded-3xl border border-emerald-400/20 bg-emerald-500/10 p-6"
    >
      <div>
        <p class="text-sm tracking-[0.2em] text-emerald-300 uppercase">Stripe Checkout</p>
        <h2 class="mt-2 text-2xl font-semibold text-white">Payment received</h2>
        <p class="mt-2 text-sm text-emerald-50/80">
          Session <span class="font-mono">{{ checkoutSummary.id }}</span> was paid successfully.
        </p>
      </div>

      <div class="grid gap-4 md:grid-cols-2">
        <article class="rounded-2xl border border-white/10 bg-slate-950/30 p-4">
          <p class="text-sm text-slate-400">Customer</p>
          <p class="mt-1 font-medium text-white">
            {{ checkoutSummary.customerEmail ?? 'Unknown' }}
          </p>
        </article>
        <article class="rounded-2xl border border-white/10 bg-slate-950/30 p-4">
          <p class="text-sm text-slate-400">Total</p>
          <p class="mt-1 font-medium text-white">
            {{ formatMoney(checkoutSummary.amountTotal, checkoutSummary.currency.toUpperCase()) }}
          </p>
        </article>
      </div>

      <ul
        class="space-y-3 rounded-2xl border border-white/10 bg-slate-950/30 p-4 text-sm text-slate-200"
      >
        <li
          v-for="lineItem in checkoutSummary.lineItems"
          :key="`${lineItem.description}-${lineItem.quantity}`"
          class="flex items-center justify-between gap-3"
        >
          <span>{{ lineItem.description }} x{{ lineItem.quantity }}</span>
          <span>{{ formatMoney(lineItem.amountTotal, lineItem.currency.toUpperCase()) }}</span>
        </li>
      </ul>

      <div class="flex flex-wrap gap-3">
        <RouterLink
          :to="appRoutes.catalog"
          class="rounded-full bg-sky-500 px-4 py-2 text-sm font-semibold text-slate-950 transition hover:bg-sky-400"
        >
          Continue shopping
        </RouterLink>
        <RouterLink
          :to="appRoutes.orders"
          class="rounded-full border border-white/10 px-4 py-2 text-sm font-medium text-white transition hover:bg-white/5"
        >
          View orders
        </RouterLink>
      </div>
    </div>

    <div
      v-else-if="items.length === 0"
      class="rounded-3xl border border-white/10 bg-white/5 p-8 text-center"
    >
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
        <BaseButton type="submit" class="w-full" :disabled="isRedirecting">
          {{ isRedirecting ? 'Redirecting to Stripe...' : 'Pay with Stripe Checkout' }}
        </BaseButton>
      </aside>
    </form>
  </section>
</template>
