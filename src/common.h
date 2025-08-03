/* Common functionality
 *
 */
#ifndef _COMMON_H_
#define _COMMON_H_

// Parse moving average types
// Example: Bollinger Bands
static TA_MAType parse_ma_type(SEXP maTypeSEXP) {
  if (maTypeSEXP == R_NilValue || !isString(maTypeSEXP) ||
      LENGTH(maTypeSEXP) < 1)
    return TA_MAType_SMA;

  const char *s = CHAR(STRING_ELT(maTypeSEXP, 0));
  if (strcasecmp(s, "SMA") == 0)
    return TA_MAType_SMA;
  if (strcasecmp(s, "EMA") == 0)
    return TA_MAType_EMA;
  if (strcasecmp(s, "WMA") == 0)
    return TA_MAType_WMA;
  if (strcasecmp(s, "DEMA") == 0)
    return TA_MAType_DEMA;
  if (strcasecmp(s, "TEMA") == 0)
    return TA_MAType_TEMA;
  if (strcasecmp(s, "TRIMA") == 0)
    return TA_MAType_TRIMA;
  if (strcasecmp(s, "KAMA") == 0)
    return TA_MAType_KAMA;
  if (strcasecmp(s, "MAMA") == 0)
    return TA_MAType_MAMA;
  if (strcasecmp(s, "T3") == 0)
    return TA_MAType_T3;
  // fallback
  return TA_MAType_SMA;
}

#endif //_COMMON_H_