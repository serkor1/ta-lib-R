// interface to ta_MACDFIX.c
//
// Parameters
//   inReal          : numeric vector (length n)
//   optSignalPeriod : integer signal period
//
// Returns
//   matrix n x 3 with columns:
//     "macd"
//     "signal"
//     "histogram"
//
#include "container.h"
#include "lib.h"
#include "names.h"
#include "shift.h"
#include <R.h>
#include <Rinternals.h>
#include <ta_libc.h>

// clang-format off
SEXP impl_ta_MACDFIX(
  SEXP inReal,
  SEXP optSignalPeriod) {
  // clang-format on
  int protect_count = 0;

  const double *restrict in_real = REAL(inReal);
  const int n = LENGTH(inReal);

  const int signal_period = INTEGER(optSignalPeriod)[0];

  SEXP output;
  double *output_ptr;

  const int lookback = TA_MACDFIX_Lookback(signal_period);

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
    TA_RetCode return_code = TA_MACDFIX(
       0,
       n - 1,
       in_real,
       signal_period,
       &start_idx,
       &end_idx,
       output_macd,
       output_signal,
       output_histogram
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
