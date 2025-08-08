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
#include <ta_libc.h>

SEXP impl_ta_CDLDRAGONFLYDOJI(SEXP open, SEXP high, SEXP low, SEXP close,
                              SEXP normalize_flag) {
  int protect_count = 0;

  R_xlen_t n = XLENGTH(open);

  if (n > INT_MAX) {
    if (protect_count > 0)
      UNPROTECT(protect_count);
    error("Number of observations exceeds maximum supported by TA-Lib");
  }
  int len = (int)n;

  const double *restrict open_ptr = REAL(open);
  const double *restrict high_ptr = REAL(high);
  const double *restrict low_ptr = REAL(low);
  const double *restrict close_ptr = REAL(close);

  SEXP result = PROTECT(allocVector(INTSXP, n));
  protect_count++;
  int *restrict out_ptr = INTEGER(result);

  int out_beg_idx = 0;
  int out_nb_elem = 0;
  TA_RetCode ret_code =
      TA_CDLDRAGONFLYDOJI(0, len - 1, open_ptr, high_ptr, low_ptr, close_ptr,
                          &out_beg_idx, &out_nb_elem, out_ptr);
  if (ret_code != TA_SUCCESS) {
    if (protect_count > 0)
      UNPROTECT(protect_count);
    error("TA-Lib computation failed with error code %d", ret_code);
  }
  shift_array(out_ptr, n, out_beg_idx);
  // the results are given in the range -100 and 100
  // if normalized it returns -1 and 1
  int is_true = Rf_asLogical(normalize_flag);
  if (is_true == 1) {
    normalize(out_ptr, n, 100, out_beg_idx);
  }

  if (protect_count > 0)
    UNPROTECT(protect_count);
  return result;
}