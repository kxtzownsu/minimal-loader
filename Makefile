REPO_ROOT := $(abspath .)
MAKE_SCRIPTS_DIR := $(REPO_ROOT)/util/make-scripts

include $(MAKE_SCRIPTS_DIR)/variables.mk
include $(MAKE_SCRIPTS_DIR)/toolchain.mk
include $(MAKE_SCRIPTS_DIR)/directories.mk
include $(MAKE_SCRIPTS_DIR)/cleanup.mk

include $(MAKE_SCRIPTS_DIR)/obj.mk

## format:
## '[2-space padding][8-char word][2-space padding][extra info, e.g: filename]'
all: $(BDIR) $(OBJ_DIR) $(ELF_DIR) $(OBJS)
	$(Q)echo "  LD        $(ELF_DIR)/final.elf"
	$(Q)$(LD) $(OBJS) -o $(ELF_DIR)/final.elf $(LDFLAGS) -T linker/loader.ld