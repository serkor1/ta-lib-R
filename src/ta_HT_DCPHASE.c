// interface to ta_HT_DCPHASE.c
//
// Parameters
//   inReal : numeric vector (length n)
//
// Returns
//   numeric vector (n x 1) "DCPHASE"
//
#include "container.h"
#include "lib.h"
#include "names.h"
#include "shift.h"
#include <R.h>
#include <Rinternals.h>
#include <ta_libc.h>

// clang-format off
SEXP impl_ta_HT_DCPHASE(
  SEXP inReal) {
  // clang-format on
  int protect_count = 0;

  const double *restrict in_real = REAL(inReal);
  const int n = LENGTH(inReal);

  SEXP output;
  double *output_ptr;

  const int lookback = TA_HT_DCPHASE_Lookback();

  // clang-format off
  const int proceed = output_container(
    n,
    lookback,
    1,
    &output,
    &output_ptr,
    &protect_count
  );
  // clang-format on

  if (proceed) {
    int start_idx = 0;
    int number_of_elements = 0;

    // clang-format off
    TA_RetCode return_code = TA_HT_DCPHASE(
      /*startIdx     */ 0,
      /*endIdx       */ n - 1,
      /*inReal       */ in_real,
      /*outBegIdx    */ &start_idx,
      /*outNbElement */ &number_of_elements,
      /*outReal      */ output_ptr
    );
    // clang-format on

    check_output(return_code, protect_count);
    shift_array(output_ptr, n, start_idx);
  }

  set_colnames(output, "DCPHASE");

  UNPROTECT(protect_count);
  return output;
}
