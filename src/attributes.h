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

// Normalize a raw TA-Lib lookback: keep the <0 invalid sentinel, but bump a
// lookback of 0 to 1 (nothing can be computed on an empty history). Shared by
// set_attribute() and the impl_ta_<NAME>_lookback() routines so the "lookback"
// attribute and lookback() can never disagree.
int ta_normalize_lookback(int lookback);

#endif /* ATTRIBUTES_H */
