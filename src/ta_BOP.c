// interface to ta_BOP.c
//
// Description
// Balance of Power: (close - open) / (high - low). Thin wrapper over TA_BOP.
// Aligns TA-Lib's compact output to full length with leading NA_REAL.
//
// Parameters
// open, high, low, close : numeric vectors of equal length
//
// Returns
// Numeric vector length n with BOP in [-1, 1], padded with NA_REAL where
// needed.

#include "R_ext/Error.h"
#include "Rinternals.h"
#include "lib.h"
#include "names.h"
#include "shift.h"
#include <ta_libc.h>

// clang-format off
SEXP impl_ta_BOP(
  SEXP open,
  SEXP high,
  SEXP low,
  SEXP close) {
  // clang-format on
  int protect_count = 0;

  const int n = LENGTH(open);
  const double *restrict open_ptr = REAL(open);
  const double *restrict high_ptr = REAL(high);
  const double *restrict low_ptr = REAL(low);
  const double *restrict close_ptr = REAL(close);

  SEXP result = PROTECT(allocMatrix(REALSXP, n, 1));
  protect_count++;
  double *restrict out_ptr = REAL(result);

  const int minimum_lookback = TA_BOP_Lookback();

  if (n < minimum_lookback) {
    Rf_warning("Input length (%d) is smaller than required lookback (%d).", n,
               minimum_lookback);
    for (int i = 0; i < n; ++i)
      out_ptr[i] = NA_REAL;
  } else {
    int out_beg_index = 0;
    int out_nb_element = 0;

    // clang-format off
    TA_RetCode return_code = TA_BOP(
      /*startIdx*/ 0,
      /*endIdx  */ n - 1,
      /*inOpen  */ open_ptr,
      /*inHigh  */ high_ptr,
      /*inLow   */ low_ptr,
      /*inClose */ close_ptr,
      /*outBeg  */ &out_beg_index,
      /*outNb   */ &out_nb_element,
      /*outReal */ out_ptr
    );
    // clang-format on

    if (return_code != TA_SUCCESS) {
      UNPROTECT(protect_count);
      Rf_error("TA_BOP failed: return code %d", return_code);
    }

    set_colnames(result, "BOP");
    shift_array(out_ptr, n, out_beg_index);
  }

  UNPROTECT(protect_count);
  return result;
}
