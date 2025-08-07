// Interface to TA_CDLDOJI
//
// Parameters
//   open: numeric vector of opening prices
//   high: numeric vector of high prices
//   low:  numeric vector of low prices
//   close: numeric vector of closing prices
//
// Description
//   Identifies "Doji" candlestick patterns, where the open and close prices are nearly equal, indicating market indecision. 
//   Returns an integer vector of the same length as the inputs, with 100 for each index where a Doji pattern is detected (0 otherwise). 
//   Leading NA values are padded for periods before the first output can be computed (if any).
#include "lib.h"
#include <limits.h>
#include <ta_libc.h>

SEXP impl_ta_CDLDOJI(SEXP open, SEXP high, SEXP low, SEXP close) {
    // Ensure input types are numeric (double); coerce if necessary for safety
    int protect_count = 0;
    if(TYPEOF(open) != REALSXP) {
        open = PROTECT(coerceVector(open, REALSXP));
        protect_count++;
    }
    if(TYPEOF(high) != REALSXP) {
        high = PROTECT(coerceVector(high, REALSXP));
        protect_count++;
    }
    if(TYPEOF(low) != REALSXP) {
        low = PROTECT(coerceVector(low, REALSXP));
        protect_count++;
    }
    if(TYPEOF(close) != REALSXP) {
        close = PROTECT(coerceVector(close, REALSXP));
        protect_count++;
    }

    // All price vectors must have the same length
    R_xlen_t n = XLENGTH(open);
    if(XLENGTH(high) != n || XLENGTH(low) != n || XLENGTH(close) != n) {
        if(protect_count > 0) UNPROTECT(protect_count);
        error("Input vectors 'open', 'high', 'low', 'close' must have the same length");
    }

    // If no data points, return an empty integer vector (length 0)
    if(n == 0) {
        SEXP result = PROTECT(allocVector(INTSXP, 0));
        if(protect_count > 0) UNPROTECT(protect_count);
        UNPROTECT(1);
        return result;
    }

    // TA-Lib uses 32-bit indexing; check for overflow of input length
    if(n > INT_MAX) {
        if(protect_count > 0) UNPROTECT(protect_count);
        error("Number of observations exceeds maximum supported by TA-Lib");
    }
    int len = (int)n;  // safe to cast after checking

    // Get pointers to the input data (treated as double arrays for TA-Lib)
    const double * restrict open_ptr  = REAL(open);
    const double * restrict high_ptr  = REAL(high);
    const double * restrict low_ptr   = REAL(low);
    const double * restrict close_ptr = REAL(close);

    // Allocate an integer output vector of length n for the result
    SEXP result = PROTECT(allocVector(INTSXP, n));
    protect_count++;
    int * restrict out_ptr = INTEGER(result);

    // Prepare variables to receive output range from TA-Lib
    int out_beg_idx = 0;
    int out_nb_elem = 0;

    // Call TA-Lib function TA_CDLDOJI to compute the pattern indicator
    TA_RetCode ret_code = TA_CDLDOJI(
        0,                 // start index (beginning of data)
        len - 1,           // end index (last data point)
        open_ptr, high_ptr, low_ptr, close_ptr,  // input price arrays
        &out_beg_idx,      // where the first computed output starts
        &out_nb_elem,      // number of output values computed
        out_ptr            // output buffer (integer results)
    );

    // Check for errors from TA-Lib computation
    if(ret_code != TA_SUCCESS) {
        if(protect_count > 0) UNPROTECT(protect_count);
        error("TA-Lib computation failed with error code %d", ret_code);
    }

    // If TA-Lib reports no output values (e.g., not enough data for even one pattern)
    if(out_nb_elem == 0) {
        // Fill entire output with NA (no pattern values could be computed)
        for(R_xlen_t i = 0; i < n; ++i) {
            out_ptr[i] = NA_INTEGER;
        }
        // Unprotect and return the result vector
        if(protect_count > 0) UNPROTECT(protect_count);
        return result;
    }

    // Shift the computed results to align with original data indices.
    // `out_beg_idx` tells how many initial elements have no valid output.
    if(out_beg_idx > 0) {
        // Move the computed results to start at index `out_beg_idx` in the output array.
        // Using memmove allows safe in-place overlapping copy.
        memmove(
            /* dest: */ out_ptr + out_beg_idx,
            /* src:  */ out_ptr,
            /* n:    */ (n - out_beg_idx) * sizeof(int)
        );
        // Pad the leading part of the output with NA values for periods with no output
        for(int i = 0; i < out_beg_idx; ++i) {
            out_ptr[i] = NA_INTEGER;  // NA for integer type
        }
    }

    // Unprotect protected objects and return the result
    if(protect_count > 0) UNPROTECT(protect_count);
    return result;
}
