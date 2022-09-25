import * as vision from '@google-cloud/vision'
import { Segment } from './types/geometry'

export function verticalSegment(
    label: vision.protos.google.cloud.vision.v1.IEntityAnnotation
): Segment {
  const corners = label.boundingPoly?.vertices ?? []
  const sortedCorners = corners.sort(
      (corner, otherCorner) => (corner?.y ?? 0) - (otherCorner?.y ?? 0)
  )
  const getY = (i: number) => sortedCorners[i]?.y ?? 0
  return {
    p1: (getY(0) + getY(1)) / 2,
    p2: (getY(2) + getY(3)) / 2,
  }
}

export function stripSku(sku: string): string {
  const matches = sku.match(/0*(.*?)(R|$)/)
  if (!matches) return sku
  return matches[1]
}

export function propertyChanged<T>(obj1: T, obj2: T, propertyName: keyof T): boolean {
  return JSON.stringify(obj1[propertyName]) != JSON.stringify(obj2[propertyName])
}
