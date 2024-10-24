
import { google } from '@google-cloud/vision/build/protos/protos'
import { BoxWithText } from '../types/geometry'

type IEntityAnnotation = google.cloud.vision.v1.IEntityAnnotation

export function toBoxWithText(annotation: IEntityAnnotation): BoxWithText {
  const corners = annotation.boundingPoly?.vertices ?? []
  const sortedCorners = corners.sort(
    (corner, otherCorner) => (corner?.y ?? 0) - (otherCorner?.y ?? 0)
  )
  const getY = (i: number) => sortedCorners[i]?.y ?? 0
  const getX = (i: number) => sortedCorners[i]?.x ?? 0
  return {
    yTop: (getY(0) + getY(1)) / 2,
    yBottom: (getY(2) + getY(3)) / 2,
    x: (getX(0) + getX(1) + getX(2) + getX(3)) / 4,
    content: annotation.description,
  }
}

export function isWithin(position: number, boxWithText: BoxWithText) {
  return boxWithText.yTop < position && position < boxWithText.yBottom
}

export function center(boxWithText: BoxWithText) {
  return (boxWithText.yTop + boxWithText.yBottom) / 2
}
