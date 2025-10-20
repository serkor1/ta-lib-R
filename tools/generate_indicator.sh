#!/usr/bin/env bash
set -euo pipefail

## usage: ./generate_indicators.sh <FAMILY> <TITLE> <FUN> [SIGNATURE] <DEFAULT_FORMULA> [ALIAS] [OUTFILE]

FAMILY="${1:?}"; TITLE="${2:?}"; FUN="${3:?}"
shift 3

## decide SIGNATURE vs DEFAULT_FORMULA
SIGNATURE=""
if (($# == 0)); then
  echo "missing DEFAULT_FORMULA" >&2; exit 2
fi

if [[ ${1} == "~"* ]]; then
  ## called without SIGNATURE
  DEFAULT_FORMULA="${1}"; shift 1
else
  ## called with SIGNATURE
  SIGNATURE="${1}"; DEFAULT_FORMULA="${2:?}"; shift 2
fi

ALIAS="${1:-$FUN}"
OUT="${2:-R/ta_${ALIAS}.R}"

TEMPLATE="tools/indicator_template.R"
START="## input start"
END="## input end"

tmp1="$(mktemp)"; tmp2="$(mktemp)"
trap 'rm -f "$tmp1" "$tmp2"' EXIT

if [[ -n $SIGNATURE ]]; then
  SIG_FORMALS=$"${SIGNATURE},"
  SIG_ACTUALS=$",${SIGNATURE}"
else
  SIG_FORMALS=""
  SIG_ACTUALS=""
fi

## 1) render template
export FUN TITLE FAMILY ALIAS START END SIGNATURE DEFAULT_FORMULA SIG_FORMALS SIG_ACTUALS
envsubst <"$TEMPLATE" >"$tmp1"

## 2) splice preserved blocks by occurrence index
if [[ -f "$OUT" ]]; then
  awk -v s="$START" -v e="$END" '
    FNR==NR { if (index($0,s)) {on=1;i++;next}
              if (on && index($0,e)) {on=0;next}
              if (on) blocks[i]=blocks[i] $0 ORS; next }
    { if (index($0,s)) { print; idx++; if (idx in blocks){printf "%s",blocks[idx]; skip=1} else skip=0; next }
      if (skip && index($0,e)) { print; skip=0; next }
      if (skip) next
      print }' "$OUT" "$tmp1" >"$tmp2"
else
  cp "$tmp1" "$tmp2"
fi

mv "$tmp2" "$OUT"
