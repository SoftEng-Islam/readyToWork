import { createRouter, createWebHistory } from 'vue-router'
import { appRoutes } from '@/shared/constants/routes'
import HomePage from '@/client/pages/HomePage.vue'
import ProductListPage from '@/client/pages/ProductListPage.vue'
import ProductDetailsPage from '@/client/pages/ProductDetailsPage.vue'
import CartPage from '@/client/pages/CartPage.vue'
import CheckoutPage from '@/client/pages/CheckoutPage.vue'
import OrdersPage from '@/client/pages/OrdersPage.vue'
import WishlistPage from '@/client/pages/WishlistPage.vue'
import AccountPage from '@/client/pages/AccountPage.vue'
import AdminDashboardPage from '@/client/pages/AdminDashboardPage.vue'

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    { path: appRoutes.home, name: 'home', component: HomePage },
    { path: appRoutes.catalog, name: 'product-list', component: ProductListPage },
    { path: appRoutes.productDetails, name: 'product-details', component: ProductDetailsPage },
    { path: appRoutes.cart, name: 'cart', component: CartPage },
    { path: appRoutes.checkout, name: 'checkout', component: CheckoutPage },
    { path: appRoutes.orders, name: 'orders', component: OrdersPage },
    { path: appRoutes.wishlist, name: 'wishlist', component: WishlistPage },
    { path: appRoutes.account, name: 'account', component: AccountPage },
    { path: appRoutes.admin, name: 'admin', component: AdminDashboardPage },
  ],
})

export default router
