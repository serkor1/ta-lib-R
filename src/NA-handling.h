// NA-handling.h
//
// Description
//    Public interface for the `na.bridge` path: drop rows where any input
//    is NA/NaN, compute the indicator on the dense (gap-free) series, then
//    scatter the results back to their original row positions. Kept in one
//    place so all generated wrappers share a single, memory-lean routine.
//
#ifndef NA_HANDLING_H
#define NA_HANDLING_H

#include <Rinternals.h>

R_xlen_t build_presence_mask(
  const double *const *input_columns,
  int k_columns,
  R_xlen_t n_rows,
  unsigned char **presence_mask);

double *dense_array(R_xlen_t num_present_rows, int k_columns);

double *compact_array(
  double *dense_column,
  const double *full_column,
  const unsigned char *presence_mask,
  R_xlen_t n_rows);

void scatter_double_array(
  double *column,
  R_xlen_t n_rows,
  const unsigned char *presence_mask,
  R_xlen_t num_present_rows,
  int begIdx,
  int nbElement);

void scatter_integer_array(
  int *column,
  R_xlen_t n_rows,
  const unsigned char *presence_mask,
  R_xlen_t num_present_rows,
  int begIdx,
  int nbElement);

// clang-format off
// Generic scatter_array
//
// Description
//    Works similar to S3 functions in R
//    _Generic( (x), type: dispatch ) ( signature )
#define scatter_array(column, n_rows, presence_mask, num_present_rows, begIdx, nbElement) \
   _Generic((column),                                                                     \
     double *: scatter_double_array,                                                      \
     int *:    scatter_integer_array                                                      \
   )((column), (n_rows), (presence_mask), (num_present_rows), (begIdx), (nbElement))
// clang-format on
// scatter array end

#endif /* NA_HANDLING_H */
