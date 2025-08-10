// Interface to ta_HT_SINE (Hilbert Transform - SineWave)
//
// Parameters
//   inReal : numeric vector of source prices.
//
// Description
//   Returns an n × 2 matrix with columns:
//     "sine"      : sine of dominant cycle phase,
//     "leadsine"  : sine of phase + 45°.
//   Leading rows are NA-padded via shift_array; column names are lower-case.
#include "lib.h"
#include "shift.h"
#include "ta_func.h"
#include <R.h>
#include <Rinternals.h>
#include <ta_libc.h>

SEXP impl_ta_HT_SINE(SEXP inReal) {
  const int n = LENGTH(inReal);
  double *restrict src = REAL(inReal);

  SEXP result = PROTECT(allocMatrix(REALSXP, n, 2));
  double *restrict sine = REAL(result); // col 0
  double *restrict leadSine = sine + n; // col 1

  // check wether the minimum
  // required matches that of
  // the input
  const int minimum_lookback = TA_HT_SINE_Lookback();
  if (n < minimum_lookback) {
    Rf_warning("Input length (%d) is smaller than required lookback (%d).", n,
               minimum_lookback);

    for (size_t i = 0; i < n; ++i) {
      sine[i] = leadSine[i] = NA_REAL;
    }

    SEXP dims = PROTECT(allocVector(VECSXP, 2));
    SEXP cn = PROTECT(allocVector(STRSXP, 2));
    SET_STRING_ELT(cn, 0, mkChar("sine"));
    SET_STRING_ELT(cn, 1, mkChar("leadsine"));
    SET_VECTOR_ELT(dims, 0, R_NilValue);
    SET_VECTOR_ELT(dims, 1, cn);
    setAttrib(result, R_DimNamesSymbol, dims);

    UNPROTECT(3);
    return result;
  }

  int outBeg = 0, outNb = 0;
  // clang-format off
  TA_RetCode ret = TA_HT_SINE(
    0,
    n > 0 ? n - 1 : 0,
    src,
    &outBeg,
    &outNb,
    sine + outBeg,
    leadSine + outBeg);
  // clang-format on

  shift_array(sine, n, outBeg);
  shift_array(leadSine, n, outBeg);

  SEXP dims = PROTECT(allocVector(VECSXP, 2));
  SEXP cn = PROTECT(allocVector(STRSXP, 2));
  SET_STRING_ELT(cn, 0, mkChar("sine"));
  SET_STRING_ELT(cn, 1, mkChar("leadsine"));
  SET_VECTOR_ELT(dims, 0, R_NilValue);
  SET_VECTOR_ELT(dims, 1, cn);
  setAttrib(result, R_DimNamesSymbol, dims);

  UNPROTECT(3);
  return result;
}
