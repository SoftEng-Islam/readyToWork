import { createRouter, createWebHistory } from 'vue-router';
import { useAuthStore } from '@/client/stores/auth';

import routes from './routes.ts';
const url = new URL(import.meta.env.BASE_URL, window.location.origin);

const router = createRouter({
	history: createWebHistory(url.pathname),
	routes: routes,
	linkActiveClass: 'active',
	linkExactActiveClass: 'exact-active',
	scrollBehavior(to, from, savedPosition) {
		console.log(to, from, savedPosition);
		if (savedPosition) {
			return savedPosition;
		}
		return {
			left: 0,
			top: 0,
		};
	},
});

router.beforeEach((to) => {
	const { session, isSignedIn } = useAuthStore();
	const requiresAuth = to.matched.some((record) => record.meta.requiresAuth);
	const requiresGuest = to.matched.some((record) => record.meta.requiresGuest);
	const requiresAdmin = to.matched.some((record) => record.meta.requiresAdmin);

	if (requiresAuth && !isSignedIn.value) {
		return {
			name: 'login',
			query: { redirect: to.fullPath },
		};
	}

	if (requiresGuest && isSignedIn.value) {
		return { name: session.value.user?.role === 'admin' ? 'admin' : 'account' };
	}

	if (requiresAdmin && session.value.user?.role !== 'admin') {
		return { name: 'account' };
	}

	return true;
});

export default router;
