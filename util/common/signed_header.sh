#!/usr/bin/env bash

SIGNED_HEADER_SIZE=$(( 0x400 ))
SIGNED_HEADER_ALIGN=$(( 0x8 ))

MAGIC_HAVEN=$(( 0xffffffff ))
MAGIC_CITADEL=$(( 0xfffffffe ))

CONFIG_TOP_SIZE=$(( 0x3000 ))

CONFIG_FLASH_BASE=$(( 0x40000 ))
CONFIG_FLASH_SIZE=$(( 0x80000 ))
CONFIG_FLASH_HALF=$(( CONFIG_FLASH_SIZE / 2 ))

CONFIG_FLASH_BANK_SIZE=$(( 0x800 ))

CONFIG_RO_SIZE=$(( 0x4000 ))
CONFIG_RW_SIZE=$(( CONFIG_FLASH_HALF - CONFIG_RO_SIZE - CONFIG_TOP_SIZE ))

CONFIG_FLASH_SLOT_A_BASE=$(( CONFIG_FLASH_BASE ))
CONFIG_FLASH_SLOT_B_BASE=$(( CONFIG_FLASH_BASE + CONFIG_FLASH_HALF ))

CONFIG_RO_A_BASE=$(( CONFIG_FLASH_SLOT_A_BASE ))
CONFIG_RO_B_BASE=$(( CONFIG_FLASH_SLOT_B_BASE ))

CONFIG_RW_A_BASE=$(( CONFIG_RO_A_BASE + CONFIG_RO_SIZE ))
CONFIG_RW_B_BASE=$(( CONFIG_RO_B_BASE + CONFIG_RO_SIZE ))

CONFIG_RO_A_OFFSET=$(( CONFIG_RO_A_BASE - CONFIG_FLASH_BASE ))
CONFIG_RW_A_OFFSET=$(( CONFIG_RW_A_BASE - CONFIG_FLASH_BASE ))
CONFIG_RO_B_OFFSET=$(( CONFIG_RO_B_BASE - CONFIG_FLASH_BASE ))
CONFIG_RW_B_OFFSET=$(( CONFIG_RW_B_BASE - CONFIG_FLASH_BASE ))


declare -A SHDR_OFF=(
  [magic]=$(( 0x000 ))
  [signature]=$(( 0x004 ))
  [img_chk_]=$(( 0x184 ))
  [tag]=$(( 0x188 ))
  [keyid]=$(( 0x1a4 ))
  [key]=$(( 0x1a8 ))
  [image_size]=$(( 0x328 ))
  [ro_base]=$(( 0x32c ))
  [ro_max]=$(( 0x330 ))
  [rx_base]=$(( 0x334 ))
  [rx_max]=$(( 0x338 ))
  [fusemap]=$(( 0x33c ))
  [infomap]=$(( 0x34c ))
  [epoch_]=$(( 0x35c ))
  [major_]=$(( 0x360 ))
  [minor_]=$(( 0x364 ))
  [timestamp_]=$(( 0x368 ))
  [p4cl_]=$(( 0x370 ))
  [applysec_]=$(( 0x374 ))
  [config1_]=$(( 0x378 ))
  [err_response_]=$(( 0x37c ))
  [expect_response_]=$(( 0x380 ))

  [u]=$(( 0x384 ))
  [u.ext_sig]=$(( 0x384 ))
  [u.ext_sig.keyid]=$(( 0x384 ))
  [u.ext_sig.r]=$(( 0x388 ))
  [u.ext_sig.s]=$(( 0x3a8 ))

  [_pad]=$(( 0x3c8 ))
  [swap_mark]=$(( 0x3dc ))
  [swap_mark.size]=$(( 0x3dc ))
  [swap_mark.offset]=$(( 0x3dc ))
  [rw_product_family_]=$(( 0x3e0 ))
  [board_id]=$(( 0x3e4 ))
  [board_id.id]=$(( 0x3e4 ))
  [board_id.mask]=$(( 0x3e8 ))
  [board_id.flags]=$(( 0x3ec ))
  [dev_id0_]=$(( 0x3f0 ))
  [dev_id1_]=$(( 0x3f4 ))
  [fuses_chk_]=$(( 0x3f8 ))
  [info_chk_]=$(( 0x3fc ))
)

declare -A SHDR_SIZE=(
  [magic]=$(( 0x004 ))
  [signature]=$(( 0x180 ))
  [img_chk_]=$(( 0x004 ))
  [tag]=$(( 0x01c ))
  [keyid]=$(( 0x004 ))
  [key]=$(( 0x180 ))
  [image_size]=$(( 0x004 ))
  [ro_base]=$(( 0x004 ))
  [ro_max]=$(( 0x004 ))
  [rx_base]=$(( 0x004 ))
  [rx_max]=$(( 0x004 ))
  [fusemap]=$(( 0x010 ))
  [infomap]=$(( 0x010 ))
  [epoch_]=$(( 0x004 ))
  [major_]=$(( 0x004 ))
  [minor_]=$(( 0x004 ))
  [timestamp_]=$(( 0x008 ))
  [p4cl_]=$(( 0x004 ))
  [applysec_]=$(( 0x004 ))
  [config1_]=$(( 0x004 ))
  [err_response_]=$(( 0x004 ))
  [expect_response_]=$(( 0x004 ))

  [u]=$(( 0x044 ))
  [u.ext_sig]=$(( 0x044 ))
  [u.ext_sig.keyid]=$(( 0x004 ))
  [u.ext_sig.r]=$(( 0x020 ))
  [u.ext_sig.s]=$(( 0x020 ))

  [_pad]=$(( 0x014 ))
  [swap_mark]=$(( 0x004 ))
  [rw_product_family_]=$(( 0x004 ))
  [board_id]=$(( 0x00c ))
  [board_id.id]=$(( 0x004 ))
  [board_id.mask]=$(( 0x004 ))
  [board_id.flags]=$(( 0x004 ))
  [dev_id0_]=$(( 0x004 ))
  [dev_id1_]=$(( 0x004 ))
  [fuses_chk_]=$(( 0x004 ))
  [info_chk_]=$(( 0x004 ))
)

# This is literally only needed for swap_mark.
declare -A SHDR_BITS=(
  [swap_mark.size]=12
  [swap_mark.offset]=20
)

sh_u32() {
  local file=$1
  local field=$2

  read_le "$file" "${SHDR_OFF[$field]}" 4
}

sh_u64() {
  local file=$1
  local field=$2

  read_le "$file" "${SHDR_OFF[$field]}" 8
}
