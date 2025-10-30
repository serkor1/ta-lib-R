// interface to ta_STOCHF.c
//
// Parameters
//   inHigh        : numeric vector of highs (length n)
//   inLow         : numeric vector of lows  (length n)
//   inClose       : numeric vector of closes (length n)
//   optFastK      : integer Fast-K period
//   optFastD      : integer Fast-D period
//   optFastD_MA   : integer MA type for Fast-D
//
// Returns
//   matrix n x 2 with columns:
//     "fastk"
//     "fastd"
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
SEXP impl_ta_STOCHF(
  SEXP inHigh,
  SEXP inLow,
  SEXP inClose,
  SEXP optFastK,
  SEXP optFastD,
  SEXP optFastD_MA) {
  // clang-format on
  int protect_count = 0;

  const double *restrict high_ptr = REAL(inHigh);
  const double *restrict low_ptr = REAL(inLow);
  const double *restrict close_ptr = REAL(inClose);
  const int n = LENGTH(inHigh);

  const int fast_k = INTEGER(optFastK)[0];
  const int fast_d = INTEGER(optFastD)[0];
  const TA_MAType fast_d_ma = as_MAType(optFastD_MA);

  SEXP output;
  double *output_ptr;

  // clang-format off
  const int lookback = TA_STOCHF_Lookback(
    fast_k, 
    fast_d, 
    fast_d_ma
  );
  // clang-format on

  // clang-format off
  const int proceed = output_container(
    n, 
    lookback, 
    2, 
    &output, 
    &output_ptr, 
    &protect_count
  );
  // clang-format on

  if (proceed) {
    int start_idx = 0, end_idx = 0;

    double *output_fastk = output_ptr;
    double *output_fastd = output_ptr + n;

    // clang-format off
    TA_RetCode return_code = TA_STOCHF(
      /*startIdx     */ 0,
      /*endIdx       */ n - 1,
      /*inHigh       */ high_ptr,
      /*inLow        */ low_ptr,
      /*inClose      */ close_ptr,
      /*optInFastK   */ fast_k,
      /*optInFastD   */ fast_d,
      /*optInFastDMA */ fast_d_ma,
      /*outBegIdx    */ &start_idx,
      /*outNbElement */ &end_idx,
      /*outFastK     */ output_fastk,
      /*outFastD     */ output_fastd
    );
    // clang-format on

    check_output(return_code, protect_count);

    shift_array(output_fastk, n, start_idx);
    shift_array(output_fastd, n, start_idx);
  }

  set_colnames(output, "fastk", "fastd");

  UNPROTECT(protect_count);
  return output;
}
