// interface to ta_MFI.c
//
// Parameters
//   inHigh        : numeric vector of highs (length n)
//   inLow         : numeric vector of lows  (length n)
//   inClose       : numeric vector of closes (length n)
//   inVolume      : numeric vector of volumes (length n)
//   optTimePeriod : integer time period
//
// Returns
//   numeric vector (n x 1) "MFI"
//
#include "container.h"
#include "lib.h"
#include "names.h"
#include "shift.h"
#include <R.h>
#include <Rinternals.h>
#include <ta_libc.h>

// clang-format off
SEXP impl_ta_MFI(
  SEXP inHigh,
  SEXP inLow,
  SEXP inClose,
  SEXP inVolume,
  SEXP optTimePeriod) {
  // clang-format on
  int protect_count = 0;

  const double *restrict high_ptr = REAL(inHigh);
  const double *restrict low_ptr = REAL(inLow);
  const double *restrict close_ptr = REAL(inClose);
  const double *restrict volume_ptr = REAL(inVolume);
  const int n = LENGTH(inHigh);

  const int time_period = INTEGER(optTimePeriod)[0];

  SEXP output;
  double *output_ptr;

  const int lookback = TA_MFI_Lookback(time_period);

  const int proceed =
      output_container(n, lookback, 1, &output, &output_ptr, &protect_count);

  if (proceed) {
    int start_idx = 0, end_idx = 0;

    // clang-format off
    TA_RetCode return_code = TA_MFI(
      /*startIdx     */ 0,
      /*endIdx       */ n - 1,
      /*inHigh       */ high_ptr,
      /*inLow        */ low_ptr,
      /*inClose      */ close_ptr,
      /*inVolume     */ volume_ptr,
      /*optInTimePrd */ time_period,
      /*outBegIdx    */ &start_idx,
      /*outNbElement */ &end_idx,
      /*outReal      */ output_ptr
    );
    // clang-format on

    check_output(return_code, protect_count);
    shift_array(output_ptr, n, start_idx);
  }

  set_colnames(output, "MFI");

  UNPROTECT(protect_count);
  return output;
}
