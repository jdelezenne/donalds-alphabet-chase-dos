/* Shared interfaces for Donald's Alphabet Chase, Turbo C 2.0 large model. */
#ifndef DONALD_H
#define DONALD_H

/* This umbrella is the supported entry point. Keep this include order:
   first declarations affect TC 2.0's symbol table and exact _BSS layout.
   In particular, do not move types or CRT headers before bss.h. */
#include "bss.h"
#include "common.h"
#include "gamedata.h"

/* Turbo C headers whose prototypes match the original calls. <io.h>/<fcntl.h> are left out on purpose:
   their prototypes of open/read/write/lseek change the code of Read_File, Write_File, Seek_File and
   load_resources (e.g. read(fd, buf, long) would truncate the long), so engine/files.c is built without them. */
#include <stdlib.h>
#include <string.h>
#include <alloc.h>
#include <time.h>

/* Semantic API names. Keep the already reconstructed ASM linker aliases so
   public-symbol records and original object ordering remain unchanged. The
   prior cga/tandy glyph names were reversed; sprite_mask_* mirrors the source. */
#define draw_char_tandy4bpp draw_char_cga
#define draw_char_cga2bpp draw_char_tandy
#define draw_char_vga8bpp draw_char_buf
#define convert_cga_pixels_and_masks clear_buffer
#define fill_rect_cells redraw_rect_hw
#define sprite_mirror_ega sprite_mask_ega
#define sprite_mirror_packed sprite_mask_cga
#define sprite_mirror_m3 sprite_mask_m3

#include "game.h"
#include "sound.h"
#include "engine.h"

#endif
