// interface to ta_BETA.c
//
// Parameters
// 		double  inReal0
// 		double  inReal1
// 		integer optInTimePeriod
//
// Returns
//      matrix (n x 1) with colum:
//          "BETA"
//
// Source
//      https://github.com/TA-Lib/ta-lib/blob/main/src/ta_func/ta_BETA.c
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
SEXP impl_ta_BETA(
	SEXP inReal0,
	SEXP inReal1,
	SEXP optInTimePeriod
)
// clang-format on
{
  // protection counter
  int protection_count = 0;

  // get length of 'inReal0' (assumes equal length across input)
  const int n = LENGTH(inReal0);

  // pointers to input arrays
  const double *restrict inReal0_ptr = REAL(inReal0);
  const double *restrict inReal1_ptr = REAL(inReal1);

  // extract input values
  const int optInTimePeriod_value = INTEGER(optInTimePeriod)[0];

  // output
  SEXP output;
  double *output_ptr;

  // calculate look back and exit
  // the function function early if
  // there is a mismatch
  const int lookback = TA_BETA_Lookback(optInTimePeriod_value);

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

    // TA_BETA returns an TA_RetCode
    // which is TA_SUCCESS if it succeeds
    // values in output_ptr gets populated
    // by pointers
    TA_RetCode return_code = TA_BETA(
      0,
      n - 1,
      inReal0_ptr,
      inReal1_ptr,
      optInTimePeriod_value,
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
  set_colnames(output, "BETA");

  UNPROTECT(protection_count);
  return output;
}
