import { LCBOProduct, Product, WalmartProduct } from '../types/products'
import { toPascalCase } from '../utils'

const CODE_REGEX = /\d{11,13}\w?/
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
        row[i] = element.replace(codeMatcher[0], 'C-O-D-E')
      }

      if (valueMatcher) {
        product.value = +valueMatcher[1]
        row[i] = element.replace(valueMatcher[0], '')
      }
    })

    const codeIndex = row.indexOf('C-O-D-E')
    const nameElements = row.slice(0, codeIndex)
    const prettyNameElements = nameElements
      .map(toPascalCase)
      .filter((element) => element != '')
    product.name = prettyNameElements.join(' ')

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
    quantity: 0,
  }
  const idVolumeDepositRegex = /(\d{8})\s*(\d{5})ML\s*DEP\s*(\d*\.\d{2})\s*ea/
  const quantityValueRegex = /\(\s*(\d+)\s*@\s*(\d+\.\d{2})\s*\)/

  const textRows = rows.map((row) => row.join(' '))

  for (const row of textRows) {
    const idVolumeDepositMatcher = row.match(idVolumeDepositRegex)
    if (idVolumeDepositMatcher) {
      currentProduct.id = idVolumeDepositMatcher[1]
      currentProduct.volume = +idVolumeDepositMatcher[2]
      currentProduct.deposit = +idVolumeDepositMatcher[3]
      continue
    }

    const quantityValueMatcher = row.match(quantityValueRegex)
    if (quantityValueMatcher) {
      currentProduct.quantity = +quantityValueMatcher[1]
      currentProduct.value = +quantityValueMatcher[2]

      products.push(currentProduct)
      currentProduct = {
        name: '',
        value: 0,
        deposit: 0,
        id: '',
        volume: 0,
        quantity: 0,
      }
      continue
    }

    currentProduct.name = row
  }
  return products
}
