import {
  filterProducts,
  filterWalmartProducts,
} from '../transformators/filters'
import {
  mergeMetroProducts,
  mergeWalmartProducts,
} from '../transformators/mergers'
import {
  normalizeLCBOProducts,
  normalizeProducts,
  normalizeWalmartProducts,
} from '../transformators/normalizers'
import { improveNaming } from '../transformators/readability'
import { RowOfText } from './geometry'
import { Product } from './products'

type ProductsConverter = (products: Product[]) => Product[]
type AsyncProductsConverter = (products: Product[]) => Promise<Product[]>

export type Store = {
  normalize: (rows: RowOfText[]) => Product[]
  filter: ProductsConverter
  merge: ProductsConverter
  improveNaming: AsyncProductsConverter
}

export const defaultStore: Store = {
  normalize: normalizeProducts,
  filter: filterProducts,
  merge: (p) => p,
  improveNaming,
}

export const walmart: Store = {
  ...defaultStore,
  normalize: normalizeWalmartProducts,
  filter: filterWalmartProducts,
  merge: mergeWalmartProducts,
}

export const lcbo: Store = {
  ...defaultStore,
  normalize: normalizeLCBOProducts,
}

export const metro: Store = {
  ...defaultStore,
  merge: mergeMetroProducts,
}

export type StoreName = 'walmart' | 'lcbo' | 'metro'
export const stores: { [name in StoreName]: Store } = { walmart, lcbo, metro }
