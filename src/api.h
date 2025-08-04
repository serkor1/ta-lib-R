#ifndef _API_H_
#define _API_H_

#include <Rinternals.h>

SEXP c_average_price(const SEXP x);
SEXP c_bollinger_bands(const SEXP x, const SEXP timePeriod, const SEXP nbDevUp, const SEXP nbDevDn, const SEXP maType);
SEXP c_cdl3blackcrows(const SEXP open, const SEXP high, const SEXP low, const SEXP close);
SEXP c_commodity_channel_index(const SEXP high, const SEXP low, const SEXP close, const SEXP period);
SEXP c_kaufman_adaptive_moving_average(const SEXP x, const SEXP period);
SEXP c_median_price(const SEXP x);
SEXP c_moving_average_convergence_divergence(SEXP x, SEXP fastPeriod, SEXP slowPeriod, SEXP signalPeriod);
SEXP c_weighted_moving_average(const SEXP x, const SEXP lag);

#endif
