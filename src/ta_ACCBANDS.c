// interface to ta_ACCBANDS.c
//
// Parameters
//   inHigh        : numeric vector of highs   (length n)
//   inLow         : numeric vector of lows    (length n)
//   inClose       : numeric vector of closes  (length n)
//   optTimePeriod : integer time period
//
// Returns
//   numeric matrix (n x 3) with columns
//     "upper"
//     "middle"
//     "lower"
//
#include "container.h"
#include "lib.h"
#include "names.h"
#include "shift.h"
#include <R.h>
#include <Rinternals.h>
#include <ta_libc.h>

// clang-format off
SEXP impl_ta_ACCBANDS(
  SEXP inHigh,
  SEXP inLow,
  SEXP inClose,
  SEXP optTimePeriod) {
  // clang-format on
  int protect_count = 0;

  const double *restrict high_ptr = REAL(inHigh);
  const double *restrict low_ptr = REAL(inLow);
  const double *restrict close_ptr = REAL(inClose);
  const int n = LENGTH(inHigh);

  const int time_period = INTEGER(optTimePeriod)[0];

  SEXP output;
  double *output_ptr;

  const int lookback = TA_ACCBANDS_Lookback(time_period);

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
    int start_idx = 0;
    int number_of_elements = 0;

    double *restrict out_upper = output_ptr;
    double *restrict out_middle = output_ptr + n;
    double *restrict out_lower = output_ptr + (2 * n);

    // clang-format off
    TA_RetCode return_code = TA_ACCBANDS(
      0,
      n - 1,
      high_ptr,
      low_ptr,
      close_ptr,
      time_period,
      &start_idx,
      &number_of_elements,
      out_upper,
      out_middle,
      out_lower
    );
    // clang-format on

    check_output(return_code, protect_count);

    shift_array(out_upper, n, start_idx);
    shift_array(out_middle, n, start_idx);
    shift_array(out_lower, n, start_idx);
  }

  set_colnames(output, "upper", "middle", "lower");

  UNPROTECT(protect_count);
  return output;
}
