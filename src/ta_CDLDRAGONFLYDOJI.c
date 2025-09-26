// Interface to TA_CDLDRAGONFLYDOJI
//
// Parameters
//   open: numeric vector of opening prices
//   high: numeric vector of high prices
//   low:  numeric vector of low prices
//   close: numeric vector of closing prices
//
// Description
//   Identifies the "Dragonfly Doji" candlestick pattern, characterized by a
//   Doji with a long lower shadow and virtually no upper shadow. Returns an
//   integer vector of the same length, with 100 for each index where a
//   Dragonfly Doji pattern is found (0 if no pattern). Leading NA values are
//   padded for periods before the first pattern can be detected.
#include "lib.h"
#include "normalize.h"
#include <limits.h>
#include <stdbool.h>
#include <ta_libc.h>

// clang-format off
SEXP impl_ta_CDLDRAGONFLYDOJI(
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

  int n = LENGTH(open);

  // clang-format off
  SEXP result = PROTECT(
    allocVector(INTSXP, n)
  ); protect_count++;
  int *restrict out_ptr = INTEGER(result);
  // clang-format on

  // clang-format off
  const int minimum_lookback = TA_CDLDRAGONFLYDOJI_Lookback();
  // clang-format on

  if (n < minimum_lookback) {
    Rf_warning("Input length (%d) is smaller than required lookback (%d).", n,
               minimum_lookback);

    for (size_t i = 0; i < n; ++i) {
      out_ptr[i] = NA_INTEGER;
    }

  } else {

    int outBeg = 0, outNb = 0;
    // clang-format off
    TA_RetCode return_code = TA_CDLDRAGONFLYDOJI(
      0, 
      n - 1, 
      open_ptr, 
      high_ptr, 
      low_ptr, 
      close_ptr,
      &outBeg, 
      &outNb, 
      out_ptr
    );
    // clang-format on

    if (return_code != TA_SUCCESS) {
      UNPROTECT(protect_count);
      Rf_error("Failed with error code %d", return_code);
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