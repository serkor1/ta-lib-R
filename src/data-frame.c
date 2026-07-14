// data-frame.c
//
// Description:
//  This C-routine converts a <matrix> to a <data.frame>
//  on the R-side. It is implemented specifically for {talib}
//  and its portablility across other packages are, at best, zero to none.
//  The only reason it has been written is to reduce the time taken to convert
//  a <matrix> to <data.frame> (see benchmarks below)
//
// Benchmark:
//
// ``` r
// x <- as.matrix(mtcars)
//
// bench::mark(
// `{talib}` = talib:::map_dfr(x),
// `{base}` = as.data.frame(x)
// )
//
// #> # A tibble: 2 × 6
// #>   expression      min   median `itr/sec` mem_alloc `gc/sec`
// #>   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
// #> 1 {talib}      1.72µs   2.56µs   372826.    1.88MB      0
// #> 2 {base}      16.04µs   19.4µs    49028.   13.36KB     29.4
// ```
//
// <sup>Created on 2026-07-13 with [reprex
// v2.1.1](https://reprex.tidyverse.org)</sup>
#include <R.h>
#include <Rinternals.h>
#include <string.h>

// clang-format off
static SEXP impl_map_dfr(
  SEXP x, 
  SEXPTYPE type
)
// clang-format on
{
  // set protection counter
  int protection_counter = 0;

  // input dimensions
  SEXP dim = getAttrib(x, R_DimSymbol);
  const int nrows = INTEGER(dim)[0];
  const int ncols = INTEGER(dim)[1];

  // column stride used by both REALSXP/INTSXP branches below
  const size_t nrow_len = (size_t)nrows;

  // clang-format off
  SEXP data_frame = PROTECT(
    allocVector(VECSXP, ncols)
  );
  // clang-format on
  ++protection_counter;

  // construct columns
  //
  // Each column is stored straight into data_frame with SET_VECTOR_ELT and
  // then filled. allocVector() returns the vector before SET_VECTOR_ELT runs,
  // and SET_VECTOR_ELT itself does not allocate, so the fresh column is rooted
  // in the already-protected data_frame with no intervening GC - no per-column
  // PROTECT is needed, and the protection stack stays at constant depth.
  if (type == REALSXP) {
    const double *restrict x_ptr = REAL(x);
    const size_t col_bytes = nrow_len * sizeof(double);

    for (int j = 0; j < ncols; ++j) {
      SEXP column = allocVector(REALSXP, nrows);
      SET_VECTOR_ELT(data_frame, j, column);

      double *restrict column_ptr = REAL(column);
      const double *restrict src = x_ptr + (size_t)j * nrows;
      memcpy(column_ptr, src, col_bytes);
    }

  } else {
    const int *restrict x_ptr = INTEGER(x);
    const size_t col_bytes = nrow_len * sizeof(int);

    for (int j = 0; j < ncols; ++j) {
      SEXP column = allocVector(INTSXP, nrows);
      SET_VECTOR_ELT(data_frame, j, column);

      int *restrict column_ptr = INTEGER(column);
      const int *restrict src = x_ptr + (size_t)j * nrows;
      memcpy(column_ptr, src, col_bytes);
    }
  }

  // dimension names
  SEXP dimnames = getAttrib(x, R_DimNamesSymbol);
  SEXP row_names =
    (dimnames == R_NilValue) ? R_NilValue : VECTOR_ELT(dimnames, 0);
  SEXP col_names =
    (dimnames == R_NilValue) ? R_NilValue : VECTOR_ELT(dimnames, 1);

  // a data.frame requires non-NULL row.names. Use the compact form
  // c(NA_integer_, -nrows) - same representation base R uses for
  // automatic row names - when the matrix carries no row dimnames.
  if (row_names == R_NilValue) {
    row_names = PROTECT(allocVector(INTSXP, 2));
    ++protection_counter;
    INTEGER(row_names)[0] = NA_INTEGER;
    INTEGER(row_names)[1] = -nrows;
  }

  setAttrib(data_frame, R_RowNamesSymbol, row_names);
  setAttrib(data_frame, R_NamesSymbol, col_names);

  // clang-format off
  SEXP class = PROTECT(
    mkString("data.frame")
  );
  // clang-format on
  ++protection_counter;
  setAttrib(data_frame, R_ClassSymbol, class);

  UNPROTECT(protection_counter);
  return data_frame;
}

// Map <matrix> to <data.frame>
//
// Description:
//  Exported functions that converts <matrix> to <data.frame>.
//  Integers and doubles are handled on the R-side via utils.R
// clang-format off
SEXP map_dfr_double(SEXP x)
// clang-format on
{
  return impl_map_dfr(x, REALSXP);
}

// clang-format off
SEXP map_dfr_integer(SEXP x)
// clang-format on
{
  return impl_map_dfr(x, INTSXP);
}