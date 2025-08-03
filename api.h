#ifndef _API_H_
#define _API_H_

#include <Rinternals.h>

SEXP c_average_price(SEXP const x);
SEXP c_bollinger_bands(const SEXP x, const SEXP timePeriod, const SEXP nbDevUp, const SEXP nbDevDn, SEXP maType);

#endif
