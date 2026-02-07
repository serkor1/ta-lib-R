// interface to ta_CDLCONCEALBABYSWALL.c
//
// Parameters
//      double  inOpen
//      double  inClose
//      double  inLow
//      double  inClose
//      bool    flag
//
// Returns
//      matrix (n x 1) with colum:
//          "CDLCONCEALBABYSWALL"
//
// Source
//      https://github.com/TA-Lib/ta-lib/blob/main/src/ta_func/ta_CDLCONCEALBABYSWALL.c
//
#include "Rinternals.h"
#include "attributes.h"
#include "container.h"
#include "lib.h"
#include "names.h"
#include "normalize.h"
#include "shift.h"
#include <ta_libc.h>

// clang-format off
SEXP impl_ta_CDLCONCEALBABYSWALL(
    SEXP inOpen,
    SEXP inHigh,
    SEXP inLow,
    SEXP inClose,
    SEXP flag
)
// clang-format on 
{
    // protection counter
    int protection_count = 0;

    // pointers to input
    const double *restrict open_ptr  = REAL(inOpen);
    const double *restrict high_ptr  = REAL(inHigh);
    const double *restrict low_ptr   = REAL(inLow);
    const double *restrict close_ptr = REAL(inClose);
    const int n = LENGTH(inOpen);

    
    SEXP output;
    int *output_ptr;

    // calculate look back and exit
    // the function function early if
    // there is a mismatch
    const int lookback = TA_CDLCONCEALBABYSWALL_Lookback();

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
        &protection_count
    );

    if (proceed) {
        int start_idx = 0;
        int end_idx   = 0;

        // TA_CDLCONCEALBABYSWALL returns an TA_RetCode
        // which is TA_SUCCESS if it succeeds
        // values in output_ptr gets populated
        // by pointers
        TA_RetCode return_code = TA_CDLCONCEALBABYSWALL(
            0,
            n - 1,
            open_ptr,
            high_ptr,
            low_ptr,
            close_ptr
            ,
            &start_idx,
            &end_idx,
            output_ptr
        );

        // check if the output is valid
        // and stop function with the TA_RetCode
        // see container.h for more details
        check_output(return_code, protection_count);

        // shift the array so it has the same number
        // of rows as 'n' - shifted values is replaced
        // with <NA> 
        // see shift.h for more details
        shift_array(output_ptr, n, start_idx);

        // ta_CDLCONCEALBABYSWALL returns values as -100, 100 and 0
        // if flag is TRUE the output values will be normalized
        // to -1, 1, 0 
        // see normalize.h for more details
        if (LOGICAL_VALUE(flag)) {
            normalize(output_ptr, n, 100, start_idx);
        }
    }

    // set the column names and lookback attribute
    // of the output container 
    // see names.h and attributes.h for more details
    set_colnames(output, "CDLCONCEALBABYSWALL");
    set_attribute(output, lookback, &protection_count);

    UNPROTECT(protection_count);
    return output;
}
