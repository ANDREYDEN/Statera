import { RowOfText } from '../types/geometry'
import { LCBOProduct, Product, WalmartProduct } from '../types/products'
import { toPascalCase } from '../utils'

const CODE_REGEX = /\d{11,13}\w?/
const VALUE_REGEX = /\$?(\d+(\.|,)\d+)/

export function normalizeProducts(rows: RowOfText[]): Product[] {
  return rows.map((row) => {
    const product: Product = {
      name: '',
      value: 0,
    }

    for (let i = 0; i < row.rightText.length; i++) {
      const element = row.rightText[i]

      const valueMatcher = element.match(VALUE_REGEX)
      if (!valueMatcher) continue

      product.value = +valueMatcher[1]
    }

    product.name = row.leftText.filter((element) => element != '').join(' ')

    return product
  })
}

export function normalizeWalmartProducts(rows: RowOfText[]): WalmartProduct[] {
  return rows.map((row) => {
    const rowText = [...row.leftText, ...row.rightText]
    const product: WalmartProduct = {
      name: '',
      value: 0,
      sku: '',
    }

    rowText.forEach((element, i) => {
      const codeMatcher = element.match(CODE_REGEX)
      const valueMatcher = element.match(VALUE_REGEX)
      if (codeMatcher) {
        product.sku = codeMatcher[0]
        rowText[i] = element.replace(codeMatcher[0], 'C-O-D-E')
      }

      if (valueMatcher) {
        product.value = +valueMatcher[1]
        rowText[i] = element.replace(valueMatcher[0], '')
      }
    })

    const codeIndex = rowText.indexOf('C-O-D-E')
    const nameElements = rowText.slice(0, codeIndex)
    const prettyNameElements = nameElements
      .map(toPascalCase)
      .filter((element) => element != '')
    product.name = prettyNameElements.join(' ')

    return product
  })
}

export function normalizeLCBOProducts(rows: RowOfText[]): LCBOProduct[] {
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

  const textRows = rows.map((row) => [...row.leftText, ...row.rightText].join(' '))

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
