// ta_VOLUME.c
//
// Parameters
//   double inReal
//   list   maSpec  (each element is integer(2): c(period, maType))
//
// Returns
//   matrix (n x (1 + length(maSpec))) with columns:
//     "VOLUME", "<MAType><period>" e.g. "SMA7"
//
#include "MAType.h"
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
      double *compact_0 = (double *)R_alloc(n, sizeof(double));
      compact_array(compact_0, x, na_mask, n_original);
      x = compact_0;
    } else {
      na_mask = NULL;
    }
  }

  // determine maSpec input
  const int n_ma = isNull(maSpec) ? 0 : LENGTH(maSpec);
  const int n_cols = 1 + n_ma;

  // output
  SEXP output;
  double *output_ptr;

  // the output container is either a INTSXP or
  // REALSXP depending on the type and will
  // return a matrix with <NA> if there is a mismatch
  // between lookback and n
  //
  // see container.h for more details
  output_container(n, 0, n_cols, &output, &output_ptr, &protection_count);
  memcpy(output_ptr, x, (size_t)n * sizeof(double));

  // set initial column name
  const char **colname =
    (const char **)R_alloc((size_t)n_cols, sizeof(*colname));
  colname[0] = "VOLUME";

  // iterate over maSpec
  for (int j = 0; j < n_ma; ++j) {
    int start_idx = 0;
    int end_idx = 0;

    // extract maSpec
    //
    // specification is a downstream enum
    // period is passed in the downstream enum
    SEXP specification = VECTOR_ELT(maSpec, j);
    const int *specification_ptr = INTEGER(specification);

    const int period = specification_ptr[0];
    const TA_MAType ma_type = (TA_MAType)specification_ptr[1];

    double *restrict offset_real = output_ptr + (size_t)(j + 1) * (size_t)n;

    // clang-format off
    // calculate moving averages
    TA_RetCode return_value = TA_MA(
      0,
      n - 1,
      x,
      period,
      ma_type,
      &start_idx,
      &end_idx,
      offset_real
    );

    // validate output
    check_output(return_value, protection_count);
    // clang-format on

    // shift the array so it has the same number
    // of rows as 'n' - shifted values is replaced
    // with <NA>
    // see shift.h for more details
    shift_array(offset_real, n, start_idx);

    char *character_buffer = (char *)R_alloc(32, sizeof(char));
    snprintf(character_buffer, 32, "%s%d", _MAType_(ma_type), period);
    colname[j + 1] = character_buffer;
  }

  // set the remaining column names
  // see names.h for more details
  column_names(output, n_cols, colname);

  // re-expand output if NAs were stripped
  // see na.h for more details
  if (na_mask != NULL) {
    output =
      reexpand_double_matrix(output, na_mask, n_original, &protection_count);
  }

  UNPROTECT(protection_count);
  return output;
}
