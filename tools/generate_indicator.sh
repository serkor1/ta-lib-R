#!/usr/bin/env bash
set -euo pipefail

## usage: ./generate_indicators.sh <FAMILY> <TITLE> <FUN> [SIGNATURE] <DEFAULT_FORMULA> [ALIAS] [OUTFILE]

FAMILY="${1:?}"; TITLE="${2:?}"; FUN="${3:?}"
shift 3

SIGNATURE=""
if (($# == 0)); then
  echo "missing DEFAULT_FORMULA" >&2; exit 2
fi

if [[ ${1} == "~"* ]]; then
  DEFAULT_FORMULA="${1}"; shift 1
else
  SIGNATURE="${1}"; DEFAULT_FORMULA="${2:?}"; shift 2
fi

ALIAS="${1:-$FUN}"
OUT="${2:-R/ta_${ALIAS}.R}"

TEMPLATE="tools/indicator_template.R"

tmp1="$(mktemp)"; tmp2="$(mktemp)"
trap 'rm -f "$tmp1" "$tmp2"' EXIT

if [[ -n $SIGNATURE ]]; then
  SIG_FORMALS="${SIGNATURE},"
  SIG_ACTUALS=",${SIGNATURE}"
else
  SIG_FORMALS=""
  SIG_ACTUALS=""
fi

if [[ -n $SIGNATURE ]]; then
  SIG_FORMALS="${SIGNATURE},"
  SIG_ACTUALS="$(
    awk -v s="$SIGNATURE" '
      BEGIN{
        gsub(/[[:space:]]+/,"",s)
        out=""; i=1; depth=0
        while (i<=length(s)) {
          c=substr(s,i,1)
          if (c=="(") { depth++; i++; continue }
          if (c==")") { if (depth>0) depth--; i++; continue }
          if (depth==0) {
            rem=substr(s,i)
            if (match(rem,/^([A-Za-z_.][A-Za-z0-9_.]*)=/)) {
              n=substr(rem,RSTART,RLENGTH-1)
              out = out (out?", ":"") n "=" n
              i += RLENGTH
              vdepth=0
              while (i<=length(s)) {
                c2=substr(s,i,1)
                if (c2=="(") vdepth++
                else if (c2==")" && vdepth>0) vdepth--
                else if (c2=="," && vdepth==0) { i++; break }
                i++
              }
              continue
            }
          }
          i++
        }
        if (out!="") print ", " out
      }'
  )"
else
  SIG_FORMALS=""; SIG_ACTUALS=""
fi


export FUN TITLE FAMILY ALIAS SIGNATURE DEFAULT_FORMULA SIG_FORMALS SIG_ACTUALS

## 1) render template
envsubst <"$TEMPLATE" >"$tmp1"

## 2) splice by label with POSIX awk
## markers must be lines like:
##   ## splice:LABEL:start
##   ... body ...
##   ## splice:LABEL:end
if [[ -f "$OUT" ]]; then
  awk '
    function rtrim(s){ sub(/[[:space:]]+$/,"",s); return s }
    function label_from(line, part,   pos,rest,needle) {
      needle = "splice:"
      pos = index(line, needle)
      if (!pos) return ""
      rest = substr(line, pos + length(needle))   # LABEL:part
      needle = ":" part
      pos = index(rest, needle)
      if (!pos) return ""
      return rtrim(substr(rest, 1, pos-1))
    }

    ## pass 1: harvest preserved bodies from existing OUT
    FNR==NR {
      lbl = label_from($0, "start")
      if (lbl != "") { cur = lbl; inside = 1; next }
      if (inside) {
        if (label_from($0, "end") == cur) { inside = 0; next }
        blocks[cur] = blocks[cur] $0 ORS
        next
      }
      next
    }

    ## pass 2: write new file from template with preserved inserts
    {
      lbl = label_from($0, "start")
      if (lbl != "") {
        print     # print the start marker
        end_lbl = lbl
        if (lbl in blocks) {
          printf "%s", blocks[lbl]
          preserve = 1
        } else {
          preserve = 0
        }
        # copy or skip template body until matching end marker
        while ( (getline line) > 0 ) {
          if (label_from(line,"end") == end_lbl) { print line; break }
          if (!preserve) print line
        }
        next
      }
      print
    }
  ' "$OUT" "$tmp1" >"$tmp2"
else
  cp "$tmp1" "$tmp2"
fi

mv "$tmp2" "$OUT"
