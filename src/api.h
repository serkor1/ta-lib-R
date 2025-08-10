// Generated from tools/generate_API.sh
#ifndef _API_H_
#define _API_H_

#include <Rinternals.h>

// clang-format off
SEXP impl_ta_ACCBANDS(SEXP inHigh, SEXP inLow, SEXP inClose, SEXP optTimePeriod);
SEXP impl_ta_ADOSC(SEXP inHigh, SEXP inLow, SEXP inClose, SEXP inVolume, SEXP optFastPeriod, SEXP optSlowPeriod);
SEXP impl_ta_AD(SEXP inHigh, SEXP inLow, SEXP inClose, SEXP inVolume);
SEXP impl_ta_APO(SEXP inRealSEXP, SEXP fastPeriodSEXP, SEXP slowPeriodSEXP, SEXP maTypeSEXP);
SEXP impl_ta_AROONOSC(SEXP inHighSEXP, SEXP inLowSEXP, SEXP timePeriodSEXP);
SEXP impl_ta_AROON(SEXP inHighSEXP, SEXP inLowSEXP, SEXP timePeriodSEXP);
SEXP impl_ta_BBANDS(SEXP inReal, SEXP optTimePeriod, SEXP optNbDevUp, SEXP optNbDevDn, SEXP optMAType);
SEXP impl_ta_CDLDOJI(SEXP open, SEXP high, SEXP low, SEXP close, SEXP normalize_flag);
SEXP impl_ta_CDLDOJISTAR(SEXP open, SEXP high, SEXP low, SEXP close, SEXP normalize_flag);
SEXP impl_ta_CDLDRAGONFLYDOJI(SEXP open, SEXP high, SEXP low, SEXP close, SEXP normalize_flag);
SEXP impl_ta_CDLEVENINGDOJISTAR(SEXP open, SEXP high, SEXP low, SEXP close, SEXP penetration, SEXP normalize_flag);
SEXP impl_ta_MACDEXT(SEXP inReal, SEXP optFastPeriod, SEXP optFastMAType, SEXP optSlowPeriod, SEXP optSlowMAType, SEXP optSignalPeriod, SEXP optSignalMAType);
SEXP impl_ta_MACDFIX(SEXP inReal, SEXP optSignalPeriod);
SEXP impl_ta_MACD(SEXP inReal, SEXP optFastPeriod, SEXP optSlowPeriod, SEXP optSignalPeriod);
SEXP impl_ta_MA(SEXP x, SEXP lag, SEXP matype);
SEXP impl_ta_RSI(SEXP inReal, SEXP optTimePeriod);
SEXP impl_ta_STOCHF(SEXP high, SEXP low, SEXP close, SEXP fastk_period, SEXP fastd_period, SEXP fastd_matype);
SEXP impl_ta_STOCHRSI(SEXP real, SEXP timeperiod, SEXP fastk_period, SEXP fastd_period, SEXP fastd_matype);
SEXP impl_ta_STOCH(SEXP high, SEXP low, SEXP close, SEXP fastk_period, SEXP slowk_period, SEXP slowk_matype, SEXP slowd_period, SEXP slowd_matype);
SEXP impl_ta_ULTOSC(SEXP high, SEXP low, SEXP close, SEXP timeperiod1, SEXP timeperiod2, SEXP timeperiod3);
// clang-format on

#endif //_API_H
