// Interface to TA_MACDEXT (MACD with controllable MA types)
//
// Parameters
//   x               : numeric vector
//   fast_period     : integer (>= 2)
//   fast_matype     : integer MAType
//   slow_period     : integer (>= 2)
//   slow_matype     : integer MAType
//   signal_period   : integer (>= 1)
//   signal_matype   : integer MAType
//
// Description
//   Computes MACD, signal, and histogram using configurable MA types.
//   Returns an n × 3 REAL matrix with columns "macd","signal","hist",
//   padded with NA_REAL up to the first valid output (lookback).
//
// Notes
//   - Input validation beyond lookback is handled on the R side.
//   - Uses in-place shifting to align outputs to length n.

#include "MAType.h"
#include "R_ext/Arith.h"
#include "R_ext/Error.h"
#include "Rinternals.h"
#include "lib.h"
#include "names.h"
#include "shift.h"
#include "ta_func.h"
#include <ta_libc.h>

// clang-format off
SEXP impl_ta_MACDEXT(
  SEXP x,
  SEXP fast_period,
  SEXP fast_matype,
  SEXP slow_period,
  SEXP slow_matype,
  SEXP signal_period,
  SEXP signal_matype) {
  // clang-format on

  int protect_count = 0;

  // input
  const int n = LENGTH(x);
  const double *restrict x_ptr = REAL(x);

  const int fastP = INTEGER(fast_period)[0];
  const int slowP = INTEGER(slow_period)[0];
  const int signalP = INTEGER(signal_period)[0];

  const TA_MAType fastT = as_MAType(fast_matype);
  const TA_MAType slowT = as_MAType(slow_matype);
  const TA_MAType signalT = as_MAType(signal_matype);

  // output matrix: n x 3 (macd, signal, hist)
  SEXP res = PROTECT(allocMatrix(REALSXP, n, 3));
  protect_count++;
  double *restrict macd = REAL(res);
  double *restrict signal = macd + n;
  double *restrict hist = macd + 2 * n;

  // clang-format off
  const int minimum_lookback = TA_MACDEXT_Lookback(
    fastP,
    fastT, 
    slowP, 
    slowT, 
    signalP, 
    signalT
  );
  // clang-format on

  if (n < minimum_lookback) {
    Rf_warning("Input length (%d) is smaller than required lookback (%d).", n,
               minimum_lookback);
    for (int i = 0; i < n; ++i) {
      macd[i] = signal[i] = hist[i] = NA_REAL;
    }
  } else {
    int outBeg = 0, outNb = 0;
    // clang-format off
    TA_RetCode return_code = TA_MACDEXT(
      /*startIdx*/ 0,
      /*endIdx  */ n - 1,
      /*inReal  */ x_ptr,
      /*fast    */ fastP, fastT,
      /*slow    */ slowP, slowT,
      /*signal  */ signalP, signalT,
      /*out     */ &outBeg, &outNb, macd, signal, hist
    );
    // clang-format on

    if (return_code != TA_SUCCESS) {
      UNPROTECT(protect_count);
      Rf_error("TA_MACDEXT failed: return code %d", return_code);
    }

    // align to length n
    shift_array(macd, n, outBeg);
    shift_array(signal, n, outBeg);
    shift_array(hist, n, outBeg);
  }

  // set column names
  // clang-format off
  set_colnames(
    res, 
    "macd", 
    "signal",
    "histogram"
  );
  // clang-format on

  UNPROTECT(protect_count);
  return res;
}
