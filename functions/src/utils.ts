import * as vision from "@google-cloud/vision"
import { Segment } from "./types/geometry"

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
