import { Product, WalmartProduct } from '../types/products'

export function filterProducts(products: Product[]): Product[] {
  const indexOfTotalRow = products.findIndex(isTotal)
  return products
    .slice(0, indexOfTotalRow == -1 ? undefined : indexOfTotalRow)
    .filter((p) => p.value && p.name && !isWeight(p))
}

export function filterWalmartProducts(
  products: WalmartProduct[]
): WalmartProduct[] {
  return products.filter((p) => p.sku && !isTotal(p) && !isWeight(p))
}

function isTotal(product: Product) {
  return product.name.toLowerCase().includes('total')
}

/**
 * Usually products that contain the "@" character are weight or discount measurements.
 * For Example: "1.59kg @ $1.49/kg", "2.99 @ 30.00%"
 * @param {Product} product Product to check
 * @return {boolean} true if product is a weight line
 */
function isWeight(product: Product): boolean {
  return product.name.includes('@')
}
