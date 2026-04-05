import { defineStore } from "pinia";
import { ref, computed } from "vue";
import type { IUserResponse } from "shared/types/models.ts";
import { loginUser, registerUser, getCurrentUser } from "./services/auth.service.ts";

export const useAuthStore = defineStore("auth", () => {
	// State
	const user = ref<IUserResponse | null>(null);
	const token = ref<string | null>(null);
	const loading = ref(false);
	const error = ref<string | null>(null);

	// Computed
	const isAuthenticated = computed(() => !!token.value && !!user.value);

	// Actions
	const login = async (email: string, password: string) => {
		try {
			loading.value = true;
			error.value = null;

			const response = await loginUser({ email, password });

			// Store token and user
			token.value = response.token;
			user.value = response.user;

			// Persist to localStorage
			localStorage.setItem("token", response.token);
			localStorage.setItem("user", JSON.stringify(response.user));

			return true;
		} catch (err: any) {
			error.value = err.message || "Login failed";
			console.error("Login error:", err);
			return false;
		} finally {
			loading.value = false;
		}
	};

	const register = async (username: string, email: string, password: string) => {
		try {
			loading.value = true;
			error.value = null;

			const response = await registerUser({ username, email, password });

			// Store token and user
			token.value = response.token;
			user.value = response.user;

			// Persist to localStorage
			localStorage.setItem("token", response.token);
			localStorage.setItem("user", JSON.stringify(response.user));

			return true;
		} catch (err: any) {
			error.value = err.message || "Registration failed";
			console.error("Registration error:", err);
			return false;
		} finally {
			loading.value = false;
		}
	};

	const logout = () => {
		// Clear state
		user.value = null;
		token.value = null;
		error.value = null;

		// Clear localStorage
		localStorage.removeItem("token");
		localStorage.removeItem("user");
	};

	const checkAuth = async () => {
		// Try to load from localStorage first
		const storedToken = localStorage.getItem("token");
		const storedUser = localStorage.getItem("user");

		if (storedToken && storedUser) {
			token.value = storedToken;
			user.value = JSON.parse(storedUser);

			// Verify token is still valid by fetching current user
			try {
				const response = await getCurrentUser();
				user.value = response.user;
				localStorage.setItem("user", JSON.stringify(response.user));
			} catch (err) {
				// Token is invalid, clear everything
				logout();
			}
		}
	};

	return {
		// State
		user,
		token,
		loading,
		error,
		// Computed
		isAuthenticated,
		// Actions
		login,
		register,
		logout,
		checkAuth,
	};
});
