import { WalmartProduct } from '../types/products'

// handle multiline items (walmart)
export function mergeWalmartProducts(rows: WalmartProduct[]): WalmartProduct[] {
  for (let i = 0; i < rows.length - 1; i++) {
    const row = rows[i]
    const nextRow = rows[i+1]
    if (row.sku && !row.value) {
      row.value = nextRow.value
    }
  }

  return rows
}
