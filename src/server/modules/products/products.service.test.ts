import { describe, expect, it } from 'vitest';
import { getProductById, getProductBySlug, listProducts } from './products.service';

describe('products.service', () => {
  it('returns the seeded demo catalog with stable slugs', () => {
    const products = listProducts();

    expect(products.map((product) => product.slug)).toEqual(
      expect.arrayContaining(['canvas-backpack', 'minimal-sneakers', 'everyday-hoodie']),
    );
  });

  it('looks up products by slug', () => {
    expect(getProductBySlug('minimal-sneakers')).toMatchObject({
      name: 'Minimal Sneakers',
      slug: 'minimal-sneakers',
    });
  });

  it('looks up products by id', () => {
    expect(getProductById('canvas-backpack')).toMatchObject({
      id: 'canvas-backpack',
      name: 'Canvas Backpack',
    });
  });

  it('returns null for an unknown slug', () => {
    expect(getProductBySlug('missing-product')).toBeNull();
  });
});
