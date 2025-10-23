// interface to ta_IMI.c
//
// Description
// Computes Intraday Momentum Index (IMI). Writes values in [0, 100].
// Pads leading NA_REAL up to the lookback.
//
// Parameters
//   open        : numeric vector of opens
//   close       : numeric vector of closes
//   timeperiod  : integer SEXP lookback (default in TA-Lib is 14)
//
// Returns
//   Numeric vector of length n with IMI values aligned to inputs.
//   Leading elements before the first computable index are NA_REAL.

#include "R_ext/Error.h"
#include "Rinternals.h"
#include "lib.h"
#include "names.h"
#include "shift.h"
#include <ta_libc.h>

// clang-format off
SEXP impl_ta_IMI(
  SEXP open,
  SEXP close,
  SEXP timeperiod) {
  // clang-format on

  int protect_count = 0;

  const int n = LENGTH(open);
  const double *restrict open_ptr = REAL(open);
  const double *restrict close_ptr = REAL(close);
  const int period = INTEGER(timeperiod)[0];

  SEXP result = PROTECT(allocMatrix(REALSXP, n, 1));
  protect_count++;
  double *restrict out_ptr = REAL(result);

  const int minimum_lookback = TA_IMI_Lookback(period);

  if (n < minimum_lookback) {
    Rf_warning("Input length (%d) is smaller than required lookback (%d).", n,
               minimum_lookback);
    for (int i = 0; i < n; ++i)
      out_ptr[i] = NA_REAL;
  } else {
    int output_begin_index = 0;
    int number_of_output_elements = 0;

    // clang-format off
    TA_RetCode return_code = TA_IMI(
      /*startIdx*/ 0,
      /*endIdx  */ n - 1,
      /*inOpen  */ open_ptr,
      /*inClose */ close_ptr,
      /*optInTP */ period,
      /*outBeg  */ &output_begin_index,
      /*outNb   */ &number_of_output_elements,
      /*outReal */ out_ptr
    );
    // clang-format on

    if (return_code != TA_SUCCESS) {
      UNPROTECT(protect_count);
      Rf_error("TA_IMI failed: return code %d", return_code);
    }

    set_colnames(result, "IMI");
    // Align to full length
    shift_array(out_ptr, n, output_begin_index);
  }

  UNPROTECT(protect_count);
  return result;
}
