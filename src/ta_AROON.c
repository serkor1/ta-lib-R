// Interface to TA_AROON (Aroon)
//
// Parameters
//   high, low     : numeric vectors (same length)
//   timeperiod    : integer SEXP (typical default 14)
//
// Description
//   Returns an n × 2 REAL matrix with columns "down","up". Leading NA_REAL
//   are padded for the initial lookback.

#include "R_ext/Error.h"
#include "Rinternals.h"
#include "lib.h"
#include "names.h"
#include "shift.h"
#include "ta_func.h"
#include "ta_libc.h"

// clang-format off
SEXP impl_ta_AROON(
  SEXP high,
  SEXP low,
  SEXP timeperiod) {
  // clang-format on

  int protect_count = 0;

  const int n = LENGTH(high);
  const double *restrict high_ptr = REAL(high);
  const double *restrict low_ptr = REAL(low);
  const int period = INTEGER(timeperiod)[0];

  // allocate n x 2 matrix: [down | up]
  SEXP result = PROTECT(allocMatrix(REALSXP, n, 2));
  protect_count++;
  double *restrict down = REAL(result);
  double *restrict up = down + n;

  const int minimum_lookback = TA_AROON_Lookback(period);

  if (n < minimum_lookback) {
    Rf_warning("Input length (%d) is smaller than required lookback (%d).", n,
               minimum_lookback);
    for (int i = 0; i < n; ++i) {
      down[i] = up[i] = NA_REAL;
    }

  } else {
    int outBeg = 0, outNb = 0;
    // clang-format off
    TA_RetCode return_code = TA_AROON(
      /*startIdx*/ 0,
      /*endIdx  */ n - 1,
      /*inHigh  */ high_ptr,
      /*inLow   */ low_ptr,
      /*optPer  */ period,
      /*outBeg  */ &outBeg,
      /*outNb   */ &outNb,
      /*outDown */ down,
      /*outUp   */ up
    );
    // clang-format on

    if (return_code != TA_SUCCESS) {
      UNPROTECT(protect_count);
      Rf_error("TA_AROON failed: return code %d", return_code);
    }

    // Align to full length
    shift_array(down, n, outBeg);
    shift_array(up, n, outBeg);
  }

  // set column names "down","up"
  set_colnames(result, "AROONDOWN", "AROONUP");

  UNPROTECT(protect_count);
  return result;
}
