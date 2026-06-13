$(LDS_GEN_DIR)/generated_a.lds: LDS_DEFINES := -DSECTION_A
$(LDS_GEN_DIR)/generated_b.lds: LDS_DEFINES := -DSECTION_B

$(LDS_GEN_DIR)/generated_%.lds: $(LDS_SRC) $(REPO_ROOT) | $(LDS_GEN_DIR)
	$(Q)echo "  PREPROC   $(notdir $@)"
	$(Q)$(CC) -E -P -x c $(LDS_DEFINES) $< -o $@

LINKER_SCRIPT := $(LDS_GEN_DIR)/generated_$*.lds