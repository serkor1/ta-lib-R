#!/usr/bin/env bash
# generate_indicator_core.sh
# usage:
#   ./generate_indicator_core.sh MACD > impl_ta_MACD.c
#   TEMPLATE=indicator_template.c.in ./generate_indicator_core.sh ACCBANDS
set -euo pipefail

if [ "$#" -ne 1 ]; then
  echo "usage: $0 <TA_NAME>" >&2
  exit 1
fi
NAME="$1"

# 1) find header (new layout first)
if [ -f "src/ta-lib/include/ta-lib/ta_func.h" ]; then
  TA_H="src/ta-lib/include/ta-lib/ta_func.h"
elif [ -f "src/ta-lib/include/ta_func.h" ]; then
  TA_H="src/ta-lib/include/ta_func.h"
else
  echo "error: ta_func.h not found" >&2
  exit 1
fi

# 2) exact main prototype: must be TA_<NAME>( and must NOT contain TA_<NAME>_
proto_line=$(awk -v name="$NAME" '
  { gsub(/\/\*[^*]*\*\//, "", $0) }
  index($0, "TA_" name "(") {
    if (index($0, "TA_" name "_") != 0) next;
    line = $0
    while (line !~ /\);/) {
      getline nxt
      gsub(/\/\*[^*]*\*\//, "", nxt)
      line = line " " nxt
    }
    gsub(/[\r\n]+/, " ", line)
    print line
    exit
  }
' "$TA_H")
[ -n "$proto_line" ] || { echo "error: TA_${NAME}(...) not found" >&2; exit 1; }

param_list=${proto_line#*(}
param_list=${param_list%);}

# 3) exact lookback prototype
lb_line=$(awk -v name="$NAME" '
  { gsub(/\/\*[^*]*\*\//, "", $0) }
  index($0, "TA_" name "_Lookback(") {
    line = $0
    while (line !~ /\);/) {
      getline nxt
      gsub(/\/\*[^*]*\*\//, "", nxt)
      line = line " " nxt
    }
    gsub(/[\r\n]+/, " ", line)
    print line
    exit
  }
' "$TA_H")
[ -n "$lb_line" ] || { echo "error: TA_${NAME}_Lookback(...) not found" >&2; exit 1; }

lb_params=${lb_line#*(}
lb_params=${lb_params%);}

# 4) classify params
declare -a in_arrays_type=()
declare -a in_arrays_name=()
declare -a in_scalars_type=()
declare -a in_scalars_name=()
declare -a out_arrays_type=()
declare -a out_arrays_name=()

IFS=',' read -r -a params <<<"$param_list"
for raw in "${params[@]}"; do
  p=$(echo "$raw" | sed 's:/\*[^*]*\*/::g; s/^[[:space:]]*//; s/[[:space:]]*$//')

  [[ "$p" =~ ^int[[:space:]]+startIdx$ ]] && continue
  [[ "$p" =~ ^int[[:space:]]+endIdx$ ]] && continue
  [[ "$p" =~ ^int[[:space:]]+\*outBegIdx$ ]] && continue
  [[ "$p" =~ ^int[[:space:]]+\*outNBElement$ ]] && continue

  if [[ "$p" =~ ^double[[:space:]]+out([A-Za-z0-9_]+)\[\]$ ]]; then
    out_arrays_type+=("double")
    out_arrays_name+=("${BASH_REMATCH[1]}")
    continue
  fi
  if [[ "$p" =~ ^int[[:space:]]+out([A-Za-z0-9_]+)\[\]$ ]]; then
    out_arrays_type+=("int")
    out_arrays_name+=("${BASH_REMATCH[1]}")
    continue
  fi

  if [[ "$p" =~ ^const[[:space:]]+double[[:space:]]+([A-Za-z0-9_]+)\[\]$ ]]; then
    in_arrays_type+=("double")
    in_arrays_name+=("${BASH_REMATCH[1]}")
    continue
  fi
  if [[ "$p" =~ ^const[[:space:]]+int[[:space:]]+([A-Za-z0-9_]+)\[\]$ ]]; then
    in_arrays_type+=("int")
    in_arrays_name+=("${BASH_REMATCH[1]}")
    continue
  fi

  if [[ "$p" =~ ^TA_MAType[[:space:]]+([A-Za-z0-9_]+)$ ]]; then
    in_scalars_type+=("MAType")
    in_scalars_name+=("${BASH_REMATCH[1]}")
    continue
  fi
  if [[ "$p" =~ ^double[[:space:]]+([A-Za-z0-9_]+)$ ]]; then
    in_scalars_type+=("double")
    in_scalars_name+=("${BASH_REMATCH[1]}")
    continue
  fi
  if [[ "$p" =~ ^int[[:space:]]+([A-Za-z0-9_]+)$ ]]; then
    in_scalars_type+=("int")
    in_scalars_name+=("${BASH_REMATCH[1]}")
    continue
  fi
done

[ "${#in_arrays_name[@]}" -gt 0 ] || { echo "error: no array inputs" >&2; exit 1; }
[ "${#out_arrays_name[@]}" -gt 0 ] || { echo "error: no array outputs" >&2; exit 1; }

## 5) R signature
## 
## // clang-format off
## SEXP impl_ta_${NAME}($R_SIGNATURE)
## // clang-format on
##
## example output:
##
## // clang-format off
## SEXP impl_ta_AROONOSC(
## 	SEXP inHigh,
## 	SEXP inLow,
## 	SEXP optInTimePeriod
## )
## // clang-format on
##
R_SIGNATURE=$'\n'
for i in "${!in_arrays_name[@]}"; do
  R_SIGNATURE+=$'\tSEXP '"${in_arrays_name[$i]}"$',\n'
done
for i in "${!in_scalars_name[@]}"; do
  R_SIGNATURE+=$'\tSEXP '"${in_scalars_name[$i]}"$',\n'
done
R_SIGNATURE=${R_SIGNATURE%$',\n'}; R_SIGNATURE+=$'\n'

## 6) PARAM_DOC
##
## // Parameters
## // $PARAM_DOC
## // Returns
##
## example output:
## 
## // Parameters
## // 		double  inHigh
## // 		double  inLow
## // 		integer optInTimePeriod
## //
##
PARAM_DOC=$''
for i in "${!in_arrays_name[@]}"; do
  n=${in_arrays_name[$i]}
  t=${in_arrays_type[$i]}
  if [ "$t" = "double" ]; then
    PARAM_DOC+=$'\t\tdouble  '"$n"$'\n// '
  else
    PARAM_DOC+=$'\t\tinteger '"$n"$'\n'
  fi
done
for i in "${!in_scalars_name[@]}"; do
  n=${in_scalars_name[$i]}
  t=${in_scalars_type[$i]}
  case "$t" in
    int)    PARAM_DOC+=$'\t\tinteger '"$n"$'\n//' ;;
    double) PARAM_DOC+=$'\t\tdouble  '"$n"$'\n//' ;;
    MAType) PARAM_DOC+=$'\t\tinteger '"$n"$' (MAType)\n//' ;;
  esac
done

## 7) VALUES
## 
## // pointers to input
## $VALUES
##
##
## 7.1) length of the input array
## 
## example output:
## 
## // get length of 'inHigh' (assumes equal length across input)
##   const int n = LENGTH(inHigh);
VALUES=$''
first_arr_name=${in_arrays_name[0]}
first_arr_type=${in_arrays_type[0]}
VALUES+=$'// get length of \''"${first_arr_name}"$'\' (assumes equal length across input)\n'
VALUES+=$'int n = LENGTH('"${first_arr_name}"$');\n\n'

## 7.2) extract the input array(s)
## 
## example output:
## 
##  // pointers to input arrays
##  const double *restrict inHigh_ptr = REAL(inHigh);
##  const double *restrict inLow_ptr = REAL(inLow);
if [ "$first_arr_type" = "double" ]; then
  VALUES+=$'// pointers to input arrays\n'
  VALUES+=$'const double *'"${first_arr_name}"$'_ptr = REAL('"${first_arr_name}"$');\n'
else
  VALUES+=$'const int *'"${first_arr_name}"$'_ptr = INTEGER('"${first_arr_name}"$');\n'
fi
for i in "${!in_arrays_name[@]}"; do
  [ "$i" -eq 0 ] && continue
  n=${in_arrays_name[$i]}
  t=${in_arrays_type[$i]}
  if [ "$t" = "double" ]; then
    VALUES+=$'const double *'"$n"$'_ptr = REAL('"$n"$');\n'
  else
    VALUES+=$'const int *'"$n"$'_ptr = INTEGER('"$n"$');\n'
  fi
done

## 7.3) extract the input argumetns(s)
## 
## example output:
## 
##  // extract input values
##  const int optInTimePeriod_ptr = INTEGER(optInTimePeriod)[0];
if [ "${#in_scalars_name[@]}" -gt 0 ]; then
  VALUES+=$'\n// extract input values\n'
fi
for i in "${!in_scalars_name[@]}"; do
  n=${in_scalars_name[$i]}
  t=${in_scalars_type[$i]}
  case "$t" in
    int)    VALUES+=$'const int '"$n"$'_value = INTEGER('"$n"$')[0];\n' ;;
    double) VALUES+=$'const double '"$n"$'_value = REAL('"$n"$')[0];\n' ;;
    MAType) VALUES+=$'const TA_MAType '"$n"$'_value = as_MAType('"$n"$');\n' ;;
  esac
done

## 8) Lookback args
##
##  // calculate look back and exit
##  // the function function early if
##  // there is a mismatch
##  const int lookback = TA_${NAME}_Lookback(
##         $LOOKBACK_ARGS
##  );
##
LOOKBACK_ARGS=""
IFS=',' read -r -a lbps <<<"$lb_params"
for raw in "${lbps[@]}"; do
  # strip /* ... */ and trim
  p=$(echo "$raw" | sed 's:/\*[^*]*\*/::g; s/^[[:space:]]*//; s/[[:space:]]*$//')
  [ -z "$p" ] && continue

  # split into words
  read -r -a toks <<<"$p"

  name=""
  for ((idx=${#toks[@]}-1; idx>=0; idx--)); do
    tok=${toks[$idx]}
    tok=${tok%,}
    tok=${tok%);}
    tok=${tok%)}
    tok=${tok%;}
    [ -z "$tok" ] && continue
    if [ "$tok" = "void" ]; then
      name=""
      break
    fi
    name="$tok"
    break
  done
  [ -z "$name" ] && continue
  LOOKBACK_ARGS+="${name}_value, "
done

LOOKBACK_ARGS=${LOOKBACK_ARGS%, }

if [ -n "$LOOKBACK_ARGS" ]; then
  LOOKBACK_ARGS=$''"$LOOKBACK_ARGS"$'\n'
fi

## 9) Value pointers
##
## TA_RetCode return_code = TA_${NAME}(
##          0,
##            n - 1,
##            $VALUE_POINTERS,
##            &start_idx,
##            &end_idx,
##            $OUTPUT_POINTERS
##        );
##
## NOTE: It doesnt quite work as expected
##       but clang-format handles the rest
VALUE_POINTERS=$''
for i in "${!in_arrays_name[@]}"; do
  VALUE_POINTERS+=$'\t\t'"${in_arrays_name[$i]}_ptr"$','
done
for i in "${!in_scalars_name[@]}"; do
  VALUE_POINTERS+=$'\t\t'"${in_scalars_name[$i]}_value"$','
done
VALUE_POINTERS=${VALUE_POINTERS%$''}

## 10) Outputs
##
## 10.1) constructs all output
##       values
OUT_COLS=${#out_arrays_name[@]}
first_out_type=${out_arrays_type[0]}

OUTPUT_COLS=$''
OUTPUT_POINTERS=$''
SHIFT_ARRAYS=$''
COLNAMES=()

for i in "${!out_arrays_name[@]}"; do
  on=${out_arrays_name[$i]}
  cbase=${on#out}
  clower=$(echo "$cbase" | tr '[:upper:]' '[:lower:]')
  if [ "$i" -eq 0 ]; then
    OUTPUT_COLS+=$''"${first_out_type}"$' *'"${clower}"$' = output_ptr;\n'
  else
    OUTPUT_COLS+=$''"${first_out_type}"$' *'"${clower}"$' = output_ptr + '"${i}"$' * n;\n'
  fi
  OUTPUT_POINTERS+=$''"${clower}"$',\n'
  SHIFT_ARRAYS+=$'shift_array('"${clower}"$', n, start_idx);\n'

  cname=${on#out}
  if [[ "$cname" == Real* ]]; then
    cname=${cname#Real}
  fi
  COLNAMES+=("$cname")
done
OUTPUT_POINTERS=${OUTPUT_POINTERS%,$'\n'}

## 10.2) column names
##
## // set the column names of the output
## // see names.h for more details
## $SET_COLUMN_NAMES
##
## example output:
##
## // set the column names of the output
## // see names.h for more details
## set_colnames(output, "AROONOSC");
if [ "$OUT_COLS" -eq 1 ]; then
  SET_COLUMN_NAMES="set_colnames(output, \"$NAME\");"
  RETURN_COLS="\"$NAME\""
else
  cn_join=""
  for c in "${COLNAMES[@]}"; do
    cn_join+="\"$c\", "
  done
  cn_join=${cn_join%, }
  SET_COLUMN_NAMES="set_colnames(output, $cn_join);"
  RETURN_COLS="$cn_join"
fi

## 10.3) output type
OUTPUT_TYPE=${out_arrays_type[0]}

## 11) NA handling code generation
##
## 11.1) build_na_mask call with all double input arrays
NA_MASK_PTRS=""
NA_N_ARRAYS=0
for i in "${!in_arrays_name[@]}"; do
  t=${in_arrays_type[$i]}
  if [ "$t" = "double" ]; then
    NA_MASK_PTRS+="${in_arrays_name[$i]}_ptr, "
    ((NA_N_ARRAYS++)) || true
  fi
done
NA_MASK_PTRS=${NA_MASK_PTRS%, }

NA_MASK_BUILD=$''
NA_MASK_BUILD+="const double *na_arrays[] = {${NA_MASK_PTRS}};"$'\n'
NA_MASK_BUILD+="        n = build_na_mask(na_mask, n, ${NA_N_ARRAYS}, na_arrays);"

## 11.2) compact_array calls for each double input
NA_COMPACT=$''
ci=0
for i in "${!in_arrays_name[@]}"; do
  t=${in_arrays_type[$i]}
  nm=${in_arrays_name[$i]}
  if [ "$t" = "double" ]; then
    NA_COMPACT+="double *compact_${ci} = (double *)R_alloc(n, sizeof(double));"$'\n'
    NA_COMPACT+="            compact_array(compact_${ci}, ${nm}_ptr, na_mask, n_original);"$'\n'
    NA_COMPACT+="            ${nm}_ptr = compact_${ci};"$'\n'
    ((ci++)) || true
  fi
done

# 12) export and run envsubst
export NAME
export R_SIGNATURE
export PARAM_DOC
export VALUES
export LOOKBACK_ARGS
export OUT_COLS
export OUTPUT_COLS
export VALUE_POINTERS
export END_IDX="&end_idx,"
export OUTPUT_POINTERS
export SHIFT_ARRAYS
export SET_COLUMN_NAMES
export RETURN_COLS
export OUTPUT_TYPE
export NA_MASK_BUILD
export NA_COMPACT

TEMPLATE_FILE=${TEMPLATE:-tools/templates/indicator_template.c.in}
envsubst < "$TEMPLATE_FILE"
