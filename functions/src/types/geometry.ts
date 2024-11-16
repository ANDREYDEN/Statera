export type BoxWithText = {
  top: Vector
  bottom: Vector
  left: Vector
  right: Vector
  center: Vector
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
