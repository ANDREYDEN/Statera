import { Product, WalmartProduct } from '../types/products'

const CODE_REGEX = /\d{11,13}/
const VALUE_REGEX = /\$?(\d+(\.|,)\d+)/

export function normalizeProducts(rows: string[][]): Product[] {
  return rows.map((row) => {
    const product: Product = {
      name: '',
      value: 0,
    }

    row.forEach((element, i) => {
      const valueMatcher = element.match(VALUE_REGEX)

      if (valueMatcher) {
        product.value = +valueMatcher[1]
        row[i] = element.replace(valueMatcher[0], '')
      }
    })
    product.name = row.filter((element) => element != '').join(' ')

    return product
  })
}

export function normalizeWalmartProducts(rows: string[][]): WalmartProduct[] {
  return rows.map((row) => {
    const product: WalmartProduct = {
      name: '',
      value: 0,
      sku: '',
    }

    row.forEach((element, i) => {
      const codeMatcher = element.match(CODE_REGEX)
      const valueMatcher = element.match(VALUE_REGEX)
      if (codeMatcher) {
        product.sku = codeMatcher[0]
        row[i] = element.replace(codeMatcher[0], '')
      }

      if (valueMatcher) {
        product.value = +valueMatcher[1]
        row[i] = element.replace(valueMatcher[0], '')
      }
    })
    product.name = row.filter((element) => element != '').join(' ')

    return product
  })
}
