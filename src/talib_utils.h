// TA-Lib-Utils.h
//
// Description
//    All functions are implemented in TA-Lib-Utils.c, and includes
//    helper functions that ease the process in porting indicators
//    to R.
//
#ifndef TALIB_UTILS_H
#define TALIB_UTILS_H

#include "ta_libc.h"
#include <Rinternals.h>

/* Coerce s to a REAL buffer, PROTECT it (++*nprot), verify length == n. */
const double *ta_real(SEXP s, R_xlen_t n, int *nprot, const char *name);

/* NA-bridge helpers for the `na.bridge` path live in NA-handling.{h,c}. */

/* rc != TA_SUCCESS -> Rf_error("<fn>: <message> (<enum>)"). */
void ta_check(TA_RetCode rc, const char *fn);

#endif /* TALIB_UTILS_H */
