// interface to ta_SAREXT.c
//
// Parameters
//   inHigh                    : numeric vector of highs (length n)
//   inLow                     : numeric vector of lows  (length n)
//   optStartValue             : numeric start value
//   optOffsetOnReverse        : numeric offset on reverse
//   optAccelerationInitLong   : numeric initial long acceleration
//   optAccelerationLong       : numeric long acceleration step
//   optAccelerationMaxLong    : numeric long acceleration maximum
//   optAccelerationInitShort  : numeric initial short acceleration
//   optAccelerationShort      : numeric short acceleration step
//   optAccelerationMaxShort   : numeric short acceleration maximum
//
// Returns
//   numeric vector (n x 1) "SAREXT"
//
#include "container.h"
#include "lib.h"
#include "names.h"
#include "shift.h"
#include <R.h>
#include <Rinternals.h>
#include <ta_libc.h>

// clang-format off
SEXP impl_ta_SAREXT(
  SEXP inHigh,
  SEXP inLow,
  SEXP optStartValue,
  SEXP optOffsetOnReverse,
  SEXP optAccelerationInitLong,
  SEXP optAccelerationLong,
  SEXP optAccelerationMaxLong,
  SEXP optAccelerationInitShort,
  SEXP optAccelerationShort,
  SEXP optAccelerationMaxShort) {
  // clang-format on
  int protect_count = 0;

  const double *restrict high_ptr = REAL(inHigh);
  const double *restrict low_ptr = REAL(inLow);
  const int n = LENGTH(inHigh);

  const double start_value = REAL(optStartValue)[0];
  const double offset_on_reverse = REAL(optOffsetOnReverse)[0];
  const double acceleration_init_long = REAL(optAccelerationInitLong)[0];
  const double acceleration_long = REAL(optAccelerationLong)[0];
  const double acceleration_max_long = REAL(optAccelerationMaxLong)[0];
  const double acceleration_init_short = REAL(optAccelerationInitShort)[0];
  const double acceleration_short = REAL(optAccelerationShort)[0];
  const double acceleration_max_short = REAL(optAccelerationMaxShort)[0];

  SEXP output;
  double *output_ptr;

  // clang-format off
  const int lookback = TA_SAREXT_Lookback(
    start_value,
    offset_on_reverse,
    acceleration_init_long,
    acceleration_long,
    acceleration_max_long,
    acceleration_init_short,
    acceleration_short,
    acceleration_max_short
  );
  // clang-format on

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
    TA_RetCode return_code = TA_SAREXT(
      0,
      n - 1,
      high_ptr,
      low_ptr,
      start_value,
      offset_on_reverse,
      acceleration_init_long,
      acceleration_long,
      acceleration_max_long,
      acceleration_init_short,
      acceleration_short,
      acceleration_max_short,
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
