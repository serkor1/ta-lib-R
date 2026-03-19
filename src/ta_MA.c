// interface to ta_MA.c
//
// Parameters
// 		double  inReal
// 		integer optInTimePeriod
//		integer optInMAType (MAType)
//
// Returns
//      matrix (n x 1) with colum name
//      depending on MAType, for example "SMA"
//
// Source
//      https://github.com/TA-Lib/ta-lib/blob/main/src/ta_func/ta_MA.c
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
SEXP impl_ta_MA(
	SEXP inReal,
	SEXP optInTimePeriod,
	SEXP optInMAType,
	SEXP na_rm
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
  const TA_MAType optInMAType_value = as_MAType(optInMAType);

  // NA handling
  // see na.h for more details
  int *na_mask = NULL;
  const int n_original = n;

  if (LOGICAL(na_rm)[0]) {
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
  const int lookback = TA_MA_Lookback(optInTimePeriod_value, optInMAType_value);

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

    // TA_MA returns an TA_RetCode
    // which is TA_SUCCESS if it succeeds
    // values in output_ptr gets populated
    // by pointers
    TA_RetCode return_code = TA_MA(
      0,
      n - 1,
      inReal_ptr,
      optInTimePeriod_value,
      optInMAType_value,
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
  // determine column name
  const char *colname = _MAType_(optInMAType_value);
  set_colnames(output, colname);
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
