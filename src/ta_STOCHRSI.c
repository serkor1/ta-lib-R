// interface to ta_STOCHRSI.c
//
// Parameters
//   inReal        : numeric vector (length n)
//   optTimePeriod : integer RSI time period
//   optFastK      : integer Fast-K period
//   optFastD      : integer Fast-D period
//   optFastD_MA   : integer MA type for Fast-D
//
// Returns
//   matrix n x 2 with columns:
//     "fastk"
//     "fastd"
//
// Details
//   This function wraps RSI from the R side, so all
//   values are offset by the <NA> values produced
//   otherwise all returned values are <NA>
//
#include "MAType.h"
#include "container.h"
#include "lib.h"
#include "names.h"
#include "shift.h"
#include <R.h>
#include <Rinternals.h>
#include <ta_libc.h>

// clang-format off
SEXP impl_ta_STOCHRSI(
  SEXP inReal,
  SEXP optTimePeriod,
  SEXP optFastK,
  SEXP optFastD,
  SEXP optFastD_MA,
  SEXP offset_by_RSI) {
  // clang-format on
  int protect_count = 0;

  const double *restrict in_real = REAL(inReal);
  const int n = LENGTH(inReal);

  const int time_period = INTEGER(optTimePeriod)[0];
  const int fast_k = INTEGER(optFastK)[0];
  const int fast_d = INTEGER(optFastD)[0];
  const TA_MAType fast_d_ma = as_MAType(optFastD_MA);
  const int offset = INTEGER(offset_by_RSI)[0];

  SEXP output;
  double *output_ptr;

  // clang-format off
  const int lookback = TA_STOCHRSI_Lookback(
    time_period, 
    fast_k, 
    fast_d, 
    fast_d_ma) + offset;
  // clang-format on

  // clang-format off
  const int proceed = output_container(
    n + offset, 
    lookback, 
    2, 
    &output,
    &output_ptr, 
    &protect_count
  );
  // clang-format on

  if (proceed) {
    int start_idx = 0, end_idx = 0;

    double *output_fastk = output_ptr;
    double *output_fastd = output_ptr + (n + offset);

    // clang-format off
    TA_RetCode return_code = TA_STOCHRSI(
       0,
       n - 1,
       in_real,
       time_period,
       fast_k,
       fast_d,
       fast_d_ma,
       &start_idx,
       &end_idx,
       output_fastk,
       output_fastd
    );
    // clang-format on

    check_output(return_code, protect_count);

    shift_array(output_fastk, n + offset, start_idx + offset);
    shift_array(output_fastd, n + offset, start_idx + offset);
  }

  set_colnames(output, "fastk", "fastd");

  UNPROTECT(protect_count);
  return output;
}
