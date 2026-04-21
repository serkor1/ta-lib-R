#!/usr/bin/env bash
set -euo pipefail

## 1) environment variables
##    and templates passed downstream
##
## 1.1) common variables and templates
FAMILY=${FAMILY:-}
TITLE=${TITLE:-}
FUN=${FUN:?}
TA_FUN=${TA_FUN:?}
ALIAS=${ALIAS:-$TA_FUN}
FORMULA=${FORMULA:-"~close"}
PLOTLY=${PLOTLY:-0}
SUBCHART=${SUBCHART:-0}
NUMERIC=${NUMERIC:-1}
OUTPUTFILE=${OUTPUTFILE:-"R/ta_${TA_FUN}.R"}

## 1.1) conditional templates
##      passed downstream
TEMPLATE_MAIN=${TEMPLATE_MAIN:-codegen/templates/indicator_template.R.in}
TEMPLATE_NUMERIC=${NUMERIC_TEMPLATE:-codegen/templates/numeric_template.R.in}

## 1.2) candlestick specific variables
##      passed downstream
AGNOSTIC=${AGNOSTIC:-"TRUE"}
CANDLESTICK=${CANDLESTICK:-0}
if [[ $CANDLESTICK -eq 1 ]]; then
  TEMPLATE_MAIN="codegen/templates/candlestick_template.R.in"
fi

## 1.3) moving average specific
##      variables
maType=${maType:--1} # NOTE: -1 is NO MA
if [[ "$maType" != "-1" ]]; then
  TEMPLATE_MAIN="codegen/templates/moving_average_template.R.in"
fi

## 1.4) rolling statistics
ROLLING=${ROLLING:-0}
if [[ "$ROLLING" != "0" ]]; then
  TEMPLATE_MAIN="codegen/templates/rolling_template.R.in"
fi

## 2) arguments passed into
##    each function is constructed
##    as an array. Has to be passed as
##    a vector from R
ARGS_ARRAY=( "$@" )

## 2.1) split the arguments by the first
##      '=' to avoid using awk
PARGS_ARR=() # arguments inside calls, becomes n = n, or k = k
CARGS_ARR=() # arguments inside .Call, becomes n, k
CARGS_TYPED_ARR=() # arguments inside .Call, type-coerced (as.integer/as.double)
SPEC_FIELDS_ARR=() # fields for MA spec-mode list(...) (key = coerced-or-default)
HAS_N=0            # track whether 'n' is already a formal signature arg
for a in "${ARGS_ARRAY[@]}"; do
  if [[ $a == *=* ]]; then
    k=${a%%=*}
    v=${a#*=}
  else
    k=$a
    v=""
  fi
  [[ "$k" == "n" ]] && HAS_N=1
  PARGS_ARR+=( ",$k=$k" )
  CARGS_ARR+=( ",$k" )
  ## decide coercion by default-value shape: dot => double, else integer
  if [[ "$v" == *.* ]]; then
    CARGS_TYPED_ARR+=( ",as.double($k)" )
    SPEC_FIELDS_ARR+=( "$k = if (missing($k)) $v else as.double($k)" )
  else
    CARGS_TYPED_ARR+=( ",as.integer($k)" )
    SPEC_FIELDS_ARR+=( "$k = if (missing($k)) ${v}L else as.integer($k)" )
  fi
done

## 2.1.1) inject 'n' as a spec-only field for MAs whose signature
##        lacks it (today: MAMA). Every MA spec carries 'n' so that
##        downstream consumers (BBANDS, STOCH, MACDEXT, ...) can
##        read ma$n uniformly to drive their calculation period.
##        The R function accepts 'n' as a formal arg so MAMA(n = 14)
##        parses in spec-mode, but it is NOT forwarded to .Call()
##        (TA_MAMA's C signature takes no period).
if [[ "$maType" != "-1" && $HAS_N -eq 0 ]]; then
  _n_default=${N_DEFAULT:-30}
  ## prepend so 'n' is the first spec field and first forwarding arg,
  ## matching the ordering used by the n-bearing MAs.
  SPEC_FIELDS_ARR=( "n = if (missing(n)) ${_n_default}L else as.integer(n)" "${SPEC_FIELDS_ARR[@]}" )
  PARGS_ARR=( ",n=n" "${PARGS_ARR[@]}" )
  ARGS_ARRAY=( "n=${_n_default}" "${ARGS_ARRAY[@]}" )
  ## NOTE: deliberately NOT adding to CARGS_ARR / CARGS_TYPED_ARR -
  ## the C wrapper for MAMA has no period parameter.
fi

## 2.2) construct arguments 
##      a la paste + collapse
PARGS=$(printf '%s ' "${PARGS_ARR[@]}"); PARGS=${PARGS%, }
if [[ "$ROLLING" != "1" ]]; then
  if [[ -n ${PARGS} ]]; then PARGS+=','; fi
fi

printf -v ARGS '%s, ' "${ARGS_ARRAY[@]}"; ARGS=${ARGS%, }
if [[ "$ROLLING" != "1" ]]; then
  if [[ -n ${ARGS} ]]; then ARGS+=','; fi
fi
## NOTE: this is passed down to
##       the {plotly} template
PPARGS=$(printf '%s ' "${PARGS_ARR[@]}");
CARGS=$(printf '%s ' "${CARGS_ARR[@]}");
CARGS_TYPED=$(printf '%s ' "${CARGS_TYPED_ARR[@]}");

## 2.3) spec-mode list fields for the moving_average template.
##      Each signature argument becomes a round-tripped entry in
##      the list returned when the MA is called without 'x'.
##      Joined with ',' + newline + indent so 'air' can reformat.
SPEC_FIELDS=""
for ((_i=0; _i<${#SPEC_FIELDS_ARR[@]}; _i++)); do
  if [[ $_i -eq 0 ]]; then
    SPEC_FIELDS="${SPEC_FIELDS_ARR[$_i]}"
  else
    SPEC_FIELDS="${SPEC_FIELDS},"$'\n\t\t\t\t'"${SPEC_FIELDS_ARR[$_i]}"
  fi
done

## 3) export environment variables
##    to replace in templates
REPLACE=''
export FUN;      REPLACE+='${FUN}'
export TITLE;    REPLACE+='${TITLE}'
export TA_FUN;   REPLACE+='${TA_FUN}'
export ALIAS;    REPLACE+='${ALIAS}'
export FAMILY;   REPLACE+='${FAMILY}'
export FORMULA;  REPLACE+='${FORMULA}'
export ARGS;     REPLACE+='${ARGS}'
export PARGS;    REPLACE+='${PARGS}'
export CARGS;    REPLACE+='${CARGS}'
export CARGS_TYPED; REPLACE+='${CARGS_TYPED}'
export PPARGS;   REPLACE+='${PPARGS}'
export AGNOSTIC; REPLACE+='${AGNOSTIC}'
export maType;   REPLACE+='${maType}'
export N_DEFAULT; REPLACE+='${N_DEFAULT}'
export SPEC_FIELDS; REPLACE+='${SPEC_FIELDS}'

## 4) construct R files
##    in temporary locations
##    to avoid breaking existing code
tmp_render="$(mktemp)"; tmp_plotly="$(mktemp)"; tmp_numeric="$(mktemp)"; tmp_ggplot="$(mktemp)"; tmp_splice="$(mktemp)"
trap 'rm -f "$tmp_render" "$tmp_plotly" "$tmp_numeric" "$tmp_ggplot" "$tmp_splice"' EXIT

## 4.1) main template
envsubst "$REPLACE" < "$TEMPLATE_MAIN" > "$tmp_render"

## 4.2) optional templates
##      pre-appended with double linebreak
##      to avoid broken code
if [[ $NUMERIC -eq 1 && $ROLLING -ne 1 ]]; then
  envsubst "$REPLACE" < "$TEMPLATE_NUMERIC" > "$tmp_numeric"
  printf '\n\n' >> "$tmp_render"
  cat "$tmp_numeric" >> "$tmp_render"
fi

if [[ $PLOTLY -eq 1 ]]; then
  if [[ $SUBCHART -eq 1 ]]; then
  TEMPLATE_PLOTLY=${TEMPLATE_PLOTLY:-codegen/templates/plotly_subchart_template.R.in}
  envsubst "$REPLACE" < "$TEMPLATE_PLOTLY" > "$tmp_plotly"
  printf '\n\n' >> "$tmp_render"
  cat "$tmp_plotly" >> "$tmp_render"
  else
  TEMPLATE_PLOTLY=${TEMPLATE_PLOTLY:-codegen/templates/plotly_main_template.R.in}
  envsubst "$REPLACE" < "$TEMPLATE_PLOTLY" > "$tmp_plotly"
  printf '\n\n' >> "$tmp_render"
  cat "$tmp_plotly" >> "$tmp_render"
  fi
fi

## 4.4) ggplot2 templates
##      for candlestick and moving average templates
##      the ggplot method is appended separately since
##      their plotly methods are baked into the main template
if [[ $CANDLESTICK -eq 1 ]]; then
  envsubst "$REPLACE" < "codegen/templates/candlestick_ggplot_template.R.in" > "$tmp_ggplot"
  printf '\n\n' >> "$tmp_render"
  cat "$tmp_ggplot" >> "$tmp_render"
elif [[ "$maType" != "-1" ]]; then
  envsubst "$REPLACE" < "codegen/templates/moving_average_ggplot_template.R.in" > "$tmp_ggplot"
  printf '\n\n' >> "$tmp_render"
  cat "$tmp_ggplot" >> "$tmp_render"
elif [[ $PLOTLY -eq 1 ]]; then
  if [[ $SUBCHART -eq 1 ]]; then
  TEMPLATE_GGPLOT=${TEMPLATE_GGPLOT:-codegen/templates/ggplot_subchart_template.R.in}
  envsubst "$REPLACE" < "$TEMPLATE_GGPLOT" > "$tmp_ggplot"
  printf '\n\n' >> "$tmp_render"
  cat "$tmp_ggplot" >> "$tmp_render"
  else
  TEMPLATE_GGPLOT=${TEMPLATE_GGPLOT:-codegen/templates/ggplot_main_template.R.in}
  envsubst "$REPLACE" < "$TEMPLATE_GGPLOT" > "$tmp_ggplot"
  printf '\n\n' >> "$tmp_render"
  cat "$tmp_ggplot" >> "$tmp_render"
  fi
fi


## 5) splice protected code regions
##    (this is the old code, it works)
##    NOTE: use -s (exists AND non-empty). If the file exists but is
##    0 bytes, awk's FNR==NR pass-1 trick misfires: no records from
##    pass 1 means `tmp_render` gets consumed as pass 1 (harvest-only),
##    pass 2 never runs, and the output is empty. -s routes 0-byte
##    files through the `else` branch which copies the rendered template.
if [[ -s "$OUTPUTFILE" ]]; then
  awk '
    function rtrim(s){ sub(/[[:space:]]+$/,"",s); return s }
    function label_from(line, part,   pos,rest,needle) {
      needle = "splice:"
      pos = index(line, needle)
      if (!pos) return ""
      rest = substr(line, pos + length(needle))      # LABEL:part
      needle = ":" part
      pos = index(rest, needle)
      if (!pos) return ""
      return rtrim(substr(rest, 1, pos-1))
    }

    ## pass 1: harvest preserved bodies from existing OUTPUTFILE
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

    ## pass 2: write new file from staged template with preserved inserts
    {
      lbl = label_from($0, "start")
      if (lbl != "") {
        print                             # print the start marker
        end_lbl = lbl
        if (lbl in blocks) {
          printf "%s", blocks[lbl]
          preserve = 1
        } else {
          preserve = 0
        }
        while ( (getline line) > 0 ) {
          if (label_from(line,"end") == end_lbl) { print line; break }
          if (!preserve) print line
        }
        next
      }
      print
    }
  ' "$OUTPUTFILE" "$tmp_render" > "$tmp_splice"
else
  cp "$tmp_render" "$tmp_splice"
fi

## 6) commit the code
##    to R/
mv "$tmp_splice" "$OUTPUTFILE"
