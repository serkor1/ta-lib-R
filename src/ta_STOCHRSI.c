// interface to ta_STOCHRSI.c
//
// Parameters
// 		double  inReal
// 		integer optInTimePeriod
//		integer optInFastK_Period
//		integer optInFastD_Period
//		integer optInFastD_MAType (MAType)
//
// Returns
//      matrix (n x 2) with colum:
//          "FastK", "FastD"
//
// Source
//      https://github.com/TA-Lib/ta-lib/blob/main/src/ta_func/ta_STOCHRSI.c
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
SEXP impl_ta_STOCHRSI(
	SEXP inReal,
	SEXP optInTimePeriod,
	SEXP optInFastK_Period,
	SEXP optInFastD_Period,
	SEXP optInFastD_MAType,
	SEXP na_bridge
)
// clang-format on
{
  // protection counter
  int protection_count = 0;

  // get length of 'inReal' (assumes equal length across input)
  int n = LENGTH(inReal);

  // pointers to input arrays
  const double *inReal_ptr = REAL(inReal);

  // extract input values
  const int optInTimePeriod_value = INTEGER(optInTimePeriod)[0];
  const int optInFastK_Period_value = INTEGER(optInFastK_Period)[0];
  const int optInFastD_Period_value = INTEGER(optInFastD_Period)[0];
  const TA_MAType optInFastD_MAType_value = as_MAType(optInFastD_MAType);

  // NA handling
  // see na.h for more details
  int *na_mask = NULL;
  const int n_original = n;

  if (LOGICAL(na_bridge)[0]) {
    na_mask = (int *)R_alloc(n, sizeof(int));
    const double *na_arrays[] = {inReal_ptr};
    n = build_na_mask(na_mask, n, 1, na_arrays);
    if (n < n_original) {
      compact_arrays(na_arrays, 1, na_mask, n_original, n);
      inReal_ptr = na_arrays[0];

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
  const int lookback = TA_STOCHRSI_Lookback(
    optInTimePeriod_value,
    optInFastK_Period_value,
    optInFastD_Period_value,
    optInFastD_MAType_value);

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

    double *fastk = output_ptr;
    double *fastd = output_ptr + 1 * n;

    // TA_STOCHRSI returns an TA_RetCode
    // which is TA_SUCCESS if it succeeds
    // values in output_ptr gets populated
    // by pointers
    TA_RetCode return_code = TA_STOCHRSI(
      0,
      n - 1,
      inReal_ptr,
      optInTimePeriod_value,
      optInFastK_Period_value,
      optInFastD_Period_value,
      optInFastD_MAType_value,
      &start_idx,
      &end_idx,
      fastk,
      fastd);

    // check if the output is valid
    // and stop function with the TA_RetCode
    // see container.h for more details
    check_output(return_code, protection_count);

    // shift the array so it has the same number
    // of rows as 'n' - shifted values is replaced
    // with <NA>
    // see shift.h for more details
    shift_array(fastk, n, start_idx);
    shift_array(fastd, n, start_idx);
  }

  // set the column names and lookback attribute
  // of the output container
  // see names.h and attributes.h for more details
  set_colnames(output, "FastK", "FastD");
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
