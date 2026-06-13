HOST_ARCH := $(shell uname -m)
CROSS_COMPILE ?= arm-none-eabi-

# We expect `VERBOSE=1`, nothing else.
ifeq ($(VERBOSE),1)
Q :=
else
Q := @
endif

### Build utilities ###
MAKE ?= make
SHELL := /bin/bash
CC := $(CROSS_COMPILE)gcc
LD := $(CROSS_COMPILE)gcc
AS := $(CROSS_COMPILE)as
OBJCOPY := $(CROSS_COMPILE)objcopy

### Standard utilities ###
SUDO ?= sudo
COPY ?= cp
MOVE ?= mv
RM ?= rm
MKDIR ?= mkdir
TOUCH ?= touch
CHMOD ?= chmod
CHOWN ?= chown
XZ ?= xz

### Compiler Flags ###
INCLUDES += -I$(INCLUDE_DIR) -I$(INCLUDE_DIR)/src
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
