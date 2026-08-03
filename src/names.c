#include "names.h"

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

// clang-format off
void index_data_frame(
  SEXP x,
  SEXP rownames
)
// clang-format on
{
  Rf_setAttrib(x, R_RowNamesSymbol, rownames);

  return;
}

// clang-format off
void index_matrix(
  SEXP x, 
  SEXP rownames, 
  SEXP colnames
)
// clang-format on
{
  // clang-format off
  SEXP container = PROTECT(
    Rf_allocVector(VECSXP, 2)
  );
  // clang-format on

  SET_VECTOR_ELT(container, 0, rownames);
  SET_VECTOR_ELT(container, 1, colnames);

  Rf_setAttrib(x, R_DimNamesSymbol, container);

  UNPROTECT(1);

  return;
}

// Index of the <xts>-object
//
// Installs the 'index'-attribute on x. The value is the
// index of the input <xts>-object, i.e. zoo::index(x),
// and is attached as-is.
// clang-format off
void index_xts(
  SEXP x,
  SEXP index
)
// clang-format on
{
  Rf_setAttrib(x, Rf_install("index"), index);

  return;
}