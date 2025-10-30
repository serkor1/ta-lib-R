// Interface to TA_OBV (On-Balance Volume)
//
// Parameters
//   real   : numeric vector of real prices
//   volume : numeric vector of volumes (same length as real)
//
#include "R_ext/Error.h"
#include "Rinternals.h"
#include "container.h"
#include "lib.h"
#include "names.h"
#include "shift.h"
#include <ta_libc.h>

// clang-format off
SEXP impl_ta_OBV(
  SEXP real,
  SEXP volume) {
  // clang-format on
  int protect_count = 0;

  // generic input
  const double *restrict real_ptr = REAL(real);
  const double *restrict volume_ptr = REAL(volume);
  const int n = LENGTH(real);

  // construct container
  SEXP output;
  double *output_ptr;

  // initialize
  const int lookback = TA_OBV_Lookback();
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
    TA_RetCode return_code = TA_OBV(
      0,
      n - 1,
      real_ptr,
      volume_ptr,
      &start_idx,
      &end_idx,
      output_ptr
    );
    // clang-format on

    // check output and return
    // error code if not TA_SUCCESS
    // clang-format off
    check_output(
      return_code, 
      protect_count
    );
    // clang-format on

    // clang-format off
    shift_array(
      output_ptr, 
      n, 
      start_idx
    );
    // clang-format on
  }

  // set column names
  set_colnames(output, "OBV");

  UNPROTECT(protect_count);
  return output;
}
