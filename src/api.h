// Generated from tools/generate_API.sh
#ifndef _API_H_
#define _API_H_

#include <Rinternals.h>

// clang-format off
SEXP impl_ta_ACCBANDS(SEXP inHigh, SEXP inLow, SEXP inClose, SEXP optTimePeriod);
SEXP impl_ta_ADOSC(SEXP inHigh, SEXP inLow, SEXP inClose, SEXP inVolume, SEXP optFastPeriod, SEXP optSlowPeriod);
SEXP impl_ta_AD(SEXP inHigh, SEXP inLow, SEXP inClose, SEXP inVolume);
SEXP impl_ta_ADXR(SEXP high, SEXP low, SEXP close, SEXP optTimePeriod);
SEXP impl_ta_ADX(SEXP high, SEXP low, SEXP close, SEXP optTimePeriod);
SEXP impl_ta_APO(SEXP inRealSEXP, SEXP fastPeriodSEXP, SEXP slowPeriodSEXP, SEXP maTypeSEXP);
SEXP impl_ta_AROONOSC(SEXP high, SEXP low, SEXP timeperiod);
SEXP impl_ta_AROON(SEXP high, SEXP low, SEXP timeperiod);
SEXP impl_ta_BBANDS(SEXP inReal, SEXP optTimePeriod, SEXP optNbDevUp, SEXP optNbDevDn, SEXP optMAType);
SEXP impl_ta_CCI(SEXP high, SEXP low, SEXP close, SEXP optTimePeriod);
SEXP impl_ta_CDL2CROWS(SEXP open, SEXP high, SEXP low, SEXP close, SEXP normalize_flag);
SEXP impl_ta_CDL3BLACKCROWS(SEXP open, SEXP high, SEXP low, SEXP close, SEXP normalize_flag);
SEXP impl_ta_CDL3INSIDE(SEXP open, SEXP high, SEXP low, SEXP close, SEXP normalize_flag);
SEXP impl_ta_CDL3LINESTRIKE(SEXP open, SEXP high, SEXP low, SEXP close, SEXP normalize_flag);
SEXP impl_ta_CDL3OUTSIDE(SEXP open, SEXP high, SEXP low, SEXP close, SEXP normalize_flag);
SEXP impl_ta_CDL3STARSINSOUTH(SEXP open, SEXP high, SEXP low, SEXP close, SEXP normalize_flag);
SEXP impl_ta_CDL3WHITESOLDIERS(SEXP open, SEXP high, SEXP low, SEXP close, SEXP normalize_flag);
SEXP impl_ta_CDLABANDONEDBABY(SEXP open, SEXP high, SEXP low, SEXP close, SEXP penetration, SEXP normalize_flag);
SEXP impl_ta_CDLADVANCEBLOCK(SEXP open, SEXP high, SEXP low, SEXP close, SEXP normalize_flag);
SEXP impl_ta_CDLDOJI(SEXP open, SEXP high, SEXP low, SEXP close, SEXP normalize_flag);
SEXP impl_ta_CDLDOJISTARSTAR(SEXP open, SEXP high, SEXP low, SEXP close, SEXP normalize_flag);
SEXP impl_ta_CDLDRAGONFLYDOJI(SEXP open, SEXP high, SEXP low, SEXP close, SEXP normalize_flag);
SEXP impl_ta_CDLEVENINGDOJISTAR(SEXP open, SEXP high, SEXP low, SEXP close, SEXP penetration, SEXP normalize_flag);
SEXP impl_ta_CMO(SEXP x, SEXP optTimePeriod);
SEXP impl_ta_HT_DCPERIOD(SEXP inReal);
SEXP impl_ta_HT_DCPHASE(SEXP inReal);
SEXP impl_ta_HT_PHASOR(SEXP inReal);
SEXP impl_ta_HT_SINE(SEXP inReal);
SEXP impl_ta_HT_TRENDLINE(SEXP inReal);
SEXP impl_ta_HT_TRENDMODE(SEXP inReal);
SEXP impl_ta_MACDEXT(SEXP inReal, SEXP optFastPeriod, SEXP optFastMAType, SEXP optSlowPeriod, SEXP optSlowMAType, SEXP optSignalPeriod, SEXP optSignalMAType);
SEXP impl_ta_MACDFIX(SEXP inReal, SEXP optSignalPeriod);
SEXP impl_ta_MACD(SEXP x, SEXP optFastPeriod, SEXP optSlowPeriod, SEXP optSignalPeriod);
SEXP impl_ta_MA(SEXP x, SEXP period, SEXP matype);
SEXP impl_ta_MFI(SEXP high, SEXP low, SEXP close, SEXP volume, SEXP timeperiod);
SEXP impl_ta_OBV(SEXP close, SEXP volume);
SEXP impl_ta_RSI(SEXP inReal, SEXP optTimePeriod);
SEXP impl_ta_SAREXT(SEXP high, SEXP low, SEXP start_value, SEXP offset_on_reverse, SEXP accel_init_long, SEXP accel_long, SEXP accel_max_long, SEXP accel_init_short, SEXP accel_short, SEXP accel_max_short);
SEXP impl_ta_SAR(SEXP high, SEXP low, SEXP acceleration, SEXP maximum);
SEXP impl_ta_STOCHF(SEXP high, SEXP low, SEXP close, SEXP fastk_period, SEXP fastd_period, SEXP fastd_matype);
SEXP impl_ta_STOCHRSI(SEXP real, SEXP timeperiod, SEXP fastk_period, SEXP fastd_period, SEXP fastd_matype);
SEXP impl_ta_STOCH(SEXP high, SEXP low, SEXP close, SEXP fastk_period, SEXP slowk_period, SEXP slowk_matype, SEXP slowd_period, SEXP slowd_matype);
SEXP impl_ta_ULTOSC(SEXP high, SEXP low, SEXP close, SEXP timeperiod1, SEXP timeperiod2, SEXP timeperiod3);
SEXP initialize_ta_lib(void);
SEXP shutdown_ta_lib(void);
// clang-format on

#endif //_API_H
