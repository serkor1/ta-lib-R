// interface to ta_BBANDS.c
//
// Parameters
//   inReal        : numeric vector (length n)
//   optTimePeriod : integer time period
//   optNbDevUp    : numeric number of deviations above
//   optNbDevDn    : numeric number of deviations below
//   optMAType     : integer MA type (see MAType.h)
//
// Returns
//   numeric matrix (n x 3) with columns
//     "upper"
//     "middle"
//     "lower"
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
SEXP impl_ta_BBANDS(
  SEXP inReal,
  SEXP optTimePeriod,
  SEXP optNbDevUp,
  SEXP optNbDevDn,
  SEXP optMAType) {
  // clang-format on
  int protect_count = 0;

  const double *restrict in_real = REAL(inReal);
  const int n = LENGTH(inReal);

  const int time_period = INTEGER(optTimePeriod)[0];
  const double nb_dev_up = REAL(optNbDevUp)[0];
  const double nb_dev_dn = REAL(optNbDevDn)[0];
  const TA_MAType moving_average = as_MAType(optMAType);

  SEXP output;
  double *output_ptr;

  // clang-format off
  const int lookback = TA_BBANDS_Lookback(
    time_period,
    nb_dev_up,
    nb_dev_dn,
    moving_average
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
    int start_idx = 0;
    int number_of_elements = 0;

    double *restrict out_upper = output_ptr;
    double *restrict out_middle = output_ptr + n;
    double *restrict out_lower = output_ptr + (2 * n);

    // clang-format off
    TA_RetCode return_code = TA_BBANDS(
      0,
      n - 1,
      in_real,
      time_period,
      nb_dev_up,
      nb_dev_dn,
      moving_average,
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
