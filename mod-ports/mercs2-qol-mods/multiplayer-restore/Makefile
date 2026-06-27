# Build the multiplayer-restore mod for the mercs2-qol-mods SDK.
#
# Drop this directory (or a copy of its contents) into
#   mercs2-qol-mods/mods/multiplayer-restore/
# and the parent project's top-level Makefile will pick it up.
# Standalone build also works if SDK_DIR points at the SDK folder.

MOD := multiplayer_restore

# Default: assume this directory was placed under
#   mercs2-qol-mods/mods/multiplayer-restore/
# If you keep it out-of-tree, override on the command line:
#   make SDK_DIR=/path/to/mercs2-qol-mods/sdk
SDK_DIR ?= ../../sdk

include $(SDK_DIR)/sdk.mk

SRC      := $(MOD).c
TARGET   := $(MOD).asi
EXTRALIBS := -lws2_32 -lwintrust

$(TARGET): $(SRC) $(SDK_OBJS)
	$(CC) $(CFLAGS) -shared -o $@ $(SRC) $(SDK_OBJS) $(LDFLAGS) $(EXTRALIBS)

clean:
	$(RM) $(TARGET) *.o

.PHONY: clean
