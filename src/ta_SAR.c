// interface to ta_SAR.c
//
// Parameters
// 		double  inHigh
// 		double  inLow
// 		double  optInAcceleration
//		double  optInMaximum
//
// Returns
//      matrix (n x 1) with colum:
//          "SAR"
//
// Source
//      https://github.com/TA-Lib/ta-lib/blob/main/src/ta_func/ta_SAR.c
//
#include "MAType.h"
#include "attributes.h"
#include "container.h"
#include "lib.h"
#include "names.h"
#include "shift.h"
#include <R.h>
#include <Rinternals.h>
#include <ta_libc.h>

// clang-format off
SEXP impl_ta_SAR(
	SEXP inHigh,
	SEXP inLow,
	SEXP optInAcceleration,
	SEXP optInMaximum
)
// clang-format on
{
  // protection counter
  int protection_count = 0;

  // get length of 'inHigh' (assumes equal length across input)
  const int n = LENGTH(inHigh);

  // pointers to input arrays
  const double *restrict inHigh_ptr = REAL(inHigh);
  const double *restrict inLow_ptr = REAL(inLow);

  // extract input values
  const double optInAcceleration_value = REAL(optInAcceleration)[0];
  const double optInMaximum_value = REAL(optInMaximum)[0];

  // output
  SEXP output;
  double *output_ptr;

  // calculate look back and exit
  // the function function early if
  // there is a mismatch
  const int lookback =
    TA_SAR_Lookback(optInAcceleration_value, optInMaximum_value);

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

    double *real = output_ptr;

    // TA_SAR returns an TA_RetCode
    // which is TA_SUCCESS if it succeeds
    // values in output_ptr gets populated
    // by pointers
    TA_RetCode return_code = TA_SAR(
      0,
      n - 1,
      inHigh_ptr,
      inLow_ptr,
      optInAcceleration_value,
      optInMaximum_value,
      &start_idx,
      &end_idx,
      real);

    // check if the output is valid
    // and stop function with the TA_RetCode
    // see container.h for more details
    check_output(return_code, protection_count);

    // shift the array so it has the same number
    // of rows as 'n' - shifted values is replaced
    // with <NA>
    // see shift.h for more details
    shift_array(real, n, start_idx);
  }

  // set the column names and lookback attribute
  // of the output container
  // see names.h and attributes.h for more details
  set_colnames(output, "SAR");
  set_attribute(output, lookback, &protection_count);

  UNPROTECT(protection_count);
  return output;
}
