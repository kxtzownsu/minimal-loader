REPO_ROOT := $(abspath .)

# Haven uses Cortex-M3, which is armv7-m / arm32.
CROSS_COMPILE ?= arm-none-eabi-
HOST_ARCH ?= $(shell uname -m)
ROOT ?= $(abspath .)
BDIR ?= build
OBJ_DIR := $(BDIR)/src
ELF_DIR := $(BDIR)/elf

SHELL ?= /bin/sh
CC := $(CROSS_COMPILE)gcc
LD := $(CROSS_COMPILE)gcc
OBJCOPY := $(CROSS_COMPILE)objcopy
CP ?= cp
RM ?= rm
MKDIR ?= mkdir
TOUCH ?= touch
PYTHON3 ?= python3

INCLUDES += -I$(REPO_ROOT)/include -I$(REPO_ROOT)/include/src
CFLAGS += $(INCLUDES) \
	-Wall \
	-std=gnu99 \
	-g \
	-fno-if-conversion \
	-fno-if-conversion2 \
	-Wno-format -Wno-format-extra-args

# architecture-specific
CFLAGS += -march=armv7-m -mcpu=cortex-m3 -mthumb -Os -mno-sched-prolog -mno-unaligned-access -ffreestanding

LDFLAGS += -march=armv7-m -mcpu=cortex-m3 -mthumb -nostartfiles -nostdlib -nostdinc

OBJS += $(OBJ_DIR)/init.o
OBJS += $(OBJ_DIR)/main.o
OBJS += $(OBJ_DIR)/vectors.o
OBJS += $(OBJ_DIR)/setup.o
OBJS += $(OBJ_DIR)/uart.o

ifeq ($(VERBOSE),)
Q := @
else
Q := 
CFLAGS += -DDEBUG
endif

all: $(ELF_DIR) $(OBJS)
	$(LD) $(OBJS) -o $(ELF_DIR)/final.elf $(LDFLAGS) -T $(REPO_ROOT)/linker/loader.ld

clean:
	$(Q)$(RM) -rf build

$(BDIR):
	$(Q)$(MKDIR) -p $@

$(OBJ_DIR):
	$(Q)$(MKDIR) -p $@

$(ELF_DIR):
	$(Q)$(MKDIR) -p $@

## format:
## '[2-space padding][8-char word][2-space padding][extra info, e.g: filename]'
$(OBJ_DIR)/%.o: src/%.c | $(OBJ_DIR)
	@echo "  CC        $(notdir $<)"
	$(Q)$(CC) -c $< -o $@ $(CFLAGS) $(CPPFLAGS)

$(OBJ_DIR)/%.o: src/%.S | $(OBJ_DIR)
	@echo "  AS        $(notdir $<)"
	$(Q)$(CC) -c $< -o $@ $(CFLAGS) $(CPPFLAGS)