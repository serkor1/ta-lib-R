#ifndef SHIFT_H
#define SHIFT_H

#include <Rinternals.h>

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

#endif /* SHIFT_H */