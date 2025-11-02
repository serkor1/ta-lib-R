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
#include "container.h"
#include "lib.h"
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
  SEXP offset
)
// clang-format on
{
  // protection counter
  int protection_count = 0;

  // get length of 'inReal' (assumes equal length across input)
  const int n = LENGTH(inReal);

  // pointers to input arrays
  const double *restrict inReal_ptr = REAL(inReal);

  // extract input values
  const int optInTimePeriod_value = INTEGER(optInTimePeriod)[0];
  const int optInFastK_Period_value = INTEGER(optInFastK_Period)[0];
  const int optInFastD_Period_value = INTEGER(optInFastD_Period)[0];
  const TA_MAType optInFastD_MAType_value = as_MAType(optInFastD_MAType);
  const int offset_value = INTEGER(offset)[0];

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

  // set the column names of the output
  // see names.h for more details
  set_colnames(output, "FastK", "FastD");

  UNPROTECT(protection_count);
  return output;
}
