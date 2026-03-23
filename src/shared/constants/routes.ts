export const appRoutes = {
  home: '/',
  catalog: '/catalog',
  productDetails: '/catalog/:slug',
  cart: '/cart',
  checkout: '/checkout',
  orders: '/orders',
  wishlist: '/wishlist',
  account: '/account',
  admin: '/admin',
} as const

export const apiRoutes = {
  base: '/api',
  health: '/health',
  graphql: '/graphql',
} as const
