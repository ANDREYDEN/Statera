/* eslint-disable require-jsdoc */
const CODE_REGEX = /\d{11,13}/;
const VALUE_REGEX = /\$?(\d+(\.|,)\d+)/;

interface Product {
  name: string;
  code: string;
  value: number;
}

export function normalize(row: string[]): Partial<Product> {
  const product: Partial<Product> = {};

  row.forEach((element, i) => {
    const codeMatcher = element.match(CODE_REGEX);
    const valueMatcher = element.match(VALUE_REGEX);
    if (codeMatcher) {
      product.code = codeMatcher[0];
      row[i] = element.replace(codeMatcher[0], "");
    }

    if (valueMatcher) {
      product.value = +valueMatcher[1];
      row[i] = element.replace(valueMatcher[0], "");
    }
  });
  product.name = row.filter(element => element != "").join(" ");

  return product;
}

export function mergeProducts(rows: Partial<Product>[]): Partial<Product>[] {
  rows.forEach((row, i) => {
    if (i > 0 && i < rows.length - 1 && !row.value) {
      for (const closeIdx of [i - 1, i + 1]) {
        // handle multiple descriptions of the same items (walmart)
        if ((rows[closeIdx].name?.length ?? 0) <= 2) {
          rows[i].value = rows[closeIdx].value;
          rows[i].code =
            (rows[i].code?.length ?? 0) > (rows[closeIdx].code?.length ?? 0)
              ? rows[i].code
              : rows[closeIdx].code;
        }
      }
    }
  });

  return rows; 
}

export function filterWalmartProducts(products: Partial<Product>[]): Partial<Product>[] {
  return products.filter((p) => p.code);
}

export function filterProducts(products: Partial<Product>[]): Partial<Product>[] {
  return products.filter((p) => p.value && p.name && nameIsValid(p.name));
}

function nameIsValid(name: string) {
  return !name.toLowerCase().includes('total') && !name.includes('@');
}