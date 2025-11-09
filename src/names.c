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
#include <R.h>
#include <R_ext/Rdynload.h>
#include <Rinternals.h>

// clang-format off
SEXP rownames_data_frame(
  SEXP x, 
  SEXP rownames
)
// clang-format on
{
  setAttrib(x, R_RowNamesSymbol, rownames);
  return R_NilValue;
}

// clang-format off
SEXP rownames_matrix(
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
  return R_NilValue;
}
