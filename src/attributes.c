// attributes.c
//
// This 'C'-program sets the attributes of the
// output container.
//  - Attributes are dispatched by a attribute tag so new
//    attributes can be added without changing the call sites:
//    add an enum entry and a case in attribute_symbol() below.
//
#include "attributes.h"
#include "Rinternals.h"

// resolve (and cache) the R symbol for an attribute
// clang-format off
static SEXP attribute_symbol(attribute attr) {
  switch (attr) {
    case LOOKBACK: {
      static SEXP lookback = NULL;
      if (lookback == NULL) {
        lookback = Rf_install("lookback");
      }
      return lookback;
    }
  }
  
  return R_NilValue;
}
// clang-format on

// Normalize lookback values
//
// Description:
//  TA-Lib returns 0 for indicators that can
//  be calculated as-is, which from an R perspective
//  makes no sense as it is not possible to calculate
//  indicators on "nothing." The normalization here translates
//  to minimum number of observations.
int normalize_lookback(int lookback) { return lookback <= 0 ? 1 : lookback; }

// clang-format off
void set_attribute(
  SEXP x, // object
  attribute attr, // attribute
  SEXP attr_value, // attribute value
  int *protection_count
)
// clang-format on
{

  // clang-format off
  switch (attr) {
    case LOOKBACK: {
      attr_value = Rf_ScalarInteger(
        normalize_lookback(
          Rf_asInteger(attr_value)
        )
      );
    }
  }
  // clang-format on

  SEXP protected_value = PROTECT(attr_value);

  if (protection_count) {
    (*protection_count)++;
  }

  Rf_setAttrib(x, attribute_symbol(attr), protected_value);
}
