OBJS += $(foreach obj,$(src-y),$(OBJ_DIR)/$(obj))
OBJ_DIRS := $(filter-out $(OBJ_DIR),$(sort $(patsubst %/,%,$(dir $(OBJS)))))

$(OBJ_DIRS):
	$(Q)$(MKDIR) -p $@

$(OBJ_DIR)/%.o: src/%.c | $(OBJ_DIR) $(OBJ_DIRS)
	$(Q)echo "  CC        $<"
	$(Q)$(CC) -c $< -o $@ $(CFLAGS) $(CPPFLAGS)

$(OBJ_DIR)/%.o: src/%.S | $(OBJ_DIR) $(OBJ_DIRS)
	$(Q)echo "  AS        $<"
	$(Q)$(CC) -c $< -o $@ $(CFLAGS) $(CPPFLAGS)
