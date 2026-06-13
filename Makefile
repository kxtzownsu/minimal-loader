REPO_ROOT := $(abspath .)
MAKE_SCRIPTS_DIR := $(REPO_ROOT)/util/make-scripts

include $(MAKE_SCRIPTS_DIR)/variables.mk
include $(MAKE_SCRIPTS_DIR)/toolchain.mk
include $(MAKE_SCRIPTS_DIR)/directories.mk
include $(MAKE_SCRIPTS_DIR)/cleanup.mk
include $(MAKE_SCRIPTS_DIR)/linker.mk
include $(MAKE_SCRIPTS_DIR)/signer.mk

include $(MAKE_SCRIPTS_DIR)/obj.mk

## echo format:
## '[2-space padding][8-char word][2-space padding][extra info, e.g: filename]'

SLOTS := a b
PROGS := $(foreach slot,$(SLOTS),$(BDIR)/minimal-loader.ro_$(slot).signed.bin)

all: $(PROGS)

.PHONY: clean
.SECONDARY: $(foreach slot,$(SLOTS),$(LDS_GEN_DIR)/generated_$(slot).lds $(ELF_DIR)/loader_$(slot).elf)

$(ELF_DIR)/loader_%.elf: $(OBJS) $(LDS_GEN_DIR)/generated_%.lds | $(ELF_DIR)
	$(Q)echo "  LD        $(notdir $@)"
	$(Q)$(LD) $(OBJS) -o $@ $(LDFLAGS) -T $(LDS_GEN_DIR)/generated_$*.lds

$(BDIR)/minimal-loader.ro_%.signed.bin: $(ELF_DIR)/loader_%.elf $(SIGNER) $(SIGNER_MANIFEST) $(PRIVKEY) | $(BDIR)
	$(Q)echo "  SIGN      $(notdir $@)"
	$(Q)$(SIGNER) \
		--input $< \
		--output $@ \
		--key $(PRIVKEY) \
		--json $(SIGNER_MANIFEST) \
		--format bin