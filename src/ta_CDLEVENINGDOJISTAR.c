// Interface to TA_CDLEVENINGDOJISTAR
//
// Parameters
//   open: numeric vector of opening prices
//   high: numeric vector of high prices
//   low:  numeric vector of low prices
//   close: numeric vector of closing prices
//   penetration: numeric scalar specifying the percentage penetration of the
//   third candle into the first candle's body (for pattern confirmation)
//
// Description
//   Identifies the "Evening Doji Star" candlestick pattern, a three-day bearish
//   reversal pattern (a long bullish candle, followed by a Doji that gaps up,
//   then a bearish candle closing well into the first candle's body). Returns
//   an integer vector of the same length, with -100 at each index where an
//   Evening Doji Star pattern is detected (0 if no pattern). The `penetration`
//   parameter is a percentage (typically 0–100%) that defines how deeply the
//   third candle should penetrate into the first candle's body for confirmation
//   (e.g., 30 for 30%). Leading NA values are padded for the initial period
//   before any pattern can occur.
#include "lib.h"
#include "normalize.h"
#include "shift.h"
#include <limits.h>
#include <stdbool.h>
#include <ta_libc.h>

// clang-format off
SEXP impl_ta_CDLEVENINGDOJISTAR(
  SEXP open, 
  SEXP high, 
  SEXP low, 
  SEXP close,
  SEXP penetration, 
  SEXP normalize_flag) {
  // clang-format on
  int protect_count = 0;

  // data
  const double *restrict open_ptr = REAL(open);
  const double *restrict high_ptr = REAL(high);
  const double *restrict low_ptr = REAL(low);
  const double *restrict close_ptr = REAL(close);
  double penetration_ptr = REAL(penetration)[0];

  int n = LENGTH(open);

  // clang-format off
  SEXP result = PROTECT(
    allocVector(INTSXP, n)
  ); protect_count++;
  int *restrict out_ptr = INTEGER(result);
  // clang-format on

  // clang-format off
  const int minimum_lookback = TA_CDLEVENINGDOJISTAR_Lookback(penetration_ptr);
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
    TA_RetCode return_code = TA_CDLEVENINGDOJISTAR(
      0, 
      n - 1, 
      open_ptr, 
      high_ptr, 
      low_ptr, 
      close_ptr,
      penetration_ptr,
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