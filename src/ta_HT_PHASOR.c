// Interface to ta_HT_PHASOR (Hilbert Transform - Phasor Components)
//
// Parameters
//   inReal : numeric vector of source prices.
//
// Description
//   Returns an n × 2 matrix with columns:
//     "inphase"     : in-phase component,
//     "quadrature"  : quadrature component.
//   Leading rows are NA-padded via shift_array; column names are lower-case.
#include "lib.h"
#include "shift.h"
#include "ta_func.h"
#include <R.h>
#include <Rinternals.h>
#include <ta_libc.h>

SEXP impl_ta_HT_PHASOR(SEXP inReal) {
  const int n = LENGTH(inReal);
  double *restrict src = REAL(inReal);

  // Allocate a 2-column matrix laid out column-major: [inphase | quadrature]
  SEXP result = PROTECT(allocMatrix(REALSXP, n, 2));
  double *restrict inphase = REAL(result);   // col 0
  double *restrict quadrature = inphase + n; // col 1

  // check wether the minimum
  // required matches that of
  // the input
  const int minimum_lookback = TA_HT_PHASOR_Lookback();
  if (n < minimum_lookback) {
    Rf_warning("Input length (%d) is smaller than required lookback (%d).", n,
               minimum_lookback);

    for (size_t i = 0; i < n; ++i) {
      inphase[i] = quadrature[i] = NA_REAL;
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
  TA_RetCode ret = TA_HT_PHASOR(
      0,
      n > 0 ? n - 1 : 0,
      src,
      &outBeg,
      &outNb,
      inphase + outBeg,
      quadrature + outBeg);
  // clang-format on

  // NA-pad both columns.
  shift_array(inphase, n, outBeg);
  shift_array(quadrature, n, outBeg);

  // Set column names (lower-case).
  SEXP dims = PROTECT(allocVector(VECSXP, 2));
  SEXP cn = PROTECT(allocVector(STRSXP, 2));
  SET_STRING_ELT(cn, 0, mkChar("inphase"));
  SET_STRING_ELT(cn, 1, mkChar("quadrature"));
  SET_VECTOR_ELT(dims, 0, R_NilValue);
  SET_VECTOR_ELT(dims, 1, cn);
  setAttrib(result, R_DimNamesSymbol, dims);

  UNPROTECT(3);
  return result;
}
