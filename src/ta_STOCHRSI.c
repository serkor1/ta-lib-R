// Interface to ta_STOCHRSI.c (Stochastic RSI)
//
// Parameters
//   real            – numeric vector of RSI values
//   timeperiod      – integer lookback for RSI calculation
//   fastk_period    – integer period for %K of StochRSI
//   fastd_period    – integer period for %D smoothing
//   fastd_matype    – integer MA type for %D smoothing
//
// Description
//   Returns an N×2 matrix with columns 'fastk' and 'fastd', both
//   of the same length as input, with NA for initial lookback.
#include "MAType.h"
#include "lib.h"
#include "names.h"
#include <R.h>
#include <Rinternals.h>
#include <ta_libc.h>

// clang-format off
SEXP impl_ta_STOCHRSI(
  SEXP real, 
  SEXP timeperiod, 
  SEXP fastk_period,
  SEXP fastd_period, 
  SEXP fastd_matype) {
  // clang-format on

  int protection_count = 0;

  // determine MAs
  TA_MAType MAType = as_MAType(fastd_matype);

  // periods
  const int fastk = INTEGER(fastk_period)[0];
  const int fastd = INTEGER(fastd_period)[0];
  const int lag = INTEGER(timeperiod)[0];

  // data
  const double *restrict series_ptr = REAL(real);

  // length
  int n = length(real);
  int outBeg = 0, outNB = 0;

  // output matrix
  // clang-format off
  SEXP output = PROTECT(
    allocMatrix(REALSXP,n,2)
  ); protection_count++;
  double *__restrict__ output_ptr = REAL(output);
  double *__restrict__ fastk_ptr = output_ptr;
  double *__restrict__ fastd_ptr = output_ptr + n;
  // clang-format on

  // verify lookback
  // clang-format off
  const int minimum_lookback = TA_STOCHRSI_Lookback(
    lag, 
    fastk,
    fastd,
    MAType
  );
  // clang-format on

  if (n < minimum_lookback) {

    Rf_warning("Input length (%d) is smaller than required lookback (%d).", n,
               minimum_lookback);

    for (size_t i = 0; i < n; ++i) {
      fastk_ptr[i] = fastd_ptr[i] = NA_REAL;
    }

  } else {

    // clang-format off
    TA_RetCode return_code = TA_STOCHRSI(
      0, 
      n - 1, 
      series_ptr,
      lag, 
      fastk, 
      fastd, 
      MAType, 
      &outBeg,
      &outNB, 
      fastk_ptr + outBeg, 
      fastd_ptr + outBeg
    );
    // clang-format on

    if (return_code != TA_SUCCESS) {
      UNPROTECT(protection_count);
      error("TA_STOCHRSI failed: return code %d", return_code);
    }

    // shift values
    shift_array(fastk_ptr, n, outBeg);
    shift_array(fastd_ptr, n, outBeg);
  }

  // set column names
  // clang-format off
  set_colnames(
    output, 
    "fastk", 
    "fastd"
  );
  // clang-format on

  UNPROTECT(protection_count);
  return output;
}