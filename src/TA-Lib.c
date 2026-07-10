#include "ta_libc.h"
#include "talib_utils.h"
#include <Rinternals.h>

// Candle Settings
//
// Parameters
//
// settingType (int)
//  0: BodyLong, 1: BodyVeryLong, 2: BodyShort
//  3: BodyDoji, 4: ShadowVeryLong, 5: ShadowVeryLong
//  6: ShadowShort, 7: ShadowVeryShort, 8: Near,
//  9: Far, 10 Equal
//
// rangeType (int)
//  0: RealBody, 1: HighLow, 2: Shadows
//
// avgPeriod (int)
//  The number of candles to consider
//  in the identification of candles
//
// factor (double)
//  The factor determines how past candles are
//  weighed in the identification. Example:
//  If avgPeriod is 10, and factor is 0.1 then in,
//  for example, BodyDoji the body of the candle should be
//  shorter than 10% of the average of the 10 past candles.
//
//  From:
//    https://github.com/TA-Lib/ta-lib/blob/main/src/ta_common/ta_global.c#L117-L173
//
// clang-format off
SEXP set_candle_setting(
  SEXP settingType, 
  SEXP rangeType,
  SEXP avgPeriod, 
  SEXP factor
) {
  // clang-format on

  // clang-format off
  TA_RetCode return_code = TA_SetCandleSettings(
    (TA_CandleSettingType) Rf_asInteger(settingType), 
    (TA_RangeType) Rf_asInteger(rangeType), 
    (int) Rf_asInteger(avgPeriod), 
    (double) Rf_asReal(factor)
  );
  // clang-format on

  // send a warning instead of error
  // to allow the interface some slack
  if (return_code != TA_SUCCESS) {
    Rf_warning("Candle settings failed (Code %d)", return_code);
  }

  return Rf_ScalarLogical(1);
}

SEXP reset_candle_setting(void) {

  // reset all candle settings
  // clang-format off
  TA_RetCode return_code = TA_RestoreCandleDefaultSettings(
    TA_AllCandleSettings
  );
  // clang-format on

  // send a warning instead of error
  // to allow the interface some slack
  if (return_code != TA_SUCCESS) {
    Rf_warning("Candle settings failed (Code %d)", return_code);
  }

  return Rf_ScalarLogical(1);
}
// Candle settings end

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