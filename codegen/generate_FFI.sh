#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

if [[ $# -gt 2 ]]; then
  usage
fi

API_HEADER="${1:-api.h}"
OUT_FILE="${2:-init.c}"

print_header() {
  cat <<'EOF'
// Generated from codegen/generate_FFI.sh
#include <R.h>
#include <R_ext/Rdynload.h>
#include <Rinternals.h>
#include <stdlib.h>

#include "api.h"

// clang-format off
#define CALLDEF(name, n) {#name, (DL_FUNC) &name, n}
// clang-format on

static const R_CallMethodDef CallEntries[] = {
EOF
}

generate_entries() {
  awk '
    # Match prototype lines
    /^SEXP[[:space:]]+/ {
      sig = $0
      sub(/^SEXP[[:space:]]+/, "", sig)
      sub(/;[[:space:]]*$/, "", sig)

      # split name and argument list
      split(sig, parts, /\(/)
      name = parts[1]
      args = parts[2]
      sub(/\)$/, "", args)                  

      # count arguments: commas + 1 (or 0 if empty)
      if (args ~ /^[[:space:]]*$/) {
        n = 0
      } else {
        tmp = args
        n = gsub(/,/, ",", tmp) + 1
      }
      printf("  CALLDEF(%s, %d),\n", name, n)
    }
  ' "$API_HEADER"
  echo "  {NULL, NULL, 0}"
}

print_footer() {
  cat <<'EOF'
};
EOF
}

print_init() {
  cat <<EOF

void R_init_talib(DllInfo *dll) {
    R_registerRoutines(dll, NULL, CallEntries, NULL, NULL);
    R_useDynamicSymbols(dll, FALSE);
}
EOF
}

main() {
  echo "Generating ${OUT_FILE} from ${API_HEADER}..."
  print_header > "$OUT_FILE"
  generate_entries >> "$OUT_FILE"
  print_footer    >> "$OUT_FILE"
  print_init      >> "$OUT_FILE"
  echo "Done: $OUT_FILE"
}

main