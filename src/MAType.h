#ifndef _LIB_H_
#define _LIB_H_
// as_MAType
//
// Parameters:
//      x: SEXP
// Description
//      Syntactic sugar for mapping SEXP
//      to TA_MAType
#include "Rinternals.h"
#include "ta_defs.h"

static TA_MAType as_MAType(SEXP x) {
  int x_ = INTEGER(x)[0];
  return (TA_MAType)x_;
}

#endif // _LIB_H_
