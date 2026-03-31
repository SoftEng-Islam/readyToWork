import { fileURLToPath } from 'node:url';
import { defineConfig } from 'vite';
import vue from '@vitejs/plugin-vue';
import tailwindcss from '@tailwindcss/vite';
// import tsconfigPaths from 'vite-tsconfig-paths';
import VueDevTools from 'vite-plugin-vue-devtools';
import Icons from 'unplugin-icons/vite';
import svgLoader from 'vite-svg-loader';
import { visualizer } from 'rollup-plugin-visualizer';

export default defineConfig(({ mode }) => {
  const plugins = [
    vue(),
    tailwindcss(),
    // tsconfigPaths(),
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
    plugins,
    resolve: {
      tsconfigPaths: true,
      alias: {
        '@': fileURLToPath(new URL('./src', import.meta.url)),
      },
    },
  };
});
