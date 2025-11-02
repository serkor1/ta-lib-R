// interface to ta_CDLDARKCLOUDCOVER.c
//
// Parameters
//      double  inOpen
//      double  inClose
//      double  inLow
//      double  inClose
//		double	optInPenetration
//      bool    flag
//
// Returns
//      matrix (n x 1) with colum:
//          "CDLDARKCLOUDCOVER"
//
// Source
//      https://github.com/TA-Lib/ta-lib/blob/main/src/ta_func/ta_CDLDARKCLOUDCOVER.c
//
#include "Rinternals.h"
#include "container.h"
#include "lib.h"
#include "names.h"
#include "normalize.h"
#include "shift.h"
#include <ta_libc.h>

// clang-format off
SEXP impl_ta_CDLDARKCLOUDCOVER(
    SEXP inOpen,
    SEXP inHigh,
    SEXP inLow,
    SEXP inClose,
	SEXP optInPenetration,
    SEXP flag
)
// clang-format on 
{
    // protection counter
    int protection_counter = 0;

    // pointers to input
    const double *restrict open_ptr  = REAL(inOpen);
    const double *restrict high_ptr  = REAL(inHigh);
    const double *restrict low_ptr   = REAL(inLow);
    const double *restrict close_ptr = REAL(inClose);
    const int n = LENGTH(inOpen);

    const double penetration = REAL(optInPenetration)[0];
    SEXP output;
    int *output_ptr;

    // calculate look back and exit
    // the function function early if
    // there is a mismatch
    const int lookback = TA_CDLDARKCLOUDCOVER_Lookback(penetration);

    // the output container is either a INTSXP or 
    // REALSXP depending on the type and will
    // return a matrix with <NA> if there is a mismatch
    // between lookback and n
    //
    // see container.h for more details
    const int proceed = output_container(
        n,
        lookback,
        1,
        &output,
        &output_ptr,
        &protection_counter
    );

    if (proceed) {
        int start_idx = 0;
        int end_idx   = 0;

        // TA_CDLDARKCLOUDCOVER returns an TA_RetCode
        // which is TA_SUCCESS if it succeeds
        // values in output_ptr gets populated
        // by pointers
        TA_RetCode return_code = TA_CDLDARKCLOUDCOVER(
            0,
            n - 1,
            open_ptr,
            high_ptr,
            low_ptr,
            close_ptr, penetration
            ,
            &start_idx,
            &end_idx,
            output_ptr
        );

        // check if the output is valid
        // and stop function with the TA_RetCode
        // see container.h for more details
        check_output(return_code, protection_counter);

        // shift the array so it has the same number
        // of rows as 'n' - shifted values is replaced
        // with <NA> 
        // see shift.h for more details
        shift_array(output_ptr, n, start_idx);

        // ta_CDLDARKCLOUDCOVER returns values as -100, 100 and 0
        // if flag is TRUE the output values will be normalized
        // to -1, 1, 0 
        // see normalize.h for more details
        if (LOGICAL_VALUE(flag)) {
            normalize(output_ptr, n, 100, start_idx);
        }
    }

    // set the column names of the output
    // see names.h for more details
    set_colnames(output, "CDLDARKCLOUDCOVER");

    UNPROTECT(protection_counter);
    return output;
}
