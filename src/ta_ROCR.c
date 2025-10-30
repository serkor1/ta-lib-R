// interface to ta_ROCR.c
//
// Parameters
//   inReal        : numeric vector (length n)
//   optTimePeriod : integer time period
//
// Returns
//   numeric vector (n x 1) "ROCR"
//
#include "container.h"
#include "lib.h"
#include "names.h"
#include "shift.h"
#include <R.h>
#include <Rinternals.h>
#include <ta_libc.h>

// clang-format off
SEXP impl_ta_ROCR(
  SEXP inReal,
  SEXP optTimePeriod) {
  // clang-format on
  int protect_count = 0;

  const double *restrict in_real = REAL(inReal);
  const int n = LENGTH(inReal);

  const int time_period = INTEGER(optTimePeriod)[0];

  SEXP output;
  double *output_ptr;

  const int lookback = TA_ROCR_Lookback(time_period);

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
    int start_idx = 0, end_idx = 0;

    // clang-format off
    TA_RetCode return_code = TA_ROCR(
       0,
       n - 1,
       in_real,
       time_period,
       &start_idx,
       &end_idx,
       output_ptr
    );
    // clang-format on

    check_output(return_code, protect_count);
    shift_array(output_ptr, n, start_idx);
  }

  set_colnames(output, "ROCR");

  UNPROTECT(protect_count);
  return output;
}
