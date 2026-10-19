; Module 0000:2A15: hand-written graphics assembly, _TEXT part 5/5 (split by relocation-table order).
; SEGMENT: DONALD 0000 2A15-2DAB
; Purpose: clipped forward/mirrored RLE sprite blits (320x200 8bpp VGA).
bits 16
%include "tasm.inc"
%include "gfx_data.inc"
%define GFX_TEXT_BASE 0x2a15

segment GFX_DATA public align=2 class=DATA use16   ; far data of the graphics modules (starts at 0B7F:000E)
segment _TEXT public align=1 class=CODE use16
gfx_text_start:
; The preceding module ends with this three-word workspace immediately before
; our first function. Derive its fixed CS address from that entry, without a
; relocatable cross-module reference (the original OMF had no offset fixups).
m3_forward_skip_left_addr equ GFX_CODE(sprite_put_m3) - 6
m3_forward_skip_right_addr equ m3_forward_skip_left_addr + 2
m3_forward_draw_width_addr equ m3_forward_skip_left_addr + 4

global _sprite_put_m3
_sprite_put_m3 equ sprite_put_m3
global _sprite_mask_m3
_sprite_mask_m3 equ sprite_mirror_m3
; FUNCTION: DONALD 0000:2A15
; sprite_put_m3: draw_sprite, g_videoMode 3
sprite_put_m3:
    push bp
    rr mov, bp, sp
    push di
    push si
    push ds
    mov ax, GFX_DATA  ; reloc
    mov ds, ax
    push es
    cld
    mov di, word [bp + 6]
    mov ax, word [bp + 8]
    mov es, ax
    mov si, word [bp + 0xa]
    mov ax, word [bp + 0xc]
    mov word [GFX.m3_forward_src_segment], ax
    mov bx, word [bp + 0xe]
    mov ax, word [bp + 0x10]
    mov word [GFX.m3_forward_y_or_row_skip], ax
    mov ax, word [GFX.clip_x1]
    shl ax, 1
    shl ax, 1
    shl ax, 1
    rr add, di, ax
    mov byte [GFX.m3_forward_subpixel_shift], 0
    rr sub, bx, ax
    mov word [GFX.m3_forward_x_or_bank_wrap], bx
    mov ax, word [GFX.clip_x2]
    sub ax, word [GFX.clip_x1]
    mov word [GFX.m3_forward_clip_columns], ax
    push ds
    inc si
    mov ax, word [GFX.m3_forward_src_segment]
    mov ds, ax
    lodsw
    inc si
    pop ds
    inc al
    push ax
    and ax, 0xff
    mov word [GFX.m3_forward_rows], ax
    pop ax
    xchg ah, al
    and ax, 0xff
    shl ax, 1
    shl ax, 1
    shl ax, 1
    mov word [GFX.m3_forward_width], ax
    mov word [GFX.m3_forward_source_width], ax
    mov ax, word [GFX.m3_forward_y_or_row_skip]
    sub ax, word [GFX.clip_y1]
    jns short L2ACA
    add word [GFX.m3_forward_rows], ax
    jg short L2A93
    jmp near L2B35
L2A93:
    neg ax
    rr mov, dx, ax
    mov ax, word [GFX.m3_forward_width]
    mov word [cs:m3_forward_skip_left_addr], ax
    push di
    push es
    rr mov, di, si
    mov ax, word [GFX.m3_forward_src_segment]
    mov es, ax
L2AA7:
    mov cx, word [cs:m3_forward_skip_left_addr]
L2AAC:
    rr xor, ax, ax
    repne scasb
    je short L2AB4
    jcxz L2ABD
L2AB4:
    mov al, byte [es:di]
    inc di
    inc cx
    rr sub, cx, ax
    jne short L2AAC
L2ABD:
    dec dx
    jne short L2AA7
    rr mov, si, di
    pop es
    pop di
    mov ax, word [GFX.clip_y1]
    mov word [GFX.m3_forward_y_or_row_skip], ax
L2ACA:
    mov ax, word [GFX.clip_y2]
    sub ax, word [GFX.m3_forward_y_or_row_skip]
    js short L2B35
    je short L2B35
    cmp ax, word [GFX.m3_forward_rows]
    jae short L2ADE
    mov word [GFX.m3_forward_rows], ax
L2ADE:
    mov word [cs:m3_forward_skip_left_addr], 0
    mov ax, word [GFX.m3_forward_x_or_bank_wrap]
    rr or, ax, ax
    jns short L2B01
    add word [GFX.m3_forward_width], ax
    neg ax
    mov word [cs:m3_forward_skip_left_addr], ax
    cmp ax, word [GFX.m3_forward_source_width]
    jae short L2B35
    rr xor, ax, ax
    mov word [GFX.m3_forward_x_or_bank_wrap], ax
L2B01:
    mov word [cs:m3_forward_skip_right_addr], 0
    mov ax, word [GFX.m3_forward_clip_columns]
    shl ax, 1
    shl ax, 1
    shl ax, 1
    sub ax, word [GFX.m3_forward_x_or_bank_wrap]
    js short L2B35
    je short L2B35
    cmp ax, word [GFX.m3_forward_width]
    jae short L2B38
    mov word [GFX.m3_forward_width], ax
    mov ax, word [GFX.m3_forward_source_width]
    sub ax, word [cs:m3_forward_skip_left_addr]
    sub ax, word [GFX.m3_forward_width]
    mov word [cs:m3_forward_skip_right_addr], ax
    jmp short L2B38
    nop
L2B35:
    jmp near L2BD4
L2B38:
    mov ax, word [GFX.m3_forward_y_or_row_skip]
    mov dx, 0x140
    mul dx
    add ax, word [GFX.m3_forward_x_or_bank_wrap]
    rr add, di, ax
    rr mov, bp, di
    mov ax, word [GFX.m3_forward_width]
    mov word [cs:m3_forward_draw_width_addr], ax
    mov dx, word [GFX.m3_forward_rows]
    mov ax, word [GFX.m3_forward_src_segment]
    mov ds, ax
    rr xor, ax, ax
    mov bx, es
L2B5C:
    mov cx, word [cs:m3_forward_skip_left_addr]
    jcxz L2B86
    mov ax, ds
    mov ds, bx
    mov es, ax
    xchg di, si
L2B6B:
    rr xor, ax, ax
    repne scasb
    je short L2B73
    jcxz L2B7C
L2B73:
    mov al, byte [es:di]
    inc di
    inc cx
    rr sub, cx, ax
    jg short L2B6B
L2B7C:
    mov ax, es
    mov es, bx
    mov ds, ax
    xchg di, si
    rr xor, ax, ax
L2B86:
    rr sub, di, cx
    add cx, word [cs:m3_forward_draw_width_addr]
    jle short L2BA1
L2B8F:
    lodsb
    rr or, al, al
    je short L2B9A
    stosb
    loop L2B8F
    jmp short L2BA1
    nop
L2B9A:
    lodsb
    rr add, di, ax
    rr sub, cx, ax
    jg short L2B8F
L2BA1:
    add cx, word [cs:m3_forward_skip_right_addr]
    jcxz L2BCB
    mov ax, ds
    mov ds, bx
    mov es, ax
    xchg di, si
L2BB0:
    rr xor, ax, ax
    repne scasb
    je short L2BB8
    jcxz L2BC1
L2BB8:
    inc cx
    mov al, byte [es:di]
    inc di
    rr sub, cx, ax
    jne short L2BB0
L2BC1:
    mov ax, es
    mov es, bx
    mov ds, ax
    xchg di, si
    rr xor, ax, ax
L2BCB:
    add bp, 0x140
    rr mov, di, bp
    dec dx
    jne short L2B5C
L2BD4:
    pop es
    pop ds
    pop si
    pop di
    pop bp
    retf
; Mirror RLE clipping workspace stays accessible while DS is the sprite data.
m3_mirror_skip_left: ; 2BDA: pixels to skip on left of the unmirrored source row
    dw 0
m3_mirror_skip_right: ; 2BDC: pixels to skip on right before mirrored drawing begins
    dw 0
m3_mirror_draw_width: ; 2BDE: clipped pixels drawn backward in destination
    dw 0

; FUNCTION: DONALD 0000:2BE0
; sprite_mirror_m3: horizontally mirrored transparent RLE sprite, VGA mode 13h
sprite_mirror_m3:
    push bp
    rr mov, bp, sp
    push di
    push si
    push ds
    mov ax, GFX_DATA  ; reloc
    mov ds, ax
    push es
    cld
    mov di, word [bp + 6]
    mov ax, word [bp + 8]
    mov es, ax
    mov si, word [bp + 0xa]
    mov ax, word [bp + 0xc]
    mov word [GFX.m3_mirror_src_segment], ax
    mov bx, word [bp + 0xe]
    mov ax, word [bp + 0x10]
    mov word [GFX.m3_mirror_y_or_row_skip], ax
    mov ax, word [GFX.clip_x1]
    shl ax, 1
    shl ax, 1
    shl ax, 1
    rr add, di, ax
    mov byte [GFX.m3_mirror_subpixel_shift], 0
    rr sub, bx, ax
    mov word [GFX.m3_mirror_x_or_bank_wrap], bx
    mov ax, word [GFX.clip_x2]
    sub ax, word [GFX.clip_x1]
    mov word [GFX.m3_mirror_clip_columns], ax
    push ds
    inc si
    mov ax, word [GFX.m3_mirror_src_segment]
    mov ds, ax
    lodsw
    inc si
    pop ds
    inc al
    push ax
    and ax, 0xff
    mov word [GFX.m3_mirror_rows], ax
    pop ax
    xchg ah, al
    and ax, 0xff
    shl ax, 1
    shl ax, 1
    shl ax, 1
    mov word [GFX.m3_mirror_width], ax
    mov word [GFX.m3_mirror_source_width], ax
    mov ax, word [GFX.m3_mirror_y_or_row_skip]
    sub ax, word [GFX.clip_y1]
    jns short L2C95
    add word [GFX.m3_mirror_rows], ax
    jg short L2C5E
    jmp near L2D00
L2C5E:
    neg ax
    rr mov, dx, ax
    mov ax, word [GFX.m3_mirror_width]
    mov word [cs:GFX_CODE(m3_mirror_skip_left)], ax
    push di
    push es
    rr mov, di, si
    mov ax, word [GFX.m3_mirror_src_segment]
    mov es, ax
L2C72:
    mov cx, word [cs:GFX_CODE(m3_mirror_skip_left)]
L2C77:
    rr xor, ax, ax
    repne scasb
    je short L2C7F
    jcxz L2C88
L2C7F:
    mov al, byte [es:di]
    inc di
    inc cx
    rr sub, cx, ax
    jne short L2C77
L2C88:
    dec dx
    jne short L2C72
    rr mov, si, di
    pop es
    pop di
    mov ax, word [GFX.clip_y1]
    mov word [GFX.m3_mirror_y_or_row_skip], ax
L2C95:
    mov ax, word [GFX.clip_y2]
    sub ax, word [GFX.m3_mirror_y_or_row_skip]
    js short L2D00
    je short L2D00
    cmp ax, word [GFX.m3_mirror_rows]
    jae short L2CA9
    mov word [GFX.m3_mirror_rows], ax
L2CA9:
    mov word [cs:GFX_CODE(m3_mirror_skip_left)], 0
    mov ax, word [GFX.m3_mirror_x_or_bank_wrap]
    rr or, ax, ax
    jns short L2CCC
    add word [GFX.m3_mirror_width], ax
    neg ax
    mov word [cs:GFX_CODE(m3_mirror_skip_left)], ax
    cmp ax, word [GFX.m3_mirror_source_width]
    jae short L2D00
    rr xor, ax, ax
    mov word [GFX.m3_mirror_x_or_bank_wrap], ax
L2CCC:
    mov word [cs:GFX_CODE(m3_mirror_skip_right)], 0
    mov ax, word [GFX.m3_mirror_clip_columns]
    shl ax, 1
    shl ax, 1
    shl ax, 1
    sub ax, word [GFX.m3_mirror_x_or_bank_wrap]
    js short L2D00
    je short L2D00
    cmp ax, word [GFX.m3_mirror_width]
    jae short L2D03
    mov word [GFX.m3_mirror_width], ax
    mov ax, word [GFX.m3_mirror_source_width]
    sub ax, word [cs:GFX_CODE(m3_mirror_skip_left)]
    sub ax, word [GFX.m3_mirror_width]
    mov word [cs:GFX_CODE(m3_mirror_skip_right)], ax
    jmp short L2D03
    nop
L2D00:
    jmp near L2DA5
L2D03:
    mov ax, word [GFX.m3_mirror_y_or_row_skip]
    mov dx, 0x140
    mul dx
    add ax, word [GFX.m3_mirror_x_or_bank_wrap]
    rr add, di, ax
    mov ax, word [GFX.m3_mirror_width]
    mov word [cs:GFX_CODE(m3_mirror_draw_width)], ax
    rr add, di, ax
    dec di
    rr mov, bp, di
    mov dx, word [GFX.m3_mirror_rows]
    mov ax, word [GFX.m3_mirror_src_segment]
    mov ds, ax
    rr xor, ax, ax
    mov bx, es
L2D2A:
    mov cx, word [cs:GFX_CODE(m3_mirror_skip_right)]
    jcxz L2D54
    mov ax, ds
    mov ds, bx
    mov es, ax
    xchg di, si
L2D39:
    rr xor, ax, ax
    repne scasb
    je short L2D41
    jcxz L2D4A
L2D41:
    mov al, byte [es:di]
    inc di
    inc cx
    rr sub, cx, ax
    jg short L2D39
L2D4A:
    mov ax, es
    mov es, bx
    mov ds, ax
    xchg di, si
    rr xor, ax, ax
L2D54:
    rr add, di, cx
    add cx, word [cs:GFX_CODE(m3_mirror_draw_width)]
    jle short L2D72
L2D5D:
    lodsb
    rr or, al, al
    je short L2D6B
    mov byte [es:di], al
    dec di
    loop L2D5D
    jmp short L2D72
    nop
L2D6B:
    lodsb
    rr sub, di, ax
    rr sub, cx, ax
    jg short L2D5D
L2D72:
    add cx, word [cs:GFX_CODE(m3_mirror_skip_left)]
    jcxz L2D9C
    mov ax, ds
    mov ds, bx
    mov es, ax
    xchg di, si
L2D81:
    rr xor, ax, ax
    repne scasb
    je short L2D89
    jcxz L2D92
L2D89:
    inc cx
    mov al, byte [es:di]
    inc di
    rr sub, cx, ax
    jne short L2D81
L2D92:
    mov ax, es
    mov es, bx
    mov ds, ax
    xchg di, si
    rr xor, ax, ax
L2D9C:
    add bp, 0x140
    rr mov, di, bp
    dec dx
    jne short L2D2A
L2DA5:
    pop es
    pop ds
    pop si
    pop di
    pop bp
    retf

; ---- Initialized graphics objects, frame offsets 14B6-14DF ----
segment GFX_DATA
%define GFX_DATA_BASE 0x14b6
gfx_data_start:

gfx_dac_levels_tail: ; 14B6, byte[7] (DAC table continuation): six-bit DAC intensities indexed by three-bit colour component; split across OMF modules
    db 0x03,0x08,0x10,0x18,0x1e,0x2d,0x3f

gfx_assert m3_forward_src_segment
gfx_m3_forward_src_segment: ; 14BD, word: source segment saved before switching DS
    dw 0x0000

gfx_assert m3_forward_dst_segment
gfx_m3_forward_dst_segment: ; 14BF, word: destination segment; unused compatibility slot in mode 3
    dw 0x0000

gfx_assert m3_forward_x_or_bank_wrap
gfx_m3_forward_x_or_bank_wrap: ; 14C1, word: relative x; packed CGA path reuses it as bank-wrap delta
    dw 0x0000

gfx_assert m3_forward_y_or_row_skip
gfx_m3_forward_y_or_row_skip: ; 14C3, word: clipped y; packed paths reuse it as row skip
    dw 0x0000

gfx_assert m3_forward_rows
gfx_m3_forward_rows: ; 14C5, word: clipped sprite height, decremented per row
    dw 0x0000

gfx_assert m3_forward_width
gfx_m3_forward_width: ; 14C7, word: clipped source row width in bytes (packed) or pixels (mode 3)
    dw 0x0000

gfx_assert m3_forward_source_width
gfx_m3_forward_source_width: ; 14C9, word: unclipped source row width
    dw 0x0000

gfx_assert m3_forward_scanline_phase
gfx_m3_forward_scanline_phase: ; 14CB, word: CGA/Tandy bank counter; unused compatibility slot in mode 3
    dw 0x0000

gfx_assert m3_forward_subpixel_shift
gfx_m3_forward_subpixel_shift: ; 14CD, byte: CGA/Tandy shift bits; mode 3 writes zero but never reads it
    db 0x00

gfx_assert m3_forward_clip_columns
gfx_m3_forward_clip_columns: ; 14CE, word: clip_x2-clip_x1, expanded by pixels/bytes per column
    dw 0x0000

gfx_assert m3_mirror_src_segment
gfx_m3_mirror_src_segment: ; 14D0, word: source segment saved before switching DS
    dw 0x0000

gfx_assert m3_mirror_dst_segment
gfx_m3_mirror_dst_segment: ; 14D2, word: destination segment; unused compatibility slot in mode 3
    dw 0x0000

gfx_assert m3_mirror_x_or_bank_wrap
gfx_m3_mirror_x_or_bank_wrap: ; 14D4, word: relative x; packed CGA path reuses it as bank-wrap delta
    dw 0x0000

gfx_assert m3_mirror_y_or_row_skip
gfx_m3_mirror_y_or_row_skip: ; 14D6, word: clipped y; packed paths reuse it as row skip
    dw 0x0000

gfx_assert m3_mirror_rows
gfx_m3_mirror_rows: ; 14D8, word: clipped sprite height, decremented per row
    dw 0x0000

gfx_assert m3_mirror_width
gfx_m3_mirror_width: ; 14DA, word: clipped source row width in bytes (packed) or pixels (mode 3)
    dw 0x0000

gfx_assert m3_mirror_source_width
gfx_m3_mirror_source_width: ; 14DC, word: unclipped source row width
    dw 0x0000

gfx_assert m3_mirror_scanline_phase
gfx_m3_mirror_scanline_phase: ; 14DE, word: CGA/Tandy bank counter; unused compatibility slot in mode 3
    dw 0x0000
gfx_data_end:
    times (0 / (($ - gfx_data_start) = 0x002a)) db 0
; The remaining mirror-workspace byte/word are KBD_DATA aliases; see gfx_data.inc.
