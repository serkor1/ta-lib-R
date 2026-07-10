// TA-Lib-Map.h
//
// Description
//  This header file creates macros for mapping
//  TA-Lib indicators to (for the compiler) readable
//  arguments
//
#ifndef TALIB_MAP_H
#define TALIB_MAP_H

/* Token pasting with argument pre-expansion. */
#define TA_CAT(a, b) TA_CAT_(a, b)
#define TA_CAT_(a, b) a##b

// Strip paranthesis from an expression -
// can be used as follows: TA_STRIP_PARANTHESIS (a,b) -> a, b
#define TA_STRIP_PARANTHESIS(...) __VA_ARGS__

/* HEAD/TAIL, used via juxtaposition against a parenthesised group:
     TA_HEAD (a,b,c) -> a        TA_TAIL (a,b,c) -> b, c
     TA_HEAD (a)     -> a        TA_TAIL (a)     -> <empty> */
#define TA_HEAD(a, ...) a
#define TA_TAIL(a, ...) __VA_ARGS__

// Count the number of arguments given
// an expression - can be used as follows:
// #define FOO(SOME_MACRO_VALUE_) (TA_COUNT_ARGUMENTS SOME_MACRO_VALUE_)
#define TA_COUNT_ARGUMENTS(...)                                                \
  TA_COUNT_ARGUMENTS_(0 __VA_OPT__(, ) __VA_ARGS__, 8, 7, 6, 5, 4, 3, 2, 1, 0)
#define TA_COUNT_ARGUMENTS_(_0, _1, _2, _3, _4, _5, _6, _7, _8, N, ...) N

/* Apply worker m(x) to each element of a PARENTHESISED group (0..8 elements),
   results space-separated. The two indirections (TA_APPLY_D/_D_) let
   TA_COUNT_ARGUMENTS and TA_STRIP_PARANTHESIS of the group expand — revealing
   the element commas — before the TA_APPLY_<n> dispatcher enumerates them. */
#define TA_APPLY(m, group)                                                     \
  TA_APPLY_D(m, TA_COUNT_ARGUMENTS group, TA_STRIP_PARANTHESIS group)
#define TA_APPLY_D(m, n, ...) TA_APPLY_D_(m, n, __VA_ARGS__)
#define TA_APPLY_D_(m, n, ...) TA_CAT(TA_APPLY_, n)(m, __VA_ARGS__)
#define TA_APPLY_0(m, ...)
#define TA_APPLY_1(m, a) m(a)
#define TA_APPLY_2(m, a, ...) m(a) TA_APPLY_1(m, __VA_ARGS__)
#define TA_APPLY_3(m, a, ...) m(a) TA_APPLY_2(m, __VA_ARGS__)
#define TA_APPLY_4(m, a, ...) m(a) TA_APPLY_3(m, __VA_ARGS__)
#define TA_APPLY_5(m, a, ...) m(a) TA_APPLY_4(m, __VA_ARGS__)
#define TA_APPLY_6(m, a, ...) m(a) TA_APPLY_5(m, __VA_ARGS__)
#define TA_APPLY_7(m, a, ...) m(a) TA_APPLY_6(m, __VA_ARGS__)
#define TA_APPLY_8(m, a, ...) m(a) TA_APPLY_7(m, __VA_ARGS__)

#endif /* TALIB_MAP_H */
