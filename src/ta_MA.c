// Interface to ta_MA (Moving Average)
//
// Parameters
//   real   : numeric vector of inputs
//   lag    : integer SEXP for MA period (1 to 100000)
//   matype : integer SEXP for MAType (0=SMA … 8=T3)
//        0: SMA
//        1:
//        2:
//
#include "MAType.h"
#include "R_ext/Error.h"
#include "container.h"
#include "lib.h"
#include "names.h"
#include "shift.h"
#include <Rinternals.h>
#include <ta_libc.h>

// clang-format off
SEXP impl_ta_MA(
  SEXP Real, 
  SEXP period, 
  SEXP matype) {
  // clang-format on
  int protect_count = 0;

  // generic input
  const double *restrict real_ptr = REAL(Real);
  const int n = length(Real);

  // specific input
  const TA_MAType MAType = as_MAType(matype);
  const int lag = INTEGER(period)[0];

  // construct container
  SEXP output;
  double *output_ptr;

  // initialize
  const int lookback = TA_MA_Lookback(lag, MAType);

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
    TA_RetCode return_code = TA_MA(
      0, 
      n - 1, 
      real_ptr, 
      lag, 
      MAType, 
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

  // determine column name
  const char *colname = _MAType_(MAType);
  set_colnames(output, colname);

  UNPROTECT(protect_count);
  return output;
}