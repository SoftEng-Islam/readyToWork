import type { Express, RequestHandler } from 'express';
import { ApolloServer } from '@apollo/server';
import { expressMiddleware } from '@as-integrations/express5';
import { ruruHTML } from 'ruru/server';
import { serveStatic } from 'ruru/static';
import { env } from '@/server/config/env';
import { typeDefs } from './typeDefs';
import { resolvers } from './resolvers';
import { createGraphQLContext } from './context';

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
