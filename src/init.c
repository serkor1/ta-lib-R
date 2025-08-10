// Generated from tools/generate_FFI.sh
#include <R.h>
#include <R_ext/Rdynload.h>
#include <stdlib.h>

#include "api.h"

// clang-format off
#define CALLDEF(name, n) {#name, (DL_FUNC) &name, n}
// clang-format on

static const R_CallMethodDef CallEntries[] = {
    CALLDEF(impl_ta_ACCBANDS, 4),
    CALLDEF(impl_ta_ADOSC, 6),
    CALLDEF(impl_ta_AD, 4),
    CALLDEF(impl_ta_APO, 4),
    CALLDEF(impl_ta_AROONOSC, 3),
    CALLDEF(impl_ta_AROON, 3),
    CALLDEF(impl_ta_BBANDS, 5),
    CALLDEF(impl_ta_CDLDOJI, 5),
    CALLDEF(impl_ta_CDLDOJISTAR, 5),
    CALLDEF(impl_ta_CDLDRAGONFLYDOJI, 5),
    CALLDEF(impl_ta_CDLEVENINGDOJISTAR, 6),
    CALLDEF(impl_ta_HT_DCPERIOD, 1),
    CALLDEF(impl_ta_HT_DCPHASE, 1),
    CALLDEF(impl_ta_HT_PHASOR, 1),
    CALLDEF(impl_ta_HT_SINE, 1),
    CALLDEF(impl_ta_HT_TRENDLINE, 1),
    CALLDEF(impl_ta_HT_TRENDMODE, 1),
    CALLDEF(impl_ta_MACDEXT, 7),
    CALLDEF(impl_ta_MACDFIX, 2),
    CALLDEF(impl_ta_MACD, 4),
    CALLDEF(impl_ta_MA, 3),
    CALLDEF(impl_ta_RSI, 2),
    CALLDEF(impl_ta_STOCHF, 6),
    CALLDEF(impl_ta_STOCHRSI, 5),
    CALLDEF(impl_ta_STOCH, 8),
    CALLDEF(impl_ta_ULTOSC, 6),
    {NULL, NULL, 0}};
