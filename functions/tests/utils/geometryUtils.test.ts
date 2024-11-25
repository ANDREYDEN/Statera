import { IEntityAnnotation, toBoxWithText } from '../../src/utils/geometryUtils'

describe('geometryUtils', () => {
  describe('toBoxWithText', () => {
    it('converts annotation to box with text', () => {
      const annotation: IEntityAnnotation = {
        boundingPoly: {
          vertices: [
            {
              x: 103,
              y: 288,
            },
            {
              x: 145,
              y: 276,
            },
            {
              x: 150,
              y: 293,
            },
            {
              x: 108,
              y: 305,
            },
          ],
        },
        description: 'E & OE',
      }
      const box = toBoxWithText(annotation)

      expect(box).toMatchSnapshot()
    })
  })
})
