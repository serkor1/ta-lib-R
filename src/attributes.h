#ifndef ATTRIBUTES_H
#define ATTRIBUTES_H
// attributes.h
//
// This header file abstracts the attribute
// setting of the output containers.
//
#include <Rinternals.h>

// Extensible attribute identifiers. Add a new attribute here and handle it in
// attribute_symbol() (plus any normalization in set_attribute) in attributes.c.
typedef enum {
  TA_ATTR_LOOKBACK,
} ta_attribute;

void set_attribute(
  SEXP obj, ta_attribute attr, SEXP value, int *protection_count);

#endif /* ATTRIBUTES_H */
