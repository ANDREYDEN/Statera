export type BoxWithText = {
  yTop: number
  yBottom: number
  xLeft: number
  xRight: number
  x: number
  y: number
  content?: string | null
}

export type RowOfText = {
  leftText: string[]
  rightText: string[]
}

export type Vector = {
  x: number
  y: number
}
