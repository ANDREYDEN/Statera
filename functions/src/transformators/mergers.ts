import { Product, WalmartProduct } from '../types/products'

/**
 * Combines multiline items in Walmart receipts
 * @param {WalmartProduct[]} products The products in each row of the receipt
 * @return {WalmartProduct[]} Combined products
 */
export function mergeWalmartProducts(products: WalmartProduct[]): WalmartProduct[] {
  for (let i = 0; i < products.length - 1; i++) {
    const row = products[i]
    const nextRow = products[i + 1]
    if (row.sku && !row.value) {
      row.value = nextRow.value
    }
  }

  return products
}

/**
 * Combines multiline items in Metro receipts
 * @param {WalmartProduct[]} products The products in each row of the receipt
 * @return {WalmartProduct[]} Combined products
 */
export function mergeMetroProducts(products: Product[]): Product[] {
  for (let i = 0; i < products.length - 1; i++) {
    const row = products[i]
    const nextRow = products[i + 1]
    if (!row.value && nextRow.name.includes('@')) {
      row.value = nextRow.value
    }
  }

  return products
}
