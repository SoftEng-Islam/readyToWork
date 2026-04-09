import { acceptHMRUpdate, defineStore } from 'pinia';

export type UiTheme = 'light' | 'dark';

const themeStorageKey = 'ready-to-work-theme';
const defaultTheme: UiTheme = 'dark';

interface UiState {
	hasHydratedTheme: boolean;
	theme: UiTheme;
}

function isUiTheme(value: string | null): value is UiTheme {
	return value === 'light' || value === 'dark';
}

function applyThemeToDocument(theme: UiTheme) {
	if (typeof document === 'undefined') {
		return;
	}

	const root = document.documentElement;
	root.classList.toggle('dark', theme === 'dark');
	root.classList.toggle('light', theme === 'light');
	root.dataset.theme = theme;
	root.style.colorScheme = theme;
}

function resolveInitialTheme(): UiTheme {
	if (typeof window === 'undefined') {
		return defaultTheme;
	}

	const storedTheme = window.localStorage.getItem(themeStorageKey);

	if (isUiTheme(storedTheme)) {
		return storedTheme;
	}

	return window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light';
}

function persistTheme(theme: UiTheme) {
	if (typeof window === 'undefined') {
		return;
	}

	window.localStorage.setItem(themeStorageKey, theme);
}

export const useUiStore = defineStore('ui', {
	state: (): UiState => ({
		hasHydratedTheme: false,
		theme: defaultTheme,
	}),
	getters: {
		isDark: (state) => state.theme === 'dark',
		themeToggleLabel(): 'Dark' | 'Light' {
			return this.isDark ? 'Light' : 'Dark';
		},
	},
	actions: {
		initializeTheme() {
			if (!this.hasHydratedTheme) {
				this.theme = resolveInitialTheme();
				this.hasHydratedTheme = true;
			}

			persistTheme(this.theme);
			applyThemeToDocument(this.theme);
		},
		setTheme(nextTheme: UiTheme) {
			this.theme = nextTheme;
			this.hasHydratedTheme = true;
			persistTheme(this.theme);
			applyThemeToDocument(this.theme);
		},
		toggleTheme() {
			this.setTheme(this.isDark ? 'light' : 'dark');
		},
	},
});

if (import.meta.hot) {
	import.meta.hot.accept(acceptHMRUpdate(useUiStore, import.meta.hot));
}
