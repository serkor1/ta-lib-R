#include <R.h>
#include <R_ext/Rdynload.h>
#include <stdlib.h>

#include "api.h"

#define CALLDEF(name, n)  {#name, (DL_FUNC) &name, n}

static const R_CallMethodDef CallEntries[] = {
  CALLDEF(c_bollinger_bands, 5),
  CALLDEF(c_cdl3blackcrows, 4),
  CALLDEF(c_commodity_channel_index, 4),
  CALLDEF(c_kaufman_adaptive_moving_average, 2),
  CALLDEF(c_median_price, 1),
  CALLDEF(c_moving_average_convergence_divergence, 4),
  CALLDEF(c_weighted_moving_average, 2),
  CALLDEF(impl_MIDPRICE, 2),
  CALLDEF(impl_ta_ACCBANDS, 4),
  CALLDEF(impl_ta_APO, 4),
  CALLDEF(impl_ta_AROONOSC, 3),
  CALLDEF(impl_ta_AROON, 3),
  CALLDEF(impl_TA_AVGPRICE, 1),
  CALLDEF(impl_ta_BBANDS, 5),
  CALLDEF(impl_ta_MACD, 4),
  CALLDEF(impl_ta_RSI, 2),
  {NULL, NULL, 0}
};
