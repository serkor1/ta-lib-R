// talib_wrap.h
//
// Description:
//  This header file extracts and parses
//  all arguments from each TA_INDICATOR located
//  in TA-Lib.h using X-Macros
#ifndef TALIB_WRAP_H
#define TALIB_WRAP_H

#include "NA-handling.h"
#include "attributes.h"
#include "names.h"
#include "normalize.h"
#include "preprocessor.h"
#include "shift.h"

// Extract nested expressions from each
// TA_INDICATOR(...)
#define TA_INPUT(...) (__VA_ARGS__)
#define TA_OPTIONS(...) (__VA_ARGS__)
#define TA_OUTPUT(...) (__VA_ARGS__)
#define TA_OUTPUT_NAME(...) (__VA_ARGS__)

// Optional parameter(s) mapped to
// their R counterpart
#define OPTIONAL_INTEGER(n) (int, Rf_asInteger, n, )
#define OPTIONAL_DOUBLE(n) (double, Rf_asReal, n, )
#define OPTIONAL_MATYPE(n) (int, Rf_asInteger, n, (TA_MAType))

// output element type tag (TA_DOUBLE|TA_INTEGER) -> R type/accessor
#define TA_SXP(RT) TA_CAT(TA_SXP_, RT)
#define TA_SXP_TA_DOUBLE REALSXP
#define TA_SXP_TA_INTEGER INTSXP
#define TA_ACC(RT) TA_CAT(TA_ACC_, RT)
#define TA_ACC_TA_DOUBLE REAL
#define TA_ACC_TA_INTEGER INTEGER

// per-input workers
//   TA_IN_ARG / TA_OPT_ARG emit trailing-comma parameters; the fixed final
//   s_na_bridge parameter absorbs the last comma, so no first-argument special
//   case is needed (same trick as the TA_IN_PASS call list below).
#define TA_IN_ARG(name) SEXP s_##name,
#define TA_IN_COERCE(name)                                                     \
  const double *name = ta_real(s_##name, ta_n, &protection_counter, #name);
#define TA_IN_PASS(name) name,
// na.bridge workers: TA_IN_PTR builds the input-pointer array for mask
// construction; TA_IN_COMPACT gathers each input into its dense column and
// repoints the local pointer at it so the TA-Lib call below sees the dense
// series unchanged.
#define TA_IN_PTR(name) name,
#define TA_IN_COMPACT(name)                                                    \
  name = compact_array(ta_dense + ta_dcol * ta_calc, name, ta_mask, ta_n);     \
  ta_dcol++;

// per-opt workers (consume the tuple)
#define TA_OPT_ARG(t) TA_OPT_ARG_ t
#define TA_OPT_ARG_(c, r, n, k) SEXP s_##n,
#define TA_OPT_READ(t) TA_OPT_READ_ t
#define TA_OPT_READ_(c, r, n, k) c n = r(s_##n);
#define TA_OPT_PASS(t) TA_OPT_PASS_ t
#define TA_OPT_PASS_(c, r, n, k) k n,
// lookback-arg variant of TA_OPT_PASS: same casted value but WITHOUT a trailing
// comma, so TA_JOIN can build the TA_<NAME>_Lookback(...) call list.
#define TA_LB_PASS(t) TA_LB_PASS_ t
#define TA_LB_PASS_(c, r, n, k) k n

// no-comma sibling of TA_OPT_ARG: one SEXP parameter per opt, comma-joined via
// TA_JOIN to form the impl_ta_<NAME>_lookback(...) signature.
#define TA_LB_ARG(t) TA_LB_ARG_ t
#define TA_LB_ARG_(c, r, n, k) SEXP s_##n

// parameter list for impl_ta_<NAME>_lookback: (void) when the indicator takes
// no options (keeps -Wstrict-prototypes happy), otherwise the joined opts.
#define TA_LB_PARAMS(OPTS_)                                                    \
  TA_CAT(TA_LB_PARAMS_, TA_COUNT_ARGUMENTS OPTS_)(OPTS_)
#define TA_LB_PARAMS_0(OPTS_) void
#define TA_LB_PARAMS_1(OPTS_) TA_JOIN(TA_LB_ARG, OPTS_)
#define TA_LB_PARAMS_2(OPTS_) TA_JOIN(TA_LB_ARG, OPTS_)
#define TA_LB_PARAMS_3(OPTS_) TA_JOIN(TA_LB_ARG, OPTS_)
#define TA_LB_PARAMS_4(OPTS_) TA_JOIN(TA_LB_ARG, OPTS_)
#define TA_LB_PARAMS_5(OPTS_) TA_JOIN(TA_LB_ARG, OPTS_)
#define TA_LB_PARAMS_6(OPTS_) TA_JOIN(TA_LB_ARG, OPTS_)
#define TA_LB_PARAMS_7(OPTS_) TA_JOIN(TA_LB_ARG, OPTS_)
#define TA_LB_PARAMS_8(OPTS_) TA_JOIN(TA_LB_ARG, OPTS_)

//
#define TA_ALLOC(RT, OUTS_)                                                    \
  Rf_allocMatrix(TA_SXP(RT), (int)ta_n, (TA_COUNT_ARGUMENTS OUTS_))

#define TA_OUT_PTRS(RT, OUTS_)                                                 \
  TA_CAT(TA_OUT_PTRS_, TA_COUNT_ARGUMENTS OUTS_)(RT)
#define TA_OUT_PTRS_1(RT) TA_ACC(RT)(out)
#define TA_OUT_PTRS_2(RT) TA_ACC(RT)(out) + 0 * ta_n, TA_ACC(RT)(out) + 1 * ta_n
#define TA_OUT_PTRS_3(RT)                                                      \
  TA_ACC(RT)(out) + 0 * ta_n, TA_ACC(RT)(out) + 1 * ta_n,                      \
    TA_ACC(RT)(out) + 2 * ta_n

// One shift per output column; column count is a compile-time literal.
#define TA_OUT_PAD(RT, OUTS_)                                                  \
  for (int ta_col = 0; ta_col < (TA_COUNT_ARGUMENTS OUTS_); ta_col++)          \
    shift_array(TA_ACC(RT)(out) + ta_col * ta_n, ta_n, begIdx, nbElement);

// na.bridge counterpart of TA_OUT_PAD: expand each dense output column back
// to full length, scattering NA into dropped rows and lookback slots.
#define TA_OUT_SCATTER(RT, OUTS_)                                              \
  for (int ta_col = 0; ta_col < (TA_COUNT_ARGUMENTS OUTS_); ta_col++)          \
    scatter_array(                                                             \
      TA_ACC(RT)(out) + ta_col * ta_n,                                         \
      ta_n,                                                                    \
      ta_mask,                                                                 \
      ta_calc,                                                                 \
      begIdx,                                                                  \
      nbElement);

// colnames for the output matrix. Every indicator returns a matrix (single
// output included), so stringize every name into the array and label the
// matrix regardless of column count.
#define TA_OUT_COLNAME(a) #a,
#define TA_OUT_COLNAMES(NAMES_)                                                \
  TA_CAT(TA_OUT_COLNAMES_, TA_COUNT_ARGUMENTS NAMES_)(NAMES_)
#define TA_OUT_COLNAMES_1(NAMES_) TA_OUT_COLNAMES_MANY(NAMES_)
#define TA_OUT_COLNAMES_2(NAMES_) TA_OUT_COLNAMES_MANY(NAMES_)
#define TA_OUT_COLNAMES_3(NAMES_) TA_OUT_COLNAMES_MANY(NAMES_)
#define TA_OUT_COLNAMES_MANY(NAMES_)                                           \
  {                                                                            \
    static const char *ta_cn[] = {TA_APPLY(TA_OUT_COLNAME, NAMES_)};           \
    set_colnames(out, ta_cn, TA_COUNT_ARGUMENTS NAMES_);                       \
  }

// candlestick normalization seam
//   Only CANDLESTICK indicators carry the extra SEXP s_normalize control arg.
//   TA_NORM_ARG appends it to the signature; TA_NORM_APPLY divides the dense
//   computed region by 100 (before padding, so NA slots are never touched);
//   TA_NORM_ARITY bumps the registered .Call arity. NOT_CANDLESTICK -> nothing.
#define TA_NORM_ARG_CANDLESTICK , SEXP s_normalize
#define TA_NORM_ARG_NOT_CANDLESTICK

#define TA_NORM_APPLY_CANDLESTICK(RT)                                          \
  if (Rf_asLogical(s_normalize) == TRUE)                                       \
    normalize(TA_ACC(RT)(out), nbElement, 100, 0);
#define TA_NORM_APPLY_NOT_CANDLESTICK(RT)

#define TA_NORM_ARITY_CANDLESTICK 1
#define TA_NORM_ARITY_NOT_CANDLESTICK 0

// TA-Lib <indicator> wrapper
//
// Description
//    This is the X-macro that writes the actual
//    underlying C-code that ports TA-Lib to R.
//    Before the migrating to X-Macros the code below
//    were autogenerated via BASH which produced the ta_<indicator>.c files
// clang-format off
#define TA_WRAPPER(NAME, RT, INS_, OPTS_, OUTS_, TA_OUTPUT_NAME_, KIND)         \
  /* signature start */                                                         \
  SEXP impl_ta_##NAME(                                                          \
    TA_APPLY(TA_IN_ARG, INS_)                                                   \
    TA_APPLY(TA_OPT_ARG, OPTS_)                                                 \
    SEXP s_na_bridge                                                            \
    TA_CAT(TA_NORM_ARG_, KIND)                                                  \
  )                                                                             \
  /* signature end*/                                                            \
  /* logic start*/                                                              \
  {                                                                             \
    /* protection counter */                                                    \
    int protection_counter = 0;                                                 \
    R_xlen_t ta_n = XLENGTH(TA_CAT(s_, TA_HEAD INS_));                          \
                                                                                \
    if (ta_n > INT_MAX) {                                                       \
      Rf_error("TA_" #NAME ": series length exceeds INT_MAX");                  \
    }                                                                           \
                                                                                \
    /* convert input to type aware pointers */                                  \
    TA_APPLY(TA_IN_COERCE, INS_)                                                \
    TA_APPLY(TA_OPT_READ, OPTS_)                                                \
                                                                                \
    /* na.bridge: drop NA rows, compute on the dense series, scatter back. */   \
    int ta_bridge = (Rf_asLogical(s_na_bridge) == TRUE);                        \
    R_xlen_t ta_calc = ta_n;                                                    \
    unsigned char *ta_mask = NULL;                                              \
    if (ta_bridge && ta_n > 0) {                                                \
                                                                                \
      const double *ta_ins[] = {TA_APPLY(TA_IN_PTR, INS_)};                     \
                                                                                \
      ta_calc = build_presence_mask(                                            \
        ta_ins,                                                                 \
        (int)(TA_COUNT_ARGUMENTS INS_),                                         \
        ta_n,                                                                   \
        &ta_mask                                                                \
      );                                                                        \
                                                                                \
      if (ta_calc > 0) {                                                        \
        double *ta_dense = dense_array(                                         \
          ta_calc,                                                              \
          (int)(TA_COUNT_ARGUMENTS INS_)                                        \
        );                                                                      \
                                                                                \
        int ta_dcol = 0;                                                        \
                                                                                \
        TA_APPLY(TA_IN_COMPACT, INS_)                                           \
      }                                                                         \
    }                                                                           \
    SEXP out = PROTECT(TA_ALLOC(RT, OUTS_));                                    \
    protection_counter++;                                                       \
    int begIdx = 0, nbElement = 0;                                              \
    if (ta_calc > 0) {                                                          \
      TA_RetCode return_value = TA_##NAME(                                      \
        0,                                                                      \
        (int) ta_calc - 1,                                                      \
        TA_APPLY(TA_IN_PASS, INS_) TA_APPLY(TA_OPT_PASS, OPTS_) & begIdx,       \
        &nbElement,                                                             \
        TA_OUT_PTRS(RT, OUTS_)                                                  \
      );                                                                        \
                                                                                \
      ta_check(return_value, "TA_" #NAME);                                      \
                                                                                \
      TA_CAT(TA_NORM_APPLY_, KIND)(RT)                                          \
    }                                                                           \
    if (ta_bridge) {                                                            \
      TA_OUT_SCATTER(RT, OUTS_)                                                 \
    } else if (ta_calc > 0) {                                                   \
      TA_OUT_PAD(RT, OUTS_)                                                     \
    }                                                                           \
    TA_OUT_COLNAMES(TA_OUTPUT_NAME_)                                            \
                                                                                \
    /* lookback attributes */                                                   \
    int lookback_value = TA_##NAME##_Lookback(TA_JOIN(TA_LB_PASS, OPTS_));      \
                                                                                \
    set_attribute(                                                              \
      out,                                                                      \
      LOOKBACK,                                                                 \
      Rf_ScalarInteger(lookback_value),                                         \
      &protection_counter                                                       \
    );                                                                          \
                                                                                \
    UNPROTECT(protection_counter);                                              \
    return out;                                                                 \
  }                                                                             \
  /* logic end*/
// clang-format on

// clang-format off
// TA_DECL
// 
// Description
//  Forward declaration of the TA_<indicator>-functions
//  
#define TA_DECL(NAME, RT, INS_, OPTS_, OUTS_, TA_OUTPUT_NAME_, KIND)  \
      extern SEXP impl_ta_##NAME(                                     \
        TA_APPLY(TA_IN_ARG, INS_)                                     \
        TA_APPLY(TA_OPT_ARG, OPTS_)                                   \
        SEXP s_na_bridge                                              \
        TA_CAT(TA_NORM_ARG_, KIND)                                    \
      );
// clang-format on

// R_CallMethodDef row: arity = #inputs + #opts.
// The registration STRING (not the C symbol) is what R names the routine.
// With useDynLib(.fixes = "C_"), R exposes C_ + this string, so register
// "impl_ta_" #NAME to match the generated .Call(C_impl_ta_<NAME>, ...).
#define TA_REG(NAME, RT, INS_, OPTS_, OUTS_, TA_OUTPUT_NAME_, KIND)            \
  {"impl_ta_" #NAME,                                                           \
   (DL_FUNC) & impl_ta_##NAME,                                                 \
   (TA_COUNT_ARGUMENTS INS_) + (TA_COUNT_ARGUMENTS OPTS_) + 1 +                \
     TA_CAT(TA_NORM_ARITY_, KIND)},

// TA_<NAME>_Lookback wrappers
//   Driven by the TA_LOOKBACK(NAME, TA_OPTIONS(...)) lines in TA-Lib.h. The
//   R-callable impl_ta_<NAME>_lookback(<opts>) reads the optional inputs from
//   their SEXPs, calls the pure TA_<NAME>_Lookback(), and returns the
//   (normalized) lookback - the same value set_attribute() attaches to the
//   indicator output.

// forward declaration
#define TA_LB_DECL(NAME, OPTS_)                                                \
  extern SEXP impl_ta_##NAME##_lookback(TA_LB_PARAMS(OPTS_));

// definition
#define TA_LB_WRAPPER(NAME, OPTS_)                                             \
  SEXP impl_ta_##NAME##_lookback(TA_LB_PARAMS(OPTS_)) {                        \
    TA_APPLY(TA_OPT_READ, OPTS_)                                               \
    return Rf_ScalarInteger(                                                   \
      normalize_lookback(TA_##NAME##_Lookback(TA_JOIN(TA_LB_PASS, OPTS_))));   \
  }

// R_CallMethodDef row: arity = #opts (no inputs, no na_bridge).
#define TA_LB_REG(NAME, OPTS_)                                                 \
  {"impl_ta_" #NAME "_lookback",                                               \
   (DL_FUNC) & impl_ta_##NAME##_lookback,                                      \
   TA_COUNT_ARGUMENTS OPTS_},

#endif /* TALIB_WRAP_H */
