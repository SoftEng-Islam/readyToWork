import { ref } from 'vue';
import { acceptHMRUpdate, defineStore } from 'pinia';

interface StateInterface {
	search: string;
	category: string;
}

const search = ref('');
const category = ref('all');

export const useCatalogStore = defineStore('mainStore', {
	state: (): StateInterface => ({
		search: search.value,
		category: category.value,
	}),
	getters: {},
	actions: {
		reset() {
			search.value = '';
			category.value = 'all';
		},
	},
});

if (import.meta.hot) {
	import.meta.hot.accept(acceptHMRUpdate(useCatalogStore, import.meta.hot));
}
