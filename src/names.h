// names
//
// Description
// Set names of matrices
#ifndef _names_h
#define _names_h

#include <R.h>
#include <Rinternals.h>

static inline void column_names(SEXP x, int n_cols,
                                const char *const *colnames) {

  SEXP dn = PROTECT(Rf_allocVector(VECSXP, 2));
  SEXP cn = PROTECT(Rf_allocVector(STRSXP, n_cols));
  for (int j = 0; j < n_cols; ++j) {
    SET_STRING_ELT(cn, j, Rf_mkCharCE(colnames[j], CE_UTF8));
  }

  SET_VECTOR_ELT(dn, 0, R_NilValue);
  SET_VECTOR_ELT(dn, 1, cn);
  Rf_dimnamesgets(x, dn);
  UNPROTECT(2);
}

// clang-format off
#define set_colnames(x, ...)                              \
  do {                                                    \
    const char *_cn_[] = {__VA_ARGS__};                   \
    column_names((x), (int) (sizeof _cn_ / sizeof *_cn_), _cn_);                                              \
  } while (0)
// clang-format on

#endif // _names_h