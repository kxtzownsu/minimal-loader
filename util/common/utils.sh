#!/usr/bin/env bash

die() {
  echo "error: $*" >&2
  exit 1
}

log_verbose() {
  if [ "${VERBOSE:-0}" -eq 1 ]; then
    echo "$*" >&2
  fi
}

fmt_hex() {
  printf "0x%08x" "$(( $1 ))"
}

file_size() {
  stat -c %s "$1"
}

read_le() {
  local file=$1
  local off=$2
  local size=$3
  local hex out i byte

  hex=$(od -An -v -j "$(( off ))" -N "$(( size ))" -t x1 "$file" | tr -d ' \n')
  [ "${#hex}" -eq "$(( size * 2 ))" ] || die "$file is truncated at $(fmt_hex "$off")"

  out=
  for ((i = size - 1; i >= 0; i--)); do
    byte=${hex:$(( i * 2 )):2}
    out+="$byte"
  done

  printf "0x%s" "$out"
}

read_u32() {
  read_le "$1" "$2" 4
}

copy_range() {
  local input=$1
  local output=$2
  local offset=$3
  local size=$4
  local block_size=$(( CONFIG_FLASH_BANK_SIZE ))

  dd if="$input" of="$output" bs="$block_size" skip="$(( offset ))" count="$(( size ))" \
    iflag=skip_bytes,count_bytes status=none
}

read_blob() {
  copy_range "$@"
}

write_blob() {
  local src=$1
  local dst=$2
  local off=$3
  local block_size=$(( CONFIG_FLASH_BANK_SIZE ))

  dd if="$src" of="$dst" bs="$block_size" seek="$(( off ))" oflag=seek_bytes conv=notrunc \
    status=none
}

trim_trailing_byte() {
  local file=$1
  local target=$2
  local size byte

  size=$(file_size "$file")
  while (( size > 0 )); do
    byte=$(tail -c 1 "$file" | od -An -tx1 | tr -d ' \n')
    [ "$byte" = "$target" ] || break
    size=$(( size - 1 ))
    truncate -s "$size" "$file"
  done
}

magic_name() {
  local magic=$1

  case "$(( magic ))" in
    "$(( MAGIC_HAVEN ))") echo "MAGIC_HAVEN" ;;
    "$(( MAGIC_CITADEL ))") echo "MAGIC_CITADEL" ;;
    *) echo "unknown" ;;
  esac
}

supported_magic() {
  local magic=$1

  case "$(( magic ))" in
    "$(( MAGIC_HAVEN ))"|"$(( MAGIC_CITADEL ))") return 0 ;;
    *) return 1 ;;
  esac
}

magic_at() {
  local file=$1
  local off=${2:-0}

  read_u32 "$file" "$(( off + SHDR_OFF[magic] ))"
}

verify_header_layout() {
  (( SIGNED_HEADER_ALIGN == 8 )) || die "bad SignedHeader alignment"
  (( SHDR_OFF[info_chk_] == SIGNED_HEADER_SIZE - SHDR_SIZE[info_chk_] )) || die "bad info_chk_ offset"
  (( SHDR_OFF[info_chk_] + SHDR_SIZE[info_chk_] == SIGNED_HEADER_SIZE )) || die "bad SignedHeader size"
  (( SHDR_OFF[u] == SHDR_OFF[expect_response_] + SHDR_SIZE[expect_response_] )) || die "bad SignedHeader union offset"
  (( SHDR_OFF[board_id] + SHDR_SIZE[board_id] == SHDR_OFF[dev_id0_] )) || die "bad SignedHeader board_id size"
}

valid_signed_header_at() {
  local file=$1
  local off=$2
  local total=$3
  local magic image_size ro_base ro_max rx_base rx_max

  (( off + SIGNED_HEADER_SIZE <= total )) || return 1

  magic=$(read_u32 "$file" "$(( off + SHDR_OFF[magic] ))")
  case "$(( magic ))" in
    "$(( MAGIC_HAVEN ))"|"$(( MAGIC_CITADEL ))") ;;
    *) return 1 ;;
  esac

  image_size=$(read_u32 "$file" "$(( off + SHDR_OFF[image_size] ))")
  ro_base=$(read_u32 "$file" "$(( off + SHDR_OFF[ro_base] ))")
  ro_max=$(read_u32 "$file" "$(( off + SHDR_OFF[ro_max] ))")
  rx_base=$(read_u32 "$file" "$(( off + SHDR_OFF[rx_base] ))")
  rx_max=$(read_u32 "$file" "$(( off + SHDR_OFF[rx_max] ))")

  (( image_size >= CONFIG_FLASH_BANK_SIZE )) || return 1
  (( rx_base == ro_base + SIGNED_HEADER_SIZE )) || return 1
  (( ro_max > ro_base )) || return 1
  (( rx_max > rx_base )) || return 1
  (( image_size <= total - off )) || return 1

  return 0
}

image_size_at() {
  local file=$1
  local off=$2

  read_u32 "$file" "$(( off + SHDR_OFF[image_size] ))"
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

  if ! supported_magic "$magic"; then
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
