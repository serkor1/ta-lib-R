#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

usage() {
  cat <<EOF >&2
Usage: ${0##*/} [SRC_DIR] [OUT_FILE]
  SRC_DIR   Directory with .c sources (default: src)
  OUT_FILE  Header file to generate (default: api.h)
EOF
  exit 1
}

if [[ $# -gt 2 ]]; then
  usage
fi

SRC_DIR="${1:-src}"
OUT_FILE="${2:-api.h}"

print_header() {
  cat <<'EOF'
// Generated from codegen/generate_API.sh
#ifndef _API_H_
#define _API_H_

#include <Rinternals.h>

// clang-format off
EOF
}

extract_signatures() {
  awk '
    # start of an SEXP function (skip static — those are TU-local helpers,
    # not entry points, and declaring them in a shared header triggers
    # -Wunused-function for every TU that does not define them)
    /^[[:space:]]*SEXP[[:space:]]+/ {
      sig = $0

      # keep reading until we hit "{" or ";"
      while (sig !~ /\{/ && sig !~ /;/) {
        if (getline <= 0) break
        # skip pure formatter lines while collecting
        if ($0 ~ /^[[:space:]]*\/\/[[:space:]]*clang-format[[:space:]]+(on|off)/)
          continue
        sig = sig " " $0
      }

      # if the formatter marker still got attached at the end of sig, drop it
      sub(/[[:space:]]*\/\/[[:space:]]*clang-format[[:space:]]+(on|off)[[:space:]]*$/, "", sig)

      # only handle real definitions (we saw "{")
      if (sig ~ /\{/) {
        left  = gsub(/\(/, "&", sig)
        right = gsub(/\)/, "&", sig)
        if (left == right) {
          sub(/\{.*$/, "", sig)

          gsub(/[[:space:]]+/, " ", sig)
          sub(/^[[:space:]]+/, "", sig)
          sub(/[[:space:]]+$/, "", sig)
          gsub(/\( /, "(", sig)
          gsub(/ \)/, ")", sig)

          printf("%s;\n", sig)
        }
      }
    }
  ' "${SRC_DIR}"/*.c | sort -u
}


print_footer() {
  cat <<'EOF'
// clang-format on

#endif //_API_H
EOF
}

# === Main driver ===
main() {
  echo "Generating ${OUT_FILE} from C sources in ${SRC_DIR}/..."
  print_header > "${OUT_FILE}"
  extract_signatures >> "${OUT_FILE}"
  print_footer    >> "${OUT_FILE}"
  echo "Done: ${OUT_FILE}"
}

main
