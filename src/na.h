// na.h
//
// C-level NA handling for the na.ignore parameter.
//
// Provides:
//   build_na_mask   - scan input arrays, build boolean mask, return clean count
//   compact_array   - copy non-masked elements into a compact buffer
//   reexpand_double_matrix - re-expand compact double output to full size
//   reexpand_int_matrix    - re-expand compact int output to full size
//   reexpand_matrix        - generic dispatch via _Generic
//
#ifndef _NA_H
#define _NA_H

#include <R.h>
#include <R_ext/Arith.h>
#include <Rinternals.h>

// Build NA mask from multiple double input arrays.
// mask[i] = 1 if any array has NA/NaN at position i.
// Returns count of non-NA rows.
// clang-format off
static inline int build_na_mask(
  int *mask,
  int n,
  int n_arrays,
  const double *const *arrays
) {
  // clang-format on
  int clean = 0;
  for (int i = 0; i < n; i++) {
    mask[i] = 0;
    for (int j = 0; j < n_arrays; j++) {
      if (ISNAN(arrays[j][i])) {
        mask[i] = 1;
        break;
      }
    }
    if (!mask[i])
      clean++;
  }
  return clean;
}

// Copy non-masked elements from src to dest.
// clang-format off
static inline void compact_array(
  double *restrict dest,
  const double *restrict src,
  const int *mask,
  int n
) {
  // clang-format on
  int j = 0;
  for (int i = 0; i < n; i++) {
    if (!mask[i])
      dest[j++] = src[i];
  }
}

// Compact multiple input arrays in-place.
// For each pointer in ptrs[], allocates a clean buffer via R_alloc,
// copies non-masked elements into it, and replaces the pointer.
// clang-format off
static inline void compact_arrays(
  const double **ptrs,
  int n_arrays,
  const int *mask,
  int n_original,
  int n_clean
) {
  // clang-format on
  for (int j = 0; j < n_arrays; j++) {
    double *buf = (double *)R_alloc(n_clean, sizeof(double));
    compact_array(buf, ptrs[j], mask, n_original);
    ptrs[j] = buf;
  }
}

// Re-expand a compact double matrix to full size,
// inserting NA_REAL at masked positions.
// Returns new PROTECTed SEXP; increments protection_count.
// clang-format off
static inline SEXP reexpand_double_matrix(
  SEXP compact,
  const int *mask,
  int n_full,
  int *protection_count
) {
  // clang-format on
  const int ncol = Rf_ncols(compact);
  const int n_compact = Rf_nrows(compact);

  SEXP full = PROTECT(allocMatrix(REALSXP, n_full, ncol));
  (*protection_count)++;

  const double *src = REAL(compact);
  double *dest = REAL(full);

  for (int col = 0; col < ncol; col++) {
    const double *s = src + col * n_compact;
    double *d = dest + col * n_full;
    int j = 0;
    for (int i = 0; i < n_full; i++) {
      d[i] = mask[i] ? NA_REAL : s[j++];
    }
  }

  // copy dimnames (column names)
  SEXP dn = Rf_getAttrib(compact, R_DimNamesSymbol);
  if (dn != R_NilValue) {
    SEXP new_dn = PROTECT(Rf_allocVector(VECSXP, 2));
    (*protection_count)++;
    SET_VECTOR_ELT(new_dn, 0, R_NilValue);
    SET_VECTOR_ELT(new_dn, 1, VECTOR_ELT(dn, 1));
    Rf_dimnamesgets(full, new_dn);
  }

  // copy lookback attribute
  SEXP lb = Rf_getAttrib(compact, Rf_install("lookback"));
  if (lb != R_NilValue) {
    Rf_setAttrib(full, Rf_install("lookback"), lb);
  }

  return full;
}

// Re-expand a compact integer matrix to full size,
// inserting NA_INTEGER at masked positions.
// Returns new PROTECTed SEXP; increments protection_count.
// clang-format off
static inline SEXP reexpand_int_matrix(
  SEXP compact,
  const int *mask,
  int n_full,
  int *protection_count
) {
  // clang-format on
  const int ncol = Rf_ncols(compact);
  const int n_compact = Rf_nrows(compact);

  SEXP full = PROTECT(allocMatrix(INTSXP, n_full, ncol));
  (*protection_count)++;

  const int *src = INTEGER(compact);
  int *dest = INTEGER(full);

  for (int col = 0; col < ncol; col++) {
    const int *s = src + col * n_compact;
    int *d = dest + col * n_full;
    int j = 0;
    for (int i = 0; i < n_full; i++) {
      d[i] = mask[i] ? NA_INTEGER : s[j++];
    }
  }

  // copy dimnames (column names)
  SEXP dn = Rf_getAttrib(compact, R_DimNamesSymbol);
  if (dn != R_NilValue) {
    SEXP new_dn = PROTECT(Rf_allocVector(VECSXP, 2));
    (*protection_count)++;
    SET_VECTOR_ELT(new_dn, 0, R_NilValue);
    SET_VECTOR_ELT(new_dn, 1, VECTOR_ELT(dn, 1));
    Rf_dimnamesgets(full, new_dn);
  }

  // copy lookback attribute
  SEXP lb = Rf_getAttrib(compact, Rf_install("lookback"));
  if (lb != R_NilValue) {
    Rf_setAttrib(full, Rf_install("lookback"), lb);
  }

  return full;
}

// Generic re-expand dispatch based on output pointer type.
// Usage: output = reexpand_matrix(output, output_ptr, na_mask, n_original,
//                                 &protection_count);
// clang-format off
#define reexpand_matrix(compact, out_ptr, mask, n_full, pcount) \
  _Generic(*(out_ptr),                                          \
    double: reexpand_double_matrix,                             \
    int:    reexpand_int_matrix                                 \
  )((compact), (mask), (n_full), (pcount))
// clang-format on

#endif /* _NA_H */
