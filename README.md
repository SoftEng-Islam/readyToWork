# Commerce Starter

Commerce Starter is a full-stack Vue 3 + Express starter for storefronts, checkout flows, and admin dashboards. It ships with a styled SPA, REST and GraphQL entry points, shared TypeScript and Zod contracts, Drizzle schema definitions, and setup scripts for local onboarding.

## What Ships Today

- Vue 3 pages for home, catalog, product details, cart, checkout, orders, wishlist, account, and admin flows
- Express 5 API modules for health, auth, products, cart, orders, and payments
- Apollo GraphQL endpoint at `/graphql`
- Embedded Ruru GraphQL IDE served from the same GraphQL route in the browser
- Hosted Stripe Checkout session flow for the storefront checkout page
- Bruno collection under `bruno/` with runnable smoke tests for implemented APIs and contract requests for planned ones
- Shared Zod schemas and TypeScript types across client and server
- Drizzle schema definitions for users, products, carts, and orders
- Developer tooling with ESLint, Prettier, Vitest, and GitHub Actions CI
- `doctor.sh` to validate local setup and `create-project.sh` to scaffold the project structure

## Starter Status

This repository is a strong baseline, not a finished commerce platform. The catalog currently uses seeded demo data, and the auth, cart persistence, order processing, and payment modules are scaffold entry points that you can replace with real infrastructure.

## Stack

| Layer      | Tech                                                |
| ---------- | --------------------------------------------------- |
| Client     | Vue 3, Vite, Vue Router, Pinia                      |
| Styling    | Tailwind CSS 4, DaisyUI, Animate.css, VueUse Motion |
| Server     | Express 5, Apollo Server, GraphQL                   |
| Validation | Zod, VeeValidate                                    |
| Data       | Drizzle ORM, PostgreSQL                             |
| Auth       | Better Auth-ready scaffold                          |
| Tooling    | TypeScript, ESLint, Prettier, Vitest, pnpm          |

## Quick Start

### Requirements

- Node.js `>=20.19.0`
- pnpm `>=10.14.0`
- PostgreSQL

### Install

```bash
cp .env.example .env
pnpm install
pnpm check:setup
pnpm dev
```

### Local Endpoints

- App, REST, and GraphQL: `http://localhost:3000`
- REST health check: `http://localhost:3000/api/health`
- GraphQL API: `http://localhost:3000/graphql`
- Embedded Ruru UI: `http://localhost:3000/graphql`
- Stripe Checkout entry point: `POST http://localhost:3000/api/payments/checkout-session`
- Bruno collection root: `./bruno`

## Environment

Copy `.env.example` to `.env` and update the values that matter for your environment.

| Variable                | Purpose                                                    |
| ----------------------- | ---------------------------------------------------------- |
| `APP_NAME`              | Server-side application name used in logs and responses    |
| `VITE_APP_NAME`         | Brand name shown in the frontend                           |
| `PORT` / `HOST`         | Express bind settings                                      |
| `FRONTEND_URL`          | Frontend base URL used for checkout return redirects       |
| `API_PREFIX`            | REST API prefix, default `/api`                            |
| `GRAPHQL_PATH`          | GraphQL mount path, default `/graphql`                     |
| `DATABASE_URL`          | PostgreSQL connection string                               |
| `BETTER_AUTH_SECRET`    | Secret for auth/session signing                            |
| `BETTER_AUTH_URL`       | Public backend base URL                                    |
| `JWT_SECRET`            | Token signing secret for JWT-style flows                   |
| `REDIS_URL`             | Optional Redis connection string                           |
| `MONGODB_URI`           | Optional MongoDB connection string, enables startup wiring |
| `STRIPE_SECRET_KEY`     | Stripe secret key for hosted checkout sessions             |
| `STRIPE_WEBHOOK_SECRET` | Stripe webhook signing secret                              |
| `STRIPE_CURRENCY`       | Currency used when the backend builds Checkout line items  |
| `VITE_API_BASE_URL`     | Client base URL for REST calls, usually `/api`             |

If `MONGODB_URI` is set, the server now attempts a MongoDB connection during boot and exposes the result in both `/api/health` and `health` over GraphQL. Leave it empty to run without MongoDB.

Example:

```env
MONGODB_URI=mongodb://127.0.0.1:27017/commerce
```

## Bruno

The [`bruno/`](./bruno/) collection is organized by API domain.

- Requests tagged `current` map to endpoints that exist in the codebase today and include runnable tests.
- Requests tagged `planned` are API contracts for modules the project still needs, such as users, checkout, categories, inventory, reviews, coupons, shipping, notifications, and admin flows.
- Requests tagged `smoke` are the fastest way to validate the current stack after a change.

Update the collection variables in [`bruno/collection.bru`](./bruno/collection.bru) if your local base URLs or placeholder ids differ from the defaults.

## Stripe Checkout

The storefront checkout page now creates hosted Stripe Checkout Sessions through the backend. Full project-specific setup notes live in [`docs/stripe-checkout.md`](./docs/stripe-checkout.md).

## Useful Scripts

| Command            | Purpose                                                                   |
| ------------------ | ------------------------------------------------------------------------- |
| `pnpm dev`         | Run the Express server with Vite middleware in development                |
| `pnpm dev:server`  | Same as `pnpm dev`                                                        |
| `pnpm ruru`        | Run only the standalone Ruru CLI UI on `:1337`                            |
| `pnpm check:setup` | Verify local tooling, `.env`, PostgreSQL, and optional Mongo reachability |
| `pnpm lint`        | Lint the repo                                                             |
| `pnpm type-check`  | Type-check client and server code                                         |
| `pnpm test`        | Start Vitest in watch mode                                                |
| `pnpm test:run`    | Run the test suite once                                                   |
| `pnpm build`       | Type-check and build the client bundle for the Express server to serve    |
| `pnpm preview`     | Build and serve the production bundle through Express                     |
| `pnpm check`       | Run lint, type-check, tests, and build in one pass                        |
| `pnpm scaffold`    | Re-run the scaffold generator                                             |

## Project Structure

```text
src/
├─ client/    # Vue app, pages, layouts, stores, composables
├─ server/    # Express app, routes, GraphQL, db, middleware
└─ shared/    # Cross-cutting schemas, types, constants, utilities
```

## Publishing Checklist

Before turning this into a public GitHub repository, update the project-specific values that should not stay generic:

1. Set `APP_NAME` and `VITE_APP_NAME` to your real product name.
2. Replace placeholder secrets in `.env` and keep `.env` out of version control.
3. Add `repository`, `homepage`, and `bugs` fields to `package.json` after the GitHub repo exists.
4. Decide which scaffolded modules stay demo-only and which ones need production wiring before launch.
5. Enable the included GitHub Actions workflow and branch protections in the new repository.

## Documentation

- Project guides live in [docs/README.md](./docs/README.md).
- Beginner-friendly setup notes live in [Overview.md](./Overview.md).
- Ruru usage notes live in [RURU.md](./RURU.md).
- Stripe Checkout notes live in [docs/stripe-checkout.md](./docs/stripe-checkout.md).
- Contribution guidance lives in [CONTRIBUTING.md](./CONTRIBUTING.md).
- Security reporting guidance lives in [SECURITY.md](./SECURITY.md).

## License

This project is available under the [MIT License](./LICENSE).
