import { describe, expect, it } from 'vitest';
import { getProductBySlug, listProducts } from './products.service';

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

  it('returns null for an unknown slug', () => {
    expect(getProductBySlug('missing-product')).toBeNull();
  });
});
