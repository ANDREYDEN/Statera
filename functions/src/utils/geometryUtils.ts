
import { google } from '@google-cloud/vision/build/protos/protos'
import { BoxWithText, Vector } from '../types/geometry'
import { sqr } from './mathUtils'

export type IEntityAnnotation = google.cloud.vision.v1.IEntityAnnotation
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
    y: mid(y(bottomLeft), y(topLeft)),
  }
  const right: Vector = {
    x: mid(x(bottomRight), x(topRight)),
    y: mid(y(bottomRight), y(topRight)),
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

export function distanceToRow(row: BoxWithText[], box2: BoxWithText): number {
  const line = [row[0].left, row[row.length - 1].right]
  const normalizedLine = sub(line[1], line[0])
  const normalizedCenter = sub(box2.center, line[0])

  return distanceToVectorLine(normalizedCenter, normalizedLine)
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

export function tan(v: Vector): number {
  return v.y / v.x
}

export function height(box: BoxWithText): number {
  return len(sub(box.top, box.bottom))
}

function distanceToVectorLine(point: Vector, vector: Vector): number {
  const d1 = len(vector)
  return Math.abs(point.x*vector.y - vector.x*point.y) / d1
}
