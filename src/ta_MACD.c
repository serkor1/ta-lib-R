// interface to ta_MACD.c
//
// Parameters
//   inReal        : numeric vector (length n)
//   optFastPeriod : integer fast EMA period
//   optSlowPeriod : integer slow EMA period
//   optSignal     : integer signal period
//
// Returns
//   matrix n x 3 with columns:
//     "MACD"
//     "MACDSignal"
//     "MACDHist"
//
#include "container.h"
#include "lib.h"
#include "names.h"
#include "shift.h"
#include <R.h>
#include <Rinternals.h>
#include <ta_libc.h>

// clang-format off
SEXP impl_ta_MACD(
  SEXP inReal,
  SEXP optFastPeriod,
  SEXP optSlowPeriod,
  SEXP optSignal) {
  // clang-format on
  int protect_count = 0;

  const double *restrict in_real = REAL(inReal);
  const int n = LENGTH(inReal);

  const int fast_period = INTEGER(optFastPeriod)[0];
  const int slow_period = INTEGER(optSlowPeriod)[0];
  const int signal_period = INTEGER(optSignal)[0];

  SEXP output;
  double *output_ptr;

  // clang-format off
  const int lookback = TA_MACD_Lookback(
    fast_period, 
    slow_period, 
    signal_period
  );
  // clang-format on

  const int proceed =
      output_container(n, lookback, 3, &output, &output_ptr, &protect_count);

  if (proceed) {
    int start_idx = 0, end_idx = 0;

    double *output_macd = output_ptr;
    double *output_signal = output_ptr + n;
    double *output_histogram = output_ptr + 2 * n;

    // clang-format off
    TA_RetCode return_code = TA_MACD(
      /*startIdx     */ 0,
      /*endIdx       */ n - 1,
      /*inReal       */ in_real,
      /*optInFastPrd */ fast_period,
      /*optInSlowPrd */ slow_period,
      /*optInSignal  */ signal_period,
      /*outBegIdx    */ &start_idx,
      /*outNbElement */ &end_idx,
      /*outMACD      */ output_macd,
      /*outMACDSignal*/ output_signal,
      /*outMACDHist  */ output_histogram
    );
    // clang-format on

    check_output(return_code, protect_count);

    shift_array(output_macd, n, start_idx);
    shift_array(output_signal, n, start_idx);
    shift_array(output_histogram, n, start_idx);
  }

  set_colnames(output, "macd", "signal", "histogram");

  UNPROTECT(protect_count);
  return output;
}
