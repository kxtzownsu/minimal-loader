SIGNER ?= $(BDIR)/util/signer/$(HOST_ARCH)/cr50-codesigner
SIGNER_MANIFEST ?= $(REPO_ROOT)/util/signer/signing/loader_manifest.json
PRIVKEY ?= $(REPO_ROOT)/util/signer/signing/loader.dev.pem
LOADER_SLOT_SIZE ?= 0x4000

signer: $(SIGNER)

$(SIGNER):
	$(Q)echo "  MAKE      util/signer"
	$(Q)$(MAKE) -C util/signer REPO_ROOT=$(abspath .) ODIR=$(abspath $(BDIR)/util/signer) ARCH=$(HOST_ARCH)