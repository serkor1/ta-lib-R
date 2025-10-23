// interface to ta_PLUS_DI.c
//
// Description
//   Computes the Plus Directional Indicator (+DI). Returns a numeric vector
//   of length n in [0,100]. Leading samples before the first computable
//   output are padded with NA_REAL.
//
// Parameters
//   high       : numeric vector of high prices
//   low        : numeric vector of low prices
//   close      : numeric vector of close prices
//   timeperiod : integer SEXP for lookback (typical default 14)
//
// Returns
//   A REALSXP vector of length n with +DI values in [0,100], left-padded with
//   NA_REAL.

#include "R_ext/Error.h"
#include "Rinternals.h"
#include "lib.h"
#include "names.h"
#include "shift.h"
#include <ta_libc.h>

// clang-format off
SEXP impl_ta_PDI(
  SEXP high,
  SEXP low,
  SEXP close,
  SEXP timeperiod) {
  // clang-format on

  int protect_count = 0;

  const int n = LENGTH(high);
  const double *restrict high_ptr = REAL(high);
  const double *restrict low_ptr = REAL(low);
  const double *restrict close_ptr = REAL(close);
  const int period = INTEGER(timeperiod)[0];

  SEXP result = PROTECT(allocMatrix(REALSXP, n, 1));
  protect_count++;
  double *restrict out_ptr = REAL(result);

  const int minimum_lookback = TA_PLUS_DI_Lookback(period);

  if (n < minimum_lookback) {
    Rf_warning("Input length (%d) is smaller than required lookback (%d).", n,
               minimum_lookback);
    for (int i = 0; i < n; ++i)
      out_ptr[i] = NA_REAL;

  } else {
    int out_beg_index = 0;
    int out_number_of_elements = 0;

    // clang-format off
    TA_RetCode return_code = TA_PLUS_DI(
      /*startIdx        */ 0,
      /*endIdx          */ n - 1,
      /*inHigh          */ high_ptr,
      /*inLow           */ low_ptr,
      /*inClose         */ close_ptr,
      /*optInTimePeriod */ period,
      /*outBeg          */ &out_beg_index,
      /*outNb           */ &out_number_of_elements,
      /*outReal         */ out_ptr
    );
    // clang-format on

    if (return_code != TA_SUCCESS) {
      UNPROTECT(protect_count);
      Rf_error("TA_PLUS_DI failed: return code %d", return_code);
    }

    set_colnames(result, "PDI");
    // Align to full length
    shift_array(out_ptr, n, out_beg_index);
  }

  UNPROTECT(protect_count);
  return result;
}
