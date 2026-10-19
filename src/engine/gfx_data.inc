; Fixed graphics frame layout (retail 0B7F, alternate 0B7A).
; These are absolute offsets, deliberately NOT relocatable addresses. The original
; hand-written code embeds them after loading the GFX_DATA paragraph in DS.
; The linked first byte is at frame:000E, not frame:0000. Every physical initializer
; is checked against this layout by gfx_assert below.
%ifndef DONALD_GFX_DATA_INC
%define DONALD_GFX_DATA_INC
; Three instances share this packed 19-byte scratch record. Its mode-3 forms
; retain unused destination-segment and scanline-phase slots from the packed
; adapter implementation. Offsets below are checked against the named scalars.
struc SPRITE_WORK
    .src_segment:    resw 1
    .dst_segment:    resw 1
    .x_or_bank_wrap: resw 1
    .y_or_row_skip:  resw 1
    .rows:           resw 1
    .width:          resw 1
    .source_width:   resw 1
    .scanline_phase: resw 1
    .subpixel_shift: resb 1
    .clip_columns:   resw 1
endstruc

struc GFX, 0x000e
    .hspan_x: resw 1       ; 000E: hspan x argument; pixel/byte start
    .hspan_y: resw 1       ; 0010: hspan y argument; scanline
    .hspan_count: resw 1       ; 0012: hspan count argument; REP count
    .hspan_colour: resw 1       ; 0014: hspan colour, expanded to repeated CGA/Tandy pixels
    .copy_src_segment: resw 1       ; 0016: copy_rect/blit_ega_core source segment
    .copy_src_x: resw 1       ; 0018: source x in mode-dependent bytes
    .copy_dst_x: resw 1       ; 001A: blit_ega_core destination x in bytes
    .copy_src_y_or_row_skip: resw 1       ; 001C: source y, reused as banked row skip after clipping
    .copy_dst_y: resw 1       ; 001E: blit_ega_core destination scanline
    .copy_width: resw 1       ; 0020: clipped row width; converted to words for MOVSW
    .copy_rows: resw 1       ; 0022: clipped row count; decremented in copy loops
    .copy_src_offset: resw 1       ; 0024: source offset plus computed scanline displacement
    .fill_rows: resw 1       ; 0026: redraw_rect_hw height multiplied by eight
    .fill_row_stride: resw 1       ; 0028: redraw_rect_hw mode stride 40/80/160/320
    .fill_row_count: resw 1       ; 002A: redraw_rect_hw STOSB/STOSW count per row
    .ega_sprite_src_segment: resw 1       ; 002C: sprite_put_ega source segment
    .ega_sprite_x_byte: resw 1       ; 002E: sprite_put_ega arithmetic x>>3
    .ega_sprite_x_pixel: resw 1       ; 0030: sprite_put_ega pixel x; low three bits shift mask
    .ega_clip_x1: resw 1       ; 0032: C-visible EGA left clip column
    .ega_clip_x2: resw 1       ; 0034: C-visible EGA right clip column, exclusive
    .ega_clip_y1: resw 1       ; 0036: C-visible EGA first scanline
    .ega_clip_y2: resw 1       ; 0038: C-visible EGA bottom scanline, exclusive
    .pack_src_segment: resw 1       ; 003A: pack_rect source segment
    .pack_dst_start: resw 1       ; 003C: pack_rect initial destination offset used to return encoded size
    .pack_rows: resb 1       ; 003E: pack_rect height byte decremented at row end
    .pack_width: resw 1       ; 003F: pack_rect width reused four times in source row advance
    .pack_columns_left: resb 1       ; 0041: pack_rect column counter
    .pack_colour_masks: resb 16      ; 0042: pack_rect clears 16 bytes then accumulates one eight-pixel bit mask per colour
    .tandy_fill_count: resw 1       ; 0052: gfx_fill_rect width+1; STOSB count
    .tandy_fill_rows_minus1: resw 1       ; 0054: gfx_fill_rect height; loop uses JNS after decrement
    .tandy_fill_colour: resw 1       ; 0056: gfx_fill_rect repeated nibble colour word; retained write-only scratch
    .cga_even_pixels: resb 256     ; 0058: set_palette16 generates paired-pixel XLAT map; cga_convert/convert_cga_pixels_and_masks alternate rows
    .cga_odd_pixels: resb 256     ; 0158: set_palette16 generates opposite-phase paired-pixel XLAT map
    .cga_even_palette: resb 16      ; 0258: first 16 copied palette entries; high nibble on even rows
    .cga_odd_palette: resb 16      ; 0268: second 16 copied palette entries; low nibble on even rows
    .cga_convert_src_segment: resw 1       ; 0278: cga_convert source segment loaded through ES
    .cga_convert_row_count: resb 1       ; 027A: cga_convert/convert_cga_pixels_and_masks number of outputs before alternating lookup maps
    .random_seed: resd 1       ; 027B: C time_t seed; rand8 updates its first three bytes as a shift register
    .ega_mirror_src_segment: resw 1       ; 027F: mirrored EGA source segment
    .ega_mirror_x_byte: resw 1       ; 0281: mirrored EGA x>>3
    .ega_mirror_x_pixel: resw 1       ; 0283: mirrored EGA original x for bit shift
    .ega_mirror_width: resb 1       ; 0285: sprite header width, positions rightmost destination byte
    .video_mode: resw 1       ; 0286: set_video_type writes adapter selector 0=CGA 1=Tandy 2=EGA 3=VGA
    .clip_x1: resw 1       ; 0288: packed/VGA left edge in eight-pixel columns
    .clip_x2: resw 1       ; 028A: packed/VGA exclusive right edge in eight-pixel columns
    .clip_y1: resw 1       ; 028C: packed/VGA first scanline
    .clip_y2: resw 1       ; 028E: packed/VGA exclusive last scanline
    .packed_src_segment: resw 1       ; 0290: source segment saved before switching DS
    .packed_dst_segment: resw 1       ; 0292: destination segment; unused compatibility slot in mode 3
    .packed_x_or_bank_wrap: resw 1       ; 0294: relative x; packed CGA path reuses it as bank-wrap delta
    .packed_y_or_row_skip: resw 1       ; 0296: clipped y; packed paths reuse it as row skip
    .packed_rows: resw 1       ; 0298: clipped sprite height, decremented per row
    .packed_width: resw 1       ; 029A: clipped source row width in bytes (packed) or pixels (mode 3)
    .packed_source_width: resw 1       ; 029C: unclipped source row width
    .packed_scanline_phase: resw 1       ; 029E: CGA/Tandy bank counter; unused compatibility slot in mode 3
    .packed_subpixel_shift: resb 1       ; 02A0: CGA/Tandy shift bits; mode 3 writes zero but never reads it
    .packed_clip_columns: resw 1       ; 02A1: clip_x2-clip_x1, expanded by pixels/bytes per column
    .sprite_underlay: resw 1       ; 02A3: value 1 selects destination-preserving underlay branches; no static writer in this game
    .swap_nibbles_data: resb 256     ; 02A5: formula swaps high/low nibbles; unused DS duplicate of CS table used by mirrored Tandy blits
    .reverse_cga_pixels: resb 256     ; 03A5: four two-bit pixel groups reversed; XLAT in mirrored CGA paths
    .font_bitmaps: resb 4096    ; 04A5: 128 eight-byte 1bpp glyphs in first 1024 bytes; gfx_init expands in place to 2048 CGA or 4096 Tandy bytes
    .text_fg: resb 1       ; 14A5: set_text_colours foreground, EGA/VGA pixel colour
    .text_bg: resb 1       ; 14A6: set_text_colours background
    .text_fg_pixels: resw 1       ; 14A7: replicated foreground CGA two-bit or Tandy nibble pixels
    .text_bg_pixels: resw 1       ; 14A9: replicated background CGA two-bit or Tandy nibble pixels
    .text_row_groups: resw 1       ; 14AB: draw_char_tandy4bpp two four-row groups
    .retrace_wait: resw 1       ; 14AD: C-visible retrace timing count
    .vline_y1: resw 1       ; 14AF: vline inclusive first scanline
    .vline_y2: resw 1       ; 14B1: vline inclusive last scanline
    .vline_colour: resw 1       ; 14B3: vline colour expanded/masked to packed destination pixels
    .dac_levels: resb 8       ; 14B5: six-bit DAC intensities indexed by three-bit colour component; split across OMF modules
    .m3_forward_src_segment: resw 1       ; 14BD: source segment saved before switching DS
    .m3_forward_dst_segment: resw 1       ; 14BF: destination segment; unused compatibility slot in mode 3
    .m3_forward_x_or_bank_wrap: resw 1       ; 14C1: relative x; packed CGA path reuses it as bank-wrap delta
    .m3_forward_y_or_row_skip: resw 1       ; 14C3: clipped y; packed paths reuse it as row skip
    .m3_forward_rows: resw 1       ; 14C5: clipped sprite height, decremented per row
    .m3_forward_width: resw 1       ; 14C7: clipped source row width in bytes (packed) or pixels (mode 3)
    .m3_forward_source_width: resw 1       ; 14C9: unclipped source row width
    .m3_forward_scanline_phase: resw 1       ; 14CB: CGA/Tandy bank counter; unused compatibility slot in mode 3
    .m3_forward_subpixel_shift: resb 1       ; 14CD: CGA/Tandy shift bits; mode 3 writes zero but never reads it
    .m3_forward_clip_columns: resw 1       ; 14CE: clip_x2-clip_x1, expanded by pixels/bytes per column
    .m3_mirror_src_segment: resw 1       ; 14D0: source segment saved before switching DS
    .m3_mirror_dst_segment: resw 1       ; 14D2: destination segment; unused compatibility slot in mode 3
    .m3_mirror_x_or_bank_wrap: resw 1       ; 14D4: relative x; packed CGA path reuses it as bank-wrap delta
    .m3_mirror_y_or_row_skip: resw 1       ; 14D6: clipped y; packed paths reuse it as row skip
    .m3_mirror_rows: resw 1       ; 14D8: clipped sprite height, decremented per row
    .m3_mirror_width: resw 1       ; 14DA: clipped source row width in bytes (packed) or pixels (mode 3)
    .m3_mirror_source_width: resw 1       ; 14DC: unclipped source row width
    .m3_mirror_scanline_phase: resw 1       ; 14DE: CGA/Tandy bank counter; unused compatibility slot in mode 3
    .m3_mirror_subpixel_shift: resb 1       ; 14E0: CGA/Tandy shift bits; mode 3 writes zero but never reads it
    .m3_mirror_clip_columns: resw 1       ; 14E1: clip_x2-clip_x1, expanded by pixels/bytes per column
endstruc
GFX.packed_work equ GFX.packed_src_segment
GFX.m3_forward_work equ GFX.m3_forward_src_segment
GFX.m3_mirror_work equ GFX.m3_mirror_src_segment
; Every record member is recoverable from the packed implementation; the
; matching slot positions establish the otherwise unused mode-3 members.
%macro gfx_check_sprite_work 1
GFX.%1 %+ _shift_layout_check equ 0 / ((GFX.%1 %+ _subpixel_shift - GFX.%1 %+ _src_segment) = SPRITE_WORK.subpixel_shift)
GFX.%1 %+ _size_layout_check equ 0 / ((GFX.%1 %+ _clip_columns + 2 - GFX.%1 %+ _src_segment) = SPRITE_WORK_size)
%endmacro
gfx_check_sprite_work packed
gfx_check_sprite_work m3_forward
gfx_check_sprite_work m3_mirror

; The last three bytes are genuinely accessed through the graphics frame but
; physically belong to KBD_DATA:0000..0002. Do not allocate them in GFX_DATA:
; the retail paragraph identity is 0B7F:14E0 == 0CCD:0000.
; keyboard.asm owns m3_mirror_subpixel_shift and m3_mirror_clip_columns.

%macro gfx_assert 1
    times (0 / (($ - gfx_data_start + GFX_DATA_BASE) = GFX.%1)) db 0
%endmacro
; Symbol difference is absolute, so CS-relative inline data gains no OMF fixup.
%define GFX_CODE(label) (label - gfx_text_start + GFX_TEXT_BASE)
%endif
