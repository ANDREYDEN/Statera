import { Product, WalmartProduct } from '../types/products'

export function filterProducts(products: Product[]): Product[] {
  return products.filter((p) => p.value && p.name && nameIsValid(p.name))
}

export function filterWalmartProducts(
  products: WalmartProduct[]
): WalmartProduct[] {
  return products.filter((p) => p.sku && nameIsValid(p.name))
}

function nameIsValid(name: string) {
  return !name.toLowerCase().includes('total') && !name.includes('@')
}
