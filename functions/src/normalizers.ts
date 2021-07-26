const CODE_REGEX = /\d{11, 13}/;

export function normalize(row: string[] ) {
  let name: string | null = null;
  let code: number | null = null;
  let value: number | null = null;

  row.forEach(element => {
    const codeMatcher = element.match(CODE_REGEX);
    if (codeMatcher) {
      code = +codeMatcher[0];
      element.replace(codeMatcher[0], '');
    }

    
  });

  return { name, code, value };
}