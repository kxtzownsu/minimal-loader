#!/usr/bin/env bash

set -euo pipefail

UTIL_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$UTIL_DIR/common/signed_header.sh"
source "$UTIL_DIR/common/utils.sh"

usage() {
  echo "$0: [ro_a.bin.signed] [ro_b.bin.signed] [rw_a.bin.signed] [rw_b.bin.signed] [output.bin]"
}

main() {
  (( $# == 5 )) || {
    usage
    exit 1
  }

  local ro_a_signedblob=$1
  local ro_b_signedblob=$2
  local rw_a_signedblob=$3
  local rw_b_signedblob=$4
  local output=$5

  verify_header_layout

  local image_magic blob_magic final_size block_size
  [ -f "$ro_a_signedblob" ] || die "RO_A missing file: $ro_a_signedblob"
  image_magic=$(magic_at "$ro_a_signedblob")
  supported_magic "$image_magic" || die "RO_A invalid magic: $(fmt_hex "$image_magic")"

  verify_blob "$ro_a_signedblob" ${CONFIG_RO_A_BASE} "RO_A"
  verify_blob "$rw_a_signedblob" ${CONFIG_RW_A_BASE} "RW_A"

  verify_blob "$ro_b_signedblob" ${CONFIG_RO_B_BASE} "RO_B"
  verify_blob "$rw_b_signedblob" ${CONFIG_RW_B_BASE} "RW_B"

  for blob in "$rw_a_signedblob" "$ro_b_signedblob" "$rw_b_signedblob"; do
    blob_magic=$(magic_at "$blob")
    if (( blob_magic != image_magic )); then
      die "$blob magic mismatch: $(fmt_hex "$blob_magic") expected $(fmt_hex "$image_magic")"
    fi
  done

  final_size=${CONFIG_FLASH_SIZE}
  block_size=$(( CONFIG_FLASH_BANK_SIZE ))

  echo "creating final image: $output size=$(fmt_hex "$final_size")"

  rm -f "$output"
  truncate -s "$final_size" "$output"
  dd if=/dev/zero bs="$block_size" count="$(( final_size / CONFIG_FLASH_BANK_SIZE ))" status=none |
    tr '\000' '\377' |
    dd of="$output" bs="$block_size" conv=notrunc status=none

  write_blob "$ro_a_signedblob" "$output" "$CONFIG_RO_A_OFFSET"
  write_blob "$rw_a_signedblob" "$output" "$CONFIG_RW_A_OFFSET"

  write_blob "$ro_b_signedblob" "$output" "$CONFIG_RO_B_OFFSET"
  write_blob "$rw_b_signedblob" "$output" "$CONFIG_RW_B_OFFSET"

  echo "success: $output is ready"
}

main "$@"
