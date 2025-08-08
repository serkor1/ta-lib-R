// Interface to TA_CDLDOJI
//
// Parameters
//   open: numeric vector of opening prices
//   high: numeric vector of high prices
//   low:  numeric vector of low prices
//   close: numeric vector of closing prices
//
// Description
//   Identifies "Doji" candlestick patterns, where the open and close prices are
//   nearly equal, indicating market indecision. Returns an integer vector of
//   the same length as the inputs, with 100 for each index where a Doji pattern
//   is detected (0 otherwise). Leading NA values are padded for periods before
//   the first output can be computed (if any).
#include "lib.h"
#include "normalize.h"
#include "shift.h"
#include <limits.h>
#include <ta_libc.h>

SEXP impl_ta_CDLDOJI(SEXP open, SEXP high, SEXP low, SEXP close,
                     SEXP normalize_flag) {

  R_xlen_t n = XLENGTH(open);
  int protect_count = 0;

  if (n > INT_MAX) {
    if (protect_count > 0)
      UNPROTECT(protect_count);
    error("Number of observations exceeds maximum supported by TA-Lib");
  }
  int len = (int)n; // safe to cast after checking

  // Get pointers to the input data (treated as double arrays for TA-Lib)
  const double *restrict open_ptr = REAL(open);
  const double *restrict high_ptr = REAL(high);
  const double *restrict low_ptr = REAL(low);
  const double *restrict close_ptr = REAL(close);

  // Allocate an integer output vector of length n for the result
  SEXP result = PROTECT(allocVector(INTSXP, n));
  protect_count++;
  int *restrict out_ptr = INTEGER(result);

  // Prepare variables to receive output range from TA-Lib
  int out_beg_idx = 0;
  int out_nb_elem = 0;

  // Call TA-Lib function TA_CDLDOJI to compute the pattern indicator
  TA_RetCode ret_code =
      TA_CDLDOJI(0, len - 1, open_ptr, high_ptr, low_ptr, close_ptr,
                 &out_beg_idx, &out_nb_elem, out_ptr);

  // Check for errors from TA-Lib computation
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

  // Unprotect protected objects and return the result
  if (protect_count > 0)
    UNPROTECT(protect_count);

  return result;
}
