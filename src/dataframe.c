// dataframe.c
#include <R.h>
#include <Rinternals.h>
#include <string.h>

// clang-format off
static SEXP map_dfr_impl(
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
  if (type == REALSXP) {
    const double *restrict x_ptr = REAL(x);
    const size_t col_bytes = nrow_len * sizeof(double);

    for (int j = 0; j < ncols; ++j) {
      SEXP column = PROTECT(allocVector(REALSXP, nrows));
      ++protection_counter;

      double *restrict column_ptr = REAL(column);

      const double *restrict src = x_ptr + (size_t)j * nrows;
      memcpy(column_ptr, src, col_bytes);

      SET_VECTOR_ELT(data_frame, j, column);
    }

  } else {
    const int *restrict x_ptr = INTEGER(x);
    const size_t col_bytes = nrow_len * sizeof(int);

    for (int j = 0; j < ncols; ++j) {
      SEXP column = PROTECT(allocVector(INTSXP, nrows));
      ++protection_counter;

      int *restrict column_ptr = INTEGER(column);
      const int *restrict src = x_ptr + (size_t)j * nrows;
      memcpy(column_ptr, src, col_bytes);

      SET_VECTOR_ELT(data_frame, j, column);
    }
  }

  // dimension names
  SEXP dimnames = getAttrib(x, R_DimNamesSymbol);
  SEXP row_names = VECTOR_ELT(dimnames, 0);
  SEXP col_names = VECTOR_ELT(dimnames, 1);
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

// clang-format off
SEXP map_dfr_double(SEXP x)
// clang-format on
{
  return map_dfr_impl(x, REALSXP);
}

// clang-format off
SEXP map_dfr_integer(SEXP x)
// clang-format on
{
  return map_dfr_impl(x, INTSXP);
}
