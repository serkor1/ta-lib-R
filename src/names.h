#ifndef NAMES_H
#define NAMES_H

#include <Rinternals.h>

void set_colnames(SEXP x, const char *const *names, int k);
void index_data_frame(SEXP x, SEXP rownames);
void index_matrix(SEXP x, SEXP rownames, SEXP colnames);
void index_xts(SEXP x, SEXP index);

#endif /* NAMES_H */
