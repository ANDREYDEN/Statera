/* eslint-disable require-jsdoc */
const CODE_REGEX = /\d{11,13}/;

export function normalize(row: string[]) {
  const name: string | null = null;
  let code: string | null = null;
  const value: number | null = null;

  row.forEach((element) => {
    const codeMatcher = element.match(CODE_REGEX);
    if (codeMatcher) {
      code = codeMatcher[0];
      element.replace(codeMatcher[0], "");
    }
  });

  return {name, code, value};
}

export function mergePrices(rows: { [height: string] : any[] }): { [height: string] : any[] } {
  const result: { [height: string] : any[] } = {};
  Object.entries(rows).forEach(([height, row], i) => {
    if (row[1] === 'H') {
      result[i-1] = [...result[i-1], ...row];
    }
  });

  return result;
}
