import axios from 'axios'
import { Product, WalmartProduct } from '../types/products'
import { stripSku } from '../utils'

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

export async function improveWalmartNaming(
    products: WalmartProduct[]
): Promise<WalmartProduct[]> {
  return Promise.all(products.map((p) => improveWalmartName(p)))
}

async function improveWalmartName(
    product: WalmartProduct
): Promise<WalmartProduct> {
  const improvedProduct = { ...product, name: improveName(product.name) }

  try {
    if (!product.sku) throw Error('Invalid SKU')
    const cleanSku = stripSku(product.sku)
    const { data } = await axios.get(`https://www.walmart.ca/search?q=${cleanSku}&c=10019`)

    console.log({ data })
  } catch (e) {
    console.error(
        `Failed to improve name for ${product.sku ?? product.name}: ${e}`
    )
  }

  return improvedProduct
}
