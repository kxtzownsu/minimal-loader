#!/usr/bin/env bash

set -euo pipefail

UTIL_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$UTIL_DIR/common/signed_header.sh"
source "$UTIL_DIR/common/utils.sh"

usage() {
  cat <<EOF
make_final_img: build a final prod image from signed RO blobs and an existing RW image


usage:
  $0 <minimal-loader.ro_a.signed.bin> <minimal-loader.ro_b.signed.bin> <source-fw.bin.prod> <output.bin.prod>
  $0 -h|--help

arguments:
  NOTE: any signed RO blobs work, you don't need minimal-loader's specifically.

  minimal-loader.ro_a.signed.bin
      signed minimal-loader image for RO_A

  minimal-loader.ro_b.signed.bin
      signed minimal-loader image for RO_B

  source-fw.bin.prod
      512 KiB prod firmware image to copy RW_A and RW_B from

      it must contain the normal RO_A, RW_A, RO_B, and RW_B layout.
      RO_A and RO_B may be empty, because this script only uses the RW sections.

  output.bin.prod
      final output file. it does not need to exist beforehand, as the script
      will create it.

example:
  $0 build/minimal-loader.ro_a.signed.bin build/minimal-loader.ro_b.signed.bin cr50.bin.prod build/final.bin.prod
EOF
}

main(){
  (( $# == 4 )) || {
    usage
    exit 1
  }

  local ARG_BLOB_RO_A=$1
  local ARG_BLOB_RO_B=$2
  local ARG_SOURCEFW=$3
  local ARG_OUTPUT=$4

  local BLOB_RW_A=$(mktemp)
  local BLOB_RW_B=$(mktemp)

  # Ensure the files actually exist...
  for file in "$ARG_BLOB_RO_A" "$ARG_BLOB_RO_B" "$ARG_SOURCEFW"; do
    [ -f "$file" ] || die "missing file: $file"
  done

  verify_header_layout

  # Did the user give us valid signed blobs?
  verify_blob "$ARG_BLOB_RO_A" ${CONFIG_RO_A_BASE} "RO_A"
  verify_blob "$ARG_BLOB_RO_B" ${CONFIG_RO_B_BASE} "RO_B"

  # Now that we've made sure the files exist, we can start extracting.
  "${UTIL_DIR}"/carver.sh --input="${ARG_SOURCEFW}" --output="${BLOB_RW_A}" --keep-header --section=RW
  "${UTIL_DIR}"/carver.sh --input="${ARG_SOURCEFW}" --output="${BLOB_RW_B}" --keep-header --section=RW --b

  # Make sure the user didn't pass an invalid file & that 
  # they actually gave us source firmware with valid RW
  # sections.
  verify_blob "$BLOB_RW_A" ${CONFIG_RW_A_BASE} "RW_A"
  verify_blob "$BLOB_RW_B" ${CONFIG_RW_B_BASE} "RW_B"


  # Everything is valid, we can pack it all together now.
  "${UTIL_DIR}"/packer.sh "${ARG_BLOB_RO_A}" "${ARG_BLOB_RO_B}" "${BLOB_RW_A}" "${BLOB_RW_B}" "${ARG_OUTPUT}"

  # We don't need these anymore
  rm -rf "${BLOB_RW_A}" "${BLOB_RW_B}"

  return 0
}

main "$@"