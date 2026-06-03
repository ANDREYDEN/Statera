import { Product } from '../types/products'

export async function analyzeReceiptWithAI(
  receiptUrl: string
): Promise<Product[]> {
  console.log(`Analyzing receipt at ${receiptUrl}`)
  return []
}
