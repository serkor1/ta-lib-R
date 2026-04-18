// interface to ta_STOCH.c
//
// Parameters
// 		double  inHigh
// 		double  inLow
// 		double  inClose
// 		integer optInFastK_Period
//		integer optInSlowK_Period
//		integer optInSlowK_MAType (MAType)
//		integer optInSlowD_Period
//		integer optInSlowD_MAType (MAType)
//
// Returns
//      matrix (n x 2) with colum:
//          "SlowK", "SlowD"
//
// Source
//      https://github.com/TA-Lib/ta-lib/blob/main/src/ta_func/ta_STOCH.c
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
#include <ta_libc.h>

// clang-format off
SEXP impl_ta_STOCH(
	SEXP inHigh,
	SEXP inLow,
	SEXP inClose,
	SEXP optInFastK_Period,
	SEXP optInSlowK_Period,
	SEXP optInSlowK_MAType,
	SEXP optInSlowD_Period,
	SEXP optInSlowD_MAType,
	SEXP na_bridge
)
// clang-format on
{
  // protection counter
  int protection_count = 0;

  // get length of 'inHigh' (assumes equal length across input)
  int n = LENGTH(inHigh);

  // pointers to input arrays
  const double *inHigh_ptr = REAL(inHigh);
  const double *inLow_ptr = REAL(inLow);
  const double *inClose_ptr = REAL(inClose);

  // extract input values
  const int optInFastK_Period_value = INTEGER(optInFastK_Period)[0];
  const int optInSlowK_Period_value = INTEGER(optInSlowK_Period)[0];
  const TA_MAType optInSlowK_MAType_value = as_MAType(optInSlowK_MAType);
  const int optInSlowD_Period_value = INTEGER(optInSlowD_Period)[0];
  const TA_MAType optInSlowD_MAType_value = as_MAType(optInSlowD_MAType);

  // NA handling
  // see na.h for more details
  int *na_mask = NULL;
  const int n_original = n;

  if (LOGICAL(na_bridge)[0]) {
    na_mask = (int *)R_alloc(n, sizeof(int));
    const double *na_arrays[] = {inHigh_ptr, inLow_ptr, inClose_ptr};
    n = build_na_mask(na_mask, n, 3, na_arrays);
    if (n < n_original) {
      compact_arrays(na_arrays, 3, na_mask, n_original, n);
      inHigh_ptr = na_arrays[0];
      inLow_ptr = na_arrays[1];
      inClose_ptr = na_arrays[2];

    } else {
      na_mask = NULL;
    }
  }

  // output
  SEXP output;
  double *output_ptr;

  // calculate look back and exit
  // the function function early if
  // there is a mismatch
  const int lookback = TA_STOCH_Lookback(
    optInFastK_Period_value,
    optInSlowK_Period_value,
    optInSlowK_MAType_value,
    optInSlowD_Period_value,
    optInSlowD_MAType_value);

  // the output container is either a INTSXP or
  // REALSXP depending on the type and will
  // return a matrix with <NA> if there is a mismatch
  // between lookback and n
  //
  // see container.h for more details
  const int proceed =
    output_container(n, lookback, 2, &output, &output_ptr, &protection_count);

  if (proceed) {
    int start_idx = 0;
    int end_idx = 0;

    double *slowk = output_ptr;
    double *slowd = output_ptr + 1 * n;

    // TA_STOCH returns an TA_RetCode
    // which is TA_SUCCESS if it succeeds
    // values in output_ptr gets populated
    // by pointers
    TA_RetCode return_code = TA_STOCH(
      0,
      n - 1,
      inHigh_ptr,
      inLow_ptr,
      inClose_ptr,
      optInFastK_Period_value,
      optInSlowK_Period_value,
      optInSlowK_MAType_value,
      optInSlowD_Period_value,
      optInSlowD_MAType_value,
      &start_idx,
      &end_idx,
      slowk,
      slowd);

    // check if the output is valid
    // and stop function with the TA_RetCode
    // see container.h for more details
    check_output(return_code, protection_count);

    // shift the array so it has the same number
    // of rows as 'n' - shifted values is replaced
    // with <NA>
    // see shift.h for more details
    shift_array(slowk, n, start_idx);
    shift_array(slowd, n, start_idx);
  }

  // set the column names and lookback attribute
  // of the output container
  // see names.h and attributes.h for more details
  set_colnames(output, "SlowK", "SlowD");
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
