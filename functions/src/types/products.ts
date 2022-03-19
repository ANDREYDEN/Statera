export type Product = {
  name: string
  value: number
}

export type WalmartProduct = Product & {
  sku?: string
}
