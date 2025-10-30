#ifndef _CONTAINER_H
#define _CONTAINER_H
// conainter.h
//
// This header file abstracts a big part of the
// of common function calls:
//
// output_container:
//    A generic function for constructing a double or integer matrix
//    which is determined by out_ptr.
//
//    The function returns an integer which serves as flag for the remaining
//    function which if 1 passes the call to TA-Lib, or exits the function
//    otherwise.
//
//    See ta_AD.c for an example on how to use it
#include "lib.h"
#include "names.h"
#include <R.h>
#include <Rinternals.h>
#include <ta_libc.h>

// double
// clang-format off
static inline int double_container(
  int n, 
  int lookback, 
  int ncol,
  SEXP *out_sexp, 
  double **out_ptr,
  int *protect_count) {
  // clang-format on

  // construct matrix and iterate
  // protect counter
  // clang-format off
    SEXP matrix = PROTECT(
      allocMatrix(REALSXP, n, ncol)
    ); 
    
    (*protect_count)++;
  // clang-format on

  // construct pointers to
  // matrix
  *out_sexp = matrix;
  *out_ptr = REAL(matrix);

  // if N is less than lookback
  // the function returns <NA> with the
  // same length
  if (n < lookback) {

    Rf_warning(
      "Input length (%d) is smaller than required lookback (%d).",
      n,
      lookback);

    const int total = n * ncol;
    for (int i = 0; i < total; ++i) {
      (*out_ptr)[i] = NA_REAL;
    }

    return 0;
  }

  return 1;
}

// integer
// clang-format off
static inline int integer_container(
  int n, 
  int lookback, 
  int ncol,
  SEXP *out_sexp, 
  int **out_ptr,
  int *protect_count) {
  // clang-format on

  // construct matrix and iterate
  // protect counter
  // clang-format off
    SEXP matrix = PROTECT(
      allocMatrix(INTSXP, n, ncol)
    ); 
    
    (*protect_count)++;
  // clang-format on

  // construct pointers to
  // matrix
  *out_sexp = matrix;
  *out_ptr = INTEGER(matrix);

  // if N is less than lookback
  // the function returns <NA> with the
  // same length
  if (n < lookback) {

    Rf_warning(
      "Input length (%d) is smaller than required lookback (%d).",
      n,
      lookback);

    const int total = n * ncol;
    for (int i = 0; i < total; ++i)
      (*out_ptr)[i] = NA_INTEGER;
    return 0;
  }

  return 1;
}

// check output
//
//
static inline void check_output(TA_RetCode x, int protect_count) {

  if (x != TA_SUCCESS) {
    Rf_unprotect(protect_count);
    Rf_error("Failed with code %d", x);
  }
}

// clang-format off
#define output_container(n, lookback, ncol, out_sexp, out_ptr, protect_count) \
  _Generic(*(out_ptr), double *: double_container, int *: integer_container)  \
  ((n), (lookback), (ncol), (out_sexp), (out_ptr), (protect_count))
// clang-format on

#endif /* _CONTAINER_H */
