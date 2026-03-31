#!/bin/sh
set -eu

umask 022

SCRIPT_NAME=${0##*/}
TARGET_DIR='.'
PROJECT_NAME=''
FORCE=0
DRY_RUN=0
INSTALL_DEPS=0
INIT_GIT=0
WITH_MONGO=0
WITH_REDIS=0
SKIP_README=0
PACKAGE_MANAGER='pnpm'
POSITIONAL_SEEN=0

usage() {
  cat <<EOF
Usage: sh ./$SCRIPT_NAME [options] [target-dir]

Scaffold the Vue 3 + Express e-commerce project tree.

Options:
  -d, --dir DIR          Target directory to scaffold.
  -n, --name NAME        Project name used in generated files.
  -f, --force            Overwrite matching files if they already exist.
      --dry-run          Print what would be created without writing files.
      --install          Run dependency installation after scaffolding.
      --git, --init-git  Initialize a git repository in the target directory.
      --no-git           Skip git initialization.
      --with-mongo       Add optional MongoDB helper files.
      --with-redis       Add optional Redis helper files.
      --skip-readme      Do not generate README.md when it is missing.
      --pm NAME          Package manager to use with --install (pnpm, npm, yarn, bun).
  -h, --help             Show this help text.

Examples:
  sh ./$SCRIPT_NAME
  sh ./$SCRIPT_NAME --dir ../my-shop --name "My Shop" --install
  sh ./$SCRIPT_NAME --dry-run --with-mongo --with-redis
EOF
}

log() {
  printf '%s\n' "$*"
}

warn() {
  printf '%s\n' "warning: $*" >&2
}

die() {
  printf '%s\n' "error: $*" >&2
  exit 1
}

trim_trailing_slash() {
  case "$1" in
    */) printf '%s\n' "${1%/}" ;;
    *) printf '%s\n' "$1" ;;
  esac
}

default_name_from_dir() {
  case "$1" in
    .) basename "$(pwd)" ;;
    */) basename "${1%/}" ;;
    *) basename "$1" ;;
  esac
}

sanitize_name() {
  printf '%s' "$1" \
    | tr '[:upper:] _.' '[:lower:]-' \
    | tr -cs '[:alnum:]-' '-' \
    | sed 's/^-*//; s/-*$//; s/--*/-/g'
}

make_dir() {
  dir=$1
  if [ "$DRY_RUN" -eq 1 ]; then
    log "dir   $dir"
    return 0
  fi
  mkdir -p "$dir"
}

touch_keep() {
  dir=$1
  target="$dir/.gitkeep"
  if [ "$DRY_RUN" -eq 1 ]; then
    log "keep  $target"
    return 0
  fi
  mkdir -p "$dir"
  touch "$target"
  log "keep  $target"
}

write_file() {
  path=$1
  if [ -e "$path" ] && [ "$FORCE" -ne 1 ]; then
    log "skip  $path"
    cat >/dev/null
    return 0
  fi
  if [ "$DRY_RUN" -eq 1 ]; then
    log "write $path"
    cat >/dev/null
    return 0
  fi
  mkdir -p "$(dirname "$path")"
  cat >"$path"
  log "write $path"
}

parse_args() {
  while [ "$#" -gt 0 ]; do
    case "$1" in
      -d|--dir)
        [ "$#" -ge 2 ] || die "$1 requires a value"
        TARGET_DIR=$2
        shift 2
        ;;
      -n|--name)
        [ "$#" -ge 2 ] || die "$1 requires a value"
        PROJECT_NAME=$2
        shift 2
        ;;
      -f|--force)
        FORCE=1
        shift
        ;;
      --dry-run)
        DRY_RUN=1
        shift
        ;;
      --install)
        INSTALL_DEPS=1
        shift
        ;;
      --no-install)
        INSTALL_DEPS=0
        shift
        ;;
      --git|--init-git)
        INIT_GIT=1
        shift
        ;;
      --no-git)
        INIT_GIT=0
        shift
        ;;
      --with-mongo)
        WITH_MONGO=1
        shift
        ;;
      --with-redis)
        WITH_REDIS=1
        shift
        ;;
      --skip-readme)
        SKIP_README=1
        shift
        ;;
      --pm|--package-manager)
        [ "$#" -ge 2 ] || die "$1 requires a value"
        PACKAGE_MANAGER=$2
        shift 2
        ;;
      -h|--help)
        usage
        exit 0
        ;;
      --)
        shift
        break
        ;;
      -*)
        die "unknown option: $1"
        ;;
      *)
        if [ "$POSITIONAL_SEEN" -eq 0 ]; then
          TARGET_DIR=$1
          POSITIONAL_SEEN=1
          shift
        else
          die "unexpected argument: $1"
        fi
        ;;
    esac
  done
}

scaffold_root_files() {
  write_file "$TARGET_DIR/package.json" <<EOF
{
  "name": "$PROJECT_NAME",
  "private": true,
  "version": "1.0.0",
  "packageManager": "pnpm@10.14.0",
  "type": "module",
  "description": "Modern Vue 3 + Express e-commerce starter with TypeScript, Drizzle, Better Auth, and Tailwind.",
  "license": "MIT",
  "engines": {
    "node": ">=20.19.0",
    "pnpm": ">=10.14.0"
  },
  "pnpm": {
    "onlyBuiltDependencies": [
      "@apollo/protobufjs",
      "@parcel/watcher",
      "argon2",
      "esbuild",
      "vue-demi"
    ]
  },
  "keywords": [
    "vue",
    "express",
    "graphql",
    "ecommerce",
    "marketplace",
    "shop",
    "drizzle-orm",
    "better-auth",
    "pinia",
    "tailwindcss",
    "typescript"
  ],
  "scripts": {
    "dev": "concurrently -k -n web,api -c cyan,green \"vite\" \"tsx watch src/server/main.ts\"",
    "dev:client": "vite",
    "dev:server": "tsx watch src/server/main.ts",
    "build": "vue-tsc -p tsconfig.app.json --noEmit && tsc -p tsconfig.server.json --noEmit && vite build",
    "preview": "vite preview",
    "start": "tsx src/server/main.ts",
    "type-check": "vue-tsc -p tsconfig.app.json --noEmit && tsc -p tsconfig.server.json --noEmit",
    "lint": "eslint .",
    "format": "prettier --write .",
    "test": "vitest",
    "test:ui": "vitest --ui",
    "coverage": "vitest run --coverage",
    "clean": "rimraf dist",
    "db:generate": "drizzle-kit generate",
    "db:migrate": "drizzle-kit migrate",
    "db:studio": "drizzle-kit studio"
  },
  "dependencies": {
    "@apollo/client": "^3.11.10",
    "@apollo/server": "^5.4.0",
    "@as-integrations/express5": "^1.1.2",
    "@formkit/auto-animate": "^0.9.0",
    "@graphql-tools/schema": "^10.0.30",
    "@heroicons/vue": "^2.2.0",
    "@remixicon/vue": "^4.7.0",
    "@vue/apollo-composable": "^4.2.2",
    "@vueuse/core": "^14.1.0",
    "@vueuse/motion": "^3.0.3",
    "animate.css": "^4.1.1",
    "argon2": "^0.44.0",
    "axios": "^1.13.2",
    "better-auth": "^1.3.8",
    "cors": "^2.8.5",
    "dotenv": "^17.2.3",
    "drizzle-orm": "^0.44.5",
    "express": "^5.1.0",
    "express-async-handler": "^1.2.0",
    "graphql": "^16.12.0",
    "helmet": "^8.1.0",
    "jsonwebtoken": "^9.0.3",
    "morgan": "^1.10.1",
    "pg": "^8.16.3",
    "pinia": "^3.0.4",
    "pino": "^9.9.4",
    "ruru": "2.0.0-rc.3",
    "tsx": "^4.21.0",
    "vee-validate": "^4.15.1",
    "vue": "^3.5.25",
    "vue-router": "^4.6.3",
    "vue-toastification": "2.0.0-rc.5",
    "zod": "^4.3.6"
  },
  "optionalDependencies": {
    "mongoose": "^8.20.1",
    "redis": "^5.8.2"
  },
  "devDependencies": {
    "@tailwindcss/aspect-ratio": "^0.4.2",
    "@tailwindcss/container-queries": "^0.1.1",
    "@tailwindcss/forms": "^0.5.10",
    "@tailwindcss/postcss": "^4.1.17",
    "@tailwindcss/typography": "^0.5.19",
    "@tailwindcss/vite": "^4.1.17",
    "@tsconfig/node22": "^22.0.5",
    "@types/cors": "^2.8.19",
    "@types/express": "^5.0.5",
    "@types/jsonwebtoken": "^9.0.10",
    "@types/morgan": "^1.9.10",
    "@types/node": "^24.10.2",
    "@types/pg": "^8.15.5",
    "@vitejs/plugin-vue": "^6.0.2",
    "@vitest/coverage-v8": "^4.0.15",
    "@vitest/ui": "^4.0.15",
    "@vue/compiler-sfc": "^3.5.25",
    "@vue/eslint-config-prettier": "^10.2.0",
    "@vue/eslint-config-typescript": "^14.6.0",
    "@vue/test-utils": "^2.4.6",
    "@vue/tsconfig": "^0.8.1",
    "autoprefixer": "^10.4.22",
    "concurrently": "^8.2.2",
    "daisyui": "^5.5.8",
    "drizzle-kit": "^0.31.4",
    "eslint": "^9.39.1",
    "eslint-plugin-vue": "~10.6.2",
    "happy-dom": "^20.0.11",
    "prettier": "3.7.4",
    "prettier-plugin-tailwindcss": "^0.7.2",
    "pino-pretty": "^13.1.1",
    "rimraf": "^6.1.3",
    "rollup-plugin-visualizer": "^6.0.5",
    "sass": "^1.95.1",
    "tailwindcss": "^4.1.17",
    "typescript": "~5.9.3",
    "typescript-eslint": "^8.42.0",
    "unplugin-icons": "^0.15.1",
    "vite": "^7.2.7",
    "vite-plugin-vue-devtools": "^8.0.5",
    "vite-svg-loader": "^5.1.0",
    "vite-tsconfig-paths": "^5.1.4",
    "vue-tsc": "^3.0.6",
    "vitest": "^4.0.15"
  }
}
EOF

  write_file "$TARGET_DIR/pnpm-workspace.yaml" <<'EOF'
onlyBuiltDependencies:
  - "@apollo/protobufjs"
  - "@parcel/watcher"
  - argon2
  - esbuild
  - vue-demi
EOF

  write_file "$TARGET_DIR/doctor.sh" <<'EOF'
#!/bin/sh

set -u

NODE_MIN_VERSION="20.19.0"
PNPM_MIN_VERSION="10.14.0"
DEFAULT_DATABASE_URL="postgresql://postgres:postgres@localhost:5432/commerce"

pass_count=0
warn_count=0
fail_count=0
env_source=".env"
database_source=".env"

say() {
  printf '%s\n' "$*"
}

pass() {
  pass_count=$((pass_count + 1))
  say "PASS  $*"
}

warn() {
  warn_count=$((warn_count + 1))
  say "WARN  $*"
}

fail() {
  fail_count=$((fail_count + 1))
  say "FAIL  $*"
}

has_cmd() {
  command -v "$1" >/dev/null 2>&1
}

version_ge() {
  node -e '
const [found, needed] = process.argv.slice(1)
const parse = (value) => value.replace(/^v/, "").split(".").map((part) => Number(part) || 0)
const left = parse(found)
const right = parse(needed)
const length = Math.max(left.length, right.length)
for (let index = 0; index < length; index += 1) {
  const leftValue = left[index] ?? 0
  const rightValue = right[index] ?? 0
  if (leftValue > rightValue) process.exit(0)
  if (leftValue < rightValue) process.exit(1)
}
process.exit(0)
' "$1" "$2"
}

mask_database_url() {
  if ! has_cmd node; then
    printf '%s\n' '(DATABASE_URL hidden)'
    return
  fi

  node -e '
const raw = process.argv[1]
try {
  const url = new URL(raw)
  if (url.password) url.password = "***"
  console.log(url.toString())
} catch {
  console.log("(invalid DATABASE_URL)")
}
' "$1"
}

check_tcp_database() {
  if ! has_cmd node; then
    return 2
  fi

  node -e '
const raw = process.argv[1]
const net = require("node:net")
let url
try {
  url = new URL(raw)
} catch {
  process.exit(2)
}
const host = url.hostname || "localhost"
const port = Number(url.port || 5432)
const socket = net.createConnection({ host, port })
socket.setTimeout(3000)
socket.on("connect", () => {
  socket.end()
  process.exit(0)
})
socket.on("timeout", () => {
  socket.destroy()
  process.exit(1)
})
socket.on("error", () => process.exit(1))
' "$1"
}

load_env_file() {
  if [ -f ./.env ]; then
    set -a
    # shellcheck disable=SC1091
    . ./.env
    set +a
    pass ".env file found"
  else
    env_source="fallback values"
    warn ".env file not found. Run: cp .env.example .env"
  fi

  if [ -n "${DATABASE_URL-}" ]; then
    database_source="$env_source"
  else
    DATABASE_URL="$DEFAULT_DATABASE_URL"
    database_source="fallback local value"
    warn "DATABASE_URL is not set. Using the local PostgreSQL fallback value"
  fi

  if [ -d ./node_modules ]; then
    pass "node_modules folder found"
  else
    warn "node_modules folder not found. Run: pnpm install"
  fi
}

say "Project doctor"
say "-------------"

if has_cmd git; then
  pass "git is installed: $(git --version | awk '{print $3}')"
else
  warn "git is not installed"
fi

if has_cmd node; then
  node_version=$(node --version)
  pass "node is installed: $node_version"
  if version_ge "$node_version" "$NODE_MIN_VERSION"; then
    pass "node version is new enough (need >= $NODE_MIN_VERSION)"
  else
    fail "node version is too old. Need >= $NODE_MIN_VERSION"
  fi
else
  fail "node is not installed"
fi

if has_cmd pnpm; then
  pnpm_version=$(pnpm --version)
  pass "pnpm is installed: $pnpm_version"
  if has_cmd node && version_ge "$pnpm_version" "$PNPM_MIN_VERSION"; then
    pass "pnpm version is new enough (need >= $PNPM_MIN_VERSION)"
  else
    fail "pnpm version is too old. Need >= $PNPM_MIN_VERSION"
  fi
else
  fail "pnpm is not installed"
fi

if has_cmd psql; then
  pass "psql is installed: $(psql --version | awk '{print $3}')"
else
  warn "psql is not installed. Install PostgreSQL client tools if you want local database commands"
fi

if has_cmd pg_isready; then
  pass "pg_isready is installed"
else
  warn "pg_isready is not installed. The script can still test PostgreSQL with Node.js"
fi

load_env_file

say ""
say "Database source: $database_source"
say "Database target: $(mask_database_url "$DATABASE_URL")"

if check_tcp_database "$DATABASE_URL"; then
  pass "PostgreSQL server port is reachable"
else
  tcp_status=$?
  if [ "$tcp_status" -eq 2 ]; then
    fail "DATABASE_URL is not valid"
  else
    fail "PostgreSQL is not reachable on the host and port from DATABASE_URL"
  fi
fi

if has_cmd psql; then
  if PGCONNECT_TIMEOUT=3 psql "$DATABASE_URL" -c "select 1" >/dev/null 2>&1; then
    pass "PostgreSQL login and database check passed"
  else
    fail "Could not log in to PostgreSQL with DATABASE_URL"
  fi
else
  warn "Database login test skipped because psql is not installed"
fi

say ""
say "Summary"
say "PASS: $pass_count"
say "WARN: $warn_count"
say "FAIL: $fail_count"

if [ "$fail_count" -gt 0 ]; then
  exit 1
fi

exit 0
EOF
  chmod +x "$TARGET_DIR/doctor.sh"

  write_file "$TARGET_DIR/.gitignore" <<EOF
node_modules
dist
coverage
.env
.env.local
.env.*.local
*.log
*.tsbuildinfo
.DS_Store
.idea
.vscode
EOF

  write_file "$TARGET_DIR/.env.example" <<EOF
APP_NAME=$PROJECT_NAME
PORT=3000
HOST=0.0.0.0
API_PREFIX=/api
GRAPHQL_PATH=/graphql
DATABASE_URL=postgresql://postgres:postgres@localhost:5432/commerce
BETTER_AUTH_SECRET=replace-with-a-long-random-string
BETTER_AUTH_URL=http://localhost:3000
JWT_SECRET=replace-with-a-long-random-string
CORS_ORIGIN=http://localhost:5173,http://localhost:5174
REDIS_URL=
MONGODB_URI=
VITE_APP_NAME=$PROJECT_NAME
VITE_API_BASE_URL=http://localhost:3000/api
EOF

  write_file "$TARGET_DIR/index.html" <<EOF
<!doctype html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>$PROJECT_NAME</title>
  </head>
  <body>
    <div id="app"></div>
    <script type="module" src="/src/client/main.ts"></script>
  </body>
</html>
EOF

  write_file "$TARGET_DIR/tsconfig.json" <<'EOF'
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "ESNext",
    "moduleResolution": "Bundler",
    "baseUrl": ".",
    "paths": {
      "@/*": ["src/*"]
    },
    "strict": true,
    "esModuleInterop": true,
    "allowSyntheticDefaultImports": true,
    "forceConsistentCasingInFileNames": true,
    "noUncheckedIndexedAccess": true,
    "exactOptionalPropertyTypes": true,
    "skipLibCheck": true,
    "resolveJsonModule": true
  }
}
EOF

  write_file "$TARGET_DIR/tsconfig.app.json" <<'EOF'
{
  "extends": "./tsconfig.json",
  "compilerOptions": {
    "lib": ["ES2022", "DOM", "DOM.Iterable"],
    "types": ["vite/client"]
  },
  "include": [
    "src/client/**/*.ts",
    "src/client/**/*.d.ts",
    "src/client/**/*.vue",
    "src/shared/**/*.ts",
    "src/shared/**/*.d.ts"
  ],
  "exclude": ["src/server/**/*"]
}
EOF

  write_file "$TARGET_DIR/tsconfig.server.json" <<'EOF'
{
  "extends": "./tsconfig.json",
  "compilerOptions": {
    "lib": ["ES2022"],
    "types": ["node"]
  },
  "include": [
    "src/server/**/*.ts",
    "src/shared/**/*.ts",
    "src/shared/**/*.d.ts"
  ],
  "exclude": ["src/client/**/*"]
}
EOF

  write_file "$TARGET_DIR/tsconfig.node.json" <<'EOF'
{
  "extends": "./tsconfig.json",
  "compilerOptions": {
    "lib": ["ES2022"],
    "types": ["node"],
    "noEmit": true
  },
  "include": ["vite.config.ts", "drizzle.config.ts", "eslint.config.js", "prettier.config.js"]
}
EOF

  write_file "$TARGET_DIR/vite.config.ts" <<'EOF'
import { fileURLToPath } from 'node:url'
import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import tailwindcss from '@tailwindcss/vite'
import tsconfigPaths from 'vite-tsconfig-paths'
import VueDevTools from 'vite-plugin-vue-devtools'
import Icons from 'unplugin-icons/vite'
import svgLoader from 'vite-svg-loader'
import { visualizer } from 'rollup-plugin-visualizer'

export default defineConfig(({ mode }) => {
  const plugins = [
    vue(),
    tailwindcss(),
    tsconfigPaths(),
    VueDevTools(),
    Icons({
      compiler: 'vue3',
    }),
    svgLoader(),
  ]

  if (mode === 'analyze') {
    plugins.push(visualizer({ filename: 'dist/stats.html', open: false }))
  }

  return {
    plugins,
    resolve: {
      alias: {
        '@': fileURLToPath(new URL('./src', import.meta.url)),
      },
    },
    server: {
      host: true,
      port: 5173,
      proxy: {
        '/api': {
          target: 'http://localhost:3000',
          changeOrigin: true,
        },
        '/graphql': {
          target: 'http://localhost:3000',
          changeOrigin: true,
        },
      },
    },
  }
})
EOF

  write_file "$TARGET_DIR/eslint.config.js" <<'EOF'
import pluginVue from 'eslint-plugin-vue'
import { defineConfigWithVueTs, vueTsConfigs } from '@vue/eslint-config-typescript'
import skipFormatting from '@vue/eslint-config-prettier/skip-formatting'

export default defineConfigWithVueTs(
  {
    ignores: ['dist/**', 'coverage/**', 'node_modules/**'],
  },
  {
    name: 'commerce/app',
    files: ['src/**/*.{ts,vue}', 'vite.config.ts', 'drizzle.config.ts'],
    extends: [pluginVue.configs['flat/recommended'], vueTsConfigs.recommended],
    rules: {
      'vue/multi-word-component-names': 'off',
      '@typescript-eslint/consistent-type-imports': 'error',
    },
  },
  skipFormatting,
)
EOF

  write_file "$TARGET_DIR/prettier.config.js" <<'EOF'
import tailwindcss from 'prettier-plugin-tailwindcss'

export default {
  semi: true,
  singleQuote: true,
  trailingComma: 'all',
  printWidth: 100,
  plugins: [tailwindcss],
}
EOF

  write_file "$TARGET_DIR/drizzle.config.ts" <<'EOF'
import 'dotenv/config'
import { defineConfig } from 'drizzle-kit'

export default defineConfig({
  schema: './src/server/db/schema/index.ts',
  out: './src/server/db/migrations',
  dialect: 'postgresql',
  dbCredentials: {
    url: process.env.DATABASE_URL ?? '',
  },
  verbose: true,
  strict: true,
})
EOF

  if [ "$SKIP_README" -eq 0 ]; then
    write_file "$TARGET_DIR/README.md" <<EOF
# $PROJECT_NAME

A Vue 3 + Express e-commerce starter with client, server, and shared layers.

## Quick Start

1. Copy \`.env.example\` to \`.env\`.
2. Run \`pnpm install\`.
3. Run \`pnpm check:setup\`.
4. Run \`pnpm dev\`.

On NixOS, use the system \`pnpm\` binary directly and skip \`corepack enable\`. This scaffold also includes \`pnpm-workspace.yaml\`, so the required dependency build scripts are already approved.

## Database

This scaffold uses plain PostgreSQL through \`pg\` and Drizzle. A local example connection string is already included in \`.env.example\`.

## Structure

- \`src/client\` for the Vue storefront and admin UI.
- \`src/server\` for Express, GraphQL, auth, and database code.
- \`src/shared\` for Zod schemas, shared types, and helpers.
EOF
  fi
}

scaffold_client_files() {
  write_file "$TARGET_DIR/src/client/env.d.ts" <<'EOF'
/// <reference types="vite/client" />

interface ImportMetaEnv {
  readonly VITE_APP_NAME?: string
  readonly VITE_API_BASE_URL?: string
}

interface ImportMeta {
  readonly env: ImportMetaEnv
}
EOF

  write_file "$TARGET_DIR/src/client/main.ts" <<'EOF'
import 'animate.css'
import 'vue-toastification/dist/index.css'
import './styles/main.css'

import { MotionPlugin } from '@vueuse/motion'
import { createApp } from 'vue'
import Toast from 'vue-toastification'
import { createPinia } from 'pinia'
import App from './App.vue'
import router from './router'

document.title = import.meta.env.VITE_APP_NAME ?? 'Commerce Starter'

const app = createApp(App)

app.use(createPinia())
app.use(router)
app.use(MotionPlugin)
app.use(Toast, {
  timeout: 2500,
  position: 'top-right',
})

app.mount('#app')
EOF

  write_file "$TARGET_DIR/src/client/App.vue" <<'EOF'
<script setup lang="ts">
import { RouterView } from 'vue-router'
import AppLayout from '@/client/layouts/AppLayout.vue'
</script>

<template>
  <AppLayout>
    <RouterView />
  </AppLayout>
</template>
EOF

  write_file "$TARGET_DIR/src/client/styles/main.css" <<'EOF'
@import 'tailwindcss';
@plugin "daisyui";

html,
body,
#app {
  min-height: 100%;
}

body {
  margin: 0;
  color: #e2e8f0;
  background:
    radial-gradient(circle at top, rgba(14, 165, 233, 0.16), transparent 38%),
    linear-gradient(180deg, #020617 0%, #0f172a 100%);
}
EOF

  write_file "$TARGET_DIR/src/client/router/index.ts" <<'EOF'
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
EOF

  write_file "$TARGET_DIR/src/client/layouts/AppLayout.vue" <<'EOF'
<script setup lang="ts">
import AppHeader from '@/client/components/layout/AppHeader.vue'
</script>

<template>
  <div class="min-h-screen text-slate-100">
    <AppHeader />
    <main class="mx-auto w-full max-w-7xl px-4 py-6 sm:px-6 lg:px-8">
      <slot />
    </main>
  </div>
</template>
EOF

  write_file "$TARGET_DIR/src/client/components/common/SectionHeading.vue" <<'EOF'
<script setup lang="ts">
defineProps<{
  eyebrow?: string
  title: string
  description?: string
}>()
</script>

<template>
  <div class="space-y-2">
    <p v-if="eyebrow" class="text-xs uppercase tracking-[0.35em] text-sky-400">
      {{ eyebrow }}
    </p>
    <h2 class="text-2xl font-semibold text-white sm:text-3xl">
      {{ title }}
    </h2>
    <p v-if="description" class="max-w-2xl text-sm text-slate-300">
      {{ description }}
    </p>
  </div>
</template>
EOF

  write_file "$TARGET_DIR/src/client/components/layout/AppHeader.vue" <<'EOF'
<script setup lang="ts">
import { RouterLink } from 'vue-router'
import { appRoutes } from '@/shared/constants/routes'
import { useAuthStore } from '@/client/stores/auth'
import { useCartStore } from '@/client/stores/cart'
import { useUiStore } from '@/client/stores/ui'

const { session, isSignedIn } = useAuthStore()
const { totalItems } = useCartStore()
const ui = useUiStore()
const brandName = import.meta.env.VITE_APP_NAME ?? 'Commerce Starter'
</script>

<template>
  <header class="border-b border-white/10 bg-slate-950/80 backdrop-blur">
    <div class="mx-auto flex w-full max-w-7xl items-center justify-between gap-4 px-4 py-4 sm:px-6 lg:px-8">
      <RouterLink :to="appRoutes.home" class="text-lg font-semibold tracking-wide text-white">
        {{ brandName }}
      </RouterLink>

      <nav class="flex flex-wrap items-center gap-4 text-sm text-slate-300">
        <RouterLink :to="appRoutes.catalog" class="transition hover:text-white">
          Catalog
        </RouterLink>
        <RouterLink :to="appRoutes.wishlist" class="transition hover:text-white">
          Wishlist
        </RouterLink>
        <RouterLink :to="appRoutes.cart" class="transition hover:text-white">
          Cart ({{ totalItems }})
        </RouterLink>
        <RouterLink :to="appRoutes.orders" class="transition hover:text-white">
          Orders
        </RouterLink>
        <RouterLink :to="appRoutes.account" class="transition hover:text-white">
          {{ isSignedIn ? 'Account' : 'Sign in' }}
        </RouterLink>
        <RouterLink
          v-if="session.user?.role === 'admin'"
          :to="appRoutes.admin"
          class="transition hover:text-white"
        >
          Admin
        </RouterLink>
        <button
          type="button"
          class="rounded-full border border-white/10 px-3 py-1 transition hover:bg-white/5"
          @click="ui.toggleTheme()"
        >
          {{ ui.isDark ? 'Light' : 'Dark' }}
        </button>
      </nav>
    </div>
  </header>
</template>
EOF

  write_file "$TARGET_DIR/src/client/components/ui/BaseButton.vue" <<'EOF'
<script setup lang="ts">
import { computed } from 'vue'

type ButtonVariant = 'primary' | 'secondary' | 'ghost'

const props = withDefaults(
  defineProps<{
    variant?: ButtonVariant
    type?: 'button' | 'submit' | 'reset'
  }>(),
  {
    variant: 'primary',
    type: 'button',
  },
)

const variantClasses: Record<ButtonVariant, string> = {
  primary: 'bg-sky-500 text-slate-950 hover:bg-sky-400',
  secondary: 'border border-white/10 bg-white/5 text-white hover:bg-white/10',
  ghost: 'text-slate-200 hover:bg-white/5',
}

const classes = computed(() => [
  'inline-flex items-center justify-center rounded-full px-4 py-2 text-sm font-medium transition',
  variantClasses[props.variant],
])
</script>

<template>
  <button :type="type" :class="classes">
    <slot />
  </button>
</template>
EOF

  write_file "$TARGET_DIR/src/client/composables/useProducts.ts" <<'EOF'
import axios from 'axios'
import { ref } from 'vue'
import type { Product } from '@/shared/schemas/product'

const api = axios.create({
  baseURL: import.meta.env.VITE_API_BASE_URL ?? '/api',
})

export function useProducts() {
  const products = ref<Product[]>([])
  const product = ref<Product | null>(null)
  const loading = ref(false)
  const error = ref<string | null>(null)

  async function fetchProducts() {
    loading.value = true
    error.value = null

    try {
      const response = await api.get<Product[]>('/products')
      products.value = response.data
    } catch (err) {
      error.value = err instanceof Error ? err.message : 'Unable to load products.'
    } finally {
      loading.value = false
    }
  }

  async function fetchProductBySlug(slug: string) {
    loading.value = true
    error.value = null

    try {
      const response = await api.get<Product>(`/products/${slug}`)
      product.value = response.data
    } catch (err) {
      error.value = err instanceof Error ? err.message : 'Unable to load product details.'
      product.value = null
    } finally {
      loading.value = false
    }
  }

  return {
    products,
    product,
    loading,
    error,
    fetchProducts,
    fetchProductBySlug,
  }
}
EOF

  write_file "$TARGET_DIR/src/client/stores/auth.ts" <<'EOF'
import { computed } from 'vue'
import { useStorage } from '@vueuse/core'

type AuthUser = {
  id: string
  name: string
  email: string
  role: 'customer' | 'admin'
}

type AuthSession = {
  token: string | null
  user: AuthUser | null
}

const session = useStorage<AuthSession>('commerce-session', {
  token: null,
  user: null,
})

export function useAuthStore() {
  const isSignedIn = computed(() => Boolean(session.value.token))

  function signIn(user: AuthUser, token: string) {
    session.value = { user, token }
  }

  function signOut() {
    session.value = { user: null, token: null }
  }

  return {
    session,
    isSignedIn,
    signIn,
    signOut,
  }
}
EOF

  write_file "$TARGET_DIR/src/client/stores/cart.ts" <<'EOF'
import { computed } from 'vue'
import { useStorage } from '@vueuse/core'
import { formatMoney } from '@/shared/utils/money'

type CartItem = {
  id: string
  name: string
  price: number
  quantity: number
  imageUrl: string
}

const items = useStorage<CartItem[]>('commerce-cart', [])

export function useCartStore() {
  const totalItems = computed(() => items.value.reduce((sum, item) => sum + item.quantity, 0))
  const subtotal = computed(() =>
    items.value.reduce((sum, item) => sum + item.price * item.quantity, 0),
  )
  const subtotalLabel = computed(() => formatMoney(subtotal.value))

  function addItem(item: CartItem) {
    const existingItem = items.value.find((entry) => entry.id === item.id)

    if (existingItem) {
      existingItem.quantity += item.quantity
      return
    }

    items.value.push(item)
  }

  function updateQuantity(id: string, quantity: number) {
    const index = items.value.findIndex((item) => item.id === id)

    if (index === -1) {
      return
    }

    if (quantity <= 0) {
      items.value.splice(index, 1)
      return
    }

    const item = items.value[index]

    if (!item) {
      return
    }

    item.quantity = quantity
  }

  function removeItem(id: string) {
    items.value = items.value.filter((item) => item.id !== id)
  }

  function clearCart() {
    items.value = []
  }

  return {
    items,
    totalItems,
    subtotal,
    subtotalLabel,
    addItem,
    updateQuantity,
    removeItem,
    clearCart,
  }
}
EOF

  write_file "$TARGET_DIR/src/client/stores/catalog.ts" <<'EOF'
import { ref } from 'vue'

const search = ref('')
const category = ref('all')

export function useCatalogStore() {
  function reset() {
    search.value = ''
    category.value = 'all'
  }

  return {
    search,
    category,
    reset,
  }
}
EOF

  write_file "$TARGET_DIR/src/client/stores/ui.ts" <<'EOF'
import { useDark, useToggle } from '@vueuse/core'

export function useUiStore() {
  const isDark = useDark()
  const toggleTheme = useToggle(isDark)

  return {
    isDark,
    toggleTheme,
  }
}
EOF

  write_file "$TARGET_DIR/src/client/types/index.ts" <<'EOF'
export type MenuLink = {
  label: string
  to: string
}

export type EmptyStateAction = {
  label: string
  to: string
}
EOF

  write_file "$TARGET_DIR/src/client/pages/HomePage.vue" <<'EOF'
<script setup lang="ts">
import { RouterLink } from 'vue-router'
import SectionHeading from '@/client/components/common/SectionHeading.vue'
import { appRoutes } from '@/shared/constants/routes'
</script>

<template>
  <section class="grid gap-8 lg:grid-cols-2 lg:items-center">
    <div class="space-y-6">
      <p class="text-sm uppercase tracking-[0.35em] text-sky-400">
        E-commerce starter
      </p>
      <h1 class="text-4xl font-semibold leading-tight text-white sm:text-6xl">
        Build storefronts, checkouts, and dashboards without starting from zero.
      </h1>
      <p class="max-w-xl text-slate-300">
        Vue 3, Express 5, GraphQL, Drizzle, Tailwind, DaisyUI, Better Auth, and the pieces you
        actually need for a real shop.
      </p>
      <div class="flex flex-wrap gap-3">
        <RouterLink
          :to="appRoutes.catalog"
          class="rounded-full bg-sky-500 px-5 py-3 text-sm font-semibold text-slate-950 transition hover:bg-sky-400"
        >
          Browse catalog
        </RouterLink>
        <RouterLink
          :to="appRoutes.checkout"
          class="rounded-full border border-white/10 px-5 py-3 text-sm font-semibold text-white transition hover:bg-white/5"
        >
          Go to checkout
        </RouterLink>
      </div>
    </div>

    <div class="rounded-3xl border border-white/10 bg-white/5 p-6 backdrop-blur">
      <SectionHeading
        eyebrow="Included"
        title="A practical e-commerce baseline"
        description="Client pages, server modules, database schema, shared validation, and a scaffold script that can generate the same structure anywhere."
      />
      <ul class="mt-6 grid gap-3 text-sm text-slate-300 sm:grid-cols-2">
        <li class="rounded-2xl border border-white/10 p-4">Product catalog and detail pages</li>
        <li class="rounded-2xl border border-white/10 p-4">Cart and checkout flow</li>
        <li class="rounded-2xl border border-white/10 p-4">Express API and GraphQL</li>
        <li class="rounded-2xl border border-white/10 p-4">Drizzle + PostgreSQL schema</li>
      </ul>
    </div>
  </section>
</template>
EOF

  write_file "$TARGET_DIR/src/client/pages/ProductListPage.vue" <<'EOF'
<script setup lang="ts">
import { computed, onMounted, ref } from 'vue'
import { autoAnimate } from '@formkit/auto-animate'
import { RouterLink } from 'vue-router'
import SectionHeading from '@/client/components/common/SectionHeading.vue'
import { useCatalogStore } from '@/client/stores/catalog'
import { useProducts } from '@/client/composables/useProducts'
import { appRoutes } from '@/shared/constants/routes'
import { formatMoney } from '@/shared/utils/money'

const listRef = ref<HTMLElement | null>(null)
const catalog = useCatalogStore()
const { products, loading, error, fetchProducts } = useProducts()

const categories = computed(() => [
  'all',
  ...new Set(products.value.map((product) => product.category)),
])

const filteredProducts = computed(() =>
  products.value.filter((product) => {
    const searchTerm = catalog.search.value.trim().toLowerCase()
    const matchesSearch =
      searchTerm.length === 0 ||
      product.name.toLowerCase().includes(searchTerm) ||
      product.description.toLowerCase().includes(searchTerm)
    const matchesCategory =
      catalog.category.value === 'all' || product.category === catalog.category.value

    return matchesSearch && matchesCategory
  }),
)

onMounted(async () => {
  if (listRef.value) {
    autoAnimate(listRef.value)
  }

  await fetchProducts()
})
</script>

<template>
  <section class="space-y-6">
    <SectionHeading
      eyebrow="Catalog"
      title="Products"
      description="Browse the store catalog, filter by search, and open any product detail page."
    />

    <div class="grid gap-4 md:grid-cols-2">
      <label class="space-y-2">
        <span class="text-sm text-slate-300">Search</span>
        <input
          v-model="catalog.search"
          type="search"
          placeholder="Search products"
          class="w-full rounded-2xl border border-white/10 bg-white/5 px-4 py-3 text-white outline-none ring-0 placeholder:text-slate-500"
        />
      </label>

      <label class="space-y-2">
        <span class="text-sm text-slate-300">Category</span>
        <select
          v-model="catalog.category"
          class="w-full rounded-2xl border border-white/10 bg-white/5 px-4 py-3 text-white outline-none ring-0"
        >
          <option v-for="category in categories" :key="category" :value="category">
            {{ category }}
          </option>
        </select>
      </label>
    </div>

    <p v-if="loading" class="text-sm text-slate-400">Loading products...</p>
    <p v-else-if="error" class="text-sm text-red-300">{{ error }}</p>

    <div ref="listRef" class="grid gap-4 md:grid-cols-2 xl:grid-cols-3">
      <article
        v-for="product in filteredProducts"
        :key="product.id"
        class="overflow-hidden rounded-3xl border border-white/10 bg-white/5 shadow-lg"
      >
        <img
          :src="product.imageUrl"
          :alt="product.name"
          class="h-56 w-full object-cover"
        />
        <div class="space-y-4 p-5">
          <div class="space-y-2">
            <p class="text-xs uppercase tracking-[0.3em] text-sky-400">{{ product.category }}</p>
            <h3 class="text-xl font-semibold text-white">{{ product.name }}</h3>
            <p class="text-sm text-slate-300">{{ product.description }}</p>
          </div>
          <div class="flex items-center justify-between gap-3">
            <span class="text-lg font-bold text-white">{{ formatMoney(product.price) }}</span>
            <RouterLink
              :to="{ name: 'product-details', params: { slug: product.slug } }"
              class="rounded-full border border-white/10 px-4 py-2 text-sm font-medium text-white transition hover:bg-white/5"
            >
              View
            </RouterLink>
          </div>
        </div>
      </article>
    </div>
  </section>
</template>
EOF

  write_file "$TARGET_DIR/src/client/pages/ProductDetailsPage.vue" <<'EOF'
<script setup lang="ts">
import { computed, onMounted } from 'vue'
import { useRoute, RouterLink } from 'vue-router'
import BaseButton from '@/client/components/ui/BaseButton.vue'
import SectionHeading from '@/client/components/common/SectionHeading.vue'
import { useCartStore } from '@/client/stores/cart'
import { useProducts } from '@/client/composables/useProducts'
import { appRoutes } from '@/shared/constants/routes'
import { formatMoney } from '@/shared/utils/money'

const route = useRoute()
const { items, subtotal, updateQuantity, removeItem, clearCart } = useCartStore()
const { product, loading, error, fetchProductBySlug } = useProducts()

const slug = computed(() => String(route.params.slug ?? ''))

onMounted(() => {
  void fetchProductBySlug(slug.value)
})

function addToCart() {
  if (!product.value) {
    return
  }

  cart.addItem({
    id: product.value.id,
    name: product.value.name,
    price: product.value.price,
    quantity: 1,
    imageUrl: product.value.imageUrl,
  })
}
</script>

<template>
  <section class="space-y-6">
    <SectionHeading eyebrow="Product" title="Product details" />

    <p v-if="loading" class="text-sm text-slate-400">Loading product...</p>
    <p v-else-if="error" class="text-sm text-red-300">{{ error }}</p>

    <article
      v-else-if="product"
      class="grid gap-6 overflow-hidden rounded-3xl border border-white/10 bg-white/5 lg:grid-cols-[1.2fr_0.8fr]"
    >
      <img
        :src="product.imageUrl"
        :alt="product.name"
        class="h-full min-h-[24rem] w-full object-cover"
      />

      <div class="space-y-5 p-6">
        <p class="text-xs uppercase tracking-[0.3em] text-sky-400">{{ product.category }}</p>
        <h1 class="text-3xl font-semibold text-white">{{ product.name }}</h1>
        <p class="text-slate-300">{{ product.description }}</p>

        <div class="flex items-center gap-3">
          <span class="text-2xl font-bold text-white">{{ formatMoney(product.price) }}</span>
          <span class="rounded-full border border-white/10 px-3 py-1 text-xs text-slate-300">
            Stock: {{ product.stock }}
          </span>
        </div>

        <div class="flex flex-wrap gap-3">
          <BaseButton @click="addToCart">Add to cart</BaseButton>
          <RouterLink
            :to="appRoutes.cart"
            class="rounded-full border border-white/10 px-4 py-2 text-sm font-medium text-white transition hover:bg-white/5"
          >
            View cart
          </RouterLink>
        </div>
      </div>
    </article>
  </section>
</template>
EOF

  write_file "$TARGET_DIR/src/client/pages/CartPage.vue" <<'EOF'
<script setup lang="ts">
import { RouterLink } from 'vue-router'
import BaseButton from '@/client/components/ui/BaseButton.vue'
import SectionHeading from '@/client/components/common/SectionHeading.vue'
import { useCartStore } from '@/client/stores/cart'
import { appRoutes } from '@/shared/constants/routes'
import { formatMoney } from '@/shared/utils/money'

const cart = useCartStore()
</script>

<template>
  <section class="space-y-6">
    <SectionHeading
      eyebrow="Cart"
      title="Your cart"
      description="Keep cart state in Pinia and persist it with VueUse."
    />

    <div v-if="items.length > 0" class="space-y-4">
      <article
        v-for="item in items"
        :key="item.id"
        class="flex flex-col gap-4 rounded-3xl border border-white/10 bg-white/5 p-4 sm:flex-row sm:items-center"
      >
        <img :src="item.imageUrl" :alt="item.name" class="h-24 w-24 rounded-2xl object-cover" />

        <div class="flex-1">
          <h3 class="text-lg font-semibold text-white">{{ item.name }}</h3>
          <p class="text-sm text-slate-300">{{ formatMoney(item.price) }}</p>
        </div>

        <div class="flex items-center gap-3">
          <button
            type="button"
            class="rounded-full border border-white/10 px-3 py-1 text-white transition hover:bg-white/5"
            @click="updateQuantity(item.id, item.quantity - 1)"
          >
            -
          </button>
          <span class="min-w-8 text-center">{{ item.quantity }}</span>
          <button
            type="button"
            class="rounded-full border border-white/10 px-3 py-1 text-white transition hover:bg-white/5"
            @click="updateQuantity(item.id, item.quantity + 1)"
          >
            +
          </button>
        </div>

        <button
          type="button"
          class="rounded-full border border-white/10 px-4 py-2 text-sm text-white transition hover:bg-white/5"
          @click="removeItem(item.id)"
        >
          Remove
        </button>
      </article>

      <div class="flex flex-col gap-4 rounded-3xl border border-white/10 bg-white/5 p-5 sm:flex-row sm:items-center sm:justify-between">
        <div>
          <p class="text-sm text-slate-400">Subtotal</p>
          <p class="text-2xl font-bold text-white">{{ formatMoney(subtotal) }}</p>
        </div>

        <div class="flex flex-wrap gap-3">
          <BaseButton variant="secondary" @click="clearCart()">Clear cart</BaseButton>
          <RouterLink
            :to="appRoutes.checkout"
            class="rounded-full bg-sky-500 px-4 py-2 text-sm font-semibold text-slate-950 transition hover:bg-sky-400"
          >
            Checkout
          </RouterLink>
        </div>
      </div>
    </div>

    <div v-else class="rounded-3xl border border-white/10 bg-white/5 p-8 text-center">
      <p class="text-lg font-semibold text-white">Your cart is empty.</p>
      <RouterLink
        :to="appRoutes.catalog"
        class="mt-4 inline-flex rounded-full bg-sky-500 px-5 py-3 text-sm font-semibold text-slate-950 transition hover:bg-sky-400"
      >
        Browse products
      </RouterLink>
    </div>
  </section>
</template>
EOF

  write_file "$TARGET_DIR/src/client/pages/CheckoutPage.vue" <<'EOF'
<script setup lang="ts">
import { useToast } from 'vue-toastification'
import { useForm } from 'vee-validate'
import SectionHeading from '@/client/components/common/SectionHeading.vue'
import BaseButton from '@/client/components/ui/BaseButton.vue'
import { useCartStore } from '@/client/stores/cart'
import { checkoutSchema } from '@/shared/schemas/checkout'
import { formatMoney } from '@/shared/utils/money'

const { items, subtotalLabel, clearCart } = useCartStore()
const toast = useToast()

const initialValues = {
  fullName: '',
  email: '',
  address: '',
  city: '',
  country: '',
  notes: '',
}

const checkoutFieldSchemas = checkoutSchema.shape

type CheckoutFieldName = keyof typeof initialValues

const validateCheckoutField = (field: CheckoutFieldName) => (value: string) => {
  const result = checkoutFieldSchemas[field].safeParse(value)
  return result.success ? true : result.error.issues[0]?.message ?? 'Invalid value'
}

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
})

const [fullName, fullNameAttrs] = defineField('fullName')
const [email, emailAttrs] = defineField('email')
const [address, addressAttrs] = defineField('address')
const [city, cityAttrs] = defineField('city')
const [country, countryAttrs] = defineField('country')
const [notes, notesAttrs] = defineField('notes')

const submitCheckout = handleSubmit((values) => {
  toast.success(`Checkout ready for ${values.fullName}. Connect your payment provider next.`)
  clearCart()
  resetForm()
})
</script>

<template>
  <section class="space-y-6">
    <SectionHeading
      eyebrow="Checkout"
      title="Checkout"
      description="A form validation example using VeeValidate and Zod."
    />

    <div v-if="items.length === 0" class="rounded-3xl border border-white/10 bg-white/5 p-8 text-center">
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
        <BaseButton type="submit" class="w-full">Place order</BaseButton>
      </aside>
    </form>
  </section>
</template>
EOF

  write_file "$TARGET_DIR/src/client/pages/OrdersPage.vue" <<'EOF'
<script setup lang="ts">
import SectionHeading from '@/client/components/common/SectionHeading.vue'
</script>

<template>
  <section class="space-y-6">
    <SectionHeading
      eyebrow="Orders"
      title="Order history"
      description="This page is ready for order timelines, invoices, and return flows."
    />

    <div class="grid gap-4 md:grid-cols-2">
      <article class="rounded-3xl border border-white/10 bg-white/5 p-6">
        <h3 class="text-lg font-semibold text-white">Sample order #1024</h3>
        <p class="mt-2 text-sm text-slate-300">Delivered, 3 items, paid by card.</p>
      </article>
      <article class="rounded-3xl border border-white/10 bg-white/5 p-6">
        <h3 class="text-lg font-semibold text-white">Sample order #1025</h3>
        <p class="mt-2 text-sm text-slate-300">Processing, 1 item, awaiting shipment.</p>
      </article>
    </div>
  </section>
</template>
EOF

  write_file "$TARGET_DIR/src/client/pages/WishlistPage.vue" <<'EOF'
<script setup lang="ts">
import { RouterLink } from 'vue-router'
import SectionHeading from '@/client/components/common/SectionHeading.vue'
import { appRoutes } from '@/shared/constants/routes'
</script>

<template>
  <section class="space-y-6">
    <SectionHeading
      eyebrow="Wishlist"
      title="Saved items"
      description="Keep the wishlist page as its own route so it can grow without touching the catalog."
    />

    <div class="rounded-3xl border border-white/10 bg-white/5 p-8 text-center">
      <p class="text-white">No wishlist items yet.</p>
      <RouterLink
        :to="appRoutes.catalog"
        class="mt-4 inline-flex rounded-full bg-sky-500 px-5 py-3 text-sm font-semibold text-slate-950 transition hover:bg-sky-400"
      >
        Browse products
      </RouterLink>
    </div>
  </section>
</template>
EOF

  write_file "$TARGET_DIR/src/client/pages/AccountPage.vue" <<'EOF'
<script setup lang="ts">
import BaseButton from '@/client/components/ui/BaseButton.vue'
import SectionHeading from '@/client/components/common/SectionHeading.vue'
import { useAuthStore } from '@/client/stores/auth'

const { session, isSignedIn, signIn, signOut } = useAuthStore()

function signInDemo() {
  signIn(
    {
      id: 'demo-user',
      name: 'Demo Shopper',
      email: 'demo@store.dev',
      role: 'customer',
    },
    'demo-token',
  )
}
</script>

<template>
  <section class="space-y-6">
    <SectionHeading
      eyebrow="Account"
      title="Account"
      description="A lightweight session store that can later be wired to Better Auth or JWT flows."
    />

    <div v-if="isSignedIn" class="space-y-4 rounded-3xl border border-white/10 bg-white/5 p-6">
      <p class="text-white">
        Signed in as <strong>{{ session.user?.name }}</strong>
      </p>
      <p class="text-sm text-slate-300">{{ session.user?.email }}</p>
      <BaseButton variant="secondary" @click="signOut()">Sign out</BaseButton>
    </div>

    <div v-else class="space-y-4 rounded-3xl border border-white/10 bg-white/5 p-6">
      <p class="text-white">This scaffold uses a demo session to show the account flow.</p>
      <BaseButton @click="signInDemo">Sign in as demo user</BaseButton>
    </div>
  </section>
</template>
EOF

  write_file "$TARGET_DIR/src/client/pages/AdminDashboardPage.vue" <<'EOF'
<script setup lang="ts">
import SectionHeading from '@/client/components/common/SectionHeading.vue'
</script>

<template>
  <section class="space-y-6">
    <SectionHeading
      eyebrow="Admin"
      title="Admin dashboard"
      description="This route is reserved for product management, orders, stock, and reporting."
    />

    <div class="grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
      <article class="rounded-3xl border border-white/10 bg-white/5 p-5">
        <p class="text-sm text-slate-400">Revenue</p>
        <p class="mt-2 text-2xl font-bold text-white">$24,820</p>
      </article>
      <article class="rounded-3xl border border-white/10 bg-white/5 p-5">
        <p class="text-sm text-slate-400">Orders</p>
        <p class="mt-2 text-2xl font-bold text-white">184</p>
      </article>
      <article class="rounded-3xl border border-white/10 bg-white/5 p-5">
        <p class="text-sm text-slate-400">Low stock</p>
        <p class="mt-2 text-2xl font-bold text-white">7</p>
      </article>
      <article class="rounded-3xl border border-white/10 bg-white/5 p-5">
        <p class="text-sm text-slate-400">Customers</p>
        <p class="mt-2 text-2xl font-bold text-white">1,248</p>
      </article>
    </div>
  </section>
</template>
EOF
}

scaffold_shared_files() {
  write_file "$TARGET_DIR/src/shared/constants/routes.ts" <<'EOF'
export const appRoutes = {
  home: '/',
  catalog: '/catalog',
  productDetails: '/catalog/:slug',
  cart: '/cart',
  checkout: '/checkout',
  orders: '/orders',
  wishlist: '/wishlist',
  account: '/account',
  admin: '/admin',
} as const

export const apiRoutes = {
  base: '/api',
  health: '/health',
  graphql: '/graphql',
} as const
EOF

  write_file "$TARGET_DIR/src/shared/schemas/auth.ts" <<'EOF'
import { z } from 'zod'

export const loginSchema = z.object({
  email: z.string().email(),
  password: z.string().min(8),
})

export const registerSchema = loginSchema.extend({
  name: z.string().min(2),
})

export type LoginInput = z.infer<typeof loginSchema>
export type RegisterInput = z.infer<typeof registerSchema>
EOF

  write_file "$TARGET_DIR/src/shared/schemas/product.ts" <<'EOF'
import { z } from 'zod'

export const productSchema = z.object({
  id: z.string(),
  slug: z.string(),
  name: z.string().min(1),
  description: z.string().min(1),
  price: z.number().nonnegative(),
  imageUrl: z.string().url(),
  category: z.string().min(1),
  stock: z.number().int().nonnegative(),
  isFeatured: z.boolean(),
  createdAt: z.string(),
})

export const createProductSchema = productSchema.omit({
  id: true,
  slug: true,
  createdAt: true,
})

export type Product = z.infer<typeof productSchema>
export type CreateProductInput = z.infer<typeof createProductSchema>
EOF

  write_file "$TARGET_DIR/src/shared/schemas/checkout.ts" <<'EOF'
import { z } from 'zod'

export const checkoutSchema = z.object({
  fullName: z.string().min(2),
  email: z.string().email(),
  address: z.string().min(8),
  city: z.string().min(2),
  country: z.string().min(2),
  notes: z.string().max(500).optional().or(z.literal('')),
})

export type CheckoutInput = z.infer<typeof checkoutSchema>
EOF

  write_file "$TARGET_DIR/src/shared/schemas/index.ts" <<'EOF'
export * from './auth'
export * from './checkout'
export * from './product'
EOF

  write_file "$TARGET_DIR/src/shared/types/api.ts" <<'EOF'
export interface ApiResponse<T> {
  data: T
  message?: string
}

export interface PaginatedResponse<T> {
  data: T[]
  total: number
  page: number
  pageSize: number
}
EOF

  write_file "$TARGET_DIR/src/shared/types/index.ts" <<'EOF'
export * from './api'
EOF

  write_file "$TARGET_DIR/src/shared/utils/money.ts" <<'EOF'
export function formatMoney(amount: number, currency = 'USD', locale = 'en-US') {
  return new Intl.NumberFormat(locale, {
    style: 'currency',
    currency,
  }).format(amount)
}
EOF

  write_file "$TARGET_DIR/src/shared/utils/slug.ts" <<'EOF'
export function slugify(value: string) {
  return value
    .toLowerCase()
    .normalize('NFKD')
    .replace(/[\u0300-\u036f]/g, '')
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-+|-+$/g, '')
}
EOF
}

scaffold_server_files() {
  write_file "$TARGET_DIR/src/server/main.ts" <<'EOF'
import { createApp } from './app'
import { env } from './config/env'
import { logger } from './config/logger'

async function bootstrap() {
  const app = await createApp()

  app.listen(env.PORT, env.HOST, () => {
    logger.info(
      {
        port: env.PORT,
        host: env.HOST,
      },
      'server started',
    )
  })
}

void bootstrap().catch((error) => {
  logger.error(error, 'failed to start server')
  process.exit(1)
})
EOF

  write_file "$TARGET_DIR/src/server/app.ts" <<'EOF'
import express from 'express'
import cors from 'cors'
import helmet from 'helmet'
import morgan from 'morgan'
import { env } from './config/env'
import { httpStream } from './config/logger'
import { registerGraphQL } from './graphql'
import { apiRouter } from './routes'
import { errorHandler } from './middlewares/error-handler'
import { notFound } from './middlewares/not-found'

export async function createApp() {
  const app = express()
  const allowedOrigins = env.CORS_ORIGIN.split(',')
    .map((origin) => origin.trim())
    .filter(Boolean)

  const isLocalDevOrigin = (origin: string) =>
    env.NODE_ENV !== 'production' && /^https?:\/\/(localhost|127\.0\.0\.1)(:\d+)?$/.test(origin)

  app.disable('x-powered-by')
  app.use(helmet())
  app.use(
    cors({
      origin(origin, callback) {
        if (!origin || allowedOrigins.includes(origin) || isLocalDevOrigin(origin)) {
          callback(null, true)
          return
        }

        callback(new Error(`CORS blocked for origin: ${origin}`))
      },
      credentials: true,
    }),
  )
  app.use(express.json())
  app.use(express.urlencoded({ extended: true }))
  app.use(morgan(env.NODE_ENV === 'production' ? 'combined' : 'dev', { stream: httpStream }))
  app.use(env.API_PREFIX, apiRouter)

  await registerGraphQL(app)

  app.use(notFound)
  app.use(errorHandler)

  return app
}
EOF

  write_file "$TARGET_DIR/src/server/config/env.ts" <<'EOF'
import { config as loadEnv } from 'dotenv'
import { z } from 'zod'

loadEnv({ override: true, quiet: true })

const envSchema = z.object({
  NODE_ENV: z.enum(['development', 'test', 'production']).default('development'),
  PORT: z.coerce.number().int().positive().default(3000),
  HOST: z.string().default('0.0.0.0'),
  APP_NAME: z.string().default('Commerce Starter'),
  API_PREFIX: z.string().default('/api'),
  GRAPHQL_PATH: z.string().default('/graphql'),
  DATABASE_URL: z
    .string()
    .min(1)
    .default('postgresql://postgres:postgres@localhost:5432/commerce'),
  BETTER_AUTH_SECRET: z.string().min(16).default('change-me-in-production'),
  BETTER_AUTH_URL: z.string().url().default('http://localhost:3000'),
  JWT_SECRET: z.string().min(16).default('change-me-in-production'),
  CORS_ORIGIN: z.string().default('http://localhost:5173,http://localhost:5174'),
  REDIS_URL: z.string().optional(),
  MONGODB_URI: z.string().optional(),
})

export const env = envSchema.parse(process.env)
EOF

  write_file "$TARGET_DIR/src/server/config/logger.ts" <<'EOF'
import pino from 'pino'
import { env } from './env'

const transport =
  env.NODE_ENV === 'production'
    ? undefined
    : {
        target: 'pino-pretty',
        options: {
          colorize: true,
        },
      }

export const logger = pino({
  level: env.NODE_ENV === 'production' ? 'info' : 'debug',
  ...(transport ? { transport } : {}),
})

export const httpStream = {
  write(message: string) {
    logger.info(message.trim())
  },
}
EOF

  write_file "$TARGET_DIR/src/server/config/auth.ts" <<'EOF'
import argon2 from 'argon2'
import jwt from 'jsonwebtoken'
import { env } from './env'

export async function hashPassword(password: string) {
  return argon2.hash(password)
}

export async function verifyPassword(hash: string, password: string) {
  return argon2.verify(hash, password)
}

export function signSessionToken(payload: object) {
  return jwt.sign(payload, env.JWT_SECRET, { expiresIn: '7d' })
}
EOF

  write_file "$TARGET_DIR/src/server/routes/index.ts" <<'EOF'
import { Router } from 'express'
import { healthRouter } from './health'
import { authRouter } from '@/server/modules/auth/auth.routes'
import { productsRouter } from '@/server/modules/products/products.routes'
import { cartRouter } from '@/server/modules/cart/cart.routes'
import { ordersRouter } from '@/server/modules/orders/orders.routes'
import { paymentsRouter } from '@/server/modules/payments/payments.routes'

export const apiRouter = Router()

apiRouter.use('/health', healthRouter)
apiRouter.use('/auth', authRouter)
apiRouter.use('/products', productsRouter)
apiRouter.use('/cart', cartRouter)
apiRouter.use('/orders', ordersRouter)
apiRouter.use('/payments', paymentsRouter)
EOF

  write_file "$TARGET_DIR/src/server/routes/health.ts" <<'EOF'
import { Router } from 'express'
import asyncHandler from 'express-async-handler'
import { env } from '@/server/config/env'

export const healthRouter = Router()

healthRouter.get(
  '/',
  asyncHandler(async (_req, res) => {
    res.json({
      status: 'ok',
      service: env.APP_NAME,
      uptime: process.uptime(),
    })
  }),
)
EOF

  write_file "$TARGET_DIR/src/server/middlewares/not-found.ts" <<'EOF'
import type { Request, Response, NextFunction } from 'express'

export function notFound(_req: Request, res: Response, _next: NextFunction) {
  res.status(404).json({
    message: 'Route not found',
  })
}
EOF

  write_file "$TARGET_DIR/src/server/middlewares/error-handler.ts" <<'EOF'
import type { Request, Response, NextFunction } from 'express'

export function errorHandler(error: unknown, _req: Request, res: Response, _next: NextFunction) {
  const message = error instanceof Error ? error.message : 'Unexpected server error'
  const errorStatusCode =
    error && typeof error === 'object' && 'statusCode' in error
      ? (error as { statusCode?: unknown }).statusCode
      : undefined
  const statusCode = typeof errorStatusCode === 'number' ? errorStatusCode : 500

  res.status(statusCode).json({
    message,
  })
}
EOF

  write_file "$TARGET_DIR/src/server/db/client.ts" <<'EOF'
import { drizzle } from 'drizzle-orm/node-postgres'
import { Pool } from 'pg'
import { env } from '@/server/config/env'

export const pool = new Pool({
  connectionString: env.DATABASE_URL,
})

export const db = drizzle(pool)
EOF

  write_file "$TARGET_DIR/src/server/db/schema/index.ts" <<'EOF'
import { pgTable, uuid, text, integer, boolean, timestamp, numeric } from 'drizzle-orm/pg-core'

export const users = pgTable('users', {
  id: uuid('id').defaultRandom().primaryKey(),
  name: text('name').notNull(),
  email: text('email').notNull().unique(),
  role: text('role').notNull().default('customer'),
  createdAt: timestamp('created_at', { withTimezone: true }).notNull().defaultNow(),
})

export const products = pgTable('products', {
  id: uuid('id').defaultRandom().primaryKey(),
  slug: text('slug').notNull().unique(),
  name: text('name').notNull(),
  description: text('description').notNull(),
  imageUrl: text('image_url').notNull(),
  category: text('category').notNull(),
  price: numeric('price', { precision: 10, scale: 2 }).notNull(),
  stock: integer('stock').notNull().default(0),
  isFeatured: boolean('is_featured').notNull().default(false),
  createdAt: timestamp('created_at', { withTimezone: true }).notNull().defaultNow(),
})

export const carts = pgTable('carts', {
  id: uuid('id').defaultRandom().primaryKey(),
  userId: uuid('user_id').notNull(),
  createdAt: timestamp('created_at', { withTimezone: true }).notNull().defaultNow(),
})

export const cartItems = pgTable('cart_items', {
  id: uuid('id').defaultRandom().primaryKey(),
  cartId: uuid('cart_id').notNull(),
  productId: uuid('product_id').notNull(),
  quantity: integer('quantity').notNull().default(1),
})

export const orders = pgTable('orders', {
  id: uuid('id').defaultRandom().primaryKey(),
  userId: uuid('user_id').notNull(),
  status: text('status').notNull().default('pending'),
  totalAmount: numeric('total_amount', { precision: 10, scale: 2 }).notNull(),
  createdAt: timestamp('created_at', { withTimezone: true }).notNull().defaultNow(),
})

export const orderItems = pgTable('order_items', {
  id: uuid('id').defaultRandom().primaryKey(),
  orderId: uuid('order_id').notNull(),
  productId: uuid('product_id').notNull(),
  quantity: integer('quantity').notNull().default(1),
  unitPrice: numeric('unit_price', { precision: 10, scale: 2 }).notNull(),
})
EOF

  write_file "$TARGET_DIR/src/server/db/seed/index.ts" <<'EOF'
export async function seedDatabase() {
  return {
    message: 'Seed data is not wired yet.',
  }
}
EOF

  write_file "$TARGET_DIR/src/server/graphql/context.ts" <<'EOF'
import type { Request, Response } from 'express'
import { db } from '@/server/db/client'

export type GraphQLContext = {
  req: Request
  res: Response
  db: typeof db
}

export function createGraphQLContext(req: Request, res: Response): GraphQLContext {
  return {
    req,
    res,
    db,
  }
}
EOF

  write_file "$TARGET_DIR/src/server/graphql/typeDefs.ts" <<'EOF'
export const typeDefs = `#graphql
  type Health {
    status: String!
    uptime: Float!
  }

  type Product {
    id: ID!
    slug: String!
    name: String!
    description: String!
    imageUrl: String!
    category: String!
    price: Float!
    stock: Int!
    isFeatured: Boolean!
    createdAt: String!
  }

  type Query {
    hello: String!
    health: Health!
    products: [Product!]!
  }
`
EOF

  write_file "$TARGET_DIR/src/server/graphql/resolvers.ts" <<'EOF'
import { env } from '@/server/config/env'
import { listProducts } from '@/server/modules/products/products.service'

export const resolvers = {
  Query: {
    hello: () => 'Hello from ' + env.APP_NAME,
    health: () => ({
      status: 'ok',
      uptime: process.uptime(),
    }),
    products: () => listProducts(),
  },
}
EOF

  write_file "$TARGET_DIR/src/server/graphql/index.ts" <<'EOF'
import type { Express } from 'express'
import { ApolloServer } from '@apollo/server'
import { expressMiddleware } from '@as-integrations/express5'
import { env } from '@/server/config/env'
import { typeDefs } from './typeDefs'
import { resolvers } from './resolvers'
import { createGraphQLContext } from './context'

export async function registerGraphQL(app: Express) {
  const server = new ApolloServer({
    typeDefs,
    resolvers,
  })

  await server.start()

  app.use(
    env.GRAPHQL_PATH,
    expressMiddleware(server, {
      context: async ({ req, res }) => createGraphQLContext(req, res),
    }),
  )
}
EOF

  write_file "$TARGET_DIR/src/server/modules/auth/auth.service.ts" <<'EOF'
import { randomUUID } from 'node:crypto'
import { hashPassword, signSessionToken, verifyPassword } from '@/server/config/auth'

export type AuthSession = {
  token: string
  user: {
    id: string
    name: string
    email: string
    role: 'customer' | 'admin'
  }
}

export async function createDemoSession(email: string, name = 'Demo Shopper'): Promise<AuthSession> {
  const user = {
    id: randomUUID(),
    name,
    email,
    role: 'customer' as const,
  }

  return {
    token: signSessionToken({ sub: user.id, email: user.email, role: user.role }),
    user,
  }
}

export async function createPasswordRecord(password: string) {
  return hashPassword(password)
}

export async function verifyPasswordRecord(hash: string, password: string) {
  return verifyPassword(hash, password)
}
EOF

  write_file "$TARGET_DIR/src/server/modules/auth/auth.routes.ts" <<'EOF'
import { Router } from 'express'
import asyncHandler from 'express-async-handler'
import { loginSchema } from '@/shared/schemas/auth'
import { createDemoSession } from './auth.service'

export const authRouter = Router()

authRouter.post(
  '/login',
  asyncHandler(async (req, res) => {
    const body = loginSchema.parse(req.body)
    const session = await createDemoSession(body.email, 'Demo Shopper')

    res.json({
      data: session,
      message: 'Demo login completed.',
    })
  }),
)

authRouter.get(
  '/session',
  asyncHandler(async (_req, res) => {
    res.json({
      data: null,
      message: 'No active session in the scaffold yet.',
    })
  }),
)
EOF

  write_file "$TARGET_DIR/src/server/modules/products/products.service.ts" <<'EOF'
import type { Product } from '@/shared/schemas/product'
import { slugify } from '@/shared/utils/slug'

const seedProducts: Array<Omit<Product, 'id' | 'slug'> & { name: string }> = [
  {
    name: 'Canvas Backpack',
    description: 'A durable everyday backpack with hidden pockets and a weatherproof shell.',
    imageUrl: 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?auto=format&fit=crop&w=1200&q=80',
    category: 'Accessories',
    price: 89.0,
    stock: 24,
    isFeatured: true,
    createdAt: '2026-01-01T00:00:00.000Z',
  },
  {
    name: 'Minimal Sneakers',
    description: 'Lightweight sneakers designed for long days and clean storefront photography.',
    imageUrl: 'https://images.unsplash.com/photo-1525966222134-fcfa99b8ae77?auto=format&fit=crop&w=1200&q=80',
    category: 'Footwear',
    price: 129.0,
    stock: 18,
    isFeatured: true,
    createdAt: '2026-01-01T00:00:00.000Z',
  },
  {
    name: 'Everyday Hoodie',
    description: 'Soft heavyweight hoodie that works across product drops and casual collections.',
    imageUrl: 'https://images.unsplash.com/photo-1509942774463-ac5d2b36c814?auto=format&fit=crop&w=1200&q=80',
    category: 'Apparel',
    price: 74.0,
    stock: 42,
    isFeatured: false,
    createdAt: '2026-01-01T00:00:00.000Z',
  },
]

export function listProducts(): Product[] {
  return seedProducts.map((product) => ({
    id: slugify(product.name),
    slug: slugify(product.name),
    ...product,
  }))
}

export function getProductBySlug(slug: string): Product | null {
  return listProducts().find((product) => product.slug === slug) ?? null
}
EOF

  write_file "$TARGET_DIR/src/server/modules/products/products.routes.ts" <<'EOF'
import { Router } from 'express'
import asyncHandler from 'express-async-handler'
import { getProductBySlug, listProducts } from './products.service'

export const productsRouter = Router()

productsRouter.get(
  '/',
  asyncHandler(async (_req, res) => {
    res.json(listProducts())
  }),
)

productsRouter.get(
  '/:slug',
  asyncHandler(async (req, res) => {
    const slug = Array.isArray(req.params.slug) ? req.params.slug[0] : req.params.slug

    if (!slug) {
      res.status(400).json({
        message: 'Product slug is required',
      })
      return
    }

    const product = getProductBySlug(slug)

    if (!product) {
      res.status(404).json({
        message: 'Product not found',
      })
      return
    }

    res.json(product)
  }),
)
EOF

  write_file "$TARGET_DIR/src/server/modules/cart/cart.routes.ts" <<'EOF'
import { Router } from 'express'
import asyncHandler from 'express-async-handler'

export const cartRouter = Router()

cartRouter.get(
  '/',
  asyncHandler(async (_req, res) => {
    res.json({
      items: [],
      message: 'Cart persistence can be added here.',
    })
  }),
)
EOF

  write_file "$TARGET_DIR/src/server/modules/orders/orders.routes.ts" <<'EOF'
import { Router } from 'express'
import asyncHandler from 'express-async-handler'

export const ordersRouter = Router()

ordersRouter.get(
  '/',
  asyncHandler(async (_req, res) => {
    res.json([
      {
        id: 'order-1024',
        status: 'delivered',
        total: 218.0,
      },
      {
        id: 'order-1025',
        status: 'processing',
        total: 89.0,
      },
    ])
  }),
)
EOF

  write_file "$TARGET_DIR/src/server/modules/payments/payments.routes.ts" <<'EOF'
import { Router } from 'express'
import asyncHandler from 'express-async-handler'

export const paymentsRouter = Router()

paymentsRouter.get(
  '/',
  asyncHandler(async (_req, res) => {
    res.json({
      provider: 'stripe',
      status: 'not-configured',
    })
  }),
)
EOF

  write_file "$TARGET_DIR/src/server/services/.gitkeep" <<'EOF'
EOF

  write_file "$TARGET_DIR/src/server/utils/.gitkeep" <<'EOF'
EOF
}

scaffold_optional_features() {
  if [ "$WITH_REDIS" -eq 1 ]; then
    write_file "$TARGET_DIR/src/server/cache/redis.ts" <<'EOF'
import { createClient } from 'redis'
import { env } from '@/server/config/env'

export async function createRedisClient() {
  if (!env.REDIS_URL) {
    return null
  }

  const client = createClient({
    url: env.REDIS_URL,
  })

  client.on('error', (error) => {
    console.error('redis error', error)
  })

  await client.connect()
  return client
}
EOF
  fi

  if [ "$WITH_MONGO" -eq 1 ]; then
    write_file "$TARGET_DIR/src/server/db/mongo.ts" <<'EOF'
import mongoose from 'mongoose'
import { env } from '@/server/config/env'

export async function connectMongo() {
  if (!env.MONGODB_URI) {
    return null
  }

  await mongoose.connect(env.MONGODB_URI)
  return mongoose.connection
}
EOF
  fi
}

scaffold_feature_dirs() {
  touch_keep "$TARGET_DIR/src/client/assets"
  touch_keep "$TARGET_DIR/src/client/components/common"
  touch_keep "$TARGET_DIR/src/client/features/auth"
  touch_keep "$TARGET_DIR/src/client/features/catalog"
  touch_keep "$TARGET_DIR/src/client/features/cart"
  touch_keep "$TARGET_DIR/src/client/features/checkout"
  touch_keep "$TARGET_DIR/src/client/features/orders"
  touch_keep "$TARGET_DIR/src/client/features/payments"
  touch_keep "$TARGET_DIR/src/client/features/reviews"
  touch_keep "$TARGET_DIR/src/client/features/wishlist"
  touch_keep "$TARGET_DIR/src/client/features/admin"
  touch_keep "$TARGET_DIR/src/client/plugins"
  touch_keep "$TARGET_DIR/src/server/cache"
  touch_keep "$TARGET_DIR/src/server/db/migrations"
  touch_keep "$TARGET_DIR/src/server/modules/users"
  touch_keep "$TARGET_DIR/src/server/modules/categories"
  touch_keep "$TARGET_DIR/src/server/modules/checkout"
  touch_keep "$TARGET_DIR/src/server/modules/reviews"
  touch_keep "$TARGET_DIR/src/server/modules/coupons"
  touch_keep "$TARGET_DIR/src/server/modules/inventory"
  touch_keep "$TARGET_DIR/src/server/modules/shipping"
  touch_keep "$TARGET_DIR/src/server/modules/notifications"
  touch_keep "$TARGET_DIR/src/server/modules/admin"
}

maybe_init_git() {
  if [ "$INIT_GIT" -ne 1 ]; then
    return 0
  fi

  if [ -d "$TARGET_DIR/.git" ]; then
    log "skip  git init (repository already exists)"
    return 0
  fi

  if [ "$DRY_RUN" -eq 1 ]; then
    log "git   init $TARGET_DIR"
    return 0
  fi

  (
    cd "$TARGET_DIR"
    git init
  )
}

maybe_install() {
  if [ "$INSTALL_DEPS" -ne 1 ]; then
    return 0
  fi

  if ! command -v "$PACKAGE_MANAGER" >/dev/null 2>&1; then
    warn "package manager '$PACKAGE_MANAGER' is not available, skipping install"
    return 0
  fi

  if [ "$DRY_RUN" -eq 1 ]; then
    log "install via $PACKAGE_MANAGER"
    return 0
  fi

  (
    cd "$TARGET_DIR"
    case "$PACKAGE_MANAGER" in
      npm)
        npm install
        ;;
      pnpm)
        pnpm install
        ;;
      yarn)
        yarn install
        ;;
      bun)
        bun install
        ;;
      *)
        die "unsupported package manager: $PACKAGE_MANAGER"
        ;;
    esac
  )
}

main() {
  parse_args "$@"
  TARGET_DIR=$(trim_trailing_slash "$TARGET_DIR")

  if [ -z "$PROJECT_NAME" ]; then
    PROJECT_NAME=$(default_name_from_dir "$TARGET_DIR")
  fi
  PROJECT_NAME=$(sanitize_name "$PROJECT_NAME")
  [ -n "$PROJECT_NAME" ] || PROJECT_NAME='commerce-app'

  if [ "$DRY_RUN" -eq 0 ]; then
    mkdir -p "$TARGET_DIR"
  fi

  log "scaffolding project '$PROJECT_NAME' in '$TARGET_DIR'"

  scaffold_root_files
  scaffold_feature_dirs
  scaffold_client_files
  scaffold_shared_files
  scaffold_server_files
  scaffold_optional_features
  maybe_init_git
  maybe_install

  log "done"
}

main "$@"
