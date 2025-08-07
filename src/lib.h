// lib.h
//
// Description
//    Common high-level TA-lib agnostic functionality
//    and other implementations
#ifndef _LIB_H_
#define _LIB_H_

// R Headers
#include <R.h>
#include <Rdefines.h>
#include <Rinternals.h>

// C Headers
#include "shift.h"
#include <string.h>

// Redifne integers to avoid
// R definition clashes
// clang-format off
#define Int32 TA_Lib_Int32
  #include <ta-lib/ta_libc.h>
#undef Int32
// clang-format on

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