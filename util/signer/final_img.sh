#!/usr/bin/env bash

set -euo pipefail

MAGIC_HAVEN=0xffffffff
MAGIC_DAUNTLESS=0xfffffffd
SIGNED_HEADER_SIZE=0x400

# SHDR == SignedHeader
# OFF == Offsets

declare -A SHDR_OFF=(
  [magic]=0x000
  [signature]=0x004
  [img_chk_]=0x184
  [tag]=0x188
  [keyid]=0x1a4
  [key]=0x1a8
  [image_size]=0x328
  [ro_base]=0x32c
  [ro_max]=0x330
  [rx_base]=0x334
  [rx_max]=0x338
  [fusemap]=0x33c
  [infomap]=0x34c
  [epoch_]=0x35c
  [major_]=0x360
  [minor_]=0x364
  [timestamp_]=0x368
  [p4cl_]=0x370
  [applysec_]=0x374
  [config1_]=0x378
  [err_response_]=0x37c
  [expect_response_]=0x380

  [u.ext_sig.keyid]=0x384
  [u.ext_sig.r]=0x388
  [u.ext_sig.s]=0x3a8

  [u.fsh.FSH_SMW_SETTING_OPTION3]=0x384
  [u.fsh.FSH_SMW_SETTING_OPTION2]=0x388
  [u.fsh.FSH_SMW_SETTING_OPTIONA]=0x38c
  [u.fsh.FSH_SMW_SETTING_OPTIONB]=0x390
  [u.fsh.FSH_SMW_SMP_WHV_OPTION1]=0x394
  [u.fsh.FSH_SMW_SMP_WHV_OPTION0]=0x398
  [u.fsh.FSH_SMW_SME_WHV_OPTION1]=0x39c
  [u.fsh.FSH_SMW_SME_WHV_OPTION0]=0x3a0

  [_pad]=0x3c8
  [swap_mark]=0x3dc
  [rw_product_family_]=0x3e0
  [board_id_type]=0x3e4
  [board_id_type_mask]=0x3e8
  [board_id_flags]=0x3ec
  [dev_id0_]=0x3f0
  [dev_id1_]=0x3f4
  [fuses_chk_]=0x3f8
  [info_chk_]=0x3fc
)

declare -A SHDR_SIZE=(
  [magic]=0x004
  [signature]=0x180
  [img_chk_]=0x004
  [tag]=0x01c
  [keyid]=0x004
  [key]=0x180
  [image_size]=0x004
  [ro_base]=0x004
  [ro_max]=0x004
  [rx_base]=0x004
  [rx_max]=0x004
  [fusemap]=0x010
  [infomap]=0x010
  [epoch_]=0x004
  [major_]=0x004
  [minor_]=0x004
  [timestamp_]=0x008
  [p4cl_]=0x004
  [applysec_]=0x004
  [config1_]=0x004
  [err_response_]=0x004
  [expect_response_]=0x004

  [u.ext_sig.keyid]=0x004
  [u.ext_sig.r]=0x020
  [u.ext_sig.s]=0x020

  [u.fsh.FSH_SMW_SETTING_OPTION3]=0x004
  [u.fsh.FSH_SMW_SETTING_OPTION2]=0x004
  [u.fsh.FSH_SMW_SETTING_OPTIONA]=0x004
  [u.fsh.FSH_SMW_SETTING_OPTIONB]=0x004
  [u.fsh.FSH_SMW_SMP_WHV_OPTION1]=0x004
  [u.fsh.FSH_SMW_SMP_WHV_OPTION0]=0x004
  [u.fsh.FSH_SMW_SME_WHV_OPTION1]=0x004
  [u.fsh.FSH_SMW_SME_WHV_OPTION0]=0x004

  [_pad]=0x014
  [swap_mark]=0x004
  [rw_product_family_]=0x004
  [board_id_type]=0x004
  [board_id_type_mask]=0x004
  [board_id_flags]=0x004
  [dev_id0_]=0x004
  [dev_id1_]=0x004
  [fuses_chk_]=0x004
  [info_chk_]=0x004
)

usage() {
  echo "$0: [ro_a.bin.signed] [ro_b.bin.signed] [rw_a.bin.signed] [rw_b.bin.signed] [output.bin]"
}

die() {
  echo "error: $*" >&2
  exit 1
}

fmt_hex() {
  printf "0x%08x" "$(( $1 ))"
}

read_le() {
  local file=$1
  local off=$2
  local size=$3
  local hex out i byte

  hex=$(od -An -v -j "$(( off ))" -N "$(( size ))" -t x1 "$file" | tr -d ' \n')
  [ "${#hex}" -eq "$(( size * 0x2 ))" ] || die "$file is truncated at $(fmt_hex "$off")"

  out=
  for ((i = size - 0x1; i >= 0x0; i--)); do
    byte=${hex:$(( i * 0x2 )):0x2}
    out+="$byte"
  done

  printf "0x%s" "$out"
}

sh_u32() {
  local file=$1
  local field=$2

  read_le "$file" "${SHDR_OFF[$field]}" 0x4
}

sh_u64() {
  local file=$1
  local field=$2

  read_le "$file" "${SHDR_OFF[$field]}" 0x8
}

magic_name() {
  local magic=$1

  case "$(( magic ))" in
    "$(( MAGIC_HAVEN ))") echo "MAGIC_HAVEN" ;;
    "$(( MAGIC_DAUNTLESS ))") echo "MAGIC_DAUNTLESS" ;;
    *) echo "unknown" ;;
  esac
}

verify_header_layout() {
  [ "$(( SHDR_OFF[info_chk_] ))" -eq "$(( 0x3fc ))" ] || die "bad info_chk_ offset"
  [ "$(( SHDR_OFF[info_chk_] + SHDR_SIZE[info_chk_] ))" -eq "$(( SIGNED_HEADER_SIZE ))" ] || die "bad SignedHeader size"
}

verify_blob() {
  local file=$1
  local adr=$2
  local name=$3

  [ -f "$file" ] || die "$name missing file: $file"

  local magic image_size ro_base ro_max rx_base rx_max
  magic=$(sh_u32 "$file" magic)
  image_size=$(sh_u32 "$file" image_size)
  ro_base=$(sh_u32 "$file" ro_base)
  ro_max=$(sh_u32 "$file" ro_max)
  rx_base=$(sh_u32 "$file" rx_base)
  rx_max=$(sh_u32 "$file" rx_max)

  echo "verifying $name target_base=$(fmt_hex "$adr") magic=$(magic_name "$magic") image_size=$(fmt_hex "$image_size")"

  if (( magic != MAGIC_HAVEN && magic != MAGIC_DAUNTLESS )); then
    die "$name invalid magic: $(fmt_hex "$magic")"
  fi

  if (( ro_base != adr )); then
    die "$name base mismatch: header=$(fmt_hex "$ro_base") expected=$(fmt_hex "$adr")"
  fi

  if (( ro_max < ro_base )); then
    die "$name invalid ro range: ro_base=$(fmt_hex "$ro_base") ro_max=$(fmt_hex "$ro_max")"
  fi

  if (( rx_max < rx_base )); then
    die "$name invalid rx range: rx_base=$(fmt_hex "$rx_base") rx_max=$(fmt_hex "$rx_max")"
  fi
}

write_blob() {
  local src=$1
  local dst=$2
  local off=$3

  dd if="$src" of="$dst" bs=1 seek="$(( off ))" conv=notrunc status=none
}

main() {
  [ "$#" -eq 0x5 ] || {
    usage
    exit 1
  }

  local ro_a_signedblob=$1
  local ro_b_signedblob=$2
  local rw_a_signedblob=$3
  local rw_b_signedblob=$4
  local output=$5

  verify_header_layout

  verify_blob "$ro_a_signedblob" 0x40000 "RO_A"
  verify_blob "$rw_a_signedblob" 0x44000 "RW_A"
  verify_blob "$ro_b_signedblob" 0x80000 "RO_B"
  verify_blob "$rw_b_signedblob" 0x84000 "RW_B"

  local rw_b_size final_size
  rw_b_size=$(stat -c %s "$rw_b_signedblob")
  final_size=$(( 0x44000 + rw_b_size ))

  echo "creating final image: $output size=$(fmt_hex "$final_size")"

  rm -f "$output"
  truncate -s "$final_size" "$output"

  write_blob "$ro_a_signedblob" "$output" 0x00000
  write_blob "$rw_a_signedblob" "$output" 0x04000
  write_blob "$ro_b_signedblob" "$output" 0x40000
  write_blob "$rw_b_signedblob" "$output" 0x44000

  echo "success: $output is ready"
}

main "$@"