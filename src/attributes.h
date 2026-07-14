#ifndef ATTRIBUTES_H
#define ATTRIBUTES_H
// attributes.h
//
// This header file abstracts the attribute
// setting of the output containers.
//
#include <Rinternals.h>

// Extensible attribute identifiers
//
// Description
//  Add new attribute(s) here and process it in attribute_symbol()
//  to implement it.
typedef enum {
  LOOKBACK,
} attribute;

void set_attribute(
  SEXP obj, attribute attr, SEXP attr_value, int *protection_count);

int normalize_lookback(int lookback);

#endif /* ATTRIBUTES_H */
