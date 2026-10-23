#ifndef CROSSING_H
#define CROSSING_H
// Crossing of series
//
// This routine identifies the crossing of two series
// from below, above or both. Commonly used in cross-over / cross-under
// strategies of, for example, moving averages.
//
// Output is an integer vector of the same lenght as the
// input series.
//
// Parameters
//      x (double/integer): short series
//      y (double/integer): long  series
//  na_rm        (boolean): if TRUE the output where <NA> will be
//                          emitted as <NA>
//  direction    (integer): 1 = over, -1 = under, 0 = both
//
// Crossing over emits 1 and crossing under emits -1 (bearish, as
// with candlestick patterns), no crossing emits 0.
//
// Author: Serkan Korkmaz
#include "R_ext/Arith.h"
#include "Rinternals.h"

// clang-format off
static inline void double_simple_crossing(
  const double * restrict x,
  const double * restrict y,
  int *          restrict output,
  R_xlen_t output_len,
  bool na_rm,
  int direction
)
// clang-format on
{
  // weights of the over and under
  // crossings; direction is passed as a
  // literal from impl_simple_crossing so the
  // compiler folds the weights and drops the
  // unused comparisons for each direction
  const int over_weight = direction >= 0;
  const int under_weight = -(direction <= 0);

  if (na_rm) {

    for (R_xlen_t i = 1; i < output_len; i++) {
      output[i] = ISNAN(x[i - 1]) | ISNAN(y[i - 1]) | ISNAN(x[i]) | ISNAN(y[i])
                    ? NA_INTEGER
                    : over_weight * ((x[i - 1] < y[i - 1]) & (x[i] > y[i])) +
                        under_weight * ((x[i - 1] > y[i - 1]) & (x[i] < y[i]));
    }

  } else {

    for (R_xlen_t i = 1; i < output_len; i++) {
      output[i] = over_weight * ((x[i - 1] < y[i - 1]) & (x[i] > y[i])) +
                  under_weight * ((x[i - 1] > y[i - 1]) & (x[i] < y[i]));
    }
  }
}

// clang-format off
static inline void integer_simple_crossing(
  const int *restrict x,
  const int *restrict y,
  int *restrict output,
  R_xlen_t output_len,
  bool na_rm,
  int direction
)
// clang-format on
{
  const int over_weight = direction >= 0;
  const int under_weight = -(direction <= 0);

  if (na_rm) {

    for (R_xlen_t i = 1; i < output_len; i++) {

      output[i] = (x[i - 1] == NA_INTEGER) | (y[i - 1] == NA_INTEGER) |
                      (x[i] == NA_INTEGER) | (y[i] == NA_INTEGER)
                    ? NA_INTEGER
                    : over_weight * ((x[i - 1] < y[i - 1]) & (x[i] > y[i])) +
                        under_weight * ((x[i - 1] > y[i - 1]) & (x[i] < y[i]));
    }

  } else {

    for (R_xlen_t i = 1; i < output_len; i++) {

      output[i] = over_weight * ((x[i - 1] < y[i - 1]) & (x[i] > y[i])) +
                  under_weight * ((x[i - 1] > y[i - 1]) & (x[i] < y[i]));
    }
  }
}

// clang-format off
SEXP impl_simple_crossing(
  SEXP x, 
  SEXP y,
  SEXP na_rm,
  SEXP direction
)
// clang-format on
{
  // protection counter
  int protection_count = 0;

  // the main assumption here is that
  // the length of x is the same as y
  //  - Hell will break loose if it isn't so
  //    any caller will have to check it before
  //    passing it here.
  R_xlen_t output_length = Rf_xlength(x);

  // clang-format off
  SEXP output_vector = PROTECT(
    Rf_allocVector(INTSXP, output_length)
  );

  protection_count++;
  // clang-format on
  int *output_vector_ptx = INTEGER(output_vector);

  // the first element is always
  // <NA> by construction and is guarded
  // against zero-length vectors
  //  **To future self:** At some point you should
  //  test whether Valgrind will catch this if its not guarded.
  if (output_length > 0) {
    output_vector_ptx[0] = NA_INTEGER;
  }

  bool remove_na = Rf_asLogical(na_rm);
  int crossing_direction = Rf_asInteger(direction);

  // each direction is passed as a literal
  // so every call is inlined into its own
  // specialised loop
  // clang-format off
  switch (TYPEOF(x)) {
    case REALSXP: {
      const double *short_series = REAL(x);
      const double *long_series  = REAL(y);

      switch (crossing_direction) {
        case 1:  double_simple_crossing(short_series, long_series, output_vector_ptx, output_length, remove_na,  1); break;
        case -1: double_simple_crossing(short_series, long_series, output_vector_ptx, output_length, remove_na, -1); break;
        default: double_simple_crossing(short_series, long_series, output_vector_ptx, output_length, remove_na,  0); break;
      }
      break;
    }
    case INTSXP: {
      const int *short_series = INTEGER(x);
      const int *long_series  = INTEGER(y);

      switch (crossing_direction) {
        case 1:  integer_simple_crossing(short_series, long_series, output_vector_ptx, output_length, remove_na,  1); break;
        case -1: integer_simple_crossing(short_series, long_series, output_vector_ptx, output_length, remove_na, -1); break;
        default: integer_simple_crossing(short_series, long_series, output_vector_ptx, output_length, remove_na,  0); break;
      }
      break;
    }
    // NOTE: There is no default fallback
    //       which you may argue is bad practise - but
    //       the caller is held responsible for the types.
  }
  // clang-format on

  UNPROTECT(protection_count);
  return output_vector;
}

#endif /* CROSSING_H */