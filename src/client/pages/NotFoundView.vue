<script setup lang="ts"></script>
<template lang="pug">
div(class="flex flex-col items-center justify-center min-h-[60vh] text-center space-y-8")
	div(class="relative")
		h1(class="text-[12rem] font-bold leading-none bg-gradient-to-br from-zinc-800 to-zinc-950 bg-clip-text text-transparent select-none") 404
		div(class="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-full")
			h2(class="text-4xl font-bold text-white mb-4") Page Not Found
			p(class="text-zinc-400 max-w-md mx-auto") The page you are looking for might have been removed, had its name changed, or is temporarily unavailable.

	router-link(
		to="/"
		class="px-8 py-3 rounded-xl bg-white text-zinc-950 font-semibold hover:bg-zinc-200 transition-colors duration-200"
	) Go Back Home
</template>
