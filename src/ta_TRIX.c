// interface to ta_TRIX.c
//
// Description
//   1-day ROC of a Triple-Smoothed EMA (TRIX). Input is a single real series.
//
// Parameters
//   real        : numeric vector (e.g., closes)
//   timeperiod  : integer SEXP lookback
//
// Returns
//   Numeric vector length n. Leading NA_REAL for lookback.

#include "R_ext/Error.h"
#include "Rinternals.h"
#include "lib.h"
#include "names.h"
#include "shift.h"
#include <ta_libc.h>

// clang-format off
SEXP impl_ta_TRIX(
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

  const int minimum_lookback = TA_TRIX_Lookback(period);

  if (n < minimum_lookback) {
    Rf_warning("Input length (%d) is smaller than required lookback (%d).", n,
               minimum_lookback);
    for (int i = 0; i < n; ++i)
      out_ptr[i] = NA_REAL;
  } else {
    int output_begin_index = 0;
    int number_of_output_elements = 0;

    // clang-format off
    TA_RetCode return_code = TA_TRIX(
      /*startIdx        */ 0,
      /*endIdx          */ n - 1,
      /*inReal          */ real_ptr,
      /*optInTimePeriod */ period,
      /*outBeg          */ &output_begin_index,
      /*outNb           */ &number_of_output_elements,
      /*outReal         */ out_ptr
    );
    // clang-format on

    if (return_code != TA_SUCCESS) {
      UNPROTECT(protect_count);
      Rf_error("TA_TRIX failed: return code %d", return_code);
    }

    set_colnames(result, "TRIX");
    shift_array(out_ptr, n, output_begin_index);
  }

  UNPROTECT(protect_count);
  return result;
}
