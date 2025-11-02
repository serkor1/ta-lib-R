// interface to ta_SAREXT.c
//
// Parameters
// 		double  inHigh
// 		double  inLow
// 		double  optInStartValue
//		double  optInOffsetOnReverse
//		double  optInAccelerationInitLong
//		double  optInAccelerationLong
//		double  optInAccelerationMaxLong
//		double  optInAccelerationInitShort
//		double  optInAccelerationShort
//		double  optInAccelerationMaxShort
//
// Returns
//      matrix (n x 1) with colum:
//          "SAREXT"
//
// Source
//      https://github.com/TA-Lib/ta-lib/blob/main/src/ta_func/ta_SAREXT.c
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
SEXP impl_ta_SAREXT(
	SEXP inHigh,
	SEXP inLow,
	SEXP optInStartValue,
	SEXP optInOffsetOnReverse,
	SEXP optInAccelerationInitLong,
	SEXP optInAccelerationLong,
	SEXP optInAccelerationMaxLong,
	SEXP optInAccelerationInitShort,
	SEXP optInAccelerationShort,
	SEXP optInAccelerationMaxShort
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
  const double optInStartValue_value = REAL(optInStartValue)[0];
  const double optInOffsetOnReverse_value = REAL(optInOffsetOnReverse)[0];
  const double optInAccelerationInitLong_value =
    REAL(optInAccelerationInitLong)[0];
  const double optInAccelerationLong_value = REAL(optInAccelerationLong)[0];
  const double optInAccelerationMaxLong_value =
    REAL(optInAccelerationMaxLong)[0];
  const double optInAccelerationInitShort_value =
    REAL(optInAccelerationInitShort)[0];
  const double optInAccelerationShort_value = REAL(optInAccelerationShort)[0];
  const double optInAccelerationMaxShort_value =
    REAL(optInAccelerationMaxShort)[0];

  // output
  SEXP output;
  double *output_ptr;

  // calculate look back and exit
  // the function function early if
  // there is a mismatch
  const int lookback = TA_SAREXT_Lookback(
    optInStartValue_value,
    optInOffsetOnReverse_value,
    optInAccelerationInitLong_value,
    optInAccelerationLong_value,
    optInAccelerationMaxLong_value,
    optInAccelerationInitShort_value,
    optInAccelerationShort_value,
    optInAccelerationMaxShort_value);

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

    // TA_SAREXT returns an TA_RetCode
    // which is TA_SUCCESS if it succeeds
    // values in output_ptr gets populated
    // by pointers
    TA_RetCode return_code = TA_SAREXT(
      0,
      n - 1,
      inHigh_ptr,
      inLow_ptr,
      optInStartValue_value,
      optInOffsetOnReverse_value,
      optInAccelerationInitLong_value,
      optInAccelerationLong_value,
      optInAccelerationMaxLong_value,
      optInAccelerationInitShort_value,
      optInAccelerationShort_value,
      optInAccelerationMaxShort_value,
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

  // set the column names of the output
  // see names.h for more details
  set_colnames(output, "SAREXT");

  UNPROTECT(protection_count);
  return output;
}
