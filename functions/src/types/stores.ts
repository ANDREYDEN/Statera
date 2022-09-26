import {
  filterProducts, filterWalmartProducts,
} from '../transformators/filters'
import { mergeWalmartProducts } from '../transformators/mergers'
import {
  normalizeLCBOProducts,
  normalizeProducts, normalizeWalmartProducts,
} from '../transformators/normalizers'
import {
  improveNaming, improveWalmartNaming,
} from '../transformators/readability'
import { Product } from './products'

type ProductsConverter = (products: Product[]) => Product[]
type AsyncProductsConverter = (products: Product[]) => Promise<Product[]>

export type Store = {
  normalize: (rows: string[][]) => Product[]
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

export const stores: {[name: string]: Store} = { walmart, lcbo }
