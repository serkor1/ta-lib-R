// init.c
//
// Description:
//    This is where TA-Lib.h is being ported to
//    R, and is the workhorse of the R package.
//
// Author: Serkan Korkmaz
#include "ta_libc.h"
#include "talib_utils.h"
#include "talib_wrap.h"
#include <R_ext/Rdynload.h>
#include <Rinternals.h>
#include <limits.h>

// forward declaration of all
// mined TA-Lib functions
#define TA_INDICATOR(...) TA_DECL(__VA_ARGS__)
#include "TA-Lib.h"
#undef TA_INDICATOR

// construct TA-Lib wrappers
#define TA_INDICATOR(...) TA_BODY(__VA_ARGS__)
#include "TA-Lib.h"
#undef TA_INDICATOR

/* global-setter wrappers (talib_globals.c) */
extern SEXP C_ta_set_unstable_period(SEXP, SEXP);
extern SEXP C_ta_set_compatibility(SEXP);
extern SEXP set_candle_setting(SEXP, SEXP, SEXP, SEXP);
extern SEXP reset_candle_setting(SEXP);

static const R_CallMethodDef CallEntries[] = {
#define TA_INDICATOR(...) TA_REG(__VA_ARGS__)
#include "TA-Lib.h"
#undef TA_INDICATOR
  {"ta_set_unstable_period", (DL_FUNC)&C_ta_set_unstable_period, 2},
  {"ta_set_compatibility", (DL_FUNC)&C_ta_set_compatibility, 1},
  {"set_candle_setting", (DL_FUNC)&set_candle_setting, 4},
  {"reset_candle_setting", (DL_FUNC)&reset_candle_setting, 1},
  {NULL, NULL, 0}};

// Initialize/Unload {talib}
//
// This section corresponds to zzz.R regarding load()/library()
// and unload() and it will initialize/shutdown TA-Lib when needed
//
//
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
