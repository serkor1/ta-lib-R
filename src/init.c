#include <R.h>
#include <R_ext/Rdynload.h>
#include <stdlib.h>

#include "api.h"

#define CALLDEF(name, n)  {#name, (DL_FUNC) &name, n}

static const R_CallMethodDef CallEntries[] = {
  CALLDEF(c_average_price, 1),
  CALLDEF(c_bollinger_bands, 5),
  {NULL, NULL, 0}
};
