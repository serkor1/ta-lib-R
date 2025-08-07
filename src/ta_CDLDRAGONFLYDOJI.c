// Interface to TA_CDLDRAGONFLYDOJI
//
// Parameters
//   open: numeric vector of opening prices
//   high: numeric vector of high prices
//   low:  numeric vector of low prices
//   close: numeric vector of closing prices
//
// Description
//   Identifies the "Dragonfly Doji" candlestick pattern, characterized by a Doji with a long lower shadow and virtually no upper shadow.
//   Returns an integer vector of the same length, with 100 for each index where a Dragonfly Doji pattern is found (0 if no pattern). 
//   Leading NA values are padded for periods before the first pattern can be detected.
#include "lib.h"
#include <limits.h>
#include <ta_libc.h>

SEXP impl_ta_CDLDRAGONFLYDOJI(SEXP open, SEXP high, SEXP low, SEXP close) {
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

    R_xlen_t n = XLENGTH(open);
    if(XLENGTH(high) != n || XLENGTH(low) != n || XLENGTH(close) != n) {
        if(protect_count > 0) UNPROTECT(protect_count);
        error("Input vectors 'open', 'high', 'low', 'close' must have the same length");
    }
    if(n == 0) {
        SEXP result = PROTECT(allocVector(INTSXP, 0));
        if(protect_count > 0) UNPROTECT(protect_count);
        UNPROTECT(1);
        return result;
    }
    if(n > INT_MAX) {
        if(protect_count > 0) UNPROTECT(protect_count);
        error("Number of observations exceeds maximum supported by TA-Lib");
    }
    int len = (int)n;

    const double * restrict open_ptr  = REAL(open);
    const double * restrict high_ptr  = REAL(high);
    const double * restrict low_ptr   = REAL(low);
    const double * restrict close_ptr = REAL(close);

    SEXP result = PROTECT(allocVector(INTSXP, n));
    protect_count++;
    int * restrict out_ptr = INTEGER(result);

    int out_beg_idx = 0;
    int out_nb_elem = 0;
    TA_RetCode ret_code = TA_CDLDRAGONFLYDOJI(
        0, len - 1,
        open_ptr, high_ptr, low_ptr, close_ptr,
        &out_beg_idx, &out_nb_elem,
        out_ptr
    );
    if(ret_code != TA_SUCCESS) {
        if(protect_count > 0) UNPROTECT(protect_count);
        error("TA-Lib computation failed with error code %d", ret_code);
    }
    if(out_nb_elem == 0) {
        for(R_xlen_t i = 0; i < n; ++i) {
            out_ptr[i] = NA_INTEGER;
        }
        if(protect_count > 0) UNPROTECT(protect_count);
        return result;
    }
    if(out_beg_idx > 0) {
        memmove(out_ptr + out_beg_idx, out_ptr, (n - out_beg_idx) * sizeof(int));
        for(int i = 0; i < out_beg_idx; ++i) {
            out_ptr[i] = NA_INTEGER;
        }
    }
    if(protect_count > 0) UNPROTECT(protect_count);
    return result;
}