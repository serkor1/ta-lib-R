// interface to ta_PPO.c
//
// Parameters
//   inReal        : numeric vector (length n)
//   optFastPeriod : integer fast period
//   optSlowPeriod : integer slow period
//   optMAType     : integer MA type
//
// Returns
//   numeric vector (n x 1) "PPO"
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
SEXP impl_ta_PPO(
  SEXP inReal,
  SEXP optFastPeriod,
  SEXP optSlowPeriod,
  SEXP optMAType) {
  // clang-format on
  int protect_count = 0;

  const double *restrict in_real = REAL(inReal);
  const int n = LENGTH(inReal);

  const int fast_period = INTEGER(optFastPeriod)[0];
  const int slow_period = INTEGER(optSlowPeriod)[0];
  const TA_MAType ma_type = as_MAType(optMAType);

  SEXP output;
  double *output_ptr;

  const int lookback = TA_PPO_Lookback(fast_period, slow_period, ma_type);

  const int proceed =
    output_container(n, lookback, 1, &output, &output_ptr, &protect_count);

  if (proceed) {
    int start_idx = 0, end_idx = 0;

    // clang-format off
    TA_RetCode return_code = TA_PPO(
       0,
       n - 1,
       in_real,
       fast_period,
       slow_period,
       ma_type,
       &start_idx,
       &end_idx,
       output_ptr
    );
    // clang-format on

    check_output(return_code, protect_count);
    shift_array(output_ptr, n, start_idx);
  }

  set_colnames(output, "PPO");

  UNPROTECT(protect_count);
  return output;
}
