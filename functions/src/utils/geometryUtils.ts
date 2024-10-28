
import { google } from '@google-cloud/vision/build/protos/protos'
import { BoxWithText } from '../types/geometry'

type IEntityAnnotation = google.cloud.vision.v1.IEntityAnnotation
type IVertex = google.cloud.vision.v1.IVertex

export function toBoxWithText(annotation: IEntityAnnotation): BoxWithText {
  const corners = annotation.boundingPoly?.vertices ?? []
  const [topLeft, topRight, bottomRight, bottomLeft] = corners

  const y = (v: IVertex) => v?.y ?? 0
  const x = (v: IVertex) => v?.x ?? 0

  const yTop = (y(topLeft) + y(topRight)) / 2
  const yBottom = (y(bottomLeft) + y(bottomRight)) / 2
  const xLeft = (x(topLeft) + x(bottomLeft)) / 2
  const xRight = (x(topRight) + x(bottomRight)) / 2

  return {
    yTop,
    yBottom,
    y: (yTop + yBottom) / 2,
    xLeft,
    xRight,
    x: (xLeft + xRight) / 2,
    content: annotation.description,
  }
}

export function isWithin(position: number, boxWithText: BoxWithText) {
  return boxWithText.yTop < position && position < boxWithText.yBottom
}

export function center(boxWithText: BoxWithText) {
  return (boxWithText.yTop + boxWithText.yBottom) / 2
}
