import { google } from '@google-cloud/vision/build/protos/protos'
import { VerticalSegment } from './types/geometry'
import _ from 'lodash'

type IEntityAnnotation = google.cloud.vision.v1.IEntityAnnotation

export function verticalSegment(
    label: IEntityAnnotation
): VerticalSegment {
  const corners = label.boundingPoly?.vertices ?? []
  const sortedCorners = corners.sort(
      (corner, otherCorner) => (corner?.y ?? 0) - (otherCorner?.y ?? 0)
  )
  const getY = (i: number) => sortedCorners[i]?.y ?? 0
  const getX = (i: number) => sortedCorners[i]?.x ?? 0
  return {
    yTop: (getY(0) + getY(1)) / 2,
    yBottom: (getY(2) + getY(3)) / 2,
    x: (getX(0) + getX(1) + getX(2) + getX(3)) / 4,
  }
}

export function stripSku(sku: string): string {
  const matches = sku.match(/0*(.*?)(R|$)/)
  if (!matches) return sku
  return matches[1]
}

export function toPascalCase(str: string): string {
  if (!str.match(/\w+/)) return str

  return _.camelCase(str).replace(/^(.)/, _.toUpper)
}

// Returns true if any of the properties changed
export function propertyChanged<T>(obj1: T, obj2: T, ...propertyNames: (keyof T)[]): boolean {
  return propertyNames.some(propertyName => JSON.stringify(obj1[propertyName]) != JSON.stringify(obj2[propertyName]))
}
