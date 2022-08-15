import { LCBOProduct, Product, WalmartProduct } from '../types/products'

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

export function normalizeLCBOProducts(rows: string[][]): LCBOProduct[] {
  const products: LCBOProduct[] = []
  let currentProduct: LCBOProduct = {
    name: '',
    value: 0,
    deposit: 0,
    id: '',
    volume: 0,
    quantity: 0
  }
  const idRegex = /\d{8}/
  const volumeRegex = /(\d{5})ML/
  const depositRegex = /DEP (\d*\.\d{2}) ea/
  const quantityValueRegex = /\((\d+) @ (\d+\.\d{2})\)/

  for (const row of rows) {
    const idMatcher = row[0].match(idRegex)
    if (idMatcher) {
      currentProduct.id = row[0]

      const volumeMatcher = row[1].match(volumeRegex)
      currentProduct.volume = volumeMatcher ? +volumeMatcher[0] : undefined

      const depositMatcher = row[2].match(depositRegex)
      currentProduct.deposit = depositMatcher ? +depositMatcher[0] : 0
      continue
    }

    const quantityValueMatcher = row[0].match(quantityValueRegex)
    if (quantityValueMatcher) {
      currentProduct.quantity = +quantityValueMatcher[0]
      currentProduct.value = +quantityValueMatcher[1]

      products.push(currentProduct)
      currentProduct = {
        name: '',
        value: 0,
        deposit: 0,
        id: '',
        volume: 0,
        quantity: 0
      }
      continue
    }

    currentProduct.name = row.join(' ')
  }
  return products
}