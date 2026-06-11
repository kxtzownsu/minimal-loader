#!/usr/bin/env bash

set -euo pipefail

UTIL_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$UTIL_DIR/common/signed_header.sh"
source "$UTIL_DIR/common/utils.sh"

INPUT=
OUTPUT=
SECTION=
KEEP_HEADER=0
REGION_B=0
VERBOSE=0

usage() {
  cat <<EOF
carver: a minimal extraction utility for GSC images

usage: \`$0\` --input=[file] --output=[file] --section=[section] [flags]
example: \`$0\` --input=cr50.bin.prod --output=ro.bin.signed --section=RO --keep-header


flags:
    --cr50        - cr50 images (default. supports Haven & Citadel images)
    --keep-header - keep the SignedHeader
    --b           - extract from the B region
    --verbose     - verbose logging
    --help        - show this message

required flags:
    --output [file]     - output file
    --input  [file]     - input file (e.g: cr50.bin.prod)
    --section [section] - which section to extract (RO or RW)


carver originally written by HavenOverflow
EOF
}

parse_args() {
  while [ "$#" -gt 0 ]; do
    case "$1" in
      --input=*)
        INPUT=${1#*=}
        ;;
      --input)
        shift
        [ "$#" -gt 0 ] || die "--input needs a value"
        INPUT=$1
        ;;
      --output=*)
        OUTPUT=${1#*=}
        ;;
      --output)
        shift
        [ "$#" -gt 0 ] || die "--output needs a value"
        OUTPUT=$1
        ;;
      --section=*)
        SECTION=${1#*=}
        ;;
      --section)
        shift
        [ "$#" -gt 0 ] || die "--section needs a value"
        SECTION=$1
        ;;
      --cr50)
        ;;
      --keep-header)
        KEEP_HEADER=1
        ;;
      --b)
        REGION_B=1
        ;;
      --verbose)
        VERBOSE=1
        ;;
      --help)
        usage
        exit 0
        ;;
      *)
        die "unknown flag: $1"
        ;;
    esac
    shift
  done
}

validate_args() {
  [ -n "$INPUT" ] || die "--input is required"
  [ -n "$OUTPUT" ] || die "--output is required"
  [ -n "$SECTION" ] || die "--section is required"
  [ -f "$INPUT" ] || die "input file not found: $INPUT"

  SECTION=$(echo "$SECTION" | tr '[:lower:]' '[:upper:]')
  case "$SECTION" in
    RO|RW) ;;
    *) die "--section must be RO or RW" ;;
  esac
}

main() {
  parse_args "$@"
  validate_args

  local total offset size data_offset out_size ro_base expected_base name
  total=$(file_size "$INPUT")

  case "$SECTION:$REGION_B" in
    RO:0)
      name=RO_A
      offset=$CONFIG_RO_A_OFFSET
      expected_base=$CONFIG_RO_A_BASE
      ;;
    RW:0)
      name=RW_A
      offset=$CONFIG_RW_A_OFFSET
      expected_base=$CONFIG_RW_A_BASE
      ;;
    RO:1)
      name=RO_B
      offset=$CONFIG_RO_B_OFFSET
      expected_base=$CONFIG_RO_B_BASE
      ;;
    RW:1)
      name=RW_B
      offset=$CONFIG_RW_B_OFFSET
      expected_base=$CONFIG_RW_B_BASE
      ;;
    *)
      die "invalid section/region"
      ;;
  esac

  valid_signed_header_at "$INPUT" "$offset" "$total" || die "invalid $name header magic or layout"
  ro_base=$(read_u32 "$INPUT" "$(( offset + SHDR_OFF[ro_base] ))")
  (( ro_base == expected_base )) || die "$name base mismatch: header=$(fmt_hex "$ro_base") expected=$(fmt_hex "$expected_base")"
  size=$(image_size_at "$INPUT" "$offset")

  data_offset=$offset
  out_size=$size
  if (( ! KEEP_HEADER )); then
    data_offset=$(( data_offset + SIGNED_HEADER_SIZE ))
    out_size=$(( out_size - SIGNED_HEADER_SIZE ))
  fi

  (( out_size > 0 )) || die "calculated empty output"
  (( data_offset + out_size <= total )) || die "calculated range exceeds input size"

  log_verbose "section=$name"
  log_verbose "carving offset=$(fmt_hex "$data_offset") size=$(fmt_hex "$out_size")"

  read_blob "$INPUT" "$OUTPUT" "$data_offset" "$out_size"

  if (( ! KEEP_HEADER )); then
    trim_trailing_byte "$OUTPUT" ff
  fi
}

main "$@"
