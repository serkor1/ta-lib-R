/*

*/
#ifndef _LIB_H_
#define _LIB_H_

// R Headers
#include <R.h>
#include <Rdefines.h>
#include <Rinternals.h>

// C Headers
#include <string.h>

// Redifne integers to abvoid
// R definition clashes
#define Int32 TA_Lib_Int32
#include <ta-lib/ta_libc.h>
#undef Int32

static void ensure_ta_initialized(void) {
  static int inited = 0;
  if (!inited) {
    if (TA_Initialize() != TA_SUCCESS) {
      Rf_error("TA-Lib initialization failed.");
    }
    inited = 1;
  }
}

// maps strings to MA enums
//
// args
// x: string, character
static TA_MAType map_moving_average(const SEXP x) {

  // 1) check input validity
  //    on C-side instead of R side
  //    as this function will be used frequently
  //    across the library.
  //
  //    fallback: simple moving average
  if (x == R_NilValue || !isString(x) || LENGTH(x) < 1)
    return TA_MAType_SMA;

  // 2) map string to enum
  //    TODO: this might be better
  //    to implement as switch-statement
  const char *s = CHAR(STRING_ELT(x, 0));
  if (strcasecmp(s, "SMA") == 0)
    return TA_MAType_SMA;
  if (strcasecmp(s, "EMA") == 0)
    return TA_MAType_EMA;
  if (strcasecmp(s, "WMA") == 0)
    return TA_MAType_WMA;
  if (strcasecmp(s, "DEMA") == 0)
    return TA_MAType_DEMA;
  if (strcasecmp(s, "TEMA") == 0)
    return TA_MAType_TEMA;
  if (strcasecmp(s, "TRIMA") == 0)
    return TA_MAType_TRIMA;
  if (strcasecmp(s, "KAMA") == 0)
    return TA_MAType_KAMA;
  if (strcasecmp(s, "MAMA") == 0)
    return TA_MAType_MAMA;
  if (strcasecmp(s, "T3") == 0)
    return TA_MAType_T3;

  // 3) fallback: simple moving average
  return TA_MAType_SMA;
}

#endif // _LIB_H_