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

static TA_MAType as_MAType(SEXP x) {
  int x_ = INTEGER(x)[0];
  return (TA_MAType)x_;
}

#endif // _MATYPE_H
