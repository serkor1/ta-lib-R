#!/usr/bin/env bash
set -euo pipefail

NAME=$1
SIGNATURE=$2
TEMPLATE=tools/templates/candlestick_template.c.in

if [[ -n "$SIGNATURE" ]]; then
  PEN_ARG=$',\n\tSEXP optInPenetration'
  PEN_READ='const double penetration = REAL(optInPenetration)[0];'
  LOOKBACK="TA_${NAME}_Lookback(penetration);"
  PEN_CALL=', penetration'
  PEN_TEMP=$'\n//\t\tdouble\toptInPenetration'
else
  PEN_ARG=''
  PEN_READ=''
  LOOKBACK="TA_${NAME}_Lookback();"
  PEN_CALL=''
  PEN_TEMP=$''
fi

export NAME LOOKBACK PEN_READ PEN_ARG PEN_CALL PEN_TEMP

OUTFILE="src/ta_${NAME}.c"

# convert {{VAR}} → ${VAR} then envsubst
sed -e 's/{{\([A-Z_][A-Z_0-9]*\)}}/${\1}/g' "$TEMPLATE" \
  | envsubst \
  > "$OUTFILE"
