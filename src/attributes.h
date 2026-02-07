#ifndef ATTRIBUTES_H
#define ATTRIBUTES_H
// attributes.h
//
// This header file abstracts the attribute
// setting of the output containers.
//
#include <Rinternals.h>

void set_attribute(SEXP obj, int lookback, int *protection_count);

#endif /* ATTRIBUTES_H */
