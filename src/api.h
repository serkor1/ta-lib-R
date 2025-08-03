#ifndef _API_H_
#define _API_H_

#include <Rinternals.h>

SEXP c_average_price(const SEXP x);
SEXP c_bollinger_bands(SEXP x, SEXP timePeriod, SEXP nbDevUp, SEXP nbDevDn,
                       SEXP maType);

#endif