#!/usr/bin/env bash
set -euo pipefail

## 1) inputs (env vars set by the R caller) and template selection
FAMILY=${FAMILY:-}
TITLE=${TITLE:-}
FUN=${FUN:?}
TA_FUN=${TA_FUN:?}
ALIAS=$TA_FUN
FORMULA=${FORMULA:-"~close"}
PLOTLY=${PLOTLY:-0}
SUBCHART=${SUBCHART:-0}
NUMERIC=${NUMERIC:-1}
AGNOSTIC=${AGNOSTIC:-"TRUE"}
CANDLESTICK=${CANDLESTICK:-0}
maType=${maType:--1}   # -1 == not a moving average
ROLLING=${ROLLING:-0}
OUTPUTFILE="R/ta_${TA_FUN}.R"

## main template — one per indicator family (mutually exclusive)
TEMPLATE_MAIN="codegen/templates/indicator_template.R.in"
if   [[ $CANDLESTICK -eq 1 ]]; then TEMPLATE_MAIN="codegen/templates/candlestick_template.R.in"
elif [[ "$maType" != "-1" ]];  then TEMPLATE_MAIN="codegen/templates/moving_average_template.R.in"
elif [[ "$ROLLING" != "0" ]];  then TEMPLATE_MAIN="codegen/templates/rolling_template.R.in"
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

## 3) export placeholders and restrict envsubst to exactly these names, so the
##    templates' own '$' usage (e.g. `state$sub`, `x$n`) is left untouched.
export FUN TITLE TA_FUN ALIAS FAMILY FORMULA ARGS PARGS CARGS CARGS_TYPED PPARGS AGNOSTIC maType SPEC_FIELDS
REPLACE='${FUN}${TITLE}${TA_FUN}${ALIAS}${FAMILY}${FORMULA}${ARGS}${PARGS}${CARGS}${CARGS_TYPED}${PPARGS}${AGNOSTIC}${maType}${SPEC_FIELDS}'

## 4) render the templates onto one accumulator, then splice (section 5).
##    Optional methods are appended with a blank-line separator; envsubst
##    writes straight onto the accumulator, so no per-template temp files.
tmp_render="$(mktemp)"; tmp_splice="$(mktemp)"
trap 'rm -f "$tmp_render" "$tmp_splice"' EXIT

## 4.1) main template
envsubst "$REPLACE" < "$TEMPLATE_MAIN" > "$tmp_render"

## 4.2) .numeric method — univariate, non-rolling indicators
if [[ $NUMERIC -eq 1 && $ROLLING -ne 1 ]]; then
  printf '\n\n' >> "$tmp_render"
  envsubst "$REPLACE" < codegen/templates/numeric_template.R.in >> "$tmp_render"
fi

## 4.3) .plotly method — standard indicators only
##      (candlestick/MA bake their plotly into the main template)
if [[ $PLOTLY -eq 1 ]]; then
  if [[ $SUBCHART -eq 1 ]]; then plotly=plotly_subchart_template.R.in
  else                          plotly=plotly_main_template.R.in; fi
  printf '\n\n' >> "$tmp_render"
  envsubst "$REPLACE" < "codegen/templates/$plotly" >> "$tmp_render"
fi

## 4.4) .ggplot method — appended for each charted family
ggplot=
if   [[ $CANDLESTICK -eq 1 ]];               then ggplot=candlestick_ggplot_template.R.in
elif [[ "$maType" != "-1" ]];                then ggplot=moving_average_ggplot_template.R.in
elif [[ $PLOTLY -eq 1 && $SUBCHART -eq 1 ]]; then ggplot=ggplot_subchart_template.R.in
elif [[ $PLOTLY -eq 1 ]];                    then ggplot=ggplot_main_template.R.in
fi
if [[ -n "$ggplot" ]]; then
  printf '\n\n' >> "$tmp_render"
  envsubst "$REPLACE" < "codegen/templates/$ggplot" >> "$tmp_render"
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
