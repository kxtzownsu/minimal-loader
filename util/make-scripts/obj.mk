OBJS += $(OBJ_DIR)/init.o
OBJS += $(OBJ_DIR)/main.o
OBJS += $(OBJ_DIR)/vectors.o
OBJS += $(OBJ_DIR)/setup.o
OBJS += $(OBJ_DIR)/uart.o

## format:
## '[2-space padding][8-char word][2-space padding][extra info, e.g: filename]'
$(OBJ_DIR)/%.o: src/%.c | $(OBJ_DIR)
	$(Q)echo "  CC        $(notdir $<)"
	$(Q)$(CC) -c $< -o $@ $(CFLAGS) $(CPPFLAGS)

$(OBJ_DIR)/%.o: src/%.S | $(OBJ_DIR)
	$(Q)echo "  AS        $(notdir $<)"
	$(Q)$(CC) -c $< -o $@ $(CFLAGS) $(CPPFLAGS)