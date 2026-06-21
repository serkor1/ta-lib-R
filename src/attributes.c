// attributes.c
//
// This 'C'-program sets the attributes of the
// output container.
//  - Its currently hardcoded for lookback only
//    but it will be expanded if there is any demand
//    for it.
//
#include "attributes.h"

// initialize the lookback value
static SEXP lookback_value = NULL;

// set lookback value
static inline SEXP ta_lookback(void) {

  if (lookback_value == NULL) {
    lookback_value = Rf_install("lookback");
  }

  return lookback_value;
}

// workhorse function to
// set the attribute
// clang-format off
void set_attribute(
  SEXP output_object, 
  int lookback, 
  int *protection_count
)
// clang-format on
{
  // upstream returns -1 if the indicator and data pairs
  // are invalid - -1 is handled on the R side but
  // attributes needs to be handled here - some functions
  // returns (weighted closing price, for one) returns lookback
  // of zero; this has to be normalized to 1 (can't calculate values on nothing)
  int normalized_lookback =
    lookback < 0 ? lookback : (lookback < 1 ? 1 : lookback);
  SEXP symbolic_value = ta_lookback();

  SEXP value = PROTECT(Rf_ScalarInteger(normalized_lookback));

  if (protection_count) {
    (*protection_count)++;
  }

  Rf_setAttrib(output_object, symbolic_value, value);
}
