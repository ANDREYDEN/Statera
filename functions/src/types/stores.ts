import {
  filterProducts, filterWalmartProducts,
} from "../transformators/filters"
import { mergeWalmartProducts } from "../transformators/mergers"
import {
  normalizeProducts, normalizeWalmartProducts,
} from "../transformators/normalizers"
import { Product } from "./products"

type ProductsConverter<T> = (products: T[]) => T[]

export type Store = {
  normalize: (rows: string[][]) => Product[]
  filter: ProductsConverter<Product>
  merge: ProductsConverter<Product>
}

export const defaultStore: Store = {
  normalize: normalizeProducts,
  filter: filterProducts,
  merge: (p) => p,
}

export const walmart: Store = {
  normalize: normalizeWalmartProducts,
  filter: filterWalmartProducts,
  merge: mergeWalmartProducts,
}
