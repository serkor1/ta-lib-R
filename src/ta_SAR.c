// interface to ta_SAR.c
//
// Parameters
//   inHigh         : numeric vector of highs (length n)
//   inLow          : numeric vector of lows  (length n)
//   optAcceleration: numeric acceleration step (e.g. 0.02)
//   optMaximum     : numeric acceleration max (e.g. 0.20)
//
// Returns
//   numeric vector (n x 1) "SAR"
//
#include "container.h"
#include "lib.h"
#include "names.h"
#include "shift.h"
#include <R.h>
#include <Rinternals.h>
#include <ta_libc.h>

// clang-format off
SEXP impl_ta_SAR(
  SEXP inHigh,
  SEXP inLow,
  SEXP optAcceleration,
  SEXP optMaximum) {
  // clang-format on
  int protect_count = 0;

  const double *restrict high_ptr = REAL(inHigh);
  const double *restrict low_ptr = REAL(inLow);
  const int n = LENGTH(inHigh);

  const double acceleration = REAL(optAcceleration)[0];
  const double maximum = REAL(optMaximum)[0];

  SEXP output;
  double *output_ptr;

  const int lookback = TA_SAR_Lookback(acceleration, maximum);

  // clang-format off
  const int proceed = output_container(
    n,
    lookback,
    1,
    &output,
    &output_ptr,
    &protect_count
  );
  // clang-format on

  if (proceed) {
    int start_idx = 0;
    int number_of_elements = 0;

    // clang-format off
    TA_RetCode return_code = TA_SAR(
      0,
      n - 1,
      high_ptr,
      low_ptr,
      acceleration,
      maximum,
      &start_idx,
      &number_of_elements,
      output_ptr
    );
    // clang-format on

    check_output(return_code, protect_count);
    shift_array(output_ptr, n, start_idx);
  }

  set_colnames(output, "SAR");

  UNPROTECT(protect_count);
  return output;
}
