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

// NA-bridge helpers for the `na.bridge` path now live in NA-handling.{h,c}.

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