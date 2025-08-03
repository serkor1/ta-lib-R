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

#endif // _LIB_H_