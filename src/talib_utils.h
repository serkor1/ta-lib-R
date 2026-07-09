#ifndef TALIB_UTILS_H
#define TALIB_UTILS_H

#include "ta_libc.h" /* TA_RetCode, TA_SetRetCodeInfo, TA_MAType, ... */
#include <Rinternals.h> /* SEXP API; avoids R.h -> R_ext/Random.h Int32 clash with TA-Lib */

/* Coerce s to a REAL buffer, PROTECT it (++*nprot), verify length == n. */
const double *ta_real(SEXP s, R_xlen_t n, int *nprot, const char *name);

/* In place: move the nb computed values at col[0..nb) to col[begIdx..begIdx+nb)
   and NA-fill the lookback region (and any tail). */
void ta_pad_real(double *col, R_xlen_t n, int begIdx, int nbElement);
void ta_pad_int(int *col, R_xlen_t n, int begIdx, int nbElement);

/* rc != TA_SUCCESS -> Rf_error("<fn>: <message> (<enum>)"). */
void ta_check(TA_RetCode rc, const char *fn);

/* Attach dimnames = list(NULL, character(names)) to an n x k matrix. */
void ta_set_colnames(SEXP mat, const char *const *names, int k);

#endif /* TALIB_UTILS_H */
