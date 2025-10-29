// TA-Lib specific options
#include "lib.h"
#include "R_ext/Error.h"
#include "api.h"
#include "shift.h"
#include "ta_defs.h"
#include "ta_func.h"
#include <R.h>
#include <Rinternals.h>
#include <ta_libc.h>

// initialize TA-Lib
SEXP initialize_ta_lib() {
  TA_RetCode return_code = TA_Initialize();

  if (return_code != TA_SUCCESS) {
    Rf_error("TA_Initialize failed (code %d)", return_code);
  }

  return ScalarLogical(1);
}

// shutdown TA-Lib
SEXP shutdown_ta_lib() {
  TA_RetCode return_code = TA_Shutdown();

  if (return_code != TA_SUCCESS) {
    Rf_error("TA_Shutdown failed (code %d)", return_code);
  }

  return ScalarLogical(1);
}

// candlestick options
//
SEXP reset_candle_setting() {

  // reset all candle settings
  // clang-format off
  TA_RetCode return_code = TA_RestoreCandleDefaultSettings( TA_AllCandleSettings
  );
  // clang-format on

  // send a warning instead of error
  // to allow the interface some slack
  if (return_code != TA_SUCCESS) {
    Rf_warning("Candle settings failed (Code %d)", return_code);
  };

  return Rf_ScalarLogical(1);
};

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
  SEXP s_settingType, 
  SEXP s_rangeType,
  SEXP s_avgPeriod, 
  SEXP s_factor
) {
  // clang-format on

  // extract values to be passed
  // onto settings
  const TA_CandleSettingType settingType = INTEGER(s_settingType)[0];
  const int rangeType = INTEGER(s_rangeType)[0];
  const int avgPeriod = INTEGER(s_avgPeriod)[0];
  const TA_RangeType factor = REAL(s_factor)[0];

  // clang-format off
  TA_RetCode return_code = TA_SetCandleSettings(
    settingType, 
    rangeType, 
    avgPeriod, 
    factor
  );
  // clang-format on

  // send a warning instead of error
  // to allow the interface some slack
  if (return_code != TA_SUCCESS) {
    Rf_warning("Candle settings failed (Code %d)", return_code);
  };

  return Rf_ScalarLogical(1);
};