// interface to ta_CDLUPSIDEGAP2CROWS.c
//
// Parameters
//      double  inOpen
//      double  inClose
//      double  inLow
//      double  inClose
//      bool    flag
//
// Returns
//      matrix (n x 1) with colum:
//          "CDLUPSIDEGAP2CROWS"
//
// Source
//      https://github.com/TA-Lib/ta-lib/blob/main/src/ta_func/ta_CDLUPSIDEGAP2CROWS.c
//
#include "Rinternals.h"
#include "attributes.h"
#include "container.h"
#include "lib.h"
#include "na.h"
#include "names.h"
#include "normalize.h"
#include "shift.h"
#include <ta_libc.h>

// clang-format off
SEXP impl_ta_CDLUPSIDEGAP2CROWS(
    SEXP inOpen,
    SEXP inHigh,
    SEXP inLow,
    SEXP inClose,
    SEXP flag,
    SEXP na_rm
)
// clang-format on
{
  // protection counter
  int protection_count = 0;

  // pointers to input
  const double *open_ptr = REAL(inOpen);
  const double *high_ptr = REAL(inHigh);
  const double *low_ptr = REAL(inLow);
  const double *close_ptr = REAL(inClose);
  int n = LENGTH(inOpen);

  // NA handling
  // see na.h for more details
  int *na_mask = NULL;
  const int n_original = n;

  if (LOGICAL(na_rm)[0]) {
    na_mask = (int *)R_alloc(n, sizeof(int));
    const double *na_arrays[] = {open_ptr, high_ptr, low_ptr, close_ptr};
    n = build_na_mask(na_mask, n, 4, na_arrays);
    if (n < n_original) {
      double *c0 = (double *)R_alloc(n, sizeof(double));
      double *c1 = (double *)R_alloc(n, sizeof(double));
      double *c2 = (double *)R_alloc(n, sizeof(double));
      double *c3 = (double *)R_alloc(n, sizeof(double));
      compact_array(c0, open_ptr, na_mask, n_original);
      compact_array(c1, high_ptr, na_mask, n_original);
      compact_array(c2, low_ptr, na_mask, n_original);
      compact_array(c3, close_ptr, na_mask, n_original);
      open_ptr = c0;
      high_ptr = c1;
      low_ptr = c2;
      close_ptr = c3;
    } else {
      na_mask = NULL;
    }
  }

  SEXP output;
  int *output_ptr;

  // calculate look back and exit
  // the function function early if
  // there is a mismatch
  const int lookback = TA_CDLUPSIDEGAP2CROWS_Lookback();

  // the output container is either a INTSXP or
  // REALSXP depending on the type and will
  // return a matrix with <NA> if there is a mismatch
  // between lookback and n
  //
  // see container.h for more details
  const int proceed =
    output_container(n, lookback, 1, &output, &output_ptr, &protection_count);

  if (proceed) {
    int start_idx = 0;
    int end_idx = 0;

    // TA_CDLUPSIDEGAP2CROWS returns an TA_RetCode
    // which is TA_SUCCESS if it succeeds
    // values in output_ptr gets populated
    // by pointers
    TA_RetCode return_code = TA_CDLUPSIDEGAP2CROWS(
      0,
      n - 1,
      open_ptr,
      high_ptr,
      low_ptr,
      close_ptr,
      &start_idx,
      &end_idx,
      output_ptr);

    // check if the output is valid
    // and stop function with the TA_RetCode
    // see container.h for more details
    check_output(return_code, protection_count);

    // shift the array so it has the same number
    // of rows as 'n' - shifted values is replaced
    // with <NA>
    // see shift.h for more details
    shift_array(output_ptr, n, start_idx);

    // ta_CDLUPSIDEGAP2CROWS returns values as -100, 100 and 0
    // if flag is TRUE the output values will be normalized
    // to -1, 1, 0
    // see normalize.h for more details
    if (LOGICAL_VALUE(flag)) {
      normalize(output_ptr, n, 100, start_idx);
    }
  }

  // set the column names and lookback attribute
  // of the output container
  // see names.h and attributes.h for more details
  set_colnames(output, "CDLUPSIDEGAP2CROWS");
  set_attribute(output, lookback, &protection_count);

  // re-expand output if NAs were stripped
  // see na.h for more details
  if (na_mask != NULL) {
    output = reexpand_matrix(
      output,
      output_ptr,
      na_mask,
      n_original,
      &protection_count);
  }

  UNPROTECT(protection_count);
  return output;
}
