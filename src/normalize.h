// normalize
//
// Parameters
// arr: The array to be normalized. Double or int pointer
// n: The size of the input array. Int.
// factor: The factor to normalize by. Double or int.
// shift: the amount of shifting. Int. Set to 0
// if no shifts
//
// Descriptions
// This function modifies the array in-place by scaling with
// a factor. The shifting parameter sets the starting point
// of the iterator.
// Its necesseary because the ta_CDL*.c programs returns -100, 0, 100
// which is not R agnostic.
//
// Note
// This function adds a 10% overhead on 1e7 arrays (ish). In either case
// it might be a better approach to make the normalization optional.
#ifndef _NORMALIZE_H
#define _NORMALIZE_H

#include <stddef.h>

// normalize double arrays
static inline void
normalize_double(double *arr, int n, double factor, int shift) {
  for (size_t i = (size_t)shift; i < (size_t)n; ++i) {
    arr[i] /= factor;
  }
}

// normalize int arrays
static inline void normalize_int(int *arr, int n, int factor, int shift) {

  for (size_t i = (size_t)shift; i < (size_t)n; ++i) {
    arr[i] /= factor;
  }
}

// clang-format off
#define normalize(arr, n, factor, shift) _Generic((arr), double*: normalize_double, int*: normalize_int)((arr),(n),(factor), (shift))
// clang-format on

// normalize_int_to_real
//
// Parameters
// integer_matrix: INTSXP matrix (candlestick output after shift and reexpand)
// divisor: The factor to divide by (typically 100.0)
// has_scattered_na: Whether NA values exist beyond the lookback
//                   region. Set to 1 when na_ignore reexpansion was
//                   performed, 0 otherwise.
// protection_count: Pointer to the PROTECT counter
//
// Description
// Converts an INTSXP matrix to REALSXP by dividing each element
// by divisor. The leading lookback region is filled with NA_REAL
// directly (no division). When has_scattered_na is 0 (the common
// path), the data region is divided unconditionally with no
// per-element NA check. When has_scattered_na is 1, elements
// equal to NA_INTEGER are mapped to NA_REAL.
//
// Returns a PROTECTed REALSXP matrix with dimnames and
// lookback attribute copied from the input.
static inline SEXP normalize_int_to_real(
  SEXP integer_matrix,
  double divisor,
  int has_scattered_na,
  int *protection_count) {
  const int num_rows = Rf_nrows(integer_matrix);
  const int num_cols = Rf_ncols(integer_matrix);
  const int total_elements = num_rows * num_cols;

  SEXP lookback_sexp = Rf_getAttrib(integer_matrix, Rf_install("lookback"));
  const int lookback_length =
    (lookback_sexp != R_NilValue) ? INTEGER(lookback_sexp)[0] : 0;

  SEXP real_matrix = PROTECT(allocMatrix(REALSXP, num_rows, num_cols));
  (*protection_count)++;

  const int *source_values = INTEGER(integer_matrix);
  double *destination_values = REAL(real_matrix);

  // leading NA region: write NA_REAL directly
  for (int i = 0; i < lookback_length; i++) {
    destination_values[i] = NA_REAL;
  }

  // data region
  if (has_scattered_na) {
    // safe path: check each element for NA_INTEGER
    // (needed after na_ignore reexpansion inserts scattered NAs)
    for (int i = lookback_length; i < total_elements; i++) {
      destination_values[i] = (source_values[i] == NA_INTEGER)
                                ? NA_REAL
                                : (double)source_values[i] / divisor;
    }
  } else {
    // fast path: no scattered NAs, unconditional division
    for (int i = lookback_length; i < total_elements; i++) {
      destination_values[i] = (double)source_values[i] / divisor;
    }
  }

  // copy dimnames (column names)
  SEXP dimnames_sexp = Rf_getAttrib(integer_matrix, R_DimNamesSymbol);
  if (dimnames_sexp != R_NilValue) {
    SEXP new_dimnames = PROTECT(Rf_allocVector(VECSXP, 2));
    (*protection_count)++;
    SET_VECTOR_ELT(new_dimnames, 0, R_NilValue);
    SET_VECTOR_ELT(new_dimnames, 1, VECTOR_ELT(dimnames_sexp, 1));
    Rf_dimnamesgets(real_matrix, new_dimnames);
  }

  // copy lookback attribute
  if (lookback_sexp != R_NilValue) {
    Rf_setAttrib(real_matrix, Rf_install("lookback"), lookback_sexp);
  }

  return real_matrix;
}

#endif /* _NORMALIZE_H */