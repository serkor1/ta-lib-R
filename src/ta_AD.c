// Interface to ta_AD (Chaikin A/D Line)
//
// Parameters
//   inHigh   : numeric vector of highs (length n)
//   inLow    : numeric vector of lows  (length n)
//   inClose  : numeric vector of closes (length n)
//   inVolume : numeric vector of volumes (length n)
//
// Description
//   Computes the cumulative Chaikin A/D Line.
//   Returns a numeric vector of length n (unnamed).
//
// Notes
//   - TA_AD has zero lookback and writes a contiguous output segment,
//     reported via outBegIdx/outNbElement. We write from index 0 and
//     then pad leading NAs by a single in-place shift for O(n) work.
//   - See TA-Lib API calling pattern (startIdx/endIdx/outBegIdx/outNbElement).
//     This wrapper follows that pattern and then normalizes to full length.
//     (Docs: C/C++ API; Function list & AD)
//     Reference: https://ta-lib.org/api/ , https://ta-lib.org/functions/ .
//     (Also exposed in TA-Lib “volume” group.)
#include "lib.h"
#include "names.h"
#include "shift.h"
#include <R.h>
#include <Rinternals.h>
#include <ta_libc.h>

SEXP impl_ta_AD(SEXP inHigh, SEXP inLow, SEXP inClose, SEXP inVolume) {
  const int n = LENGTH(inHigh);

  // 0) Fast length sanity: all inputs must match; empty -> empty.
  if (n == 0)
    return allocVector(REALSXP, 0);
  if (LENGTH(inLow) != n || LENGTH(inClose) != n || LENGTH(inVolume) != n) {
    Rf_error("AD: input lengths must match.");
  }

  // 1) Alias input buffers with restrict for better alias analysis.
  const double *restrict high = REAL(inHigh);
  const double *restrict low = REAL(inLow);
  const double *restrict close = REAL(inClose);
  const double *restrict volume = REAL(inVolume);

  // 2) Allocate full-length output; unnamed vector by contract.
  SEXP result = PROTECT(allocMatrix(REALSXP, n, 1));
  double *restrict out = REAL(result);

  // 3) Call TA-Lib over the whole range; write from index 0.
  int outBeg = 0, outNb = 0;
  // clang-format off
  const TA_RetCode ret = TA_AD(
    0,
    n - 1,
    high,
    low, 
    close, 
    volume, 
    &outBeg, 
    &outNb,
    out
);
  // clang-format on

  if (ret != TA_SUCCESS) {
    UNPROTECT(1);
    Rf_error("TA_AD failed (code %d).", (int)ret);
  }

  // 4) Normalize to input length by padding leading NAs.
  //    This shifts [0..outNb-1] to start at index outBeg.
  shift_array(out, n, outBeg);

  set_colnames(result, "AD");

  UNPROTECT(1);
  return result;
}
