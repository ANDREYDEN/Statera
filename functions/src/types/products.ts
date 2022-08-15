export type Product = {
  name: string
  value: number
}

export type WalmartProduct = Product & {
  sku?: string
}

export type LCBOProduct = Product & {
  id: string
  deposit: number
  quantity: number
  volume?: number
}
