// interface to ta_TRANGE.c
//
// Description
//   R wrapper for TA_TRANGE. Computes True Range from high, low, close.
//
// Parameters
//   high, low, close: numeric vectors (same length)
//
// Returns
//   n x 1 REAL matrix with column "trange", padded with NA_REAL for
//   the initial lookback.

#include "R_ext/Error.h"
#include "Rinternals.h"
#include "lib.h"
#include "names.h"
#include "shift.h"
#include <ta_libc.h>

// clang-format off
SEXP impl_ta_TRANGE(SEXP high, SEXP low, SEXP close) {
  // clang-format on
  int protect_count = 0;

  const int n = LENGTH(high);
  const double *restrict high_ptr = REAL(high);
  const double *restrict low_ptr = REAL(low);
  const double *restrict close_ptr = REAL(close);

  SEXP result = PROTECT(allocMatrix(REALSXP, n, 1));
  protect_count++;
  double *restrict out_ptr = REAL(result);

  const int minimum_lookback = TA_TRANGE_Lookback();

  if (n < minimum_lookback) {
    Rf_warning("Input length (%d) is smaller than lookback (%d).", n,
               minimum_lookback);
    for (int i = 0; i < n; ++i)
      out_ptr[i] = NA_REAL;
  } else {
    int out_begin = 0, number_of_elements = 0;

    // clang-format off
    TA_RetCode return_code = TA_TRANGE(
      /*startIdx*/ 0,
      /*endIdx  */ n - 1,
      /*inHigh  */ high_ptr,
      /*inLow   */ low_ptr,
      /*inClose */ close_ptr,
      /*outBeg  */ &out_begin,
      /*outNb   */ &number_of_elements,
      /*outReal */ out_ptr
    );
    // clang-format on

    if (return_code != TA_SUCCESS) {
      UNPROTECT(protect_count);
      Rf_error("TA_TRANGE failed: return code %d", return_code);
    }

    shift_array(out_ptr, n, out_begin);
    set_colnames(result, "TRANGE");
  }

  UNPROTECT(protect_count);
  return result;
}
