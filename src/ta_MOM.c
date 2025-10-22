// interface to ta_MOM.c
//
// Description
// Momentum over a lookback period. Thin wrapper over TA_MOM.
// Aligns TA-Lib's compact output to full length with leading NA_REAL.
//
// Parameters
// real       : numeric vector
// timeperiod : integer lookback (e.g., 10)
//
// Returns
// Numeric vector length n with momentum values, padded with NA_REAL where
// needed.

#include "R_ext/Error.h"
#include "Rinternals.h"
#include "lib.h"
#include "names.h"
#include "shift.h"
#include <ta_libc.h>

// clang-format off
SEXP impl_ta_MOM(
  SEXP real,
  SEXP timeperiod) {
  // clang-format on
  int protect_count = 0;

  const int n = LENGTH(real);
  const double *restrict real_ptr = REAL(real);
  const int period = INTEGER(timeperiod)[0];

  SEXP result = PROTECT(allocMatrix(REALSXP, n, 1));
  protect_count++;
  double *restrict out_ptr = REAL(result);

  const int minimum_lookback = TA_MOM_Lookback(period);

  if (n < minimum_lookback) {
    Rf_warning("Input length (%d) is smaller than required lookback (%d).", n,
               minimum_lookback);
    for (int i = 0; i < n; ++i)
      out_ptr[i] = NA_REAL;
  } else {
    int out_beg_index = 0;
    int out_nb_element = 0;

    // clang-format off
    TA_RetCode return_code = TA_MOM(
      /*startIdx*/ 0,
      /*endIdx  */ n - 1,
      /*inReal  */ real_ptr,
      /*optPer  */ period,
      /*outBeg  */ &out_beg_index,
      /*outNb   */ &out_nb_element,
      /*outReal */ out_ptr
    );
    // clang-format on

    if (return_code != TA_SUCCESS) {
      UNPROTECT(protect_count);
      Rf_error("TA_MOM failed: return code %d", return_code);
    }

    set_colnames(result, "MOM");
    shift_array(out_ptr, n, out_beg_index);
  }

  UNPROTECT(protect_count);
  return result;
}
