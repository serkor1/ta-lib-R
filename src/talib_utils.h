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

// NA-bridge helpers
//
// Description
//    Machinery for the `na.bridge` path: drop rows where any input is
//    NA/NaN, compute the indicator on the dense (gap-free) series, then
//    scatter the results back to their original row positions. Kept in
//    one place so all 128 generated wrappers share a single, memory-lean
//    implementation.

/* Allocate + fill a "present-row" bitset and return the number of present
   rows (m). Row i is present iff every input column is non-NA/non-NaN at i.
   *mask_out receives the bitset (R_alloc'd: freed when the .Call returns). */
R_xlen_t ta_na_prepare(
  const double *const *ins, int k, R_xlen_t n, unsigned char **mask_out);

/* Allocate an m*k dense scratch block (R_alloc'd). */
double *ta_dense_alloc(R_xlen_t m, int k);

/* Gather the present rows of one input into a dense column; returns dst. */
double *ta_compact(
  double *dst, const double *src, const unsigned char *mask, R_xlen_t n);

// scatter array start
void scatter_double_array(
  double *col,
  R_xlen_t n,
  const unsigned char *mask,
  R_xlen_t m,
  int begIdx,
  int nbElement);
void scatter_integer_array(
  int *col,
  R_xlen_t n,
  const unsigned char *mask,
  R_xlen_t m,
  int begIdx,
  int nbElement);

// clang-format off
// Generic scatter_array (see shift_array above)
#define scatter_array(col, n, mask, m, begIdx, nbElement)                    \
   _Generic((col), double*: scatter_double_array, int*: scatter_integer_array) \
   ((col), (n), (mask), (m), (begIdx), (nbElement))
// clang-format on
// scatter array end

/* rc != TA_SUCCESS -> Rf_error("<fn>: <message> (<enum>)"). */
void ta_check(TA_RetCode rc, const char *fn);

void set_colnames(SEXP x, const char *const *names, int k);

#endif /* TALIB_UTILS_H */
