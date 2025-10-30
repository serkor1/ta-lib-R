// interface to ta_BOP.c
//
// Parameters
//   inOpen  : numeric vector of opens (length n)
//   inHigh  : numeric vector of highs (length n)
//   inLow   : numeric vector of lows  (length n)
//   inClose : numeric vector of closes (length n)
//
// Returns
//   numeric vector (n x 1) "BOP"
//
#include "container.h"
#include "lib.h"
#include "names.h"
#include "shift.h"
#include <R.h>
#include <Rinternals.h>
#include <ta_libc.h>

// clang-format off
SEXP impl_ta_BOP(
  SEXP inOpen,
  SEXP inHigh,
  SEXP inLow,
  SEXP inClose) {
  // clang-format on
  int protect_count = 0;

  const double *restrict open_ptr = REAL(inOpen);
  const double *restrict high_ptr = REAL(inHigh);
  const double *restrict low_ptr = REAL(inLow);
  const double *restrict close_ptr = REAL(inClose);
  const int n = LENGTH(inOpen);

  SEXP output;
  double *output_ptr;

  const int lookback = TA_BOP_Lookback();

  const int proceed =
    output_container(n, lookback, 1, &output, &output_ptr, &protect_count);

  if (proceed) {
    int start_idx = 0, end_idx = 0;

    // clang-format off
    TA_RetCode return_code = TA_BOP(
       0,
       n - 1,
       open_ptr,
       high_ptr,
       low_ptr,
       close_ptr,
       &start_idx,
       &end_idx,
       output_ptr
    );
    // clang-format on

    check_output(return_code, protect_count);
    shift_array(output_ptr, n, start_idx);
  }

  set_colnames(output, "BOP");

  UNPROTECT(protect_count);
  return output;
}
