// Interface to ta_ADOSC (Chaikin A/D Oscillator)
//
// Parameters
//   inHigh        : numeric vector of highs (length n)
//   inLow         : numeric vector of lows  (length n)
//   inClose       : numeric vector of closes (length n)
//   inVolume      : numeric vector of volumes (length n)
//   optFastPeriod : integer fast EMA period (default 3 in TA-Lib)
//   optSlowPeriod : integer slow EMA period (default 10 in TA-Lib)
//
#include "container.h"
#include "lib.h"
#include "names.h"
#include "shift.h"
#include <R.h>
#include <Rinternals.h>
#include <ta_libc.h>

// clang-format off
SEXP impl_ta_ADOSC(
  SEXP inHigh, 
  SEXP inLow, 
  SEXP inClose, 
  SEXP inVolume,
  SEXP optFastPeriod, 
  SEXP optSlowPeriod) {
  // clang-format on
  int protect_count = 0;

  // generic input
  const double *restrict high = REAL(inHigh);
  const double *restrict low = REAL(inLow);
  const double *restrict close = REAL(inClose);
  const double *restrict volume = REAL(inVolume);
  const int n = LENGTH(inHigh);

  // specific input
  const int fastP = INTEGER(optFastPeriod)[0];
  const int slowP = INTEGER(optSlowPeriod)[0];

  // construct container
  SEXP output;
  double *output_ptr;

  // initialize
  // clang-format off
  const int lookback = TA_ADOSC_Lookback(
    fastP, 
    slowP
  );

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
    const TA_RetCode return_code = TA_ADOSC(
      0,
      n - 1, 
      high, 
      low, 
      close, 
      volume, 
      fastP, 
      slowP, 
      &start_idx,
      &end_idx,
      output_ptr
    );

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
  set_colnames(output, "ADOSC");

  UNPROTECT(protect_count);
  return output;
}
