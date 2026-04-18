#ifndef _MATYPE_H
#define _MATYPE_H
// as_MAType
//
// Parameters:
//      x: SEXP
// Description
//      Syntactic sugar for mapping SEXP
//      to TA_MAType
#include "Rinternals.h"
#include "ta_defs.h"

static inline TA_MAType as_MAType(SEXP x) {
  int x_ = INTEGER(x)[0];
  return (TA_MAType)x_;
}

// clang-format off
static inline const char *_MAType_(TA_MAType t) {
  static const char *const k[] = {
    "SMA",   
    "EMA",  
    "WMA",  
    "DEMA", 
    "TEMA",
    "TRIMA", 
    "KAMA", 
    "MAMA", 
    "T3"
  };
  unsigned u = (unsigned)t;
  return u < (sizeof k / sizeof k[0]) ? k[u] : "INVALID";
}
// clang-format on

#endif // _MATYPE_H
