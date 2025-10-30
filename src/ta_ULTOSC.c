// interface to ta_ULTOSC.c
//
// Parameters
//   inHigh    : numeric vector of highs (length n)
//   inLow     : numeric vector of lows  (length n)
//   inClose   : numeric vector of closes (length n)
//   optPeriod1: integer first period
//   optPeriod2: integer second period
//   optPeriod3: integer third period
//
// Returns
//   numeric vector (n x 1) "ULTOSC"
//
#include "container.h"
#include "lib.h"
#include "names.h"
#include "shift.h"
#include <R.h>
#include <Rinternals.h>
#include <ta_libc.h>

// clang-format off
SEXP impl_ta_ULTOSC(
  SEXP inHigh,
  SEXP inLow,
  SEXP inClose,
  SEXP optPeriod1,
  SEXP optPeriod2,
  SEXP optPeriod3) {
  // clang-format on
  int protect_count = 0;

  const double *restrict high_ptr = REAL(inHigh);
  const double *restrict low_ptr = REAL(inLow);
  const double *restrict close_ptr = REAL(inClose);
  const int n = LENGTH(inHigh);

  const int period1 = INTEGER(optPeriod1)[0];
  const int period2 = INTEGER(optPeriod2)[0];
  const int period3 = INTEGER(optPeriod3)[0];

  SEXP output;
  double *output_ptr;

  const int lookback = TA_ULTOSC_Lookback(period1, period2, period3);

  const int proceed =
      output_container(n, lookback, 1, &output, &output_ptr, &protect_count);

  if (proceed) {
    int start_idx = 0, end_idx = 0;

    // clang-format off
    TA_RetCode return_code = TA_ULTOSC(
      /*startIdx     */ 0,
      /*endIdx       */ n - 1,
      /*inHigh       */ high_ptr,
      /*inLow        */ low_ptr,
      /*inClose      */ close_ptr,
      /*optInPeriod1 */ period1,
      /*optInPeriod2 */ period2,
      /*optInPeriod3 */ period3,
      /*outBegIdx    */ &start_idx,
      /*outNbElement */ &end_idx,
      /*outReal      */ output_ptr
    );
    // clang-format on

    check_output(return_code, protect_count);
    shift_array(output_ptr, n, start_idx);
  }

  set_colnames(output, "ULTOSC");

  UNPROTECT(protect_count);
  return output;
}
