#ifndef NAMES_H
#define NAMES_H

#include <Rinternals.h>

void set_colnames(SEXP x, const char *const *names, int k);
void rownames_data_frame(SEXP x, SEXP rownames);
void rownames_matrix(SEXP x, SEXP rownames, SEXP colnames);

#endif /* NAMES_H */
