#include "talib_utils.h"
#include <limits.h>
#include <string.h>

const double *ta_real(SEXP s, R_xlen_t n, int *nprot, const char *name) {
  if (XLENGTH(s) != n)
    Rf_error(
      "input '%s' has length %lld, expected %lld",
      name,
      (long long)XLENGTH(s),
      (long long)n);
  SEXP c = PROTECT(Rf_coerceVector(s, REALSXP));
  (*nprot)++;
  return REAL(c);
}

void ta_pad_real(double *col, R_xlen_t n, int begIdx, int nbElement) {
  if (begIdx < 0)
    begIdx = 0;
  if (begIdx > n)
    begIdx = (int)n;
  if (nbElement < 0)
    nbElement = 0;
  if ((R_xlen_t)begIdx + nbElement > n)
    nbElement = (int)(n - begIdx);
  memmove(col + begIdx, col, (size_t)nbElement * sizeof(double));
  for (R_xlen_t i = 0; i < begIdx; i++)
    col[i] = NA_REAL;
  for (R_xlen_t i = (R_xlen_t)begIdx + nbElement; i < n; i++)
    col[i] = NA_REAL;
}

void ta_pad_int(int *col, R_xlen_t n, int begIdx, int nbElement) {
  if (begIdx < 0)
    begIdx = 0;
  if (begIdx > n)
    begIdx = (int)n;
  if (nbElement < 0)
    nbElement = 0;
  if ((R_xlen_t)begIdx + nbElement > n)
    nbElement = (int)(n - begIdx);
  memmove(col + begIdx, col, (size_t)nbElement * sizeof(int));
  for (R_xlen_t i = 0; i < begIdx; i++)
    col[i] = NA_INTEGER;
  for (R_xlen_t i = (R_xlen_t)begIdx + nbElement; i < n; i++)
    col[i] = NA_INTEGER;
}

void ta_check(TA_RetCode rc, const char *fn) {
  if (rc == TA_SUCCESS)
    return;
  TA_RetCodeInfo info;
  TA_SetRetCodeInfo(rc, &info);
  Rf_error("%s: %s (%s)", fn, info.infoStr, info.enumStr);
}

void ta_set_colnames(SEXP mat, const char *const *names, int k) {
  SEXP dn = PROTECT(Rf_allocVector(VECSXP, 2));
  SEXP cn = PROTECT(Rf_allocVector(STRSXP, k));
  for (int j = 0; j < k; j++)
    SET_STRING_ELT(cn, j, Rf_mkChar(names[j]));
  SET_VECTOR_ELT(dn, 0, R_NilValue);
  SET_VECTOR_ELT(dn, 1, cn);
  Rf_setAttrib(mat, R_DimNamesSymbol, dn);
  UNPROTECT(2);
}
