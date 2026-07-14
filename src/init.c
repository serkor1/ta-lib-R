// init.c
//
// Description:
//    This is where TA-Lib.h is being ported to
//    R, and is the workhorse of the R package.
//
// Author: Serkan Korkmaz
#include "ta_libc.h"
#include "talib_utils.h"
#include "wrapper.h"
#include <R_ext/Rdynload.h>
#include <Rinternals.h>
#include <limits.h>

// TA_DECL / TA_LB_DECL emit the forward declarations (prototypes) for the
// mined TA-Lib entry points. They reuse the argument-shape helpers from
// wrapper.h, so each prototype tracks its TA_WRAPPER-generated definition.
// clang-format off
#define TA_DECL(NAME, RT, INS_, OPTS_, OUTS_, TA_OUTPUT_NAME_, KIND)  \
      extern SEXP impl_ta_##NAME(                                     \
        TA_APPLY(TA_IN_ARG, INS_)                                     \
        TA_APPLY(TA_OPT_ARG, OPTS_)                                   \
        SEXP s_na_bridge                                              \
        TA_CAT(TA_NORM_ARG_, KIND)                                    \
      );
// clang-format on
#define TA_LB_DECL(NAME, OPTS_)                                                \
  extern SEXP impl_ta_##NAME##_lookback(TA_LB_PARAMS(OPTS_));

// forward declaration of all
// mined TA-Lib functions (indicator + lookback)
#define TA_INDICATOR(...) TA_DECL(__VA_ARGS__)
#define TA_LOOKBACK(...) TA_LB_DECL(__VA_ARGS__)
#include "TA-Lib.h"
#undef TA_INDICATOR
#undef TA_LOOKBACK

// construct TA-Lib wrappers (indicator + lookback)
#define TA_INDICATOR(...) TA_WRAPPER(__VA_ARGS__)
#define TA_LOOKBACK(...) TA_LB_WRAPPER(__VA_ARGS__)
#include "TA-Lib.h"
#undef TA_INDICATOR
#undef TA_LOOKBACK

/* trading-volume wrappers (volume.c) */
extern SEXP impl_ta_VOLUME(SEXP, SEXP, SEXP);
extern SEXP impl_ta_VOLUME_lookback(SEXP, SEXP);

/* global-setter wrappers (talib_globals.c) */
extern SEXP ta_set_unstable_period(SEXP, SEXP);
extern SEXP ta_set_compatibility(SEXP);
extern SEXP set_candle_setting(SEXP, SEXP, SEXP, SEXP);
extern SEXP reset_candle_setting(SEXP);
extern SEXP initialize_ta_lib(void);
extern SEXP map_dfr_double(SEXP);
extern SEXP map_dfr_integer(SEXP);
extern SEXP shutdown_ta_lib(void);

// TA_REG / TA_LB_REG emit the R_CallMethodDef rows. Arity is derived from the
// same TA_COUNT_ARGUMENTS / TA_NORM_ARITY helpers the wrapper signature uses:
//   indicator = #inputs + #opts + 1 (na_bridge) + candlestick normalize arg
//   lookback  = #opts
// The registration STRING (not the C symbol) is what R names the routine:
// with useDynLib(.fixes = "C_"), R exposes C_ + this string, matching the
// generated .Call(C_impl_ta_<NAME>, ...).
#define TA_REG(NAME, RT, INS_, OPTS_, OUTS_, TA_OUTPUT_NAME_, KIND)            \
  {"impl_ta_" #NAME,                                                           \
   (DL_FUNC) & impl_ta_##NAME,                                                 \
   (TA_COUNT_ARGUMENTS INS_) + (TA_COUNT_ARGUMENTS OPTS_) + 1 +                \
     TA_CAT(TA_NORM_ARITY_, KIND)},
#define TA_LB_REG(NAME, OPTS_)                                                 \
  {"impl_ta_" #NAME "_lookback",                                               \
   (DL_FUNC) & impl_ta_##NAME##_lookback,                                      \
   TA_COUNT_ARGUMENTS OPTS_},

static const R_CallMethodDef CallEntries[] = {
#define TA_INDICATOR(...) TA_REG(__VA_ARGS__)
#define TA_LOOKBACK(...) TA_LB_REG(__VA_ARGS__)
#include "TA-Lib.h"
#undef TA_INDICATOR
#undef TA_LOOKBACK
  {"impl_ta_VOLUME", (DL_FUNC)&impl_ta_VOLUME, 3},
  {"impl_ta_VOLUME_lookback", (DL_FUNC)&impl_ta_VOLUME_lookback, 2},
  {"ta_set_unstable_period", (DL_FUNC)&ta_set_unstable_period, 2},
  {"ta_set_compatibility", (DL_FUNC)&ta_set_compatibility, 1},
  {"set_candle_setting", (DL_FUNC)&set_candle_setting, 4},
  {"reset_candle_setting", (DL_FUNC)&reset_candle_setting, 1},
  {"rownames_data_frame", (DL_FUNC)&rownames_data_frame, 2},
  {"rownames_matrix", (DL_FUNC)&rownames_matrix, 3},
  {"map_dfr_double", (DL_FUNC)&map_dfr_double, 1},
  {"map_dfr_integer", (DL_FUNC)&map_dfr_integer, 1},
  {"initialize_ta_lib", (DL_FUNC)&initialize_ta_lib, 0},
  {"shutdown_ta_lib", (DL_FUNC)&shutdown_ta_lib, 0},
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
