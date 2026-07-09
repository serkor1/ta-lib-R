#ifndef TALIB_WRAP_H
#define TALIB_WRAP_H

#include "talib_map.h"

/* ---- list wrappers used inside the generated TA_FUNC rows.
   They PARENTHESISE their contents so the groups survive the
   TA_FUNC -> TA_BODY forwarding hop intact. ----------------------------------
 */
#define TA_INPUT(...) (__VA_ARGS__)
#define TA_OPTIONS(...) (__VA_ARGS__)
#define TA_OUTPUT(...) (__VA_ARGS__)
#define TA_OUTPUT_NAME(...) (__VA_ARGS__)

/* ---- optional-param tags -> (ctype, reader, name, call-cast) tuple ---------
 */
#define OPTIONAL_INTEGER(n) (int, Rf_asInteger, n, )
#define OPTIONAL_DOUBLE(n) (double, Rf_asReal, n, )
#define OPTIONAL_MATYPE(n) (int, Rf_asInteger, n, (TA_MAType))

/* ---- output element type tag (TA_DOUBLE|TA_INTEGER) -> R type/accessor/pad
 * --------
 */
#define TA_SXP(RT) TA_CAT(TA_SXP_, RT)
#define TA_SXP_TA_DOUBLE REALSXP
#define TA_SXP_TA_INTEGER INTSXP
#define TA_ACC(RT) TA_CAT(TA_ACC_, RT)
#define TA_ACC_TA_DOUBLE REAL
#define TA_ACC_TA_INTEGER INTEGER
#define TA_PAD(RT) TA_CAT(TA_PAD_, RT)
#define TA_PAD_TA_DOUBLE ta_pad_real
#define TA_PAD_TA_INTEGER ta_pad_int

/* ---- per-input workers -----------------------------------------------------
 */
#define TA_IN_ARG_LEAD(name) , SEXP s_##name
#define TA_IN_COERCE(name)                                                     \
  const double *name = ta_real(s_##name, ta_n, &nprot, #name);
#define TA_IN_PASS(name) name,

/* ---- per-opt workers (consume the tuple) -----------------------------------
 */
#define TA_OPT_ARG_LEAD(t) TA_OPT_ARG_LEAD_ t
#define TA_OPT_ARG_LEAD_(c, r, n, k) , SEXP s_##n
#define TA_OPT_READ(t) TA_OPT_READ_ t
#define TA_OPT_READ_(c, r, n, k) c n = r(s_##n);
#define TA_OPT_PASS(t) TA_OPT_PASS_ t
#define TA_OPT_PASS_(c, r, n, k) k n,

/* ---- outputs: alloc / call pointers / pad (dispatch on group size) ---------
 */
#define TA_ALLOC(RT, OUTS_) TA_CAT(TA_ALLOC_, TA_NARG OUTS_)(RT)
#define TA_ALLOC_1(RT) Rf_allocVector(TA_SXP(RT), ta_n)
#define TA_ALLOC_2(RT) Rf_allocMatrix(TA_SXP(RT), (int)ta_n, 2)
#define TA_ALLOC_3(RT) Rf_allocMatrix(TA_SXP(RT), (int)ta_n, 3)

#define TA_OUT_PTRS(RT, OUTS_) TA_CAT(TA_OUT_PTRS_, TA_NARG OUTS_)(RT)
#define TA_OUT_PTRS_1(RT) TA_ACC(RT)(out)
#define TA_OUT_PTRS_2(RT) TA_ACC(RT)(out) + 0 * ta_n, TA_ACC(RT)(out) + 1 * ta_n
#define TA_OUT_PTRS_3(RT)                                                      \
  TA_ACC(RT)(out) + 0 * ta_n, TA_ACC(RT)(out) + 1 * ta_n,                      \
    TA_ACC(RT)(out) + 2 * ta_n

#define TA_OUT_PAD(RT, OUTS_) TA_CAT(TA_OUT_PAD_, TA_NARG OUTS_)(RT)
#define TA_OUT_PAD_1(RT) TA_PAD(RT)(TA_ACC(RT)(out), ta_n, begIdx, nbElement);
#define TA_OUT_PAD_2(RT)                                                       \
  TA_PAD(RT)(TA_ACC(RT)(out) + 0 * ta_n, ta_n, begIdx, nbElement);             \
  TA_PAD(RT)(TA_ACC(RT)(out) + 1 * ta_n, ta_n, begIdx, nbElement);
#define TA_OUT_PAD_3(RT)                                                       \
  TA_PAD(RT)(TA_ACC(RT)(out) + 0 * ta_n, ta_n, begIdx, nbElement);             \
  TA_PAD(RT)(TA_ACC(RT)(out) + 1 * ta_n, ta_n, begIdx, nbElement);             \
  TA_PAD(RT)(TA_ACC(RT)(out) + 2 * ta_n, ta_n, begIdx, nbElement);

/* colnames only for a matrix (>1 output); dispatcher juxtaposes the group. */
#define TA_OUT_COLNAMES(TA_OUTPUT_NAME_)                                       \
  TA_CAT(TA_OUT_COLNAMES_, TA_NARG TA_OUTPUT_NAME_) TA_OUTPUT_NAME_
#define TA_OUT_COLNAMES_1(a)
#define TA_OUT_COLNAMES_2(a, b)                                                \
  {                                                                            \
    static const char *ta_cn[] = {#a, #b};                                     \
    ta_set_colnames(out, ta_cn, 2);                                            \
  }
#define TA_OUT_COLNAMES_3(a, b, c)                                             \
  {                                                                            \
    static const char *ta_cn[] = {#a, #b, #c};                                 \
    ta_set_colnames(out, ta_cn, 3);                                            \
  }

/* ---- the three expansions of one table row ---------------------------------
 */

/* Function body. INS_ has >= 1 input: emit the first param, then the remaining
   inputs and the opts with leading commas -> no trailing comma in the list. */
#define TA_BODY(NAME, RT, INS_, OPTS_, OUTS_, TA_OUTPUT_NAME_)                 \
  SEXP C_##NAME(                                                               \
    SEXP TA_CAT(s_, TA_HEAD INS_) TA_APPLY(TA_IN_ARG_LEAD, (TA_TAIL INS_))     \
      TA_APPLY(TA_OPT_ARG_LEAD, OPTS_)) {                                      \
    int nprot = 0;                                                             \
    R_xlen_t ta_n = XLENGTH(TA_CAT(s_, TA_HEAD INS_));                         \
    if (ta_n > INT_MAX)                                                        \
      Rf_error("TA_" #NAME ": series length exceeds INT_MAX");                 \
    TA_APPLY(TA_IN_COERCE, INS_)                                               \
    TA_APPLY(TA_OPT_READ, OPTS_)                                               \
    SEXP out = PROTECT(TA_ALLOC(RT, OUTS_));                                   \
    nprot++;                                                                   \
    if (ta_n > 0) {                                                            \
      int begIdx = 0, nbElement = 0;                                           \
      TA_RetCode rc = TA_##NAME(                                               \
        0,                                                                     \
        (int)ta_n - 1,                                                         \
        TA_APPLY(TA_IN_PASS, INS_) TA_APPLY(TA_OPT_PASS, OPTS_) & begIdx,      \
        &nbElement,                                                            \
        TA_OUT_PTRS(RT, OUTS_));                                               \
      ta_check(rc, "TA_" #NAME);                                               \
      TA_OUT_PAD(RT, OUTS_)                                                    \
    }                                                                          \
    TA_OUT_COLNAMES(TA_OUTPUT_NAME_)                                           \
    UNPROTECT(nprot);                                                          \
    return out;                                                                \
  }

/* Forward declaration (same parameter list as the body). */
#define TA_DECL(NAME, RT, INS_, OPTS_, OUTS_, TA_OUTPUT_NAME_)                 \
  extern SEXP C_##NAME(                                                        \
    SEXP TA_CAT(s_, TA_HEAD INS_) TA_APPLY(TA_IN_ARG_LEAD, (TA_TAIL INS_))     \
      TA_APPLY(TA_OPT_ARG_LEAD, OPTS_));

/* R_CallMethodDef row: arity = #inputs + #opts.
   Register the bare name; NAMESPACE's useDynLib(.fixes = "C_") adds the C_
   prefix. */
#define TA_REG(NAME, RT, INS_, OPTS_, OUTS_, TA_OUTPUT_NAME_)                  \
  {#NAME, (DL_FUNC) & C_##NAME, (TA_NARG INS_) + (TA_NARG OPTS_)},

#endif /* TALIB_WRAP_H */
