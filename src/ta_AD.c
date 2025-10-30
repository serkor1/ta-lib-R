// Interface to ta_AD (Chaikin A/D Line)
//
// Parameters
//   inHigh   : numeric vector of highs (length n)
//   inLow    : numeric vector of lows  (length n)
//   inClose  : numeric vector of closes (length n)
//   inVolume : numeric vector of volumes (length n)
//
#include "container.h"
#include "lib.h"
#include "names.h"
#include "shift.h"
#include <R.h>
#include <Rinternals.h>
#include <ta_libc.h>

// clang-format off
SEXP impl_ta_AD(
  SEXP inHigh, 
  SEXP inLow, 
  SEXP inClose, 
  SEXP inVolume) {
  // clang-format on
  int protect_count = 0;

  // generic input
  const double *restrict high = REAL(inHigh);
  const double *restrict low = REAL(inLow);
  const double *restrict close = REAL(inClose);
  const double *restrict volume = REAL(inVolume);
  const int n = LENGTH(inHigh);

  // construct container
  SEXP output;
  double *output_ptr;

  // initialize
  const int lookback = TA_AD_Lookback();
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
    TA_RetCode return_code = TA_AD(
      0, 
      n - 1, 
      high, 
      low, 
      close, 
      volume, 
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
  set_colnames(output, "AD");

  UNPROTECT(protect_count);
  return output;
}
