// Interface to TA_SAREXT (Parabolic SAR - Extended)
//
// Parameters
//   high, low                    : numeric vectors (same length)
//   start_value                  : numeric scalar (double)
//   offset_on_reverse            : numeric scalar (double)
//   accel_init_long              : numeric scalar (double)
//   accel_long                   : numeric scalar (double)
//   accel_max_long               : numeric scalar (double)
//   accel_init_short             : numeric scalar (double)
//   accel_short                  : numeric scalar (double)
//   accel_max_short              : numeric scalar (double)
//
// Description
//   Returns a numeric vector of length n, padded with NA_REAL for the initial
//   lookback, then SAREXT values thereafter.

#include "R_ext/Error.h"
#include "Rinternals.h"
#include "lib.h"
#include "names.h"
#include "shift.h"
#include <ta_libc.h>

// clang-format off
SEXP impl_ta_SAREXT(
  SEXP high,
  SEXP low,
  SEXP start_value,
  SEXP offset_on_reverse,
  SEXP accel_init_long,
  SEXP accel_long,
  SEXP accel_max_long,
  SEXP accel_init_short,
  SEXP accel_short,
  SEXP accel_max_short) {
  // clang-format on

  int protect_count = 0;

  const int n = LENGTH(high);
  const double *restrict high_ptr = REAL(high);
  const double *restrict low_ptr = REAL(low);

  const double startv = REAL(start_value)[0];
  const double offset_rev = REAL(offset_on_reverse)[0];

  const double a_init_l = REAL(accel_init_long)[0];
  const double a_l = REAL(accel_long)[0];
  const double a_max_l = REAL(accel_max_long)[0];

  const double a_init_s = REAL(accel_init_short)[0];
  const double a_s = REAL(accel_short)[0];
  const double a_max_s = REAL(accel_max_short)[0];

  SEXP result = PROTECT(allocMatrix(REALSXP, n, 1));
  protect_count++;
  double *restrict out_ptr = REAL(result);

  const int minimum_lookback = TA_SAREXT_Lookback(
      startv, offset_rev, a_init_l, a_l, a_max_l, a_init_s, a_s, a_max_s);

  if (n < minimum_lookback) {
    Rf_warning("Input length (%d) is smaller than required lookback (%d).", n,
               minimum_lookback);
    for (int i = 0; i < n; ++i)
      out_ptr[i] = NA_REAL;

  } else {
    int outBeg = 0, outNb = 0;

    // clang-format off
    TA_RetCode rc = TA_SAREXT(
      /*startIdx*/ 0,
      /*endIdx  */ n - 1,
      /*inHigh  */ high_ptr,
      /*inLow   */ low_ptr,
      /*startV  */ startv,
      /*offRev  */ offset_rev,
      /*aInitL  */ a_init_l,
      /*aL      */ a_l,
      /*aMaxL   */ a_max_l,
      /*aInitS  */ a_init_s,
      /*aS      */ a_s,
      /*aMaxS   */ a_max_s,
      /*outBeg  */ &outBeg,
      /*outNb   */ &outNb,
      /*outReal */ out_ptr
    );
    // clang-format on

    if (rc != TA_SUCCESS) {
      UNPROTECT(protect_count);
      Rf_error("TA_SAREXT failed: return code %d", rc);
    }

    set_colnames(result, "SAR");
    shift_array(out_ptr, n, outBeg);
  }

  UNPROTECT(protect_count);
  return result;
}
