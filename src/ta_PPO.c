// interface to ta_PPO.c
//
// Description
//   Percentage Price Oscillator. Difference between fast and slow MAs as
//   percentage of slow MA.
//
// Parameters
//   real         : numeric vector (e.g., closes)
//   fastperiod   : integer SEXP
//   slowperiod   : integer SEXP
//   ma_type      : integer SEXP mapped to TA_MAType via as_MAType()
//
// Returns
//   Numeric vector length n. Leading NA_REAL for lookback.

#include "MAType.h"
#include "R_ext/Error.h"
#include "Rinternals.h"
#include "lib.h"
#include "names.h"
#include "shift.h"
#include <ta_libc.h>

// clang-format off
SEXP impl_ta_PPO(
  SEXP real,
  SEXP fastperiod,
  SEXP slowperiod,
  SEXP ma_type) {
  // clang-format on
  int protect_count = 0;

  const int n = LENGTH(real);
  const double *restrict real_ptr = REAL(real);
  const int fast_period = INTEGER(fastperiod)[0];
  const int slow_period = INTEGER(slowperiod)[0];
  const TA_MAType ma = as_MAType(ma_type);

  SEXP result = PROTECT(allocMatrix(REALSXP, n, 1));
  protect_count++;
  double *restrict out_ptr = REAL(result);

  const int minimum_lookback = TA_PPO_Lookback(fast_period, slow_period, ma);

  if (n < minimum_lookback) {
    Rf_warning("Input length (%d) is smaller than required lookback (%d).", n,
               minimum_lookback);
    for (int i = 0; i < n; ++i)
      out_ptr[i] = NA_REAL;
  } else {
    int output_begin_index = 0;
    int number_of_output_elements = 0;

    // clang-format off
    TA_RetCode return_code = TA_PPO(
      /*startIdx        */ 0,
      /*endIdx          */ n - 1,
      /*inReal          */ real_ptr,
      /*optInFastPeriod */ fast_period,
      /*optInSlowPeriod */ slow_period,
      /*optInMAType     */ ma,
      /*outBeg          */ &output_begin_index,
      /*outNb           */ &number_of_output_elements,
      /*outReal         */ out_ptr
    );
    // clang-format on

    if (return_code != TA_SUCCESS) {
      UNPROTECT(protect_count);
      Rf_error("TA_PPO failed: return code %d", return_code);
    }

    set_colnames(result, "PPO");
    shift_array(out_ptr, n, output_begin_index);
  }

  UNPROTECT(protect_count);
  return result;
}
