# Commerce Starter

Commerce Starter is a full-stack Vue 3 + Express starter for storefronts, checkout flows, and admin dashboards. It ships with a styled SPA, REST and GraphQL entry points, shared TypeScript and Zod contracts, Drizzle schema definitions, and setup scripts for local onboarding.

## What Ships Today

- Vue 3 pages for home, catalog, product details, cart, checkout, orders, wishlist, account, and admin flows
- Express 5 API modules for health, auth, products, cart, orders, and payments
- Apollo GraphQL endpoint at `/graphql`
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

- Frontend: `http://localhost:5173`
- REST health check: `http://localhost:3000/api/health`
- GraphQL: `http://localhost:3000/graphql`

## Environment

Copy `.env.example` to `.env` and update the values that matter for your environment.

| Variable                    | Purpose                                                 |
| --------------------------- | ------------------------------------------------------- |
| `APP_NAME`                  | Server-side application name used in logs and responses |
| `VITE_APP_NAME`             | Brand name shown in the frontend                        |
| `PORT` / `HOST`             | Express bind settings                                   |
| `API_PREFIX`                | REST API prefix, default `/api`                         |
| `GRAPHQL_PATH`              | GraphQL mount path, default `/graphql`                  |
| `DATABASE_URL`              | PostgreSQL connection string                            |
| `BETTER_AUTH_SECRET`        | Secret for auth/session signing                         |
| `BETTER_AUTH_URL`           | Public backend base URL                                 |
| `JWT_SECRET`                | Token signing secret for JWT-style flows                |
| `CORS_ORIGIN`               | Allowed browser origins, comma-separated                |
| `REDIS_URL` / `MONGODB_URI` | Optional integrations for extended builds               |
| `VITE_API_BASE_URL`         | Client base URL for REST calls                          |

## Useful Scripts

| Command            | Purpose                                                   |
| ------------------ | --------------------------------------------------------- |
| `pnpm dev`         | Run the Vite client and Express server together           |
| `pnpm dev:client`  | Run only the frontend                                     |
| `pnpm dev:server`  | Run only the backend                                      |
| `pnpm check:setup` | Verify local tooling, `.env`, and PostgreSQL reachability |
| `pnpm lint`        | Lint the repo                                             |
| `pnpm type-check`  | Type-check client and server code                         |
| `pnpm test`        | Start Vitest in watch mode                                |
| `pnpm test:run`    | Run the test suite once                                   |
| `pnpm build`       | Type-check and build the client bundle                    |
| `pnpm check`       | Run lint, type-check, tests, and build in one pass        |
| `pnpm scaffold`    | Re-run the scaffold generator                             |

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

- Beginner-friendly setup notes live in [Overview.md](./Overview.md).
- Contribution guidance lives in [CONTRIBUTING.md](./CONTRIBUTING.md).
- Security reporting guidance lives in [SECURITY.md](./SECURITY.md).

## License

This project is available under the [MIT License](./LICENSE).
