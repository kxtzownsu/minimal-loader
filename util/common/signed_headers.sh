#!/usr/bin/env bash

SIGNED_HEADER_SIZE=0x400
SIGNED_HEADER_ALIGN=0x8
SIGNED_MANIFEST_SIZE=0x400
SIGNED_MANIFEST_ALIGN=0x8

MAGIC_HAVEN=0xffffffff
MAGIC_CITADEL=0xfffffffe
MAGIC_DAUNTLESS=0xfffffffd

ID_ROM_EXT=0x4552544f
ID_OWNER_FW=0x3042544f

CONFIG_FLASH_SIZE=$((512 * 1024))
CFG_FLASH_HALF=$((CONFIG_FLASH_SIZE >> 1))
CONFIG_RO_SIZE=0x4000
CONFIG_RW_SIZE=$((CFG_FLASH_HALF - 0x4000 - 0x3000))

CONFIG_DT_FLASH_SIZE=$((1024 * 1024))
CFG_DT_FLASH_HALF=$((CONFIG_DT_FLASH_SIZE >> 1))
CONFIG_DT_RW_SIZE=0x77000

# SignedHeader

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

  [u]=0x384
  [u.ext_sig]=0x384
  [u.ext_sig.keyid]=0x384
  [u.ext_sig.r]=0x388
  [u.ext_sig.s]=0x3a8

  [u.fsh]=0x384
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
  [swap_mark.size]=0x3dc
  [swap_mark.offset]=0x3dc
  [rw_product_family_]=0x3e0
  [board_id]=0x3e4
  [board_id.id]=0x3e4
  [board_id.mask]=0x3e8
  [board_id.flags]=0x3ec
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

  [u]=0x044
  [u.ext_sig]=0x044
  [u.ext_sig.keyid]=0x004
  [u.ext_sig.r]=0x020
  [u.ext_sig.s]=0x020

  [u.fsh]=0x020
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
  [board_id]=0x00c
  [board_id.id]=0x004
  [board_id.mask]=0x004
  [board_id.flags]=0x004
  [dev_id0_]=0x004
  [dev_id1_]=0x004
  [fuses_chk_]=0x004
  [info_chk_]=0x004
)

# This is literally only needed for swap_mark.
declare -A SHDR_BITS=(
  [swap_mark.size]=12
  [swap_mark.offset]=20
)

# SignedManifest

declare -A SMAN_OFF=(
  [signature]=0x000
  [constraint_selector_bits]=0x180
  [constraint_device_id]=0x184
  [constraint_manuf_state_creator]=0x1a4
  [constraint_manuf_state_owner]=0x1a8
  [constraint_life_cycle_state]=0x1ac
  [key]=0x1b0
  [address_translation]=0x330
  [identifier]=0x334
  [manifest_major]=0x338
  [manifest_minor]=0x33a
  [signed_region_end]=0x33c
  [image_size]=0x340
  [major]=0x344
  [minor]=0x348
  [security_version]=0x34c
  [timestamp]=0x350
  [binding_value]=0x358
  [max_key_version]=0x378
  [code_start]=0x37c
  [code_end]=0x380
  [entry_point]=0x384
  [extensions]=0x388
)

declare -A SMAN_SIZE=(
  [signature]=0x180
  [constraint_selector_bits]=0x004
  [constraint_device_id]=0x020
  [constraint_manuf_state_creator]=0x004
  [constraint_manuf_state_owner]=0x004
  [constraint_life_cycle_state]=0x004
  [key]=0x180
  [address_translation]=0x004
  [identifier]=0x004
  [manifest_major]=0x002
  [manifest_minor]=0x002
  [signed_region_end]=0x004
  [image_size]=0x004
  [major]=0x004
  [minor]=0x004
  [security_version]=0x004
  [timestamp]=0x008
  [binding_value]=0x020
  [max_key_version]=0x004
  [code_start]=0x004
  [code_end]=0x004
  [entry_point]=0x004
  [extensions]=0x078
)

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

sman_u32() {
  local file=$1
  local field=$2

  read_le "$file" "${SMAN_OFF[$field]}" 0x4
}

sman_u64() {
  local file=$1
  local field=$2

  read_le "$file" "${SMAN_OFF[$field]}" 0x8
}
