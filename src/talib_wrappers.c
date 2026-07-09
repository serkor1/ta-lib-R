#include "ta_libc.h" /* TA_* prototypes, TA_RetCode, TA_MAType */
#include "talib_utils.h"
#include "talib_wrap.h"
#include <Rinternals.h> /* SEXP API; NOT R.h (its Random.h clashes with TA-Lib's Int32) */
#include <limits.h> /* INT_MAX */

/* Emit one SEXP C_<NAME>(...) definition per row. */
#define TA_INDICATOR(...) TA_BODY(__VA_ARGS__)
#include "TA-Lib.h"
#undef TA_INDICATOR