import type { Product } from '@/shared/schemas/product';
import { slugify } from '@/shared/utils/slug';

const seedProducts: Array<Omit<Product, 'id' | 'slug'> & { name: string }> = [
  {
    name: 'Canvas Backpack',
    description: 'A durable everyday backpack with hidden pockets and a weatherproof shell.',
    imageUrl:
      'https://images.unsplash.com/photo-1542291026-7eec264c27ff?auto=format&fit=crop&w=1200&q=80',
    category: 'Accessories',
    price: 89.0,
    stock: 24,
    isFeatured: true,
    createdAt: '2026-01-01T00:00:00.000Z',
  },
  {
    name: 'Minimal Sneakers',
    description: 'Lightweight sneakers designed for long days and clean storefront photography.',
    imageUrl:
      'https://images.unsplash.com/photo-1525966222134-fcfa99b8ae77?auto=format&fit=crop&w=1200&q=80',
    category: 'Footwear',
    price: 129.0,
    stock: 18,
    isFeatured: true,
    createdAt: '2026-01-01T00:00:00.000Z',
  },
  {
    name: 'Everyday Hoodie',
    description: 'Soft heavyweight hoodie that works across product drops and casual collections.',
    imageUrl:
      'https://images.unsplash.com/photo-1509942774463-ac5d2b36c814?auto=format&fit=crop&w=1200&q=80',
    category: 'Apparel',
    price: 74.0,
    stock: 42,
    isFeatured: false,
    createdAt: '2026-01-01T00:00:00.000Z',
  },
];

export function listProducts(): Product[] {
  return seedProducts.map((product) => ({
    id: slugify(product.name),
    slug: slugify(product.name),
    ...product,
  }));
}

export function getProductBySlug(slug: string): Product | null {
  return listProducts().find((product) => product.slug === slug) ?? null;
}

export function getProductById(id: string): Product | null {
  return listProducts().find((product) => product.id === id) ?? null;
}
