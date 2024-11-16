
import { google } from '@google-cloud/vision/build/protos/protos'
import { BoxWithText, Vector } from '../types/geometry'

type IEntityAnnotation = google.cloud.vision.v1.IEntityAnnotation
type IVertex = google.cloud.vision.v1.IVertex

export function toBoxWithText(annotation: IEntityAnnotation): BoxWithText {
  const corners = annotation.boundingPoly?.vertices ?? []
  const [topLeft, topRight, bottomRight, bottomLeft] = corners

  const y = (v: IVertex) => v?.y ?? 0
  const x = (v: IVertex) => v?.x ?? 0
  const mid = (a: number, b: number) => (a + b) / 2

  const top: Vector = {
    x: mid(x(topLeft), x(topRight)),
    y: mid(y(topLeft), y(topRight)),
  }
  const bottom: Vector = {
    x: mid(x(bottomLeft), x(bottomRight)),
    y: mid(y(bottomLeft), y(bottomRight)),
  }
  const left: Vector = {
    x: mid(x(bottomLeft), x(topLeft)),
    y: mid(y(bottomLeft), y(bottomRight)),
  }
  const right: Vector = {
    x: mid(x(bottomRight), x(topRight)),
    y: mid(y(bottomRight), y(bottomRight)),
  }
  const center: Vector = {
    x: mid(top.x, bottom.x),
    y: mid(left.y, right.y),
  }
  return {
    top, bottom, right, left, center,
    content: annotation.description,
  }
}

export function isWithin(position: number, boxWithText: BoxWithText) {
  return boxWithText.top.y < position && position < boxWithText.bottom.y
}

export function yCenter(boxWithText: BoxWithText) {
  return (boxWithText.top.y + boxWithText.bottom.y) / 2
}

export function add(a: Vector, b: Vector) {
  return { x: a.x + b.x, y: a.y + b.y }
}

export function sub(a: Vector, b: Vector) {
  return { x: a.x - b.x, y: a.y - b.y }
}
