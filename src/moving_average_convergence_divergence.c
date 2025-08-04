#include "lib.h"

SEXP c_moving_average_convergence_divergence(SEXP x, SEXP fastPeriod,
                                             SEXP slowPeriod,
                                             SEXP signalPeriod) {
  const int fastP = asInteger(fastPeriod);
  const int slowP = asInteger(slowPeriod);
  const int signalP = asInteger(signalPeriod);
  const int len = length(x);
  const double *__restrict__ inReal = REAL(x);

  int outBegIdx = 0, outNBElement = 0;

  // TA-LIB output scratch buffers (max size len)
  double *__restrict__ outMACD = (double *)R_alloc((size_t)len, sizeof(double));
  double *__restrict__ outSignal =
      (double *)R_alloc((size_t)len, sizeof(double));
  double *__restrict__ outHistogram =
      (double *)R_alloc((size_t)len, sizeof(double));

  // Call TA-LIB MACD: full range
  TA_RetCode ret =
      TA_MACD(0, len - 1, inReal, fastP, slowP, signalP, &outBegIdx,
              &outNBElement, outMACD, outSignal, outHistogram);

  // Prepare R output objects: three REALSXP vectors of length len
  SEXP macd_vec = PROTECT(allocVector(REALSXP, len));
  SEXP signal_vec = PROTECT(allocVector(REALSXP, len));
  SEXP hist_vec = PROTECT(allocVector(REALSXP, len));

  double *macd_d = REAL(macd_vec);
  double *signal_d = REAL(signal_vec);
  double *hist_d = REAL(hist_vec);

  // Initialize all to NA (covers lookback + error cases)
  for (int i = 0; i < len; ++i) {
    macd_d[i] = NA_REAL;
    signal_d[i] = NA_REAL;
    hist_d[i] = NA_REAL;
  }

  if (ret == TA_SUCCESS && outNBElement > 0) {
    // Copy computed outputs into place, respecting outBegIdx
    memcpy(macd_d + outBegIdx, outMACD, (size_t)outNBElement * sizeof(double));
    memcpy(signal_d + outBegIdx, outSignal,
           (size_t)outNBElement * sizeof(double));
    memcpy(hist_d + outBegIdx, outHistogram,
           (size_t)outNBElement * sizeof(double));
  }

  // Bundle into a named list: list(macd=..., signal=..., hist=...)
  SEXP ans = PROTECT(allocVector(VECSXP, 3));
  SET_VECTOR_ELT(ans, 0, macd_vec);
  SET_VECTOR_ELT(ans, 1, signal_vec);
  SET_VECTOR_ELT(ans, 2, hist_vec);

  // Set names
  SEXP names = PROTECT(allocVector(STRSXP, 3));
  SET_STRING_ELT(names, 0, mkChar("macd"));
  SET_STRING_ELT(names, 1, mkChar("signal"));
  SET_STRING_ELT(names, 2, mkChar("hist"));
  setAttrib(ans, R_NamesSymbol, names);

  UNPROTECT(5); // macd_vec, signal_vec, hist_vec, ans, names
  return ans;
}