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
  // attr(x, "lookback") is the cumulative count of leading
  // rows TA-Lib did not compute: the input's own lookback
  // plus the indicator's, summed through chained indicators.
  LOOKBACK,
} attribute;

// clang-format off
void set_attribute(
  SEXP obj, 
  attribute attr, 
  SEXP attr_value, 
  int *protection_count
);
// clang-format on

#endif /* ATTRIBUTES_H */
