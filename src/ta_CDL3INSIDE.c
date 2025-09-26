// Interface to TA_CDL3INSIDE
//
// Parameters
//   open:  numeric vector of opening prices
//   high:  numeric vector of high prices
//   low:   numeric vector of low prices
//   close: numeric vector of closing prices
//   normalize_flag: logical; if TRUE, scale outputs to +/-100 consistently
//
// Description
//   Identifies "Three Inside Up/Down". Returns an integer vector the same
//   length as inputs with +100 for "Three Inside Up", -100 for "Three Inside
//   Down", and 0 otherwise. Leading NA values are padded so the output length
//   matches the input length.
#include "R_ext/Arith.h"
#include "Rdefines.h"
#include "Rinternals.h"
#include "lib.h"
#include "normalize.h"
#include "shift.h"
#include "ta_func.h"
#include <limits.h>
#include <stdbool.h>
#include <ta_libc.h>

// clang-format off
SEXP impl_ta_CDL3INSIDE(
  SEXP open,
  SEXP high,
  SEXP low,
  SEXP close,
  SEXP normalize_flag) {
  // clang-format on

  int protect_count = 0;

  // data
  const double *restrict open_ptr = REAL(open);
  const double *restrict high_ptr = REAL(high);
  const double *restrict low_ptr = REAL(low);
  const double *restrict close_ptr = REAL(close);

  const int n = LENGTH(open);

  // clang-format off
  SEXP result = PROTECT(
    allocVector(INTSXP, n)
  ); protect_count++;
  int *restrict out_ptr = INTEGER(result);
  // clang-format on

  const int minimum_lookback = TA_CDL3INSIDE_Lookback();

  if (n < minimum_lookback) {
    Rf_warning("Input length (%d) is smaller than required lookback (%d).", n,
               minimum_lookback);
    for (int i = 0; i < n; ++i) {
      out_ptr[i] = NA_INTEGER;
    }
  } else {

    int outBeg = 0, outNb = 0;
    TA_RetCode return_code =
        TA_CDL3INSIDE(0, n - 1, open_ptr, high_ptr, low_ptr, close_ptr, &outBeg,
                      &outNb, out_ptr);

    if (return_code != TA_SUCCESS) {
      UNPROTECT(protect_count);
      Rf_error("TA_CDL3INSIDE failed with error code %d", return_code);
    }

    // shift array
    shift_array(out_ptr, n, outBeg);

    bool do_normalize = LOGICAL_VALUE(normalize_flag);
    if (do_normalize) {
      normalize(out_ptr, n, 100, outBeg);
    }
  }

  UNPROTECT(protect_count);
  return result;
}
