// interface to ta_ROC.c and ta_ROCP.c
//
// Description
//   Computes Rate of Change. If as_percentage is FALSE, uses ROC:
//   ((price/prevPrice)-1)*100. If TRUE, uses ROCP: (price-prevPrice)/prevPrice.
//   Returns a numeric vector of length n, left-padded with NA_REAL.
//
// Parameters
//   in_real     : numeric vector of prices
//   timeperiod  : integer SEXP lookback (typical default 10)
//   as_percentage : logical scalar (TRUE -> ROCP, FALSE -> ROC)
//
// Returns
//   A REALSXP vector of length n with ROC or ROCP values. NA_REAL for the
//   initial lookback observations.

#include "R_ext/Arith.h"
#include "R_ext/Error.h"
#include "Rinternals.h"
#include "lib.h"
#include "names.h"
#include "shift.h"
#include <stdbool.h>
#include <ta_libc.h>

// clang-format off
SEXP impl_ta_ROC(
  SEXP in_real,
  SEXP timeperiod) {
  // clang-format on

  int protect_count = 0;

  const int n = LENGTH(in_real);
  const double *restrict in_ptr = REAL(in_real);
  const int period = INTEGER(timeperiod)[0];

  SEXP result = PROTECT(allocMatrix(REALSXP, n, 1));
  protect_count++;
  double *restrict out_ptr = REAL(result);

  const int minimum_lookback = TA_ROC_Lookback(period);

  if (n < minimum_lookback) {
    Rf_warning("Input length (%d) is smaller than required lookback (%d).", n,
               minimum_lookback);
    for (int i = 0; i < n; ++i)
      out_ptr[i] = NA_REAL;

  } else {
    int out_beg_index = 0;
    int out_number_of_elements = 0;

    // clang-format off
    TA_RetCode return_code = TA_ROC(
    /*startIdx        */ 0,
    /*endIdx          */ n - 1,
    /*inReal          */ in_ptr,
    /*optInTimePeriod */ period,
    /*outBeg          */ &out_beg_index,
    /*outNb           */ &out_number_of_elements,
    /*outReal         */ out_ptr
    );
    // clang-format on

    if (return_code != TA_SUCCESS) {
      UNPROTECT(protect_count);
      Rf_error("TA_ROC failed: return code %d", return_code);
    }

    set_colnames(result, "ROC");
    shift_array(out_ptr, n, out_beg_index);
  }

  UNPROTECT(protect_count);
  return result;
}
