// interface to ta_MACDEXT.c
//
// Parameters
//   inReal          : numeric vector (length n)
//   optFastPeriod   : integer fast period
//   optFastMAType   : integer MA type for fast period
//   optSlowPeriod   : integer slow period
//   optSlowMAType   : integer MA type for slow period
//   optSignalPeriod : integer signal period
//   optSignalMAType : integer MA type for signal
//
// Returns
//   matrix n x 3 with columns:
//     "macd"
//     "signal"
//     "histogram"
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
SEXP impl_ta_MACDEXT(
  SEXP inReal,
  SEXP optFastPeriod,
  SEXP optFastMAType,
  SEXP optSlowPeriod,
  SEXP optSlowMAType,
  SEXP optSignalPeriod,
  SEXP optSignalMAType) {
  // clang-format on
  int protect_count = 0;

  const double *restrict in_real = REAL(inReal);
  const int n = LENGTH(inReal);

  const int fast_period = INTEGER(optFastPeriod)[0];
  const TA_MAType fast_ma = as_MAType(optFastMAType);
  const int slow_period = INTEGER(optSlowPeriod)[0];
  const TA_MAType slow_ma = as_MAType(optSlowMAType);
  const int signal_period = INTEGER(optSignalPeriod)[0];
  const TA_MAType signal_ma = as_MAType(optSignalMAType);

  SEXP output;
  double *output_ptr;

  // clang-format off
  const int lookback = TA_MACDEXT_Lookback(
    fast_period, 
    fast_ma, 
    slow_period,
    slow_ma, 
    signal_period, 
    signal_ma
  );
  // clang-format on

  // clang-format off
  const int proceed = output_container(
    n, 
    lookback, 
    3, 
    &output,
    &output_ptr, 
    &protect_count
  );
  // clang-format on

  if (proceed) {
    int start_idx = 0, end_idx = 0;

    double *output_macd = output_ptr;
    double *output_signal = output_ptr + n;
    double *output_histogram = output_ptr + 2 * n;

    // clang-format off
    TA_RetCode return_code = TA_MACDEXT(
      /*startIdx        */ 0,
      /*endIdx          */ n - 1,
      /*inReal          */ in_real,
      /*optInFastPeriod */ fast_period,
      /*optInFastMAType */ fast_ma,
      /*optInSlowPeriod */ slow_period,
      /*optInSlowMAType */ slow_ma,
      /*optInSignalPrd  */ signal_period,
      /*optInSignalMA   */ signal_ma,
      /*outBegIdx       */ &start_idx,
      /*outNbElement    */ &end_idx,
      /*outMACD         */ output_macd,
      /*outMACDSignal   */ output_signal,
      /*outMACDHist     */ output_histogram
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
