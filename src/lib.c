// TA-Lib specific options
//
#include "lib.h"
#include "shift.h"
#include <R.h>
#include <Rinternals.h>
#include <ta_libc.h>

// initialize TA-Lib
SEXP initialize_ta_lib() {
  TA_RetCode return_code = TA_Initialize();

  if (return_code != TA_SUCCESS) {
    Rf_error("TA_Initialize failed (code %d)", return_code);
  }

  TA_RestoreCandleDefaultSettings(TA_AllCandleSettings);

  return ScalarLogical(1);
}

// shutdown TA-Lib
SEXP shutdown_ta_lib() {
  TA_RetCode return_code = TA_Shutdown();

  if (return_code != TA_SUCCESS) {
    Rf_error("TA_Shutdown failed (code %d)", return_code);
  }

  return ScalarLogical(1);
}