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
  int *protection_count) {
  // clang-format on

  SEXP symbolic_value = ta_lookback();

  SEXP value = PROTECT(Rf_ScalarInteger(lookback));
  if (protection_count) {
    (*protection_count)++;
  }

  Rf_setAttrib(output_object, symbolic_value, value);
}
