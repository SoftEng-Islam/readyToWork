# Overview

This file is the simple guide.
Think of this project like a toy shop made from two big parts:

- The front part: the website people see in the browser
- The back part: the server and database that do the work behind the curtain

This starter already gives you both.

## 1. What This Project Uses

This project uses these main tools:

- `Node.js`: runs JavaScript and TypeScript on your computer or server
- `pnpm`: installs packages faster than npm
- `Vue 3`: builds the website pages
- `Vite`: starts the website fast while you build
- `Express`: runs the backend server
- `TypeScript`: helps catch mistakes early
- `PostgreSQL`: stores data like users, products, and orders
- `Drizzle ORM`: talks to PostgreSQL using TypeScript
- `Tailwind CSS` and `DaisyUI`: make the UI look good
- `GraphQL` with Apollo Server: lets the client ask the server for data
- `Zod`: checks if data is valid
- `Better Auth`: planned auth tool for real sign-in systems

## 2. What You Must Install On Your PC

To start working, install these things:

- `Git`
- `Node.js` version `20.19.0` or newer
- `pnpm` version `10.14.0` or newer
- `PostgreSQL`
- A code editor like `VS Code`
- A browser like `Chrome` or `Firefox`

## 3. What You Must Install On A Server

If you want to run this project on a real server, install these too:

- `Git`
- `Node.js` version `20.19.0` or newer
- `pnpm`
- `PostgreSQL`
- A process runner like `pm2` or `systemd` so the app stays alive
- Optional but common: `Nginx` as a reverse proxy

You do **not** need these to start:

- `MongoDB`
- `Redis`

They are optional.

## 4. Before You Start

Open a terminal inside the project folder.

If you are on normal Linux, macOS, or Windows:

```bash
pnpm install
```

If you are on `NixOS`:

- Do not run `corepack enable`
- Just use the system `pnpm` command directly

Then run:

```bash
pnpm install
```

## 5. Make Your Environment File

This project needs a `.env` file.
That file is where secrets and settings live.

Copy the example file:

```bash
cp .env.example .env
```

Now you have a real `.env` file.

## 6. What The Important .env Values Mean

Open `.env` and check these values:

```env
PORT=3000
DATABASE_URL=postgresql://postgres:postgres@localhost:5432/commerce
BETTER_AUTH_SECRET=replace-with-a-long-random-string
BETTER_AUTH_URL=http://localhost:3000
JWT_SECRET=replace-with-a-long-random-string
CORS_ORIGIN=http://localhost:5173,http://localhost:5174
VITE_API_BASE_URL=http://localhost:3000/api
```

Easy meaning:

- `PORT`: where the backend server runs
- `DATABASE_URL`: how the app finds PostgreSQL
- `BETTER_AUTH_SECRET`: secret key for auth
- `BETTER_AUTH_URL`: backend base URL
- `JWT_SECRET`: secret key for tokens
- `CORS_ORIGIN`: which browser addresses are allowed to talk to the API
- `VITE_API_BASE_URL`: where the frontend sends API requests

## 7. PostgreSQL Quick Guide

You need PostgreSQL running before the app can really use the database.

This starter expects this local setup by default:

- user: `postgres`
- password: `postgres`
- database: `commerce`
- port: `5432`

That matches this default `.env` value:

```env
DATABASE_URL=postgresql://postgres:postgres@localhost:5432/commerce
```

If your PostgreSQL setup is different, that is fine.
Just change `DATABASE_URL` in `.env`.

Example:

```env
DATABASE_URL=postgresql://myuser:mypassword@localhost:5432/mydatabase
```

### How To Run PostgreSQL

How you start PostgreSQL depends on how you installed it:

- On many Linux systems: `sudo systemctl start postgresql`
- On macOS with Homebrew: `brew services start postgresql`
- On Windows: start the PostgreSQL service from the Services app

If PostgreSQL is already running in the background, you do not need to start it again.

### How To Check If PostgreSQL Is Running

These commands are useful:

```bash
pg_isready -h localhost -p 5432 -U postgres
psql postgresql://postgres:postgres@localhost:5432/commerce -c "select 1"
```

If those commands work, PostgreSQL is running and the login details are probably correct.

You can also run:

```bash
pnpm check:setup
```

That script checks whether PostgreSQL is reachable for this project.

### How To Create A Database

If the `commerce` database does not exist yet, create it.

Using the command line:

```bash
createdb -U postgres -h localhost -p 5432 commerce
```

Or from inside `psql`:

```sql
CREATE DATABASE commerce;
```

If you want a different database name, create that database and then put the same name in `DATABASE_URL`.

### How To Connect And Work With PostgreSQL

Use `psql` to open PostgreSQL from the terminal:

```bash
psql postgresql://postgres:postgres@localhost:5432/commerce
```

Or with separated flags:

```bash
psql -U postgres -h localhost -p 5432 -d commerce
```

Useful `psql` commands:

- `\l` = list databases
- `\c commerce` = connect to the `commerce` database
- `\dt` = list tables
- `\d table_name` = describe one table
- `\q` = quit `psql`

Simple SQL examples:

```sql
SELECT current_database();
SELECT now();
```

### How To Delete A Database

Be careful with this because deleting a database removes all of its data.

Using the command line:

```bash
dropdb -U postgres -h localhost -p 5432 commerce
```

Or from inside `psql`:

```sql
DROP DATABASE commerce;
```

You usually cannot drop a database while you are connected to it.
If needed, first connect to another database like `postgres`, then run the drop command.

### How This Project Works With PostgreSQL

After PostgreSQL is running and the database exists, these project commands matter:

```bash
pnpm db:generate
pnpm db:migrate
pnpm db:studio
```

Easy meaning:

- `pnpm db:generate`: create Drizzle migration files after schema changes
- `pnpm db:migrate`: apply migrations to PostgreSQL
- `pnpm db:studio`: open Drizzle Studio to inspect your data

Normal flow:

1. Start PostgreSQL.
2. Make sure the database exists.
3. Check `DATABASE_URL` in `.env`.
4. Run `pnpm db:migrate`.
5. Run `pnpm dev`.

## 8. Start The Project

Run this:

```bash
pnpm dev
```

This starts two things:

- The frontend website with Vite
- The backend API server with Express

Usually you will get:

- Frontend: `http://localhost:5173/`
- Backend: `http://localhost:3000/`

Sometimes Vite uses `5174` if `5173` is busy.
That is okay.
This project is already ready for that.

## 9. Useful Links While Developing

After the app starts, these are useful:

- Website: `http://localhost:5173/` or `http://localhost:5174/`
- API health check: `http://localhost:3000/api/health`
- GraphQL endpoint: `http://localhost:3000/graphql`

## 10. Useful Commands

Use these a lot:

```bash
pnpm dev
pnpm check:setup
pnpm build
pnpm start
pnpm type-check
pnpm lint
pnpm test
pnpm db:generate
pnpm db:migrate
pnpm db:studio
```

What they do:

- `pnpm dev`: run the app in development mode
- `pnpm check:setup`: check if the main tools are installed and if PostgreSQL is reachable
- `pnpm build`: check types and build the frontend
- `pnpm start`: run the backend server
- `pnpm type-check`: check TypeScript errors
- `pnpm lint`: check code style problems
- `pnpm test`: run tests
- `pnpm db:generate`: make Drizzle migration files
- `pnpm db:migrate`: apply database changes
- `pnpm db:studio`: open Drizzle Studio

## 11. Folder Map

This is the simple map:

- `src/client`: frontend app
- `src/server`: backend app
- `src/shared`: shared code used by both sides
- `src/server/db`: database files
- `src/server/graphql`: GraphQL files
- `src/server/modules`: backend features like products, auth, cart, orders
- `src/client/pages`: app pages
- `src/client/components`: reusable UI pieces
- `src/client/stores`: frontend state

## 12. First Day Checklist

If you are a new developer, do this in order:

1. Install Node.js, pnpm, PostgreSQL, Git, and VS Code.
2. Clone the project.
3. Open the project folder.
4. Run `cp .env.example .env`.
5. Make sure PostgreSQL is running.
6. Make sure the database in `DATABASE_URL` exists.
7. Run `pnpm install`.
8. Run `pnpm check:setup`.
9. Run `pnpm dev`.
10. Open the website in the browser.
11. Open the health check URL.

If all of that works, you are ready.

## 13. First Day Checklist For A Server

If you are preparing a real server, do this:

1. Install Node.js, pnpm, PostgreSQL, and Git.
2. Clone the project on the server.
3. Create `.env`.
4. Set real secrets, not demo secrets.
5. Make sure PostgreSQL is reachable from the server.
6. Run `pnpm install`.
7. Run `pnpm build`.
8. Run `pnpm start` or use `pm2`.
9. Put `Nginx` in front if you want a public domain.
10. Use HTTPS in production.

## 14. Things You Should Change Before Production

Do not keep the demo values.
Change these:

- `BETTER_AUTH_SECRET`
- `JWT_SECRET`
- `DATABASE_URL`
- `BETTER_AUTH_URL`
- `CORS_ORIGIN`

Also make sure:

- PostgreSQL uses a strong password
- The server firewall is set correctly
- HTTPS is enabled
- Logs are saved somewhere safe

## 15. Common Problems

### Problem: `pnpm` is not found

Fix:

- Install pnpm first
- Then run `pnpm install`

### Problem: `DATABASE_URL` error

Fix:

- Make sure `.env` exists
- Make sure PostgreSQL is running
- Make sure the database name in `.env` is correct

### Problem: Vite starts on `5174`

Fix:

- Nothing is wrong
- Port `5173` was busy, so Vite picked another free port

### Problem: The server starts but database features fail

Fix:

- PostgreSQL is not ready
- Or the username, password, port, or database name in `DATABASE_URL` is wrong

### Problem: Build-script warnings from pnpm

Fix:

- This project is already configured for the required packages
- Run `pnpm rebuild` if you ever need to rebuild local binaries again

## 16. Optional Tools You Can Add Later

You may add these later if your app needs them:

- `Redis` for caching
- `MongoDB` for extra document storage

## 15. MongoDB Support

MongoDB support is now wired into the server, but it stays optional until you set `MONGODB_URI`.

Example:

```env
MONGODB_URI=mongodb://127.0.0.1:27017/commerce
```

How it works:

- If `MONGODB_URI` is empty, the server starts without MongoDB.
- If `MONGODB_URI` has a value, the server tries to connect to MongoDB during startup.
- The REST health route and the GraphQL health query both report the MongoDB connection state.

This means MongoDB is ready for future modules like:

- user profiles
- notifications
- activity logs
- product reviews

## 16. Bruno API Collection

This project has a `bruno/` folder for API testing in Bruno.

How it is arranged now:

- requests tagged `current` match APIs that already exist in the server
- requests tagged `planned` are future API contracts you can implement next
- requests tagged `smoke` are the fastest checks for health, auth, products, and GraphQL

Important current requests include:

- `GET /api/health`
- `POST /api/auth/login`
- `GET /api/auth/session`
- `GET /api/products`
- `GET /api/products/:slug`
- `GET /api/cart`
- `GET /api/orders`
- `GET /api/payments`
- `POST /graphql`

Planned requests are also prepared for:

- users
- checkout
- categories
- inventory
- reviews
- coupons
- shipping
- notifications
- admin endpoints
- `Nginx` for reverse proxy
- `pm2` for process management
- Docker if your team likes containers

## 17. Very Short Version

If you want the tiny version:

```bash
cp .env.example .env
pnpm install
pnpm check:setup
pnpm dev
```

Then open the browser and start building.
