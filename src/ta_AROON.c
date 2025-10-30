// interface to ta_AROON.c
//
// Parameters
//   inHigh        : numeric vector of highs (length n)
//   inLow         : numeric vector of lows  (length n)
//   optTimePeriod : integer time period (default in TA-Lib is 14)
//
// Returns
//   matrix n x 2 with columns:
//     "AROONDOWN"
//     "AROONUP"
//
#include "container.h"
#include "lib.h"
#include "names.h"
#include "shift.h"
#include <R.h>
#include <Rinternals.h>
#include <ta_libc.h>

// clang-format off
SEXP impl_ta_AROON(
  SEXP inHigh,
  SEXP inLow,
  SEXP optTimePeriod) {
  // clang-format on
  int protect_count = 0;

  const double *restrict high_ptr = REAL(inHigh);
  const double *restrict low_ptr = REAL(inLow);
  const int n = LENGTH(inHigh);

  const int time_period = INTEGER(optTimePeriod)[0];

  SEXP output;
  double *output_ptr;

  const int lookback = TA_AROON_Lookback(time_period);

  // clang-format off
  const int proceed = output_container(
    n, 
    lookback, 
    2, 
    &output,
    &output_ptr,
    &protect_count
  );
  // clang-format on

  if (proceed) {

    int start_idx = 0, end_idx = 0;

    double *out_aroon_down = output_ptr;
    double *out_aroon_up = output_ptr + n;

    // clang-format off
    TA_RetCode return_code = TA_AROON(
       0,
       n - 1,
       high_ptr,
       low_ptr,
       time_period,
       &start_idx,
       &end_idx,
       out_aroon_down,
       out_aroon_up
    );
    // clang-format on

    check_output(return_code, protect_count);

    shift_array(out_aroon_down, n, start_idx);
    shift_array(out_aroon_up, n, start_idx);
  }

  set_colnames(output, "AROONDOWN", "AROONUP");

  UNPROTECT(protect_count);
  return output;
}
