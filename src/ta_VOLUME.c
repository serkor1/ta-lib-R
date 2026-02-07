// Volume Indicator
//
// Parameters
//   double inReal
//   list   maSpec
//
// Returns
//   matrix (n x k) where k is the number of
//   maSpecs
//
// Details
//   maSpec is a list of integers
//
// TODO: Simplify this program
#include "MAType.h"
#include "container.h"
#include "lib.h"
#include "names.h"
#include "shift.h"
#include "ta_MA.h"
#include <R.h>
#include <Rinternals.h>
#include <string.h>
#include <ta_libc.h>

// clang-format off
SEXP impl_ta_VOLUME(
    SEXP inReal,
    SEXP maSpec
)
// clang-format on
{

  // return 'inReal' if 'maSpec' is empty
  // or NULL
  if (isNull(maSpec) || LENGTH(maSpec) == 0) {
    return inReal;
  }

  // protection counter
  int protection_count = 0;

  // get length of 'inReal' (assumes equal length across input)
  const int n = LENGTH(inReal);

  // pointers to input arrays
  const double *restrict inReal_ptr = REAL(inReal);

  // extract values passed downstream
  // to impl_ta_MA
  const int n_ma = LENGTH(maSpec);
  const int n_cols = 1 + n_ma; // VOLUME + each MA

  // output
  SEXP output;
  double *restrict output_ptr;

  // construct output container with
  // lookback set to 0 (lookbacks are handled by impl_ta_MA)
  const int proceed =
    output_container(n, 0, n_cols, &output, &output_ptr, &protection_count);

  // copy inReal to the output
  // container
  // clang-format off
  memcpy(
    output_ptr, 
    inReal_ptr, 
    (size_t) n * sizeof(double)
  );
  // clang-format on

  // prepare column names for the output container
  // (determined at runtime)
  const char **colname = (const char **)R_alloc((size_t)n_cols, sizeof(char *));

  // first column name is *always* VOLUME
  colname[0] = "VOLUME";

  for (int j = 0; j < n_ma; ++j) {
    int protect_inner = 0;

    // extract specifications
    SEXP spec = VECTOR_ELT(maSpec, j);

    // pointers to specification
    const int *spec_ptr = INTEGER(spec);

    // values
    const int optInTimePeriod = spec_ptr[0];
    const int optInMAType = spec_ptr[1];

    // impl_ta_MA expects SEXP
    // clang-format off
    SEXP period_sexp = PROTECT(
      ScalarInteger(optInTimePeriod)
    ); protect_inner++;
    SEXP maType_sexp = PROTECT(
      ScalarInteger(optInMAType)
    ); protect_inner++;
    // clang-format on

    // calculate Moving Averages
    // clang-format off
    SEXP ma_res = PROTECT(
      impl_ta_MA(
        inReal, 
        period_sexp, 
        maType_sexp
      )
    ); protect_inner++;
    // clang-format on

    // pointer to results
    double *ma_ptr = REAL(ma_res);

    // copy to output
    double *col_ptr = output_ptr + (size_t)(j + 1) * n;

    // clang-format off
    memcpy(
      col_ptr, 
      ma_ptr, 
      (size_t)n * sizeof(double)
    );
    // clang-format on

    // construct column names
    // as TA_MAType+optInTimePeriod
    // ie. SMA17
    // see see names.h for more details
    const char *maTypeName = _MAType_((TA_MAType)optInMAType);
    char *name_buffer = (char *)R_alloc(32, sizeof(char));

    // clang-format off
    snprintf(
      name_buffer, 
      32, 
      "%s%d", 
      maTypeName, 
      optInTimePeriod
    );
    // clang-format on

    colname[j + 1] = name_buffer;

    UNPROTECT(protect_inner);
  }

  // set column names
  column_names(output, n_cols, colname);

  UNPROTECT(protection_count);
  return output;
}
