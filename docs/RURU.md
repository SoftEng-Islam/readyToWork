# Ruru In This Project

This project already has `ruru` installed and available in the app.

- Package dependency: [package.json](/data/github/dev.readyToWork/package.json)
- GraphQL registration: [src/server/graphql/index.ts](/data/github/dev.readyToWork/src/server/graphql/index.ts)

## What Ruru Is

Ruru is a GraphQL IDE from the Grafast project. According to the official docs, it is a GraphiQL distribution that is designed to be easy to deploy and can be embedded directly into a Node.js server.

Official references:

- https://grafast.org/ruru/
- https://grafast.org/ruru/server

## How It Works Here

In this repo, GraphQL is still served by Apollo Server, but the browser UI is now provided by Ruru.

- `GET {{GRAPHQL_PATH}}` serves the Ruru interface when the request accepts HTML.
- `POST {{GRAPHQL_PATH}}` continues to serve the GraphQL API.
- Ruru static assets are served from `{{GRAPHQL_PATH}}/ruru-static/`.

With the default `.env`, that means:

- GraphQL API: `http://localhost:3000/graphql`
- Ruru UI: `http://localhost:3000/graphql`
- Ruru static assets: `http://localhost:3000/graphql/ruru-static/`

## How To Use It

1. Start the app:

```bash
pnpm dev
```

2. Open the Ruru UI in your browser:

```text
http://localhost:3000/graphql
```

3. Run a query, for example:

```graphql
query HealthAndProducts {
  hello
  health {
    status
    service
    mongo {
      enabled
      state
    }
  }
  products {
    id
    slug
    name
    price
  }
}
```

## Using The Ruru CLI

The official Ruru CLI docs say the CLI requires Node 22+ and is useful because it can proxy requests to work around CORS issues.

Official CLI reference:

- https://grafast.org/ruru/cli

Since `ruru` is already installed in this project, you do not need to install it again. You can run it through `pnpm exec`.

### Basic CLI Usage For This Repo

Start your app first:

```bash
pnpm dev
```

Then start the Ruru CLI in a second terminal:

```bash
pnpm exec ruru -Pe http://localhost:3000/graphql
```

Then open:

```text
http://localhost:1337
```

That command means:

- `-e`: the GraphQL endpoint to target
- `-P`: proxy GraphQL requests through the CLI server so CORS does not get in your way

### Useful CLI Options

The official CLI page documents these options:

- `-e, --endpoint`: query and mutation endpoint
- `-p, --port`: port for the Ruru CLI server, default `1337`
- `-P, --proxy`: proxy requests to bypass CORS issues
- `-S, --subscriptions`: enable subscriptions and derive a websocket endpoint automatically
- `-s, --subscription-endpoint`: explicitly set the websocket subscription endpoint

### Example Commands

Use the default port:

```bash
pnpm exec ruru -Pe http://localhost:3000/graphql
```

Use a different local Ruru port:

```bash
pnpm exec ruru -p 1400 -Pe http://localhost:3000/graphql
```

Use the repo's GraphQL path from `.env` if you changed it:

```bash
pnpm exec ruru -Pe http://localhost:3000/your-graphql-path
```

If you later add GraphQL subscriptions to this server, a CLI command would look like:

```bash
pnpm exec ruru -SPe http://localhost:3000/graphql
```

Or with an explicit websocket endpoint:

```bash
pnpm exec ruru -Pe http://localhost:3000/graphql -s ws://localhost:3000/graphql
```

### When To Use CLI vs The Embedded Ruru Page

Use the embedded page at `/graphql` when:

- you want the simplest setup
- you want the IDE served by the same Express app
- you do not need a separate proxy server

Use the CLI when:

- you want to inspect another GraphQL API quickly
- you want proxy mode to avoid CORS problems
- you want a separate local debugging UI without changing the app server

### Important Note About Node Version

This project currently allows Node `>=20.19.0`, but the official Ruru CLI docs say the CLI requires Node 22+.

That means:

- the embedded Ruru page in this project can still be used with the app's normal runtime
- the standalone `ruru` CLI should be run on Node 22 or newer

## Useful Notes

- If you open `/graphql` in a browser, Ruru will render.
- If your client sends `POST /graphql`, it still hits Apollo Server normally.
- The endpoint path comes from `GRAPHQL_PATH` in `.env`.
- If you change `GRAPHQL_PATH`, Ruru follows that same path automatically because both the HTML and the API are registered from the same env value.
- If you use the CLI instead of the embedded page, the default Ruru UI URL is `http://localhost:1337` unless you change it with `-p`.

## Implementation Summary

The server uses the official Ruru server helpers:

- `ruruHTML(...)` from `ruru/server` to generate the IDE HTML
- `serveStatic(...)` from `ruru/static` to serve the static assets locally

This matches the official Grafast recommendation for Node/Express-style servers, adapted to the existing Apollo + Express setup in this repo.
