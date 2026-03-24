export const typeDefs = `#graphql
  type MongoHealth {
    enabled: Boolean!
    state: String!
    host: String
    name: String
  }

  type Health {
    status: String!
    service: String!
    uptime: Float!
    mongo: MongoHealth!
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
`;
