
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
#include "shift.h"
#include <string.h>
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