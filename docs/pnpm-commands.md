# PNPM Commands Guide

This document lists the most useful `pnpm` commands specifically tailored for this modern Vue + Express E-commerce starter project.

## 🚀 Running the Project

- **`pnpm dev`**
  Runs the Express app in development mode with Vite middleware.

- **`pnpm dev:server`**
  Same as `pnpm dev`.

## 🛠️ Utilities & Tools

- **`pnpm ruru`**
  Starts Ruru (a modern GraphQL IDE) on `http://localhost:1337/` which proxies requests to your API. *Note: Ensure your backend is running (`pnpm dev` or `pnpm dev:server`) before launching this!*

- **`pnpm check`**
  A comprehensive check script that runs your linter, TypeScript compiler checks, tests, and a test build. Perfect to run before committing code.

## 🗄️ Database Operations (Drizzle ORM)

- **`pnpm db:generate`**
  Generates new SQL migration files based on updates to your Drizzle schema.

- **`pnpm db:migrate`**
  Applies the generated migrations to your active database.

- **`pnpm db:studio`**
  Opens Drizzle Studio in your browser, providing a visual UI to explore and edit your database tables.

## 🧪 Testing (Vitest)

- **`pnpm test`**
  Runs tests in watch mode.

- **`pnpm test:run`**
  Runs tests exactly once (useful for CI environments).

- **`pnpm test:ui`**
  Opens the fancy Vitest UI in your browser to inspect test runs.

- **`pnpm coverage`**
  Generates a test coverage report for your code.

## 🧹 Code Quality

- **`pnpm format`**
  Automatically formats your codebase using Prettier.

- **`pnpm lint`**
  Runs ESLint to find issues in your JavaScript/TypeScript/Vue code.

- **`pnpm type-check`**
  Verifies your TypeScript types across both the frontend and backend without emitting compiled files.

---

## 📦 General `pnpm` Package Management

While outside of your predefined scripts, these are essential commands for managing your project dependencies:

- **`pnpm install`** (or `pnpm i`)
  Installs all dependencies listed in your `package.json`.

- **`pnpm add <package>`**
  Installs a new package as a runtime dependency.

- **`pnpm add -D <package>`**
  Installs a new package as a development dependency.

- **`pnpm remove <package>`**
  Uninstalls a package.

- **`pnpm update --interactive --latest`**
  Provides a visual, interactive menu in your terminal to safely upgrade your packages to their newest versions.
