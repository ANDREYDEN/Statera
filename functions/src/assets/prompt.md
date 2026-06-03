Analyze the receipt image at the following URL and extract the list of products, their prices, and quantities. 
Return the data in JSON format with the following structure: 
```
[{ 
    "name": string, 
    "value": number, 
}]
```

**Important rules**
- respond with JSON only
- if the image does not contain a receipt, response with `[]`
