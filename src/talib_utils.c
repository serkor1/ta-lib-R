#include "talib_utils.h"
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
void shift_double_array(
  double *col, 
  R_xlen_t n, 
  int begIdx, 
  int nbElement
)
// clang-format on
{
  if (begIdx < 0)
    begIdx = 0;
  if (begIdx > n)
    begIdx = (int)n;
  if (nbElement < 0)
    nbElement = 0;

  if ((R_xlen_t)begIdx + nbElement > n)
    nbElement = (int)(n - begIdx);

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
  if (begIdx < 0)
    begIdx = 0;
  if (begIdx > n)
    begIdx = (int)n;
  if (nbElement < 0)
    nbElement = 0;
  if ((R_xlen_t)begIdx + nbElement > n)
    nbElement = (int)(n - begIdx);

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
// shift array end

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
