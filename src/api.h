#ifndef _API_H_
#define _API_H_

#include <Rinternals.h>

SEXP c_average_price(SEXP const x);
SEXP c_bollinger_bands(const SEXP x, const SEXP timePeriod, const SEXP nbDevUp, const SEXP nbDevDn, const SEXP maType);
SEXP c_commodity_channel_index(const SEXP high, const SEXP low, const SEXP close, const SEXP period);
SEXP c_kaufman_adaptive_moving_average(const SEXP x, const SEXP period);
SEXP c_weighted_moving_average(const SEXP x, const SEXP lag);

#endif
