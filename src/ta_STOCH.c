// Interface to ta_STOCH.c (Slow Stochastic)
//
// Parameters
//   high            – numeric vector of 'High' prices
//   low             – numeric vector of 'Low' prices
//   close           – numeric vector of 'Close' prices
//   fastk_period    – integer lookback for %K
//   slowk_period    – integer smoothing for %K
//   slowk_matype    – integer MA type for %K
//   slowd_period    – integer lookback for %D
//   slowd_matype    – integer MA type for %D
//
// Description
//   Returns an N×2 matrix with columns 'slowk' and 'slowd', NA-filled
//   for initial lookback.
#include "MAType.h"
#include "lib.h"
#include "names.h"
#include <ta_libc.h>
#include <R.h>
#include <Rinternals.h>

// clang-format off
SEXP impl_ta_STOCH(
    SEXP high,
    SEXP low, 
    SEXP close, 
    SEXP fastk_period,
    SEXP slowk_period, 
    SEXP slowk_matype, 
    SEXP slowd_period,
    SEXP slowd_matype) {
  // clang-format on

  int protect_count = 0;
  // Determine MAs
  TA_MAType k_MA = as_MAType(slowk_matype);
  TA_MAType d_MA = as_MAType(slowd_matype);

  // periods
  const int fastk = INTEGER(fastk_period)[0];
  const int slowk = INTEGER(slowk_period)[0];
  const int slowd = INTEGER(slowd_period)[0];

  // data
  const double *restrict high_ptr = REAL(high);
  const double *restrict low_ptr = REAL(low);
  const double *restrict close_ptr = REAL(close);

  int n = length(high);

  // clang-format off
  SEXP result = PROTECT(
    allocMatrix(REALSXP, n, 2)
  ); protect_count++;
  double *__restrict__ mat = REAL(result);
  double *__restrict__ outSlowK = mat;
  double *__restrict__ outSlowD = mat + n;
  // clang-format on

  // clang-format off
  const int minimum_lookback = TA_STOCH_Lookback(
    fastk, 
    slowk, 
    k_MA, 
    slowd, 
    d_MA
    );
  // clang-format on
  if (n < minimum_lookback) {
    Rf_warning("Input length (%d) is smaller than required lookback (%d).", n,
               minimum_lookback);

    for (size_t i = 0; i < n; ++i) {
      outSlowK[i] = outSlowK[i] = NA_REAL;
    }

  } else {
    int outBeg = 0, outNB = 0;
    // clang-format off
    TA_RetCode return_code = TA_STOCH(
        0,
        n - 1,
        high_ptr,
        low_ptr,
        close_ptr,                             
        fastk,
        slowk,
        k_MA,
        slowd,
        d_MA,
        &outBeg,
        &outNB, 
        outSlowK + outBeg,
        outSlowD + outBeg
    );
    // clang-format on

    if (return_code != TA_SUCCESS) {
      UNPROTECT(protect_count);
      error("TA_STOCH failed: return code %d", return_code);
    }

    // shift array and pad
    // with leading NAs
    shift_array(outSlowK, n, outBeg);
    shift_array(outSlowD, n, outBeg);
  }

  // set column names
  // clang-format off
  set_colnames(
    result, 
    "slowk", 
    "slowd"
  );
  // clang-format on

  UNPROTECT(protect_count);
  return result;
}