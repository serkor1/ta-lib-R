// interface to ta_HT_SINE.c
//
// Description
//   R wrapper for TA_HT_SINE. Computes sine and lead-sine series.
//
// Parameters
//   real: numeric vector of prices (length n)
//
// Returns
//   n x 2 REAL matrix with columns "sine", "lead_sine", padded with NA_REAL
//   for the initial lookback.

#include "R_ext/Error.h"
#include "Rinternals.h"
#include "lib.h"
#include "names.h"
#include "shift.h"
#include <ta_libc.h>

// clang-format off
SEXP impl_ta_HT_SINE(SEXP real) {
  // clang-format on
  int protect_count = 0;

  const int n = LENGTH(real);
  const double *restrict real_ptr = REAL(real);

  SEXP result = PROTECT(allocMatrix(REALSXP, n, 2));
  protect_count++;
  double *restrict base_ptr = REAL(result);
  double *restrict out_sine_ptr = base_ptr + 0 * n;
  double *restrict out_lead_sine_ptr = base_ptr + 1 * n;

  const int minimum_lookback = TA_HT_SINE_Lookback();

  if (n < minimum_lookback) {
    Rf_warning("Input length (%d) is smaller than lookback (%d).", n,
               minimum_lookback);
    for (int i = 0; i < n; ++i) {
      out_sine_ptr[i] = NA_REAL;
      out_lead_sine_ptr[i] = NA_REAL;
    }
  } else {
    int out_begin = 0, number_of_elements = 0;

    // clang-format off
    TA_RetCode return_code = TA_HT_SINE(
      /*startIdx   */ 0,
      /*endIdx     */ n - 1,
      /*inReal     */ real_ptr,
      /*outBeg     */ &out_begin,
      /*outNb      */ &number_of_elements,
      /*outSine    */ out_sine_ptr,
      /*outLead    */ out_lead_sine_ptr
    );
    // clang-format on

    if (return_code != TA_SUCCESS) {
      UNPROTECT(protect_count);
      Rf_error("TA_HT_SINE failed: return code %d", return_code);
    }

    shift_array(out_sine_ptr, n, out_begin);
    shift_array(out_lead_sine_ptr, n, out_begin);
    set_colnames(result, "sine", "leadsine");
  }

  UNPROTECT(protect_count);
  return result;
}
