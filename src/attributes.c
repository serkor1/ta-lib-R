// attributes.c
//
// This 'C'-program sets the attributes of the
// output container.
//  - Attributes are dispatched by a ta_attribute tag so new
//    attributes can be added without changing the call sites:
//    add an enum entry and a case in attribute_symbol() below.
//
#include "attributes.h"

// resolve (and cache) the R symbol for an attribute
// clang-format off
static SEXP attribute_symbol(ta_attribute attr) {
  switch (attr) {
  case TA_ATTR_LOOKBACK: {
    static SEXP lookback = NULL;
    if (lookback == NULL) {
      lookback = Rf_install("lookback");
    }
    return lookback;
  }
  }

  return R_NilValue; // unreachable for a valid ta_attribute
}
// clang-format on

// normalize a raw TA-Lib lookback (see attributes.h)
int ta_normalize_lookback(int lookback) {
  // upstream returns -1 if the indicator and data pairs
  // are invalid - -1 is handled on the R side but
  // attributes needs to be handled here - some functions
  // returns (weighted closing price, for one) returns lookback
  // of zero; this has to be normalized to 1 (can't calculate values on
  // nothing)
  return lookback < 0 ? lookback : (lookback < 1 ? 1 : lookback);
}

// workhorse function to
// set the attribute
// clang-format off
void set_attribute(
  SEXP obj,
  ta_attribute attr,
  SEXP value,
  int *protection_count
)
// clang-format on
{
  // per-attribute value normalization
  if (attr == TA_ATTR_LOOKBACK) {
    value = Rf_ScalarInteger(ta_normalize_lookback(Rf_asInteger(value)));
  }

  // protect before attribute_symbol() may allocate a new symbol
  SEXP protected_value = PROTECT(value);

  if (protection_count) {
    (*protection_count)++;
  }

  Rf_setAttrib(obj, attribute_symbol(attr), protected_value);
}
