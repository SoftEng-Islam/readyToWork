import { fileURLToPath } from 'node:url';
import { defineConfig } from 'vite';
import vue from '@vitejs/plugin-vue';
import tailwindcss from '@tailwindcss/vite';
// import tsconfigPaths from 'vite-tsconfig-paths';
import VueDevTools from 'vite-plugin-vue-devtools';
import Icons from 'unplugin-icons/vite';
import svgLoader from 'vite-svg-loader';
import { visualizer } from 'rollup-plugin-visualizer';
import viteImagemin from 'vite-plugin-imagemin';
import vuePugPlugin from 'vite-plugin-pug';

export default defineConfig(({ mode }) => {
	const server = {
		watch: {
			// port: port,
			open: true,
			usePolling: true,
			interval: 300,
			ignored: ['**/mongodb-data/**'],
		},
	};
	const plugins = [
		viteImagemin({
			gifsicle: {
				optimizationLevel: 7,
				interlaced: false,
			},
			optipng: {
				optimizationLevel: 7,
			},
			mozjpeg: {
				quality: 20,
			},
			pngquant: {
				quality: [0.8, 0.9],
				speed: 4,
			},
			svgo: {
				plugins: [
					{
						name: 'removeViewBox',
					},
					{
						name: 'removeEmptyAttrs',
						active: false,
					},
				],
			},
		}),
		vue({
			template: {
				preprocessOptions: {
					// 'preprocessOptions' is passed through to the pug compiler
					plugins: [vuePugPlugin],
				},
			},
		}),
		tailwindcss(),
		VueDevTools(),
		Icons({
			compiler: 'vue3',
		}),
		svgLoader(),
	];

	if (mode === 'analyze') {
		plugins.push(visualizer({ filename: 'dist/stats.html', open: false }));
	}

	return {
		server,
		plugins,
		css: {
			devSourcemap: mode === 'development',
		},
		resolve: {
			tsconfigPaths: true,
			alias: {
				'@': fileURLToPath(new URL('./src', import.meta.url)),
			},
		},
	};
});
