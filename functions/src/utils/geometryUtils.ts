
import { google } from '@google-cloud/vision/build/protos/protos'
import { BoxWithText, Vector } from '../types/geometry'
import { avg, sqr } from './mathUtils'

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

export function add(a: Vector, b: Vector): Vector {
  return { x: a.x + b.x, y: a.y + b.y }
}

export function sub(a: Vector, b: Vector): Vector {
  return { x: a.x - b.x, y: a.y - b.y }
}

export function len(v: Vector): number {
  return Math.sqrt(sqr(v.x) + sqr(v.y))
}

export function rotateAntiClockwise(v:Vector, angle: number) : Vector {
  const sin = Math.sin(angle)
  const cos = Math.sqrt(1 - sqr(sin))
  return {
    x: cos * v.x - sin * v.y,
    y: sin * v.x + cos * v.y,
  }
}

export function rotateClockwise(v:Vector, angle: number) : Vector {
  const sin = Math.sin(angle)
  const cos = Math.sqrt(1 - sin^2)
  return {
    x: sin * v.y + cos * v.x,
    y: cos * v.y - sin * v.x,
  }
}

export function rotateToHorizontal(box: BoxWithText) : BoxWithText {
  const [newLeft, newRight] = rotateLineToHorizontal(box.left, box.right)
  const height = len(sub(box.top, box.bottom))
  const center: Vector = { x: avg(newLeft.x, newRight.x), y: avg(newLeft.y, newRight.y) }
  return {
    ...box,
    left: newLeft,
    right: newRight,
    top: { ...center, y: center.y - height / 2 },
    bottom: { ...center, y: center.y + height/ 2 },
    center,
  }
}

export function rotateLineToHorizontal(v1: Vector, v2: Vector) : [Vector, Vector] {
  // if (len(v1) > len(v2)) {
  //   return rotateLineToHorizontal(v2, v1)
  // }

  const r1 = len(v1)
  const r2 = len(v2)
  const length = len(sub(v2, v1))
  const mult = r1 < r2 ? 1 : -1
  console.log({ v1, v2, r1, r2, mult })


  const x3 = (sqr(r2) - sqr(r1) - mult * sqr(length)) / (2 * length)
  const v3: Vector = {
    x: x3,
    y: Math.sqrt(sqr(r1) - sqr(x3)),
  }

  const x4 = (sqr(r2) - sqr(r1) + mult * sqr(length)) / (2 * length)
  const v4: Vector = {
    x: x4,
    y: Math.sqrt(sqr(r2) - sqr(x4)),
  }
  return [v3, v4]
}
