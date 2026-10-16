; tasm.inc: encodings that TASM/MASM chose and NASM does not emit by itself.
; rr OP, dst, src  ->  the "reg, r/m" opcode form (8B/33/03/...), which TASM uses for register-register ops.
%define R16_ax 0
%define R16_cx 1
%define R16_dx 2
%define R16_bx 3
%define R16_sp 4
%define R16_bp 5
%define R16_si 6
%define R16_di 7
%define R8_al 0
%define R8_cl 1
%define R8_dl 2
%define R8_bl 3
%define R8_ah 4
%define R8_ch 5
%define R8_dh 6
%define R8_bh 7
%define OPW_add 0x03
%define OPW_or  0x0B
%define OPW_adc 0x13
%define OPW_sbb 0x1B
%define OPW_and 0x23
%define OPW_sub 0x2B
%define OPW_xor 0x33
%define OPW_cmp 0x3B
%define OPW_mov 0x8B
%define OPB_add 0x02
%define OPB_or  0x0A
%define OPB_adc 0x12
%define OPB_sbb 0x1A
%define OPB_and 0x22
%define OPB_sub 0x2A
%define OPB_xor 0x32
%define OPB_cmp 0x3A
%define OPB_mov 0x8A
%macro rr 3
%ifdef R16_%2
    db OPW_%1, 0xC0 | (R16_%2 << 3) | R16_%3
%else
    db OPB_%1, 0xC0 | (R8_%2 << 3) | R8_%3
%endif
%endmacro

; GFX_DATA variables shared by the graphics modules (offsets in frame 0B7F)
%define GV_MODE 0x286   ; video type 0 CGA, 1 Tandy, 2 EGA (written by set_video_type)

; Structures the asm reads (offsets only: NASM struc emits no bytes). C side: donald.h.
struc SPRITE                ; header written by grab()/grab_vga(), read byte by byte by sprite_put_*/sprite_mask_*
    .kind:  resb 1          ; never written by the C code
    .hm1:   resb 1          ; height - 1 (SPR_HM1)
    .w:     resb 1          ; width (SPR_W)
    .pad:   resb 1
    .data:                  ; SPR_HDR = 4
endstruc
struc CMPHDR                ; .CMP file as loaded by load_file (docs/CMP.md); cmp_unpack_* get a pointer to .layout
    .len:    resw 1         ; payload length (file size - 2)
    .layout: resb 1         ; 1 = row-major (cmp_unpack_planar), else column-major (cmp_unpack_cga)
    .rle:                   ; RLE stream
endstruc
struc WINDOW                ; struct window (16 bytes); not addressed by the asm, listed so both sides agree
    .x: resw 1
    .y: resw 1
    .w: resw 1
    .h: resw 1
    .fg: resw 1
    .bg: resw 1
    .col: resw 1
    .row: resw 1
endstruc
struc FILE_ENTRY            ; struct file_entry (18 bytes)
    .name: resd 1
    .size: resd 1
    .data: resd 1
    .disk: resw 1
    .pos:  resd 1
endstruc
