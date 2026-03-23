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
