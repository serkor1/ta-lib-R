#include "ta_libc.h"
#include "talib_wrap.h"
#include <R_ext/Rdynload.h>
#include <Rinternals.h> /* SEXP API; NOT R.h (Random.h Int32 clashes with TA-Lib) */

/* forward-declare every indicator wrapper */
#define TA_INDICATOR(...) TA_DECL(__VA_ARGS__)
#include "TA-Lib.h"
#undef TA_INDICATOR

/* global-setter wrappers (talib_globals.c) */
extern SEXP C_ta_set_unstable_period(SEXP, SEXP);
extern SEXP C_ta_set_compatibility(SEXP);
extern SEXP C_ta_set_candle_settings(SEXP, SEXP, SEXP, SEXP);
extern SEXP C_ta_restore_candle_defaults(SEXP);

static const R_CallMethodDef CallEntries[] = {
#define TA_INDICATOR(...) TA_REG(__VA_ARGS__)
#include "TA-Lib.h"
#undef TA_INDICATOR
  {"ta_set_unstable_period", (DL_FUNC)&C_ta_set_unstable_period, 2},
  {"ta_set_compatibility", (DL_FUNC)&C_ta_set_compatibility, 1},
  {"ta_set_candle_settings", (DL_FUNC)&C_ta_set_candle_settings, 4},
  {"ta_restore_candle_defaults", (DL_FUNC)&C_ta_restore_candle_defaults, 1},
  {NULL, NULL, 0}};

/* Package name is `talib`. Rename R_init_talib / R_unload_talib to match the
   R package's DLL name if it differs. */
void R_init_talib(DllInfo *dll) {

  if (TA_Initialize() != TA_SUCCESS) {
    Rf_error("TA_Initialize() failed");
  }

  R_registerRoutines(dll, NULL, CallEntries, NULL, NULL);
  R_useDynamicSymbols(dll, FALSE);
  R_forceSymbols(dll, TRUE);
}

void R_unload_talib(DllInfo *dll) {
  (void)dll;
  TA_Shutdown();
}
