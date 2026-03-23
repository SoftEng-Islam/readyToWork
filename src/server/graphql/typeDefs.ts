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
