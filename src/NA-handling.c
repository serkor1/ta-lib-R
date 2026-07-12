// <NA>-handling
//
// Description
//  TA-Lib does handle <NA>-values if passed into the
//  TA_<indicator>()-function—it returns all <NA> if a
//  single <NA> is passed via in*-arrays.
//
//  This C-routine strips all <NA> while recording their postional
//  index, and then reinserts them once the indicator is returned,
//  if (bool) na.bridge is passed as TRUE from the R-side.
//
#include <Rinternals.h>
#include <R_ext/Arith.h>
#include <R_ext/RS.h>
#include <string.h>

// clang-format off
#define TA_BIT_GET(bitmask, bit_index) \
    ((bitmask)[(R_xlen_t)(bit_index) >> 3] & (unsigned char) (1u << ((bit_index) & 7)))
#define TA_BIT_SET(bitmask, bit_index) \
    ((bitmask)[(R_xlen_t)(bit_index) >> 3] |= (unsigned char) (1u << ((bit_index) & 7)))
// clang-format on

// Build presence mask
//
// Description
//    A row is "present" iff every input column holds a finite value
//    (non-NA/NaN) at that index -- TA-Lib cannot consume either. Bit i of
//    `presence_mask` is set for every present row; dropped rows stay 0.
//    Returns the number of present rows, i.e. the dense length the
//    indicator is computed on.
//
// clang-format off
R_xlen_t build_presence_mask(
    const double *const *input_columns, // the k input columns, each n_rows long
    int k_columns,
    R_xlen_t n_rows,
    unsigned char **presence_mask       // out: allocated bitmask, one bit per row
)
// clang-format on
{
  // one bit per row, rounded up to whole bytes
  size_t nbytes = (size_t)((n_rows + 7) / 8);

  unsigned char *mask = (unsigned char *)R_alloc(nbytes, 1);
  memset(mask, 0, nbytes);

  R_xlen_t num_present = 0;
  for (R_xlen_t row = 0; row < n_rows; row++) {
    int present = 1;
    for (int col = 0; col < k_columns; col++) {
      if (ISNAN(input_columns[col][row])) {
        present = 0;
        break;
      }
    }
    if (present) {
      TA_BIT_SET(mask, row);
      num_present++;
    }
  }

  *presence_mask = mask;
  return num_present;
}

// Dense array
//
// Description
//    Allocates the dense (num_present_rows x k_columns) buffer that the
//    compacted inputs are gathered into before the indicator runs.
//
// clang-format off
double *dense_array(
    R_xlen_t num_present_rows,
    int k_columns
)
// clang-format on
{
  return (double *)R_alloc(
    (size_t)num_present_rows * (size_t)k_columns, sizeof(double));
}

// Compact array
//
// Description
//    Gathers the present rows of one full-length input column into the
//    front of `dense_column`, skipping the NA rows via `presence_mask`.
//
// clang-format off
double *compact_array(
    double *dense_column,               // out: present values, packed to the front
    const double *full_column,          // one full-length (n_rows) input column
    const unsigned char *presence_mask,
    R_xlen_t n_rows
)
// clang-format on
{
  R_xlen_t dense = 0;
  for (R_xlen_t row = 0; row < n_rows; row++) {
    if (TA_BIT_GET(presence_mask, row)) {
      dense_column[dense++] = full_column[row];
    }
  }
  return dense_column;
}

// Scatter array
//
// Description
//    Inverse of compact_array for a single output column. The dense TA-Lib
//    output occupies column[0 .. nbElement-1]; dense index d in
//    [0, num_present_rows) maps to the d-th present (set) row of
//    `presence_mask`. We walk original rows from the top down: because a
//    present row's original position is always >= its dense index, the raw
//    values can be expanded up into place without a second buffer.
//
//       d in [begIdx, num_present_rows)  -> raw value column[d - begIdx]
//       d in [0, begIdx)                 -> NA (lookback)
//       dropped rows                     -> NA
//
// clang-format off
void scatter_double_array(
    double *column,
    R_xlen_t n_rows,
    const unsigned char *presence_mask,
    R_xlen_t num_present_rows,
    int begIdx,    // TA-Lib lookback: leading dense rows with no output
    int nbElement  // TA-Lib output count: number of raw values produced
)
// clang-format on
{
  R_xlen_t dense = num_present_rows - 1;
  R_xlen_t raw = (R_xlen_t)nbElement - 1;
  for (R_xlen_t row = n_rows - 1; row >= 0; row--) {
    if (dense >= 0 && TA_BIT_GET(presence_mask, row)) {
      if (dense >= (R_xlen_t)begIdx && raw >= 0) {
        column[row] = column[raw];
        raw--;
      } else {
        column[row] = NA_REAL;
      }
      dense--;
    } else {
      column[row] = NA_REAL;
    }
  }
}

// clang-format off
void scatter_integer_array(
    int *column,
    R_xlen_t n_rows,
    const unsigned char *presence_mask,
    R_xlen_t num_present_rows,
    int begIdx,
    int nbElement
)
// clang-format on
{
  R_xlen_t dense = num_present_rows - 1;
  R_xlen_t raw = (R_xlen_t)nbElement - 1;
  for (R_xlen_t row = n_rows - 1; row >= 0; row--) {
    if (dense >= 0 && TA_BIT_GET(presence_mask, row)) {
      if (dense >= (R_xlen_t)begIdx && raw >= 0) {
        column[row] = column[raw];
        raw--;
      } else {
        column[row] = NA_INTEGER;
      }
      dense--;
    } else {
      column[row] = NA_INTEGER;
    }
  }
}
#undef TA_BIT_GET
#undef TA_BIT_SET

// Generic scatter_array
// clang-format off
#define scatter_array(column, n_rows, presence_mask, num_present_rows, begIdx, nbElement) \
   _Generic((column),                                                                     \
     double *: scatter_double_array,                                                      \
     int *:    scatter_integer_array                                                      \
   )((column), (n_rows), (presence_mask), (num_present_rows), (begIdx), (nbElement))
// clang-format on
