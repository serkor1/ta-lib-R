#include "talib_utils.h"
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

// Shift array
//
// Parameters
// col: the array to be shifted. Double or int pointer
// n: the size of the input array. Int.
// begIdx: the amount of shifting. Int.
// nbElement:
//
// Description
// This function shifts an array to the right, or down in memory, and adds
// leading NAs from 0 to the shift value.
//
// Details
// arr + shift advances pointer, ie. shifts
// the entire array in memory. So an array of
// {0,1,2} shifted with 1 does {garbage value, 1,
// 2}, a shift by 0 just returns the {0,1,2} array
//
// Generic
// It has a generic version shift_array(...)
//
// Note
// See: https://gist.github.com/barosl/e0af4a92b2b8cabd05a7
// See:
// https://stackoverflow.com/questions/479207/how-to-achieve-function-overloading-in-c
// See:
// https://stackoverflow.com/questions/479207/how-to-achieve-function-overloading-in-c/25026358#25026358
// clang-format off
#define MAX(x, y) (((x) < (y)) ? (y) : (x))
#define MIN(x, y) (((x) < (y)) ? (x) : (y)) 
void shift_double_array(
  double *col, 
  R_xlen_t n, 
  int begIdx, 
  int nbElement
)
// clang-format on
{
  // clip begIdx between 0 and n
  begIdx = MIN(MAX(begIdx, 0), (int)n);

  // clip nbElement between 0 and n - begIdx
  // clang-format off
  nbElement = MAX(nbElement, 0);
  nbElement = (int) MIN(
    (R_xlen_t) nbElement, 
    n - (R_xlen_t) begIdx
  );
  // clang-format on

  // clang-format off
  memmove(
    col + begIdx, 
    col, 
    (size_t)nbElement * sizeof(double)
  );
  // clang-format on

  // <NA> padding
  for (R_xlen_t i = 0; i < begIdx; i++) {
    col[i] = NA_REAL;
  }

  for (R_xlen_t i = (R_xlen_t)begIdx + nbElement; i < n; i++) {
    col[i] = NA_REAL;
  }
}

// clang-format off
void shift_integer_array(
  int *col,
  R_xlen_t n,
  int begIdx,
  int nbElement
)
// clang-format on
{

  // clip begIdx between 0 and n
  begIdx = MIN(MAX(begIdx, 0), (int)n);

  // clip nbElement between 0 and n - begIdx
  // clang-format off
  nbElement = MAX(nbElement, 0);
  nbElement = (int) MIN(
    (R_xlen_t) nbElement, 
    n - (R_xlen_t) begIdx
  );
  // clang-format on

  // clang-format off
  memmove(
    col + begIdx, 
    col, 
    (size_t)nbElement * sizeof(int)
  );
  // clang-format on

  // <NA> padding
  for (R_xlen_t i = 0; i < begIdx; i++) {
    col[i] = NA_INTEGER;
  }
  for (R_xlen_t i = (R_xlen_t)begIdx + nbElement; i < n; i++) {
    col[i] = NA_INTEGER;
  }
}
#undef MAX
#undef MIN
// shift array end

// NA-bridge helpers
//
// Description
//    A row is "present" iff every input column is non-NA/non-NaN at that
//    index (TA-Lib cannot consume either). The present rows are gathered
//    into a dense series, the indicator is computed on that dense series,
//    and scatter_* expands each output column back to full length in
//    place -- writing NA into the dropped rows and the leading lookback
//    slots. No output-side scratch buffer is needed.
//
// clang-format off
#define TA_BIT_GET(mask, i) ((mask)[(R_xlen_t)(i) >> 3] & (unsigned char)(1u << ((i) & 7)))
#define TA_BIT_SET(mask, i) ((mask)[(R_xlen_t)(i) >> 3] |= (unsigned char)(1u << ((i) & 7)))
// clang-format on

R_xlen_t ta_na_prepare(
  const double *const *ins, int k, R_xlen_t n, unsigned char **mask_out) {
  size_t nbytes = (size_t)((n + 7) / 8);
  unsigned char *mask = (unsigned char *)R_alloc(nbytes, 1);
  memset(mask, 0, nbytes);

  R_xlen_t m = 0;
  for (R_xlen_t i = 0; i < n; i++) {
    int present = 1;
    for (int c = 0; c < k; c++) {
      if (ISNAN(ins[c][i])) {
        present = 0;
        break;
      }
    }
    if (present) {
      TA_BIT_SET(mask, i);
      m++;
    }
  }

  *mask_out = mask;
  return m;
}

double *ta_dense_alloc(R_xlen_t m, int k) {
  return (double *)R_alloc((size_t)m * (size_t)k, sizeof(double));
}

double *ta_compact(
  double *dst, const double *src, const unsigned char *mask, R_xlen_t n) {
  R_xlen_t j = 0;
  for (R_xlen_t i = 0; i < n; i++) {
    if (TA_BIT_GET(mask, i)) {
      dst[j++] = src[i];
    }
  }
  return dst;
}

// Scatter array
//
// Description
//    Inverse of ta_compact for a single output column. The dense TA-Lib
//    output occupies col[0 .. nbElement-1]; dense index d in [0, m) maps
//    to the d-th present (set) row of `mask`. We walk original rows from
//    the top down: because a present row's original position is always
//    >= its dense index, the raw values can be expanded up into place
//    without a second buffer.
//
//       d in [begIdx, m)  -> raw value col[d - begIdx]
//       d in [0, begIdx)  -> NA (lookback)
//       dropped rows      -> NA
//
// clang-format off
void scatter_double_array(
  double *col,
  R_xlen_t n,
  const unsigned char *mask,
  R_xlen_t m,
  int begIdx,
  int nbElement
)
// clang-format on
{
  R_xlen_t d = m - 1;                     // dense pointer (top-down)
  R_xlen_t src = (R_xlen_t)nbElement - 1; // raw output pointer col[src]
  for (R_xlen_t orig = n - 1; orig >= 0; orig--) {
    if (d >= 0 && TA_BIT_GET(mask, orig)) {
      if (d >= (R_xlen_t)begIdx && src >= 0) {
        col[orig] = col[src];
        src--;
      } else {
        col[orig] = NA_REAL;
      }
      d--;
    } else {
      col[orig] = NA_REAL;
    }
  }
}

// clang-format off
void scatter_integer_array(
  int *col,
  R_xlen_t n,
  const unsigned char *mask,
  R_xlen_t m,
  int begIdx,
  int nbElement
)
// clang-format on
{
  R_xlen_t d = m - 1;
  R_xlen_t src = (R_xlen_t)nbElement - 1;
  for (R_xlen_t orig = n - 1; orig >= 0; orig--) {
    if (d >= 0 && TA_BIT_GET(mask, orig)) {
      if (d >= (R_xlen_t)begIdx && src >= 0) {
        col[orig] = col[src];
        src--;
      } else {
        col[orig] = NA_INTEGER;
      }
      d--;
    } else {
      col[orig] = NA_INTEGER;
    }
  }
}
#undef TA_BIT_GET
#undef TA_BIT_SET
// NA-bridge helpers end

void ta_check(TA_RetCode rc, const char *fn) {
  if (rc == TA_SUCCESS)
    return;
  TA_RetCodeInfo info;
  TA_SetRetCodeInfo(rc, &info);
  Rf_error("%s: %s (%s)", fn, info.infoStr, info.enumStr);
}

// Column Names
//
// Description:
//    Set the column names of the <matrix>-object
// clang-format off
void set_colnames(
  SEXP x, // assumed to be a matrix
  const char *const *names, 
  int k // columns
)
// clang-format on
{
  // protection counter
  int protection_counter = 0;

  // clang-format off
  SEXP dimensions = PROTECT(
    Rf_allocVector(VECSXP, 2)
  );
  protection_counter++;

  SEXP colnames = PROTECT(
    Rf_allocVector(STRSXP, k)
  );
  protection_counter++;
  // clang-format on

  for (int j = 0; j < k; j++) {
    SET_STRING_ELT(colnames, j, Rf_mkChar(names[j]));
  }

  SET_VECTOR_ELT(dimensions, 0, R_NilValue);
  SET_VECTOR_ELT(dimensions, 1, colnames);

  // set attributes of
  // the underlying <matrix>
  Rf_setAttrib(x, R_DimNamesSymbol, dimensions);

  UNPROTECT(protection_counter);
}

// names.c
//
// When using rownames(x) <- x_names from R
// it adds additional checks which introduces
// a overhead on really large matrix and data.frame
// objects.
//
// This program introduces a low-cost and barebone
// rowname function for data.frame and matrix objects which does no checks. One
// caveat is that rownames via names *has* to be passed as a character vector,
// if not it will crash and burn.
//
// params
//    x: a matrix/data.frame
//    rownames: character
//    colnames: character
//
// NOTE: If colnames is NOT passed in matrix methods
//       it will crash.

// clang-format off
void rownames_data_frame(
  SEXP x, 
  SEXP rownames
)
// clang-format on
{
  setAttrib(x, R_RowNamesSymbol, rownames);

  return;
}

// clang-format off
void rownames_matrix(
  SEXP x, 
  SEXP rownames, 
  SEXP colnames
)
// clang-format on
{
  // clang-format off
  SEXP container = PROTECT(
    allocVector(VECSXP, 2)
  );
  // clang-format on

  SET_VECTOR_ELT(container, 0, rownames);
  SET_VECTOR_ELT(container, 1, colnames);

  setAttrib(x, R_DimNamesSymbol, container);

  UNPROTECT(1);

  return;
}