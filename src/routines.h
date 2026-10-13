// routines.h
//
// Description:
//    Prototypes for the hand-written .Call() entry points registered
//    in init.c. Each defining file includes this header, so a signature
//    that drifts from its declaration fails to compile.
//
#ifndef ROUTINES_H
#define ROUTINES_H

#include <Rinternals.h>

// volume.c
SEXP impl_ta_VOLUME(SEXP inReal, SEXP maSpec, SEXP na_bridge);
SEXP impl_ta_VOLUME_lookback(SEXP maSpec);

// TA-Lib.c
SEXP set_candle_setting(
  SEXP settingType, SEXP rangeType, SEXP avgPeriod, SEXP factor);
SEXP reset_candle_setting(void);
SEXP ta_set_unstable_period(SEXP s_id, SEXP s_period);
SEXP ta_set_compatibility(SEXP s_value);
SEXP initialize_ta_lib(void);
SEXP shutdown_ta_lib(void);

// data-frame.c
SEXP map_dfr_double(SEXP x);
SEXP map_dfr_integer(SEXP x);

#endif /* ROUTINES_H */
