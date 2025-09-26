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
// Description
//   ADOSC = EMA_fast(AD) - EMA_slow(AD).
//   Returns a numeric vector of length n (unnamed). Leading NAs equal
//   to TA_ADOSC lookback (EMA of the slower of the two periods) are padded.
//
// Notes
//   - TA-Lib’s ADOSC defaults and definition per docs (volume group).
//     The lookback equals EMA lookback of the slower period.
//     References: TA-Lib API and volume indicator docs.
//     https://ta-lib.org/api/ ,
//     https://ta-lib.github.io/ta-lib-python/func_groups/volume_indicators.html
//   - Implementation writes from index 0 and then performs one in-place
//     shift to insert NA padding at the front.
//
// Micro-optimizations
//   * Restrict-qualified pointers for better alias analysis
//   * Single allocation, single pass over the output
//   * Early empty/length checks avoid TA call on degenerate ranges
#include "lib.h"
#include "shift.h"
#include <R.h>
#include <Rinternals.h>
#include <ta_libc.h>

SEXP impl_ta_ADOSC(SEXP inHigh, SEXP inLow, SEXP inClose, SEXP inVolume,
                   SEXP optFastPeriod, SEXP optSlowPeriod) {
  const int n = LENGTH(inHigh);

  // 0) Length checks; empty → empty.
  if (n == 0)
    return allocVector(REALSXP, 0);
  if (LENGTH(inLow) != n || LENGTH(inClose) != n || LENGTH(inVolume) != n) {
    Rf_error("ADOSC: input lengths must match.");
  }

  // 1) Read optional periods (no bounds check here; TA-Lib validates).
  const int fastP = INTEGER(optFastPeriod)[0];
  const int slowP = INTEGER(optSlowPeriod)[0];

  // 2) Alias inputs with restrict.
  const double *restrict high = REAL(inHigh);
  const double *restrict low = REAL(inLow);
  const double *restrict close = REAL(inClose);
  const double *restrict volume = REAL(inVolume);

  // 3) Allocate full-length output.
  SEXP result = PROTECT(allocVector(REALSXP, n));
  double *restrict out = REAL(result);

  // 4) Call TA-Lib from index 0; write from out[0].
  int outBeg = 0, outNb = 0;
  // clang-format off
  const TA_RetCode ret = TA_ADOSC(
    0,
    n - 1, 
    high, 
    low, 
    close, 
    volume, 
    fastP, 
    slowP, 
    &outBeg,
    &outNb,
    out
);
  // clang-format on

  if (ret != TA_SUCCESS) {
    UNPROTECT(1);
    Rf_error("TA_ADOSC failed (code %d).", (int)ret);
  }

  // 5) Normalize by padding leading NAs equal to outBeg (EMA lookback).
  shift_array(out, n, outBeg);

  UNPROTECT(1);
  return result;
}
