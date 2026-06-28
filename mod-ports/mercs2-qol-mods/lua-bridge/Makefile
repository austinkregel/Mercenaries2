# Build the lua-bridge mod for the mercs2-qol-mods SDK.
#
# Drop this directory (or a copy of its contents) into
#   mercs2-qol-mods/mods/lua-bridge/
# and the parent project's top-level Makefile will pick it up.
# Standalone build also works if SDK_DIR points at the SDK folder.

MOD := lua_bridge

SDK_DIR ?= ../../sdk

include $(SDK_DIR)/sdk.mk

SRC      := $(MOD).c
TARGET   := $(MOD).asi
EXTRALIBS := -lws2_32

# If the luaL_register hijack is added later via a global assembly
# file (see the deferred-feature note in lua_bridge.c), include it
# here:
#   ASM_SRC := lua_bridge_asm.S
#   SRC    += $(ASM_SRC)

$(TARGET): $(SRC) $(SDK_OBJS)
	$(CC) $(CFLAGS) -shared -o $@ $(SRC) $(SDK_OBJS) $(LDFLAGS) $(EXTRALIBS)

clean:
	$(RM) $(TARGET) *.o

.PHONY: clean
