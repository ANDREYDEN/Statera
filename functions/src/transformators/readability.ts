import { Product, WalmartProduct } from '../types/products'
import { stripSku } from '../utils'
import puppeteer from 'puppeteer'

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
  const newProducts: WalmartProduct[] = []
  for (const p of products) {
    const formattedProduct = await improveWalmartName(p)
    newProducts.push(formattedProduct)
  }
  return newProducts
}

async function improveWalmartName(
  product: WalmartProduct
): Promise<WalmartProduct> {
  const improvedProduct = { ...product, name: improveName(product.name) }
  if (!product.sku) {
    console.error('SKU was not found')
    return product
  }

  const cleanSku = stripSku(product.sku)
  const productUrl = `https://www.walmart.ca/search?q=${cleanSku}&c=10019`
  console.log(`Improving name for ${cleanSku}...`)

  try {
    const browser = await puppeteer.launch()
    const page = await browser.newPage()
    // eslint-disable-next-line max-len
    page.setUserAgent(
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:74.0) Gecko/20100101 Firefox/74.0'
    )
    await page.goto(productUrl)

    const element = await page.$('[data-automation="name"]')
    if (!element) throw new Error('Product was not found')

    const productName = await element.evaluate((e) => e.textContent)
    if (!productName) throw new Error('Could not read product name')

    return { ...product, name: productName }
  } catch (e) {
    console.error(`Failed to improve name for ${cleanSku}: ${e}`)
  }

  return improvedProduct
}
