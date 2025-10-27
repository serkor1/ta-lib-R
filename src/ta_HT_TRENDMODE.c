// interface to ta_HT_TRENDMODE.c
//
// Description
//   R wrapper for TA_HT_TRENDMODE. Returns trend vs. cycle mode flags.
//
// Parameters
//   real: numeric vector of prices (length n)
//
// Returns
//   n x 1 INTEGER matrix with column "trend_mode", values are typically 0/1,
//   padded with NA_INTEGER for the initial lookback.

#include "R_ext/Error.h"
#include "Rinternals.h"
#include "lib.h"
#include "names.h"
#include "shift.h"
#include <ta_libc.h>

// clang-format off
SEXP impl_ta_HT_TRENDMODE(SEXP real) {
  // clang-format on
  int protect_count = 0;

  const int n = LENGTH(real);
  const double *restrict real_ptr = REAL(real);

  SEXP result = PROTECT(allocMatrix(INTSXP, n, 1));
  protect_count++;
  int *restrict out_ptr = INTEGER(result);

  const int minimum_lookback = TA_HT_TRENDMODE_Lookback();

  if (n < minimum_lookback) {
    Rf_warning("Input length (%d) is smaller than lookback (%d).", n,
               minimum_lookback);
    for (int i = 0; i < n; ++i)
      out_ptr[i] = NA_INTEGER;
  } else {
    int out_begin = 0, number_of_elements = 0;

    // clang-format off
    TA_RetCode return_code = TA_HT_TRENDMODE(
      /*startIdx  */ 0,
      /*endIdx    */ n - 1,
      /*inReal    */ real_ptr,
      /*outBeg    */ &out_begin,
      /*outNb     */ &number_of_elements,
      /*outInteger*/ out_ptr
    );
    // clang-format on

    if (return_code != TA_SUCCESS) {
      UNPROTECT(protect_count);
      Rf_error("TA_HT_TRENDMODE failed: return code %d", return_code);
    }

    shift_array(out_ptr, n, out_begin);
    set_colnames(result, "TRENDMODE");
  }

  UNPROTECT(protect_count);
  return result;
}
