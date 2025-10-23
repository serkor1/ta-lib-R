// interface to ta_DX.c
//
// Description
//   Directional Movement Index. Computes DX from high, low, close.
//
// Parameters
//   high        : numeric vector of highs
//   low         : numeric vector of lows
//   close       : numeric vector of closes
//   timeperiod  : integer SEXP lookback (default in TA-Lib is 14)
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
SEXP impl_ta_DX(
  SEXP high,
  SEXP low,
  SEXP close,
  SEXP timeperiod) {
  // clang-format on
  int protect_count = 0;

  const int n = LENGTH(high);
  if (LENGTH(low) != n || LENGTH(close) != n) {
    Rf_error("Inputs 'high', 'low', and 'close' must have equal length.");
  }

  const double *restrict high_ptr = REAL(high);
  const double *restrict low_ptr = REAL(low);
  const double *restrict close_ptr = REAL(close);
  const int period = INTEGER(timeperiod)[0];

  SEXP result = PROTECT(allocMatrix(REALSXP, n, 1));
  protect_count++;
  double *restrict out_ptr = REAL(result);

  const int minimum_lookback = TA_DX_Lookback(period);

  if (n < minimum_lookback) {
    Rf_warning("Input length (%d) is smaller than required lookback (%d).", n,
               minimum_lookback);
    for (int i = 0; i < n; ++i)
      out_ptr[i] = NA_REAL;
  } else {
    int output_begin_index = 0;
    int number_of_output_elements = 0;

    // clang-format off
    TA_RetCode return_code = TA_DX(
      /*startIdx        */ 0,
      /*endIdx          */ n - 1,
      /*inHigh          */ high_ptr,
      /*inLow           */ low_ptr,
      /*inClose         */ close_ptr,
      /*optInTimePeriod */ period,
      /*outBeg          */ &output_begin_index,
      /*outNb           */ &number_of_output_elements,
      /*outReal         */ out_ptr
    );
    // clang-format on

    if (return_code != TA_SUCCESS) {
      UNPROTECT(protect_count);
      Rf_error("TA_DX failed: return code %d", return_code);
    }

    set_colnames(result, "DX");
    shift_array(out_ptr, n, output_begin_index);
  }

  UNPROTECT(protect_count);
  return result;
}
