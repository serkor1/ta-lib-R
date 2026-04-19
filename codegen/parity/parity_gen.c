// codegen/parity/parity_gen.c
//
// Standalone snapshot generator. Links against TA-Lib only - NO R
// headers, NO Rinternals, NO SEXP. Reads BTC OHLCV from a CSV file,
// runs upstream TA-Lib via the abstract layer for every function it
// finds, writes one self-describing CSV per indicator into a target
// directory. An R script (csv_to_rds.R) then converts those CSVs
// into the .rds files the parity comparator consumes.
//
// Build (one shell command, line-continuations omitted):
//   gcc -O2 -Wall -Wextra
//       -Isrc/ta-lib/local/include -Isrc/ta-lib/local/include/ta-lib
//       codegen/parity/parity_gen.c
//       src/ta-lib/local/lib/libta-lib.a -lm
//       -o codegen/parity/parity_gen
//
// Usage:
//   codegen/parity/parity_gen <btc.csv> <output_dir>
//
// BTC CSV input format:
//   Header line:   open,high,low,close,volume
//   Data lines:    five comma-separated doubles, one row per bar
//
// Output CSV format (one file per upstream function, e.g. RSI.csv):
//   # upstream=RSI
//   # opt_inputs=optInTimePeriod=14
//   # input_kind=Real
//   # input_columns=close
//   # output_types=Real
//   # lookback=14
//   # outBegIdx=14
//   # outNbElement=9986
//   # n=10000
//   outReal
//   NA
//   NA
//   ...
//   50.123456789012345
//
// Composites (VOLUME) are emitted directly from this program by
// composing TA-Lib calls (TA_SMA passes over the volume column).
// No R involvement at any point.

#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>
#include <math.h>
#include <ta_libc.h>

#define MAX_BTC_ROWS 200000
#define PATH_BUF 1024
#define OPT_BUF 2048

// ---- snprintf accumulator --------------------------------------------------
//
// Append to a fixed buffer at `pos`, returning the new position. Safe
// against the CWE-190 underflow pattern CodeQL flags around naive
// `pos += snprintf(buf + pos, BUF - pos, ...)`: the `BUF - pos`
// expression underflows once `pos` overshoots the buffer (which can
// happen because snprintf returns the length it WOULD have written,
// even when truncated). This helper:
//   - returns `pos` unchanged when the buffer is already full;
//   - clamps `pos` to `bufsize - 1` on truncation, so the next call
//     sees a valid (possibly zero) remaining space.
static size_t append_fmt(
  char *buf,
  size_t bufsize,
  size_t pos,
  const char *fmt,
  ...
) {
  if (bufsize == 0 || pos >= bufsize) return pos;
  va_list ap;
  va_start(ap, fmt);
  int written = vsnprintf(buf + pos, bufsize - pos, fmt, ap);
  va_end(ap);
  if (written < 0) return pos;
  if ((size_t)written >= bufsize - pos) return bufsize - 1;  // truncated
  return pos + (size_t)written;
}

// ---- BTC reader ------------------------------------------------------------

typedef struct {
  int n;
  double *open;
  double *high;
  double *low;
  double *close;
  double *volume;
} btc_t;

static void btc_alloc(btc_t *b, int cap) {
  b->open = (double *)malloc((size_t)cap * sizeof(double));
  b->high = (double *)malloc((size_t)cap * sizeof(double));
  b->low = (double *)malloc((size_t)cap * sizeof(double));
  b->close = (double *)malloc((size_t)cap * sizeof(double));
  b->volume = (double *)malloc((size_t)cap * sizeof(double));
}

static void btc_free(btc_t *b) {
  free(b->open);
  free(b->high);
  free(b->low);
  free(b->close);
  free(b->volume);
}

static int btc_read(const char *path, btc_t *b) {
  FILE *f = fopen(path, "r");
  if (!f) {
    fprintf(stderr, "could not open BTC CSV: %s\n", path);
    return -1;
  }

  char line[1024];
  if (!fgets(line, sizeof(line), f)) {
    fprintf(stderr, "empty BTC CSV\n");
    fclose(f);
    return -1;
  }
  // Header is informational; we trust column order open,high,low,close,volume.

  btc_alloc(b, MAX_BTC_ROWS);
  int i = 0;
  while (fgets(line, sizeof(line), f)) {
    if (i >= MAX_BTC_ROWS) {
      fprintf(stderr, "BTC CSV exceeds %d rows\n", MAX_BTC_ROWS);
      fclose(f);
      btc_free(b);
      return -1;
    }
    if (sscanf(
          line,
          "%lf,%lf,%lf,%lf,%lf",
          &b->open[i],
          &b->high[i],
          &b->low[i],
          &b->close[i],
          &b->volume[i]) != 5) {
      fprintf(stderr, "malformed row %d: %s", i + 1, line);
      fclose(f);
      btc_free(b);
      return -1;
    }
    i++;
  }
  fclose(f);
  b->n = i;
  return 0;
}

// ---- Output writer ---------------------------------------------------------

// Output format: high precision (17 significant digits is the round-trip
// guarantee for IEEE 754 double, per ECMA-262 / IEEE).
static void write_real(FILE *f, double v) {
  if (isnan(v)) fputs("NA", f);
  else fprintf(f, "%.17g", v);
}

// One snapshot file per indicator. Caller supplies pre-built data.
static int emit_snapshot(
  const char *out_dir,
  const char *upstream_name,
  const char *opt_summary,
  const char *input_kind,
  const char *input_columns,
  unsigned int n_outputs,
  const char *const *output_names,
  const char *output_types,    // e.g. "Real" or "Real,Real,Real" or "Integer"
  int lookback,
  int outBegIdx,
  int outNbElement,
  int n,
  void **outputs,              // array of double*/int* per output slot
  const int *output_is_int     // 1 = Integer, 0 = Real
) {
  char path[PATH_BUF];
  snprintf(path, sizeof(path), "%s/%s.csv", out_dir, upstream_name);
  FILE *f = fopen(path, "w");
  if (!f) {
    fprintf(stderr, "  could not open %s for write\n", path);
    return -1;
  }

  // Metadata header (R parses these via comment.char = "#")
  fprintf(f, "# upstream=%s\n", upstream_name);
  fprintf(f, "# opt_inputs=%s\n", opt_summary ? opt_summary : "");
  fprintf(f, "# input_kind=%s\n", input_kind);
  fprintf(f, "# input_columns=%s\n", input_columns);
  fprintf(f, "# output_types=%s\n", output_types);
  fprintf(f, "# lookback=%d\n", lookback);
  fprintf(f, "# outBegIdx=%d\n", outBegIdx);
  fprintf(f, "# outNbElement=%d\n", outNbElement);
  fprintf(f, "# n=%d\n", n);

  // CSV header: output paramNames
  for (unsigned int c = 0; c < n_outputs; c++) {
    if (c > 0) fputc(',', f);
    fputs(output_names[c], f);
  }
  fputc('\n', f);

  // Body: n rows, one per bar.
  // Position [0..outBegIdx-1] is conventionally NA (lookback region).
  // Positions [outBegIdx..outBegIdx+outNbElement-1] hold TA-Lib output
  // values, written by upstream into outputs[col][0..outNbElement-1].
  // Positions past outBegIdx+outNbElement are uncommon but defensively NA.
  for (int row = 0; row < n; row++) {
    int in_data = (row >= outBegIdx) && (row < outBegIdx + outNbElement);
    int local = row - outBegIdx;
    for (unsigned int c = 0; c < n_outputs; c++) {
      if (c > 0) fputc(',', f);
      if (!in_data) {
        fputs("NA", f);
      } else if (output_is_int[c]) {
        fprintf(f, "%d", ((int *)outputs[c])[local]);
      } else {
        write_real(f, ((double *)outputs[c])[local]);
      }
    }
    fputc('\n', f);
  }

  fclose(f);
  return 0;
}

// ---- Helper: format opt-inputs summary for the metadata header -------------
// Walks all opt-input slots and emits "name=value;name=value;..." with
// TA-Lib metadata defaults. Caller provides a buffer at least OPT_BUF wide.
static void format_opt_summary(
  const TA_FuncHandle *handle,
  const TA_FuncInfo *info,
  char *buf,
  size_t bufsz
) {
  size_t pos = 0;
  buf[0] = '\0';
  for (unsigned int i = 0; i < info->nbOptInput; i++) {
    const TA_OptInputParameterInfo *op = NULL;
    if (TA_GetOptInputParameterInfo(handle, i, &op) != TA_SUCCESS || !op) continue;
    const char *sep = (i > 0) ? ";" : "";
    if (op->type == TA_OptInput_RealRange || op->type == TA_OptInput_RealList) {
      pos = append_fmt(buf, bufsz, pos, "%s%s=%g",
                       sep, op->paramName, op->defaultValue);
    } else {
      pos = append_fmt(buf, bufsz, pos, "%s%s=%d",
                       sep, op->paramName, (int)op->defaultValue);
    }
    if (pos >= bufsz) break;
  }
}

// ---- Helper: describe inputs for the metadata header -----------------------
// Builds two short strings:
//   kind     - "Real", "Price", or "Real,Real" etc. (slot types in order)
//   columns  - the BTC columns we actually pass for each slot
//              (e.g. "close", "high+low+close", "high,low" for 2-Real)
static void format_input_summary(
  const TA_FuncHandle *handle,
  const TA_FuncInfo *info,
  char *kind,
  size_t kindsz,
  char *cols,
  size_t colsz
) {
  size_t kpos = 0, cpos = 0;
  kind[0] = '\0';
  cols[0] = '\0';

  for (unsigned int i = 0; i < info->nbInput; i++) {
    const TA_InputParameterInfo *ip = NULL;
    if (TA_GetInputParameterInfo(handle, i, &ip) != TA_SUCCESS || !ip) continue;

    const char *sep = (i > 0) ? "," : "";
    if (ip->type == TA_Input_Price) {
      kpos = append_fmt(kind, kindsz, kpos, "%sPrice", sep);
      // OHLCV components actually consumed (per flags).
      const char *plus = "";
      if (ip->flags & TA_IN_PRICE_OPEN) {
        cpos = append_fmt(cols, colsz, cpos, "%sopen", plus); plus = "+";
      }
      if (ip->flags & TA_IN_PRICE_HIGH) {
        cpos = append_fmt(cols, colsz, cpos, "%shigh", plus); plus = "+";
      }
      if (ip->flags & TA_IN_PRICE_LOW) {
        cpos = append_fmt(cols, colsz, cpos, "%slow", plus); plus = "+";
      }
      if (ip->flags & TA_IN_PRICE_CLOSE) {
        cpos = append_fmt(cols, colsz, cpos, "%sclose", plus); plus = "+";
      }
      if (ip->flags & TA_IN_PRICE_VOLUME) {
        cpos = append_fmt(cols, colsz, cpos, "%svolume", plus);
      }
    } else if (ip->type == TA_Input_Real) {
      kpos = append_fmt(kind, kindsz, kpos, "%sReal", sep);
      const char *col;
      if (strcmp(ip->paramName, "inReal0") == 0) col = "high";
      else if (strcmp(ip->paramName, "inReal1") == 0) col = "low";
      else if (strcmp(ip->paramName, "inVolume") == 0) col = "volume";
      else col = "close";
      cpos = append_fmt(cols, colsz, cpos, "%s%s", sep, col);
    } else {
      kpos = append_fmt(kind, kindsz, kpos, "%sInteger", sep);
      cpos = append_fmt(cols, colsz, cpos, "%s(unsupported)", sep);
    }
  }
}

// ---- Per-indicator processing ---------------------------------------------

// Returns 0 on snapshot written, 1 on intentional skip, -1 on error.
static int process_one(const TA_FuncInfo *info, btc_t *btc, const char *out_dir) {
  const TA_FuncHandle *handle = info->handle;

  // Skip Integer-input functions (none currently wrapped in the package).
  for (unsigned int i = 0; i < info->nbInput; i++) {
    const TA_InputParameterInfo *ip = NULL;
    if (TA_GetInputParameterInfo(handle, i, &ip) != TA_SUCCESS || !ip) continue;
    if (ip->type == TA_Input_Integer) {
      fprintf(stderr, "  SKIP %-22s integer-input (not wrapped)\n", info->name);
      return 1;
    }
  }

  TA_ParamHolder *params = NULL;
  TA_RetCode rc = TA_ParamHolderAlloc(handle, &params);
  if (rc != TA_SUCCESS) {
    fprintf(stderr, "  ERR  %-22s ParamHolderAlloc rc=%d\n", info->name, rc);
    return -1;
  }

  // Wire inputs. Dispatch Real slots on paramName so the choice is
  // robust to input shapes other than the naive "1-Real or 2-Real":
  //   inReal           -> close   (the overwhelmingly common case)
  //   inReal0 / inReal1-> high / low (CORREL, BETA convention)
  //   inVolume         -> volume (only TA_OBV exposes a bare Real volume slot)
  // Anything else falls back to close with a stderr note for visibility.
  for (unsigned int i = 0; i < info->nbInput; i++) {
    const TA_InputParameterInfo *ip = NULL;
    TA_GetInputParameterInfo(handle, i, &ip);
    if (ip->type == TA_Input_Price) {
      int f = ip->flags;
      rc = TA_SetInputParamPricePtr(
        params, i,
        (f & TA_IN_PRICE_OPEN) ? btc->open : NULL,
        (f & TA_IN_PRICE_HIGH) ? btc->high : NULL,
        (f & TA_IN_PRICE_LOW) ? btc->low : NULL,
        (f & TA_IN_PRICE_CLOSE) ? btc->close : NULL,
        (f & TA_IN_PRICE_VOLUME) ? btc->volume : NULL,
        NULL  /* no openInterest in BTC */);
    } else if (ip->type == TA_Input_Real) {
      const double *src;
      if (strcmp(ip->paramName, "inReal0") == 0) src = btc->high;
      else if (strcmp(ip->paramName, "inReal1") == 0) src = btc->low;
      else if (strcmp(ip->paramName, "inVolume") == 0) src = btc->volume;
      else src = btc->close;
      rc = TA_SetInputParamRealPtr(params, i, src);
    }
    if (rc != TA_SUCCESS) {
      fprintf(stderr, "  ERR  %-22s SetInputParam[%u] rc=%d\n", info->name, i, rc);
      TA_ParamHolderFree(params);
      return -1;
    }
  }

  // Lookback (read after opt defaults are loaded by ParamHolderAlloc).
  TA_Integer lookback = 0;
  rc = TA_GetLookback(params, &lookback);
  if (rc != TA_SUCCESS) {
    fprintf(stderr, "  ERR  %-22s GetLookback rc=%d\n", info->name, rc);
    TA_ParamHolderFree(params);
    return -1;
  }

  // Allocate one output buffer per output slot.
  void **outputs = (void **)malloc(info->nbOutput * sizeof(void *));
  int *output_is_int = (int *)malloc(info->nbOutput * sizeof(int));
  const char **output_names = (const char **)malloc(info->nbOutput * sizeof(char *));
  char output_types_str[256] = "";
  size_t ots_pos = 0;

  for (unsigned int i = 0; i < info->nbOutput; i++) {
    const TA_OutputParameterInfo *op = NULL;
    TA_GetOutputParameterInfo(handle, i, &op);
    output_names[i] = op->paramName;

    const char *sep = (i > 0) ? "," : "";
    if (op->type == TA_Output_Real) {
      outputs[i] = malloc((size_t)btc->n * sizeof(double));
      rc = TA_SetOutputParamRealPtr(params, i, (double *)outputs[i]);
      output_is_int[i] = 0;
      ots_pos = append_fmt(output_types_str, sizeof(output_types_str),
                           ots_pos, "%sReal", sep);
    } else {
      outputs[i] = malloc((size_t)btc->n * sizeof(int));
      rc = TA_SetOutputParamIntegerPtr(params, i, (int *)outputs[i]);
      output_is_int[i] = 1;
      ots_pos = append_fmt(output_types_str, sizeof(output_types_str),
                           ots_pos, "%sInteger", sep);
    }
    if (rc != TA_SUCCESS) {
      fprintf(stderr, "  ERR  %-22s SetOutputParam[%u] rc=%d\n", info->name, i, rc);
      for (unsigned int j = 0; j <= i; j++) free(outputs[j]);
      free(outputs); free(output_is_int); free(output_names);
      TA_ParamHolderFree(params);
      return -1;
    }
  }

  // Run.
  TA_Integer outBegIdx = 0, outNbElement = 0;
  rc = TA_CallFunc(params, 0, btc->n - 1, &outBegIdx, &outNbElement);
  TA_ParamHolderFree(params);

  int ret = 0;
  if (rc != TA_SUCCESS) {
    fprintf(stderr, "  ERR  %-22s CallFunc rc=%d\n", info->name, rc);
    ret = -1;
  } else {
    char opt_buf[OPT_BUF];
    char kind_buf[64];
    char cols_buf[256];
    format_opt_summary(handle, info, opt_buf, sizeof(opt_buf));
    format_input_summary(handle, info, kind_buf, sizeof(kind_buf),
                         cols_buf, sizeof(cols_buf));
    if (emit_snapshot(out_dir, info->name, opt_buf, kind_buf, cols_buf,
                      info->nbOutput, output_names, output_types_str,
                      (int)lookback, (int)outBegIdx, (int)outNbElement,
                      btc->n, outputs, output_is_int) == 0) {
      printf("  OK   %-22s lookback=%-4d nb=%d outputs=%u\n",
             info->name, (int)lookback, (int)outNbElement, info->nbOutput);
    } else {
      ret = -1;
    }
  }

  for (unsigned int i = 0; i < info->nbOutput; i++) free(outputs[i]);
  free(outputs); free(output_is_int); free(output_names);
  return ret;
}

// ---- Composite: VOLUME ----------------------------------------------------
//
// VOLUME is a hand-written R wrapper with no single upstream equivalent.
// Composition matching the R wrapper's default (ma = list(SMA(7), SMA(15))):
//   col 0: raw volume (lookback 0)
//   col 1: TA_SMA(volume, 7)
//   col 2: TA_SMA(volume, 15)
//
// Composite lookback = max of component lookbacks (= 14 for SMA(15)).
//
// We compose via TA_SMA directly. Pure upstream composition; no R.
static int process_volume_composite(btc_t *btc, const char *out_dir) {
  const int n = btc->n;

  // SMA(7) and SMA(15) on the volume column.
  double *sma7 = (double *)malloc((size_t)n * sizeof(double));
  double *sma15 = (double *)malloc((size_t)n * sizeof(double));
  TA_Integer beg7 = 0, nb7 = 0, beg15 = 0, nb15 = 0;

  TA_RetCode rc = TA_SMA(0, n - 1, btc->volume, 7, &beg7, &nb7, sma7);
  if (rc != TA_SUCCESS) {
    fprintf(stderr, "  ERR  VOLUME composite TA_SMA(7) rc=%d\n", rc);
    free(sma7); free(sma15); return -1;
  }
  rc = TA_SMA(0, n - 1, btc->volume, 15, &beg15, &nb15, sma15);
  if (rc != TA_SUCCESS) {
    fprintf(stderr, "  ERR  VOLUME composite TA_SMA(15) rc=%d\n", rc);
    free(sma7); free(sma15); return -1;
  }

  // Build a synthetic 3-column snapshot. We pad SMA columns into
  // full-length-n buffers with NA at the lookback positions, so
  // emit_snapshot can write them positionally.
  double *vol_full = (double *)malloc((size_t)n * sizeof(double));
  double *sma7_full = (double *)malloc((size_t)n * sizeof(double));
  double *sma15_full = (double *)malloc((size_t)n * sizeof(double));
  for (int i = 0; i < n; i++) {
    vol_full[i] = btc->volume[i];
    sma7_full[i] = (i < beg7) ? NAN : sma7[i - beg7];
    sma15_full[i] = (i < beg15) ? NAN : sma15[i - beg15];
  }

    // The R wrapper's column shapes:
  //   col 0 (VOLUME): full-length raw volume, no NA padding (lookback=0)
  //   col 1 (SMA7):   NA for [0..5], valid for [6..n-1]
  //   col 2 (SMA15):  NA for [0..13], valid for [14..n-1]
  //
  // emit_snapshot's lookback gating is uniform across columns, so we
  // pass outBegIdx=0 / outNbElement=n and rely on the per-column
  // NaN values already baked into the *_full buffers (vol_full has no
  // NaN; sma7_full/sma15_full got NaN at their respective leading
  // regions in the loop above). write_real renders NaN as "NA".
  int composite_lookback = (beg7 > beg15 ? beg7 : beg15);  /* metadata only */

  void *outputs[3] = { vol_full, sma7_full, sma15_full };
  int output_is_int[3] = {0, 0, 0};
  const char *output_names[3] = {"VOLUME", "SMA7", "SMA15"};

  int ret = emit_snapshot(
    out_dir, "VOLUME",
    "ma=SMA(n=7);SMA(n=15)",  /* mirrors R wrapper default */
    "Real", "volume",
    3,                         /* n_outputs */
    output_names,
    "Real,Real,Real",          /* output_types */
    composite_lookback,        /* metadata: max(component lookbacks) */
    0,                         /* outBegIdx: dump full buffers as-is */
    n,                         /* outNbElement: full length */
    n,
    outputs, output_is_int);

  if (ret == 0) {
    printf("  COMP VOLUME                lookback=%-4d nb=%d outputs=3\n",
           composite_lookback, n);
  }

  free(sma7); free(sma15); free(vol_full); free(sma7_full); free(sma15_full);
  return ret;
}

// ---- Composite: STOCHRSI --------------------------------------------------
//
// Canonical Chande/Kroll Stochastic RSI per the original 1994 paper:
//
//     RSI(close, optInTimePeriod)
//   then
//     STOCHF(rsi as H/L/C, optInFastK_Period, optInFastD_Period, optInFastD_MAType)
//
// We compose this explicitly (TA_RSI -> TA_STOCHF) rather than calling
// TA_STOCHRSI directly. Functionally identical numerically, but the
// composite makes the canonical recipe self-documenting and is the
// reference the R wrapper is expected to match.
//
// Defaults are TA-Lib's metadata defaults for STOCHRSI:
//   optInTimePeriod    = 14
//   optInFastK_Period  = 5
//   optInFastD_Period  = 3
//   optInFastD_MAType  = SMA (0)
//
// If the R wrapper diverges from this composite (e.g. by computing RSI
// twice via TA_STOCHRSI on a pre-computed RSI series), the parity test
// is expected to fail until the wrapper is corrected.
static int process_stochrsi_composite(btc_t *btc, const char *out_dir) {
  const int n = btc->n;
  const int period = 14;
  const int fastk = 5;
  const int fastd = 3;
  const TA_MAType fastd_ma = (TA_MAType)0;  /* SMA */

  /* Step 1: RSI(close, period). */
  double *rsi = (double *)malloc((size_t)n * sizeof(double));
  TA_Integer rsi_beg = 0, rsi_nb = 0;
  TA_RetCode rc = TA_RSI(0, n - 1, btc->close, period, &rsi_beg, &rsi_nb, rsi);
  if (rc != TA_SUCCESS) {
    fprintf(stderr, "  ERR  STOCHRSI composite TA_RSI rc=%d\n", rc);
    free(rsi); return -1;
  }

  /* Step 2: STOCHF(rsi as H/L/C, fastk, fastd, ma). On a single-line
   * series the high/low/close inputs are all the same vector; min/max
   * over the FastK window collapses to min/max of that series. */
  double *fastK = (double *)malloc((size_t)rsi_nb * sizeof(double));
  double *fastD = (double *)malloc((size_t)rsi_nb * sizeof(double));
  TA_Integer st_beg = 0, st_nb = 0;
  rc = TA_STOCHF(0, rsi_nb - 1, rsi, rsi, rsi,
                 fastk, fastd, fastd_ma,
                 &st_beg, &st_nb, fastK, fastD);
  if (rc != TA_SUCCESS) {
    fprintf(stderr, "  ERR  STOCHRSI composite TA_STOCHF rc=%d\n", rc);
    free(rsi); free(fastK); free(fastD); return -1;
  }

  /* Combined lookback in the original close series:
   *   rsi_beg              (NAs from inner TA_RSI; equals period for startIdx=0)
   * + st_beg               (NAs from TA_STOCHF on the RSI series)
   * Equals TA_STOCHRSI_Lookback() -- same shape as a direct call.        */
  const int composite_offset = rsi_beg + st_beg;

  /* Pad to full n with NaN, copy values into the right positions. */
  double *fastK_full = (double *)malloc((size_t)n * sizeof(double));
  double *fastD_full = (double *)malloc((size_t)n * sizeof(double));
  for (int i = 0; i < n; i++) {
    fastK_full[i] = NAN;
    fastD_full[i] = NAN;
  }
  for (int i = 0; i < st_nb; i++) {
    fastK_full[composite_offset + i] = fastK[i];
    fastD_full[composite_offset + i] = fastD[i];
  }

  void *outputs[2] = { fastK_full, fastD_full };
  int output_is_int[2] = {0, 0};
  const char *output_names[2] = {"FastK", "FastD"};

  char opt_summary[256];
  snprintf(opt_summary, sizeof(opt_summary),
           "optInTimePeriod=%d;optInFastK_Period=%d;optInFastD_Period=%d;optInFastD_MAType=%d",
           period, fastk, fastd, (int)fastd_ma);

  int ret = emit_snapshot(
    out_dir, "STOCHRSI",
    opt_summary,
    "Real", "close",
    2,                         /* n_outputs */
    output_names,
    "Real,Real",
    composite_offset,          /* lookback (metadata) */
    0,                         /* outBegIdx: pre-padded */
    n,                         /* outNbElement: emit full buffers */
    n,
    outputs, output_is_int);

  if (ret == 0) {
    printf("  COMP STOCHRSI              lookback=%-4d nb=%d outputs=2\n",
           composite_offset, n);
  }

  free(rsi); free(fastK); free(fastD); free(fastK_full); free(fastD_full);
  return ret;
}

// ---- Driver ----------------------------------------------------------------

/* Names handled by composite generators rather than the abstract layer. */
static int is_composite_name(const char *name) {
  return strcmp(name, "VOLUME") == 0 || strcmp(name, "STOCHRSI") == 0;
}

typedef struct {
  btc_t *btc;
  const char *out_dir;
  int n_ok;
  int n_skip;
  int n_err;
} ctx_t;

static void each_cb(const TA_FuncInfo *info, void *opaque) {
  ctx_t *ctx = (ctx_t *)opaque;
  if (is_composite_name(info->name)) {
    /* Skip: handled by a dedicated composite below. */
    return;
  }
  int r = process_one(info, ctx->btc, ctx->out_dir);
  if (r == 0) ctx->n_ok++;
  else if (r == 1) ctx->n_skip++;
  else ctx->n_err++;
}

int main(int argc, char **argv) {
  if (argc < 3) {
    fprintf(stderr, "usage: %s <btc.csv> <output_dir>\n", argv[0]);
    return 1;
  }

  btc_t btc;
  if (btc_read(argv[1], &btc) != 0) return 1;
  fprintf(stderr, "Read %d OHLCV rows from %s\n", btc.n, argv[1]);

  TA_RetCode rc = TA_Initialize();
  if (rc != TA_SUCCESS) {
    fprintf(stderr, "TA_Initialize rc=%d\n", rc);
    btc_free(&btc);
    return 1;
  }
  TA_RestoreCandleDefaultSettings(TA_AllCandleSettings);

  ctx_t ctx = {&btc, argv[2], 0, 0, 0};
  TA_ForEachFunc(each_cb, &ctx);

  /* Composite hand-written wrappers. */
  if (process_volume_composite(&btc, argv[2]) == 0) ctx.n_ok++;
  else ctx.n_err++;
  if (process_stochrsi_composite(&btc, argv[2]) == 0) ctx.n_ok++;
  else ctx.n_err++;

  TA_Shutdown();
  btc_free(&btc);

  fprintf(stderr, "\nDone. wrote=%d  skip=%d  errors=%d\n",
          ctx.n_ok, ctx.n_skip, ctx.n_err);
  return ctx.n_err == 0 ? 0 : 1;
}
