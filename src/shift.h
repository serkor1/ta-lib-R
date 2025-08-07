#ifndef _SHIFT_H
#define _SHIFT_H
// Shift Arrays
//
// This program creates a generic function
// that shifts an array. Its like function overloading
// and templates, but with extra steps.
//
// See: https://gist.github.com/barosl/e0af4a92b2b8cabd05a7
// See: https://stackoverflow.com/questions/479207/how-to-achieve-function-overloading-in-c
// See: https://stackoverflow.com/questions/479207/how-to-achieve-function-overloading-in-c/25026358#25026358
#include "R_ext/Arith.h"
#include <string.h>

static void shift_double_array(double *arr, int len, int shift) {
  // 0) edge-case:
  //    If the shift is greater than
  //    the length of the array, or the shift
  //    is lte 0, everything is NA.
  //
  //    **NOTE:** this is highly unlikely but
  //    added just in case to avoid crashes.
  //
  //    It could probably be a better idea just
  //    terminate the function instead.
  if (shift <= 0 || shift >= len) {
    for (int i = 0; i < len; ++i) {
      arr[i] = NA_REAL;
    }
    return;
  }

  // 1) shift the arrayy
  //    in place
  memmove(
      /*dest:*/ arr + shift, // NOTE: arr + shift advances pointer, ie. shifts
                             // the entire array in memory. So an array of
                             // {0,1,2} shifted with 1 does {garbage value, 1,
                             // 2}, a shift by 0 just returns the {0,1,2} array
      /*src*/ arr,
      /*n*/ (size_t)(len - shift) * sizeof(double));

  // 2) add leading NAs
  //    as NA_REAL for
  //    type compatibility
  for (int i = 0; i < shift; ++i) {
    arr[i] = NA_REAL;
  }
}

static void shift_int_array(int *arr, int len, int shift) {
  // 0) edge-case:
  //    If the shift is greater than
  //    the length of the array, or the shift
  //    is lte 0, everything is NA.
  //
  //    **NOTE:** this is highly unlikely but
  //    added just in case to avoid crashes.
  //
  //    It could probably be a better idea just
  //    terminate the function instead.
  if (shift < 0 || shift >= len) { // Possible bug: If there is no shift, then this would fill it with NAs. Same geos for the double versions
    for (int i = 0; i < len; ++i) {
      arr[i] = NA_INTEGER;
    }
    return;
  }

  // 1) shift the arrayy
  //    in place
  memmove(
      /*dest:*/ arr + shift, // NOTE: arr + shift advances pointer, ie. shifts
                             // the entire array in memory. So an array of
                             // {0,1,2} shifted with 1 does {garbage value, 1,
                             // 2}, a shift by 0 just returns the {0,1,2} array
      /*src*/ arr,
      /*n*/ (size_t)(len - shift) * sizeof(int));

  // 2) add leading NAs
  //    as NA_REAL for
  //    type compatibility
  for (int i = 0; i < shift; ++i) {
    arr[i] = NA_INTEGER;
  }
}

#define shift_array(arr, len, shift) _Generic((arr), int*: shift_int_array, double*: shift_double_array)(arr, len, shift)

#endif // _SHIFT_H