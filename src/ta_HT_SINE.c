// interface to ta_HT_SINE.c
//
// Parameters
// 		double  inReal
//
// Returns
//      matrix (n x 2) with colum:
//          "Sine", "LeadSine"
//
// Source
//      https://github.com/TA-Lib/ta-lib/blob/main/src/ta_func/ta_HT_SINE.c
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
SEXP impl_ta_HT_SINE(
	SEXP inReal
)
// clang-format on
{
  // protection counter
  int protection_count = 0;

  // get length of 'inReal' (assumes equal length across input)
  const int n = LENGTH(inReal);

  // pointers to input arrays
  const double *restrict inReal_ptr = REAL(inReal);

  // output
  SEXP output;
  double *output_ptr;

  // calculate look back and exit
  // the function function early if
  // there is a mismatch
  const int lookback = TA_HT_SINE_Lookback();

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

    double *sine = output_ptr;
    double *leadsine = output_ptr + 1 * n;

    // TA_HT_SINE returns an TA_RetCode
    // which is TA_SUCCESS if it succeeds
    // values in output_ptr gets populated
    // by pointers
    TA_RetCode return_code =
      TA_HT_SINE(0, n - 1, inReal_ptr, &start_idx, &end_idx, sine, leadsine);

    // check if the output is valid
    // and stop function with the TA_RetCode
    // see container.h for more details
    check_output(return_code, protection_count);

    // shift the array so it has the same number
    // of rows as 'n' - shifted values is replaced
    // with <NA>
    // see shift.h for more details
    shift_array(sine, n, start_idx);
    shift_array(leadsine, n, start_idx);
  }

  // set the column names of the output
  // see names.h for more details
  set_colnames(output, "Sine", "LeadSine");

  UNPROTECT(protection_count);
  return output;
}
