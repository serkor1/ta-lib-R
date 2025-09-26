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
// Generated from tools/generate_API.sh
#ifndef _API_H_
#define _API_H_

#include <Rinternals.h>

// clang-format off
EOF
}

extract_signatures() {
  awk '
    /^[[:space:]]*(static[[:space:]]+)?SEXP[[:space:]]+/ {
      sig = $0

      while (sig !~ /\{/ && sig !~ /;/) {
        if (getline <= 0) break
        sig = sig " " $0
      }
      
      if (sig ~ /\{/) {
        
        left = gsub(/\(/,"&",sig)
        right = gsub(/\)/,"&",sig)
        if (left == right) {
          
          sub(/\{.*$/,"",sig)
          
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
