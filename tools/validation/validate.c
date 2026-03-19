// tools/validation/validate.c
//
// Bare TA-Lib C calls for validating the R package wrappers.
// NOT part of the CRAN package — compiled separately via R CMD SHLIB.
//
// Compile (from repo root):
//   PKG_CFLAGS="-Isrc/ta-lib/local/include -Isrc/ta-lib/local/include/ta-lib" \
//   PKG_LIBS="src/ta-lib/local/lib/libta-lib.a -lm" \
//   R CMD SHLIB tools/validation/validate.c
//
#include <R.h>
#include <Rinternals.h>
#include <ta_libc.h>

// build_result: create an n x ncol REALSXP matrix filled with NA,
// then copy each TA-Lib output column into the correct position.
// This is intentionally simple (no shift.h, no container.h) so
// it serves as an independent reference.
static SEXP build_result(
  int n,
  int ncol,
  int start_idx,
  int n_out,
  double **cols)
{
  SEXP result = PROTECT(allocMatrix(REALSXP, n, ncol));
  double *res = REAL(result);

  for (int i = 0; i < n * ncol; i++)
    res[i] = NA_REAL;

  for (int c = 0; c < ncol; c++) {
    double *dest = res + (size_t)c * n;
    for (int i = 0; i < n_out; i++)
      dest[start_idx + i] = cols[c][i];
  }

  UNPROTECT(1);
  return result;
}

// --- SMA (single input, single output) ---
SEXP validate_SMA(SEXP inReal, SEXP optInTimePeriod)
{
  int n = LENGTH(inReal);
  int period = INTEGER(optInTimePeriod)[0];
  double *out = (double *)R_alloc(n, sizeof(double));
  int si, ei;

  TA_RetCode rc =
    TA_MA(0, n - 1, REAL(inReal), period, TA_MAType_SMA, &si, &ei, out);
  if (rc != TA_SUCCESS)
    Rf_error("TA_MA(SMA) failed: %d", rc);

  double *cols[] = {out};
  return build_result(n, 1, si, ei - si + 1, cols);
}

// --- RSI (single input, single output, momentum) ---
SEXP validate_RSI(SEXP inReal, SEXP optInTimePeriod)
{
  int n = LENGTH(inReal);
  int period = INTEGER(optInTimePeriod)[0];
  double *out = (double *)R_alloc(n, sizeof(double));
  int si, ei;

  TA_RetCode rc = TA_RSI(0, n - 1, REAL(inReal), period, &si, &ei, out);
  if (rc != TA_SUCCESS)
    Rf_error("TA_RSI failed: %d", rc);

  double *cols[] = {out};
  return build_result(n, 1, si, ei - si + 1, cols);
}

// --- BBANDS (single input, 3 outputs) ---
SEXP validate_BBANDS(
  SEXP inReal,
  SEXP optInTimePeriod,
  SEXP optInNbDevUp,
  SEXP optInNbDevDn,
  SEXP optInMAType)
{
  int n = LENGTH(inReal);
  int period = INTEGER(optInTimePeriod)[0];
  double devup = REAL(optInNbDevUp)[0];
  double devdn = REAL(optInNbDevDn)[0];
  TA_MAType ma = (TA_MAType)INTEGER(optInMAType)[0];

  double *upper = (double *)R_alloc(n, sizeof(double));
  double *middle = (double *)R_alloc(n, sizeof(double));
  double *lower = (double *)R_alloc(n, sizeof(double));
  int si, ei;

  TA_RetCode rc = TA_BBANDS(
    0, n - 1, REAL(inReal), period, devup, devdn, ma, &si, &ei, upper, middle,
    lower);
  if (rc != TA_SUCCESS)
    Rf_error("TA_BBANDS failed: %d", rc);

  double *cols[] = {upper, middle, lower};
  return build_result(n, 3, si, ei - si + 1, cols);
}

// --- STOCHRSI (single input, 2 outputs) ---
// Calls TA_STOCHRSI directly on close prices.
// TA-Lib internally computes RSI then applies Stochastic.
SEXP validate_STOCHRSI(
  SEXP inReal,
  SEXP optInTimePeriod,
  SEXP optInFastK_Period,
  SEXP optInFastD_Period,
  SEXP optInFastD_MAType)
{
  int n = LENGTH(inReal);
  int period = INTEGER(optInTimePeriod)[0];
  int fastk = INTEGER(optInFastK_Period)[0];
  int fastd = INTEGER(optInFastD_Period)[0];
  TA_MAType ma = (TA_MAType)INTEGER(optInFastD_MAType)[0];

  double *outK = (double *)R_alloc(n, sizeof(double));
  double *outD = (double *)R_alloc(n, sizeof(double));
  int si, ei;

  TA_RetCode rc = TA_STOCHRSI(
    0, n - 1, REAL(inReal), period, fastk, fastd, ma, &si, &ei, outK, outD);
  if (rc != TA_SUCCESS)
    Rf_error("TA_STOCHRSI failed: %d", rc);

  double *cols[] = {outK, outD};
  return build_result(n, 2, si, ei - si + 1, cols);
}

// --- ATR (multi-input HLC, single output) ---
SEXP validate_ATR(
  SEXP inHigh,
  SEXP inLow,
  SEXP inClose,
  SEXP optInTimePeriod)
{
  int n = LENGTH(inHigh);
  int period = INTEGER(optInTimePeriod)[0];
  double *out = (double *)R_alloc(n, sizeof(double));
  int si, ei;

  TA_RetCode rc = TA_ATR(
    0, n - 1, REAL(inHigh), REAL(inLow), REAL(inClose), period, &si, &ei, out);
  if (rc != TA_SUCCESS)
    Rf_error("TA_ATR failed: %d", rc);

  double *cols[] = {out};
  return build_result(n, 1, si, ei - si + 1, cols);
}
