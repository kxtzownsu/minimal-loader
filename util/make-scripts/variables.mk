BDIR ?= $(REPO_ROOT)/build
OBJ_DIR := $(BDIR)/src
ELF_DIR := $(BDIR)/elf
INCLUDE_DIR := $(REPO_ROOT)/include

LINKER_DIR := $(REPO_ROOT)/linker
LDS_SRC := $(LINKER_DIR)/loader.ld.S
LDS_GEN_DIR := $(BDIR)/$(notdir $(LINKER_DIR))