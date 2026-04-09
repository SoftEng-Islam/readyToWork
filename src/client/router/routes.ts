import { appRoutes } from '@/shared/constants/routes';

import HomePage from '@/client/pages/HomePage.vue';
import ProductListPage from '@/client/pages/ProductListPage.vue';
import ProductDetailsPage from '@/client/pages/ProductDetailsPage.vue';
import CartPage from '@/client/pages/CartPage.vue';
import CheckoutPage from '@/client/pages/CheckoutPage.vue';
import OrdersPage from '@/client/pages/OrdersPage.vue';
import WishlistPage from '@/client/pages/WishlistPage.vue';
import AccountPage from '@/client/pages/AccountPage.vue';
import AdminDashboardPage from '@/client/pages/AdminDashboardPage.vue';

export default [
	{ path: appRoutes.home, name: 'home', component: HomePage, meta: { requiresAuth: false } },
	{
		path: '/login',
		name: 'login',
		component: () => import('../pages/LoginView.vue'),
		meta: { requiresAuth: false, requiresGuest: true },
	},
	{ path: appRoutes.catalog, name: 'product-list', component: ProductListPage, meta: { requiresAuth: false } },
	{ path: appRoutes.productDetails, name: 'product-details', component: ProductDetailsPage, meta: { requiresAuth: false } },
	{ path: appRoutes.cart, name: 'cart', component: CartPage, meta: { requiresAuth: false } },
	{ path: appRoutes.checkout, name: 'checkout', component: CheckoutPage, meta: { requiresAuth: true } },
	{ path: appRoutes.orders, name: 'orders', component: OrdersPage, meta: { requiresAuth: true } },
	{ path: appRoutes.wishlist, name: 'wishlist', component: WishlistPage, meta: { requiresAuth: true } },
	{ path: appRoutes.account, name: 'account', component: AccountPage, meta: { requiresAuth: false } },
	{ path: appRoutes.admin, name: 'admin', component: AdminDashboardPage, meta: { requiresAuth: true, requiresAdmin: true } },

	{
		path: '/:pathMatch(.*)*',
		component: () => import('../pages/NotFoundView.vue'),
	},
];
