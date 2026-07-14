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

#endif /* _NORMALIZE_H */
