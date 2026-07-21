import OpenAI from 'openai'
import { Product } from '../../types/products'
import { readFile } from 'node:fs/promises'
import path from 'node:path'

export async function analyzeReceiptWithAI(
  receiptUrl: string
): Promise<Product[]> {
  console.log(`Analyzing receipt at ${receiptUrl}`)

  const prompt = await readFile(
    path.join(__dirname, '../../assets/prompt.md'),
    'utf-8'
  )

  const client = new OpenAI()
  const response = await client.responses.create({
    model: 'gpt-5-nano',
    input: [
      {
        role: 'user',
        content: [
          { type: 'input_text', text: prompt },
          { type: 'input_image', image_url: receiptUrl, detail: 'auto' },
        ],
      },
    ],
  })

  const products = JSON.parse(response.output_text) as Product[]
  return products
}
