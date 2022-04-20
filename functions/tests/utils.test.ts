import { stripSku } from '../src/utils'

describe('Utils', () => {
  it('strips SKU of leading 0s', () => {
    const cleanSku = stripSku('00012340123')
    expect(cleanSku).toEqual('12340123')
  })
}) 
