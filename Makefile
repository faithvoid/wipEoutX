.DEFAULT_GOAL := all

XBE_TITLE = wipEoutX
GEN_XISO  = wipEoutX.iso

NXDK_DIR ?= $(abspath $(CURDIR)/../nxdk)
NXDK_SDL3_DIR ?= $(abspath $(CURDIR)/../nxdk/nxdk-sdl3)

OUTPUT_DIR ?= bin

SRCS  = $(sort $(wildcard $(CURDIR)/src/wipeout/*.c))
SRCS += $(addprefix $(CURDIR)/src/, \
	input.c \
	mem.c \
	render_nv2a.c \
	system.c \
	types.c \
	utils.c \
	platform_xbox.c)

CFLAGS += -O3 -march=pentium3

ENGINE_OBJS = $(SRCS:.c=.obj)

$(ENGINE_OBJS): CFLAGS += \
	-std=gnu99 -Wall -Wno-unused-variable \
	-I$(CURDIR)/src/libs \
	-I$(CURDIR)/src/xbox_compat \
	-include $(CURDIR)/src/xbox_compat/xbox_compat.h \
	-DXBOX_HW_RENDERER \
	-DSTBI_WRITE_NO_STDIO \

.PHONY: stage-assets
stage-assets:
	@mkdir -p $(OUTPUT_DIR)
	@if [ -d $(CURDIR)/wipeout ]; then \
		echo "[ ASSETS   ] wipeout/ -> $(OUTPUT_DIR)/wipeout"; \
		mkdir -p $(OUTPUT_DIR)/wipeout; \
		cp -R $(CURDIR)/wipeout/. $(OUTPUT_DIR)/wipeout/; \
	else \
		echo "[ ASSETS   ] no ./wipeout directory, ISO will not contain game data"; \
	fi

$(GEN_XISO): stage-assets

include $(NXDK_DIR)/Makefile
include $(NXDK_SDL3_DIR)/config_sdl.make

CFLAGS += $(SDL3_FLAGS) \
          -DNXDK \
          -Wall -Wextra -Wno-unused-parameter \
          -DDRMP3_NO_SIMD -DMINIMP3_NO_SIMD \
          -DFT2_BUILD_LIBRARY \
          -DFT_ERR_PREFIX=FT_Err_ \
          -I$(CURDIR)/src \
          -I$(FREETYPE_DIR)/include \
          -I$(SDL_TTF_DIR)/include \
          -I$(SDL_IMAGE_DIR)/include \
          -I$(SDL_MIXER_DIR)/include \
          -DSDLTTF_VENDORED=1 \
          -DSDLTTF_PLUTOSVG=0 \
          -DSDLTTF_HARFBUZZ=0 \
          -DSDLMIXER_VENDORED=1

CXXFLAGS += $(SDL3_FLAGS) \
            -DNXDK \
            -I$(FREETYPE_DIR)/include \
            -I$(SDL_TTF_DIR)/include \
            -I$(SDL_IMAGE_DIR)/include \
            -I$(SDL_MIXER_DIR)/include

main.exe: libSDL3.lib
$(XBE_TITLE).exe: libSDL3.lib
