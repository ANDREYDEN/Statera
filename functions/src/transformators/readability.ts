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
  const lower = name.toLowerCase()
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
  if (!product.sku) return { ...product, name: improveName(product.name) }

  const cleanSku = stripSku(product.sku)
  try {
    const { data } = await axios.get(`https://www.walmart.ca/search?q=${cleanSku}&c=10019`)

    console.log({ data })
  } catch (e) {
    console.error(`Failed to improve name for ${cleanSku}: ${e}`)
  }

  return product
}
