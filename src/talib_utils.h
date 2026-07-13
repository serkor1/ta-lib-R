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

// shift array start
void shift_double_array(double *col, R_xlen_t n, int begIdx, int nbElement);
void shift_integer_array(int *col, R_xlen_t n, int begIdx, int nbElement);

// clang-format off
// Generic shift_array
//
// Description
//    Works similar to S3 functions in R
//    _Generic( (x), type: dispatch ) ( signature )
#define shift_array(col, n, begIdx, nbElement)                            \
   _Generic((col), double*: shift_double_array, int*: shift_integer_array) \
   ((col), (n), (begIdx), (nbElement))
// clang-format on
// shift array end

/* NA-bridge helpers for the `na.bridge` path live in NA-handling.{h,c}. */

/* rc != TA_SUCCESS -> Rf_error("<fn>: <message> (<enum>)"). */
void ta_check(TA_RetCode rc, const char *fn);

void set_colnames(SEXP x, const char *const *names, int k);
void rownames_data_frame(SEXP x, SEXP rownames);
void rownames_matrix(SEXP x, SEXP rownames, SEXP colnames);

#endif /* TALIB_UTILS_H */
