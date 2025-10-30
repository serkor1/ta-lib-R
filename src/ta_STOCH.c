// interface to ta_STOCH.c
//
// Parameters
//   inHigh        : numeric vector of highs (length n)
//   inLow         : numeric vector of lows  (length n)
//   inClose       : numeric vector of closes (length n)
//   optFastK      : integer Fast-K period
//   optSlowK      : integer Slow-K period
//   optSlowK_MA   : integer MA type for Slow-K (see MAType.h)
//   optSlowD      : integer Slow-D period
//   optSlowD_MA   : integer MA type for Slow-D
//
// Returns
//   matrix n x 2 with columns:
//     "slowk"
//     "slowd"
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
SEXP impl_ta_STOCH(
  SEXP inHigh,
  SEXP inLow,
  SEXP inClose,
  SEXP optFastK,
  SEXP optSlowK,
  SEXP optSlowK_MA,
  SEXP optSlowD,
  SEXP optSlowD_MA){
  // clang-format on
  int protect_count = 0;

  const double *restrict high_ptr = REAL(inHigh);
  const double *restrict low_ptr = REAL(inLow);
  const double *restrict close_ptr = REAL(inClose);
  const int n = LENGTH(inHigh);

  const int fast_k = INTEGER(optFastK)[0];
  const int slow_k = INTEGER(optSlowK)[0];
  const TA_MAType slow_k_ma = as_MAType(optSlowK_MA);
  const int slow_d = INTEGER(optSlowD)[0];
  const TA_MAType slow_d_ma = as_MAType(optSlowD_MA);

  SEXP output;
  double *output_ptr;

  // clang-format off
  const int lookback = TA_STOCH_Lookback(
    fast_k, 
    slow_k, 
    slow_k_ma, 
    slow_d, 
    slow_d_ma
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

    double *output_slowk = output_ptr;
    double *output_slowd = output_ptr + n;

    // clang-format off
      TA_RetCode return_code = TA_STOCH(
        /*startIdx     */ 0,
        /*endIdx       */ n - 1,
        /*inHigh       */ high_ptr,
        /*inLow        */ low_ptr,
        /*inClose      */ close_ptr,
        /*optInFastK   */ fast_k,
        /*optInSlowK   */ slow_k,
        /*optInSlowKMA */ slow_k_ma,
        /*optInSlowD   */ slow_d,
        /*optInSlowDMA */ slow_d_ma,
        /*outBegIdx    */ &start_idx,
        /*outNbElement */ &end_idx,
        /*outSlowK     */ output_slowk,
        /*outSlowD     */ output_slowd
      );
    // clang-format on

    check_output(return_code, protect_count);

    shift_array(output_slowk, n, start_idx);
    shift_array(output_slowd, n, start_idx);
  }

  set_colnames(output, "slowk", "slowd");

  UNPROTECT(protect_count);
  return output;
}
