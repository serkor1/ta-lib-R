// interface to ta_IMI.c
//
// Parameters
//   inOpen        : numeric vector of opens (length n)
//   inClose       : numeric vector of closes (length n)
//   optTimePeriod : integer time period
//
// Returns
//   numeric vector (n x 1) "IMI"
//
// Notes
//   TA-Lib marks IMI as an indicator with an unstable period. Inputs and range
//   are consistent with the current TA-Lib C API.
//   :contentReference[oaicite:1]{index=1}
#include "container.h"
#include "lib.h"
#include "names.h"
#include "shift.h"
#include <R.h>
#include <Rinternals.h>
#include <ta_libc.h>

// clang-format off
SEXP impl_ta_IMI(
  SEXP inOpen,
  SEXP inClose,
  SEXP optTimePeriod) {
  // clang-format on
  int protect_count = 0;

  const double *restrict open_ptr = REAL(inOpen);
  const double *restrict close_ptr = REAL(inClose);
  const int n = LENGTH(inOpen);

  const int time_period = INTEGER(optTimePeriod)[0];

  SEXP output;
  double *output_ptr;

  const int lookback = TA_IMI_Lookback(time_period);

  const int proceed =
      output_container(n, lookback, 1, &output, &output_ptr, &protect_count);

  if (proceed) {
    int start_idx = 0, end_idx = 0;

    // clang-format off
    TA_RetCode return_code = TA_IMI(
      /*startIdx     */ 0,
      /*endIdx       */ n - 1,
      /*inOpen       */ open_ptr,
      /*inClose      */ close_ptr,
      /*optInTimePrd */ time_period,
      /*outBegIdx    */ &start_idx,
      /*outNbElement */ &end_idx,
      /*outReal      */ output_ptr
    );
    // clang-format on

    check_output(return_code, protect_count);
    shift_array(output_ptr, n, start_idx);
  }

  set_colnames(output, "IMI");

  UNPROTECT(protect_count);
  return output;
}
