import {
  filterProducts,
  filterWalmartProducts,
} from '../transformators/filters'
import { mergeMetroProducts, mergeWalmartProducts } from '../transformators/mergers'
import {
  normalizeLCBOProducts,
  normalizeProducts,
  normalizeWalmartProducts,
} from '../transformators/normalizers'
import {
  improveNaming,
  improveWalmartNaming,
} from '../transformators/readability'
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
  improveNaming: improveNaming,
}

export const walmart: Store = {
  normalize: normalizeWalmartProducts,
  filter: filterWalmartProducts,
  merge: mergeWalmartProducts,
  improveNaming: improveWalmartNaming,
}

export const lcbo: Store = {
  normalize: normalizeLCBOProducts,
  filter: filterProducts,
  merge: (p) => p,
  improveNaming,
}

export const metro: Store = {
  normalize: normalizeProducts,
  filter: filterProducts,
  merge: mergeMetroProducts,
  improveNaming: improveNaming,
}

export const stores: { [name: string]: Store } = { walmart, lcbo, metro }
