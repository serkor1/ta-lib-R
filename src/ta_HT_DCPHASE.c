// interface to ta_HT_DCPHASE.c
//
// Description
//   R wrapper for TA_HT_DCPHASE. Computes the Hilbert Transform Dominant
//   Cycle Phase on a single real-valued series.
//
// Parameters
//   real: numeric vector of prices (length n)
//
// Returns
//   n x 1 REAL matrix with column "ht_dcphase", padded with NA_REAL for
//   the initial lookback.

// Includes
#include "R_ext/Error.h"
#include "Rinternals.h"
#include "lib.h"
#include "names.h"
#include "shift.h"
#include <ta_libc.h>

// clang-format off
SEXP impl_ta_HT_DCPHASE(SEXP real) {
  // clang-format on
  int protect_count = 0;

  const int n = LENGTH(real);
  const double *restrict real_ptr = REAL(real);

  SEXP result = PROTECT(allocMatrix(REALSXP, n, 1));
  protect_count++;
  double *restrict out_ptr = REAL(result);

  const int minimum_lookback = TA_HT_DCPHASE_Lookback();

  if (n < minimum_lookback) {
    Rf_warning("Input length (%d) is smaller than lookback (%d).", n,
               minimum_lookback);
    for (int i = 0; i < n; ++i)
      out_ptr[i] = NA_REAL;
  } else {
    int out_begin = 0, number_of_elements = 0;

    // clang-format off
    TA_RetCode return_code = TA_HT_DCPHASE(
      /*startIdx*/ 0,
      /*endIdx  */ n - 1,
      /*inReal  */ real_ptr,
      /*outBeg  */ &out_begin,
      /*outNb   */ &number_of_elements,
      /*outReal */ out_ptr
    );
    // clang-format on

    if (return_code != TA_SUCCESS) {
      UNPROTECT(protect_count);
      Rf_error("TA_HT_DCPHASE failed: return code %d", return_code);
    }

    shift_array(out_ptr, n, out_begin);
    set_colnames(result, "DCPHASE");
  }

  UNPROTECT(protect_count);
  return result;
}
