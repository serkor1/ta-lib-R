#include <R.h>
#include <R_ext/Rdynload.h>
#include <Rinternals.h>

/* Declaration of the wrapper */
#include "api.h"

static const R_CallMethodDef CallEntries[] = {
    {"c_average_price", (DL_FUNC)&c_average_price, 1},
    {"c_bollinger_bands", (DL_FUNC)&c_bollinger_bands, 5},
    {NULL, NULL, 0}};

void R_init_talib(DllInfo *dll) {
  R_registerRoutines(dll, NULL, CallEntries, NULL, NULL);
  R_useDynamicSymbols(dll, FALSE);
}
