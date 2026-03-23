import { describe, expect, it } from 'vitest';
import { slugify } from './slug';

describe('slugify', () => {
  it('normalizes whitespace and punctuation into a URL-safe slug', () => {
    expect(slugify('  Minimal Sneakers!  ')).toBe('minimal-sneakers');
  });

  it('strips diacritics so slugs stay ASCII-safe', () => {
    expect(slugify('Crème Brûlée')).toBe('creme-brulee');
  });
});
