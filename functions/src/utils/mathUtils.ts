export const avg = (...params: number[]) => params.reduce((acc, p) => acc + p, 0) / params.length

export const sqr = (x: number) => Math.pow(x, 2)
