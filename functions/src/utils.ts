import _ from 'lodash'

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
export function propertyChanged<T>(
  obj1: T,
  obj2: T,
  ...propertyNames: (keyof T)[]
): boolean {
  return propertyNames.some(
    (propertyName) =>
      JSON.stringify(obj1[propertyName]) != JSON.stringify(obj2[propertyName])
  )
}
