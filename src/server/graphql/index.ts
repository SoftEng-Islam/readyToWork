import type { Express, RequestHandler } from 'express';
import { ApolloServer } from '@apollo/server';
import { expressMiddleware } from '@as-integrations/express5';
import { ruruHTML } from 'ruru/server';
import { serveStatic } from 'ruru/static';
import { env } from '@/server/config/env';
import { typeDefs } from './typeDefs';
import { resolvers } from './resolvers';
import { createGraphQLContext } from './context';

const ruruContentSecurityPolicy = [
  "default-src 'self'",
  "base-uri 'self'",
  "connect-src 'self' ws: wss:",
  "font-src 'self' https: data:",
  "form-action 'self'",
  "frame-ancestors 'self'",
  "img-src 'self' data: blob:",
  "object-src 'none'",
  "script-src 'self' 'unsafe-inline'",
  "script-src-attr 'none'",
  "style-src 'self' https: 'unsafe-inline'",
  "worker-src 'self' blob:",
].join('; ');

function normalizePath(pathname: string) {
  if (pathname.startsWith('/')) {
    return pathname;
  }

  return `/${pathname}`;
}

export async function registerGraphQL(app: Express) {
  const server = new ApolloServer({
    typeDefs,
    resolvers,
  });
  const graphqlPath = normalizePath(env.GRAPHQL_PATH);
  const ruruStaticPath = `${graphqlPath.replace(/\/$/, '')}/ruru-static/`;

  await server.start();

  app.get(graphqlPath, (req, res, next) => {
    if (!req.accepts('html')) {
      next();
      return;
    }

    res
      .status(200)
      .type('html')
      .setHeader('Content-Security-Policy', ruruContentSecurityPolicy)
      .send(
        ruruHTML({
          endpoint: graphqlPath,
          staticPath: ruruStaticPath,
        }),
      );
  });

  app.use(serveStatic(ruruStaticPath) as RequestHandler);
  app.use(
    graphqlPath,
    expressMiddleware(server, {
      context: async ({ req, res }) => createGraphQLContext(req, res),
    }),
  );
}
