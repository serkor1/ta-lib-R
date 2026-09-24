#include "utils.h"
#include <R_ext/Arith.h> // ISNAN, NA_REAL, NA_INTEGER
#include <R_ext/RS.h>    // R_alloc
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

// NA-bridge helpers for the `na.bridge` path now live in NA-handling.{h,c}.

void ta_check(TA_RetCode rc, const char *fn) {
  if (rc == TA_SUCCESS)
    return;
  TA_RetCodeInfo info;
  TA_SetRetCodeInfo(rc, &info);
  Rf_error("%s: %s (%s)", fn, info.infoStr, info.enumStr);
}
