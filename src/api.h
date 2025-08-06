#ifndef _API_H_
#define _API_H_

#include <Rinternals.h>

SEXP c_bollinger_bands(const SEXP x, const SEXP timePeriod, const SEXP nbDevUp, const SEXP nbDevDn, const SEXP maType);
SEXP c_cdl3blackcrows(const SEXP open, const SEXP high, const SEXP low, const SEXP close);
SEXP c_commodity_channel_index(const SEXP high, const SEXP low, const SEXP close, const SEXP period);
SEXP c_kaufman_adaptive_moving_average(const SEXP x, const SEXP period);
SEXP c_median_price(const SEXP x);
SEXP c_moving_average_convergence_divergence(SEXP x, SEXP fastPeriod, SEXP slowPeriod, SEXP signalPeriod);
SEXP c_weighted_moving_average(const SEXP x, const SEXP lag);
SEXP impl_MIDPRICE(const SEXP x, const SEXP n);
SEXP impl_ta_ACCBANDS(SEXP inHigh, SEXP inLow, SEXP inClose, SEXP optTimePeriod);
SEXP impl_ta_APO(SEXP inRealSEXP, SEXP fastPeriodSEXP, SEXP slowPeriodSEXP, SEXP maTypeSEXP);
SEXP impl_ta_AROONOSC(SEXP inHighSEXP, SEXP inLowSEXP, SEXP timePeriodSEXP);
SEXP impl_ta_AROON(SEXP inHighSEXP, SEXP inLowSEXP, SEXP timePeriodSEXP);
SEXP impl_TA_AVGPRICE(const SEXP x);
SEXP impl_ta_BBANDS(SEXP inReal, SEXP optTimePeriod, SEXP optNbDevUp, SEXP optNbDevDn, SEXP optMAType);
SEXP impl_ta_MACD(SEXP inReal, SEXP optFastPeriod, SEXP optSlowPeriod, SEXP optSignalPeriod);
SEXP impl_ta_RSI(SEXP inReal, SEXP optTimePeriod);

#endif
