// Volume Indicator
//
// Parameters
//   inReal: numeric vector (volume)
//   maSpec: list of integer vectors c(n, MAType)
//
// Returns
//   Matrix with first column = VOLUME, remaining columns = requested MAs.
//   MA column names are MAType+period, e.g. "EMA10".
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
  int protection_count = 0;

  // length and pointer to volume
  const int n = LENGTH(inReal);
  const double *restrict inReal_ptr = REAL(inReal);

  // If no MAs requested, just return original inReal
  if (isNull(maSpec) || LENGTH(maSpec) == 0) {
    return inReal;
  }

  const int n_ma = LENGTH(maSpec);
  const int n_cols = 1 + n_ma; // VOLUME + each MA

  // output matrix via generic container helper
  SEXP output;
  double *restrict output_ptr;

  // no lookback requirement for the combined container itself
  (void)output_container(n, 0, n_cols, &output, &output_ptr, &protection_count);

  // first column: raw volume
  memcpy(output_ptr, inReal_ptr, (size_t)n * sizeof(double));

  // prepare column name storage for names.h::column_names
  const char **cn = (const char **)R_alloc((size_t)n_cols, sizeof(char *));
  cn[0] = "VOLUME";

  // build MA columns
  for (int j = 0; j < n_ma; ++j) {
    SEXP spec = VECTOR_ELT(maSpec, j);

    if (TYPEOF(spec) != INTSXP || LENGTH(spec) < 2) {
      UNPROTECT(protection_count);
      error("impl_ta_VOLUME: each maSpec element must be integer vector c(n, "
            "MaType)");
    }

    const int *spec_ptr = INTEGER(spec);
    const int period = spec_ptr[0];      // n
    const int ma_type_int = spec_ptr[1]; // MaType

    // wrap parameters for impl_ta_MA
    SEXP period_sexp = PROTECT(ScalarInteger(period));
    SEXP maType_sexp = PROTECT(ScalarInteger(ma_type_int));

    // call MA implementation; result is n x 1 REAL matrix
    SEXP ma_res = PROTECT(impl_ta_MA(inReal, period_sexp, maType_sexp));
    double *ma_ptr = REAL(ma_res);

    // copy MA into column j+1 (column-major)
    double *col_ptr = output_ptr + (size_t)(j + 1) * n;
    memcpy(col_ptr, ma_ptr, (size_t)n * sizeof(double));

    // build column name MAType+period, e.g. "EMA10"
    const char *ma_name = _MAType_((TA_MAType)ma_type_int);

    // allocate a small buffer from R's heap for the name
    char *name_buf = (char *)R_alloc(32, sizeof(char));
    snprintf(name_buf, 32, "%s%d", ma_name, period);
    cn[j + 1] = name_buf;

    UNPROTECT(3); // period_sexp, maType_sexp, ma_res
  }

  // set column names using names.h helper
  column_names(output, n_cols, cn);

  UNPROTECT(protection_count);
  return output;
}
