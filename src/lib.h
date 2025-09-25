// lib.h
//
// Description
//    Common high-level TA-lib agnostic functionality
//    and other implementations
#ifndef _LIB_H_
#define _LIB_H_

#define R_RANDOM_H
// R Headers
#include <R.h>
#include <Rdefines.h>
#include <Rinternals.h>

#undef R_RANDOM_H

// C Headers
#include "shift.h"
#include <string.h>

// Redifne integers to avoid
// R definition clashes
// clang-format off
#define Int32 TA_Lib_Int32
  #include <ta-lib/ta_libc.h>
#undef Int32
// clang-format on

#endif // _LIB_H_