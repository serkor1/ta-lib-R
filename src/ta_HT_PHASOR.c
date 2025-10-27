// interface to ta_HT_PHASOR.c
//
// Description
//   R wrapper for TA_HT_PHASOR. Computes in-phase and quadrature components.
//
// Parameters
//   real: numeric vector of prices (length n)
//
// Returns
//   n x 2 REAL matrix with columns "in_phase", "quadrature", padded with
//   NA_REAL for the initial lookback.

#include "R_ext/Error.h"
#include "Rinternals.h"
#include "lib.h"
#include "names.h"
#include "shift.h"
#include <ta_libc.h>

// clang-format off
SEXP impl_ta_HT_PHASOR(SEXP real) {
  // clang-format on
  int protect_count = 0;

  const int n = LENGTH(real);
  const double *restrict real_ptr = REAL(real);

  SEXP result = PROTECT(allocMatrix(REALSXP, n, 2));
  protect_count++;
  double *restrict base_ptr = REAL(result);
  double *restrict out_in_phase_ptr = base_ptr + 0 * n;
  double *restrict out_quadrature_ptr = base_ptr + 1 * n;

  const int minimum_lookback = TA_HT_PHASOR_Lookback();

  if (n < minimum_lookback) {
    Rf_warning("Input length (%d) is smaller than lookback (%d).", n,
               minimum_lookback);
    for (int i = 0; i < n; ++i) {
      out_in_phase_ptr[i] = NA_REAL;
      out_quadrature_ptr[i] = NA_REAL;
    }
  } else {
    int out_begin = 0, number_of_elements = 0;

    // clang-format off
    TA_RetCode return_code = TA_HT_PHASOR(
      /*startIdx    */ 0,
      /*endIdx      */ n - 1,
      /*inReal      */ real_ptr,
      /*outBeg      */ &out_begin,
      /*outNb       */ &number_of_elements,
      /*outInPhase  */ out_in_phase_ptr,
      /*outQuadr    */ out_quadrature_ptr
    );
    // clang-format on

    if (return_code != TA_SUCCESS) {
      UNPROTECT(protect_count);
      Rf_error("TA_HT_PHASOR failed: return code %d", return_code);
    }

    shift_array(out_in_phase_ptr, n, out_begin);
    shift_array(out_quadrature_ptr, n, out_begin);
    set_colnames(result, "inphase", "quadrature");
  }

  UNPROTECT(protect_count);
  return result;
}
