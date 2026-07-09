#include "ta_libc.h"
#include "talib_utils.h"
#include <Rinternals.h> /* SEXP API; NOT R.h (Random.h Int32 clashes with TA-Lib) */

SEXP C_ta_set_unstable_period(SEXP s_id, SEXP s_period) {
  ta_check(
    TA_SetUnstablePeriod(
      (TA_FuncUnstId)Rf_asInteger(s_id),
      (unsigned int)Rf_asInteger(s_period)),
    "TA_SetUnstablePeriod");
  return R_NilValue;
}

SEXP C_ta_set_compatibility(SEXP s_value) {
  ta_check(
    TA_SetCompatibility((TA_Compatibility)Rf_asInteger(s_value)),
    "TA_SetCompatibility");
  return R_NilValue;
}

SEXP C_ta_set_candle_settings(
  SEXP s_type, SEXP s_range, SEXP s_avg, SEXP s_factor) {
  ta_check(
    TA_SetCandleSettings(
      (TA_CandleSettingType)Rf_asInteger(s_type),
      (TA_RangeType)Rf_asInteger(s_range),
      Rf_asInteger(s_avg),
      Rf_asReal(s_factor)),
    "TA_SetCandleSettings");
  return R_NilValue;
}

SEXP C_ta_restore_candle_defaults(SEXP s_type) {
  ta_check(
    TA_RestoreCandleDefaultSettings((TA_CandleSettingType)Rf_asInteger(s_type)),
    "TA_RestoreCandleDefaultSettings");
  return R_NilValue;
}
