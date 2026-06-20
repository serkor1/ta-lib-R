// ta_VOLUME.c
//
// Parameters
//   double  inReal
//   list    maSpec  (each element is integer(2): c(period, maType))
//   logical na_rm
//
// Returns
//   matrix (n x (1 + length(maSpec))) with columns:
//     "VOLUME", "<MAType><period>" e.g. "SMA7"
//
//   The "lookback" attribute is the maximum lookback across all maSpec
//   entries, and 0 when no maSpec is supplied. The "VOLUME" column itself
//   always has a lookback of 0.
//
#include "MAType.h"
#include "attributes.h"
#include "container.h"
#include "lib.h"
#include "na.h"
#include "names.h"
#include "shift.h"
#include <R.h>
#include <Rinternals.h>
#include <stdio.h>
#include <string.h>
#include <ta_libc.h>

// the lookback function is exported as a standalone function for downstream
// wrappers. 'inReal' is unused but kept for call-signature parity with
// impl_ta_VOLUME
// clang-format off
SEXP impl_ta_VOLUME_lookback(
  SEXP inReal,
  SEXP maSpec
)
// clang-format on
{
  (void)inReal;

  const int n_ma = isNull(maSpec) ? 0 : LENGTH(maSpec);

  // maximum lookback across all maSpec entries (stays 0 when none supplied)
  int lookback = 0;
  for (int j = 0; j < n_ma; ++j) {
    // each specification is integer(2): c(period, maType)
    const int *spec = INTEGER(VECTOR_ELT(maSpec, j));
    const int ma_lookback = TA_MA_Lookback(spec[0], (TA_MAType)spec[1]);
    if (ma_lookback > lookback) {
      lookback = ma_lookback;
    }
  }

  SEXP output = PROTECT(Rf_ScalarInteger(lookback));

  UNPROTECT(1);
  return output;
}

// clang-format off
SEXP impl_ta_VOLUME(
  SEXP inReal,
  SEXP maSpec,
  SEXP na_rm
)
// clang-format on
{
  // protection counter
  int protection_count = 0;

  // get length of 'inReal' (assumes equal length across input)
  int n = LENGTH(inReal);
  const double *x = REAL(inReal);

  // NA handling
  // see na.h for more details
  int *na_mask = NULL;
  const int n_original = n;

  if (LOGICAL(na_rm)[0]) {
    na_mask = (int *)R_alloc(n, sizeof(int));
    const double *na_arrays[] = {x};
    n = build_na_mask(na_mask, n, 1, na_arrays);
    if (n < n_original) {
      compact_arrays(na_arrays, 1, na_mask, n_original, n);
      x = na_arrays[0];
    } else {
      na_mask = NULL;
    }
  }

  // one column for 'VOLUME' plus one per moving average
  const int n_ma = isNull(maSpec) ? 0 : LENGTH(maSpec);
  const int n_cols = 1 + n_ma;

  // the output container is either an INTSXP or REALSXP and returns a
  // matrix of <NA> on a lookback mismatch - the 'VOLUME' column is always
  // valid, so the container lookback is 0
  // see container.h for more details
  SEXP output;
  double *output_ptr;
  output_container(n, 0, n_cols, &output, &output_ptr, &protection_count);

  // first column is the (NA-compacted) volume itself
  memcpy(output_ptr, x, (size_t)n * sizeof(double));

  // column names: "VOLUME" followed by "<MAType><period>"
  const char **colname =
    (const char **)R_alloc((size_t)n_cols, sizeof(*colname));
  colname[0] = "VOLUME";

  // maximum lookback across all maSpec entries (stays 0 when none supplied)
  int lookback = 0;

  for (int j = 0; j < n_ma; ++j) {
    // each specification is integer(2): c(period, maType)
    const int *spec = INTEGER(VECTOR_ELT(maSpec, j));
    const int period = spec[0];
    const TA_MAType ma_type = (TA_MAType)spec[1];

    // track the largest lookback seen so far
    const int ma_lookback = TA_MA_Lookback(period, ma_type);
    if (ma_lookback > lookback) {
      lookback = ma_lookback;
    }

    // moving average is written into column (j + 1)
    double *restrict ma = output_ptr + (size_t)(j + 1) * (size_t)n;

    int start_idx = 0;
    int end_idx = 0;

    // clang-format off
    TA_RetCode return_value = TA_MA(
      0,
      n - 1,
      x,
      period,
      ma_type,
      &start_idx,
      &end_idx,
      ma
    );
    // clang-format on
    check_output(return_value, protection_count);

    // pad the leading 'start_idx' rows with <NA> so the column has 'n' rows
    // see shift.h for more details
    shift_array(ma, n, start_idx);

    char *buffer = (char *)R_alloc(32, sizeof(char));
    snprintf(buffer, 32, "%s%d", _MAType_(ma_type), period);
    colname[j + 1] = buffer;
  }

  // set the column names and the (maximum) lookback attribute
  // see names.h and attributes.h for more details
  column_names(output, n_cols, colname);
  set_attribute(output, lookback, &protection_count);

  // re-expand output if NAs were stripped
  // see na.h for more details
  if (na_mask != NULL) {
    output =
      reexpand_double_matrix(output, na_mask, n_original, &protection_count);
  }

  UNPROTECT(protection_count);
  return output;
}
