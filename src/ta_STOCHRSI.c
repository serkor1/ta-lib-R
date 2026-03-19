// interface to ta_STOCHRSI.c
//
// Parameters
// 		double  inReal
// 		integer optInTimePeriod
//		integer optInFastK_Period
//		integer optInFastD_Period
//		integer optInFastD_MAType (MAType)
//    integer offset
//
// Returns
//      matrix (n x 2) with colum:
//          "FastK", "FastD"
//
// Source
//      https://github.com/TA-Lib/ta-lib/blob/main/src/ta_func/ta_STOCHRSI.c
//
// Details
//   This function wraps RSI from the R side, so all
//   values are offset by the <NA> values produced
//   otherwise all returned values are <NA>
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
  SEXP offset,
  SEXP na_ignore
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
  const int offset_value = INTEGER(offset)[0];

  // NA handling
  // see na.h for more details
  int *na_mask = NULL;
  const int n_original = n;

  if (LOGICAL(na_ignore)[0]) {
    na_mask = (int *)R_alloc(n, sizeof(int));
    const double *na_arrays[] = {inReal_ptr};
    n = build_na_mask(na_mask, n, 1, na_arrays);
    if (n < n_original) {
      double *compact_0 = (double *)R_alloc(n, sizeof(double));
      compact_array(compact_0, inReal_ptr, na_mask, n_original);
      inReal_ptr = compact_0;
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
                         optInFastD_MAType_value) +
                       offset_value;

  // the output container is either a INTSXP or
  // REALSXP depending on the type and will
  // return a matrix with <NA> if there is a mismatch
  // between lookback and n
  //
  // see container.h for more details
  const int proceed = output_container(
    n + offset_value,
    lookback,
    2,
    &output,
    &output_ptr,
    &protection_count);

  if (proceed) {
    int start_idx = 0;
    int end_idx = 0;

    double *fastk = output_ptr;
    double *fastd = output_ptr + 1 * (n + offset_value);

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
    shift_array(fastk, n + offset_value, start_idx + offset_value);
    shift_array(fastd, n + offset_value, start_idx + offset_value);
  }

  // set the column names and lookback attribute
  // of the output container
  // see names.h and attributes.h for more details
  set_colnames(output, "FastK", "FastD");
  set_attribute(output, lookback, &protection_count);

  // re-expand output if NAs were stripped
  // see na.h for more details
  //
  // The output has (n_compacted + offset_value) rows but must expand to
  // (n_original + offset_value) rows.  Build an extended mask: the first
  // offset_value entries are 0 (pass-through for the shift-generated NA
  // padding), followed by the original data mask.
  if (na_mask != NULL) {
    const int n_full = n_original + offset_value;
    int *ext_mask = (int *)R_alloc(n_full, sizeof(int));
    memset(ext_mask, 0, offset_value * sizeof(int));
    memcpy(ext_mask + offset_value, na_mask, n_original * sizeof(int));

    output =
      reexpand_double_matrix(output, ext_mask, n_full, &protection_count);
  }

  UNPROTECT(protection_count);
  return output;
}
