# Ideally we should pass this from the root makefile
REPO_ROOT ?= $(abspath ../../)
ARCH ?= $(shell uname -m)
CROSS_COMPILE ?=
SHELL ?= /bin/sh
PKG_CONFIG ?= pkg-config
CXX ?= $(CROSS_COMPILE)g++
ODIR ?= $(REPO_ROOT)/build/util/signer

CFLAGS := -I$(ODIR)/include \
	-Icommon \
	-Wno-deprecated-declarations \
	-DHAVE_JSON=1

INCLUDES += $(shell $(PKG_CONFIG) libxml-2.0 --cflags)
INCLUDES += $(shell $(PKG_CONFIG) libcrypto --cflags)
INCLUDES += $(shell $(PKG_CONFIG) libssl --cflags)
INCLUDES += $(shell $(PKG_CONFIG) libelf --cflags)

ifeq ($(STATIC),)
LIBS += $(shell $(PKG_CONFIG) libxml-2.0 --libs)
LIBS += $(shell $(PKG_CONFIG) libcrypto --libs)
LIBS += $(shell $(PKG_CONFIG) libssl --libs)
LIBS += $(shell $(PKG_CONFIG) libelf --libs)
LIBS += $(shell $(PKG_CONFIG) libusb-1.0 --libs)
else
LIBS += $(REPO_ROOT)/lib/$(ARCH)/libxml-2.0.a
LIBS += $(REPO_ROOT)/lib/$(ARCH)/liblzma.a
LIBS += $(REPO_ROOT)/lib/$(ARCH)/libz.a
LIBS += $(REPO_ROOT)/lib/$(ARCH)/libcrypto.a
LIBS += $(REPO_ROOT)/lib/$(ARCH)/libssl.a
LIBS += $(REPO_ROOT)/lib/$(ARCH)/libelf.a
LIBS += $(REPO_ROOT)/lib/$(ARCH)/libusb-1.0.a
CFLAGS += -static
endif

ifeq ($(VERBOSE),)
Q := @
else
Q := 
endif

SCRIPTS := codesigner.cc aes.cc ecdh.cc image.cc publickey.cc gnubby.cc

all: $(ODIR)/$(ARCH) $(ODIR)/$(ARCH)/cr50-codesigner

## format:
## '[2-space padding][8-char word][2-space padding][extra info, e.g: filename]'
$(ODIR)/$(ARCH):
	$(Q)echo "  MKDIR     $@"
	$(Q)mkdir -p $@

$(ODIR)/$(ARCH)/cr50-codesigner: $(SCRIPTS)
	$(Q)mkdir -p $(ODIR)/include
	$(Q)echo "  PMJP      pmjp.h"
	$(Q)./pmjp.py signing/loader_manifest.json > $(ODIR)/include/pmjp.h
	$(Q)echo "  CXX       $@"
	$(Q)$(CXX) $^ -o $@ $(CFLAGS) $(INCLUDES) $(LIBS)

clean:
	$(Q)echo "  CLEAN   "
	$(Q)rm -rf $(ODIR)
