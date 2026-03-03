import { Product } from '../types/products'

export async function improveNaming(products: Product[]): Promise<Product[]> {
  return products.map((p) => ({
    ...p,
    name: improveName(p.name),
  }))
}

function improveName(name: string): string {
  let words = name.split(' ')
  if (words.length > 2) {
    words = words.filter((word) => word.length > 2)
  }

  const cleanName = words.join(' ')
  const lower = cleanName.toLowerCase()
  return lower[0].toUpperCase() + lower.slice(1)
}
