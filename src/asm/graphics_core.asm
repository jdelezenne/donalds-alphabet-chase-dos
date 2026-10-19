; Module 0000:08B9: hand-written graphics assembly, _TEXT part 3/5 (split by relocation-table order).
; SEGMENT: DONALD 0000 08B9-277E
; Purpose: graphics driver core: screen/buffer clears, .CMP RLE decoders, palette, DOS helpers, text glyphs, video retrace waits.
bits 16
%include "tasm.inc"
%include "gfx_data.inc"
%define GFX_TEXT_BASE 0x08b9
BDA_CRTC_PORT equ 0x0063 ; BIOS data area, CRTC I/O port at 0040:0063

segment GFX_DATA public align=2 class=DATA use16   ; far data of the graphics modules (starts at 0B7F:000E)
segment _TEXT public align=1 class=CODE use16
gfx_text_start:

global _clear_screen
_clear_screen equ clear_screen
global _redraw_rect_hw
_redraw_rect_hw equ fill_rect_cells
global _far_copy
_far_copy equ far_copy
global _present_buffer
_present_buffer equ present_buffer
global _sprite_put_ega
_sprite_put_ega equ sprite_put_ega
global _cga_shift_rows
_cga_shift_rows equ cga_shift_rows
global _pack_rect
_pack_rect equ pack_rect
global _gfx_fill_rect
_gfx_fill_rect equ gfx_fill_rect
global _dos_free_kb
_dos_free_kb equ dos_free_kb
global _cmp_unpack_planar
_cmp_unpack_planar equ cmp_unpack_planar
global _cmp_unpack_cga
_cmp_unpack_cga equ cmp_unpack_cga
global _enable_ints
_enable_ints equ enable_ints
global _disable_ints
_disable_ints equ disable_ints
global _set_palette16
_set_palette16 equ set_palette16
global _cga_convert
_cga_convert equ cga_convert
global _clear_buffer
_clear_buffer equ convert_cga_pixels_and_masks
global _normalize_ptr
_normalize_ptr equ normalize_ptr
global _dos_putc
_dos_putc equ dos_putc
global _rand8
_rand8 equ rand8
global _sprite_mask_ega
_sprite_mask_ega equ sprite_mirror_ega
global _dos_set_drive
_dos_set_drive equ dos_set_drive
global _cga_select_palette
_cga_select_palette equ cga_select_palette
global _set_palette_reg
_set_palette_reg equ set_palette_reg
global _set_video_type
_set_video_type equ set_video_type
global _set_bios_mode
_set_bios_mode equ set_bios_mode
global _sprite_put_cga
_sprite_put_cga equ sprite_put_cga
global _sprite_mask_cga
_sprite_mask_cga equ sprite_mirror_packed
global _set_text_colours
_set_text_colours equ set_text_colours
global _draw_char_cga
_draw_char_cga equ draw_char_tandy4bpp
global _draw_char_tandy
_draw_char_tandy equ draw_char_cga2bpp
global _draw_char_ega
_draw_char_ega equ draw_char_ega
global _draw_char_buf
_draw_char_buf equ draw_char_vga8bpp
global _gfx_init
_gfx_init equ gfx_init
global _set_palette_regs
_set_palette_regs equ set_palette_regs
global _in_vretrace
_in_vretrace equ in_vretrace
global _wait_vretrace
_wait_vretrace equ wait_vretrace
global _vline
_vline equ vline
global _set_dac_regs
_set_dac_regs equ set_dac_regs
; FUNCTION: DONALD 0000:08B9
; clear_screen: clears video memory B800/A000 per mode
clear_screen:
    push bp
    rr mov, bp, sp
    push di
    push si
    push ds
    mov ax, GFX_DATA  ; reloc
    mov ds, ax
    push es
    mov ax, 0xb800
    mov es, ax
    mov di, 0
    mov cx, 0x2000
    cmp word [GFX.video_mode], 0
    je short L0908
    shl ch, 1
    cmp word [GFX.video_mode], 1
    je short L0908
    mov ax, 0xa000
    mov es, ax
    cmp word [GFX.video_mode], 2
    je short L08F1
    shl ch, 1
    jmp short L0908
    nop
L08F1:
    mov cx, 0xfa0
    mov dx, 0x3ce
    mov ax, 0x205
    out dx, al
    inc dx
    rr mov, al, ah
    out dx, al
    dec dx
    mov ax, 0xff08
    out dx, al
    inc dx
    rr mov, al, ah
    out dx, al
L0908:
    rr mov, ax, di
    rep stosw
    pop es
    pop ds
    pop si
    pop di
    pop bp
    retf

; FUNCTION: DONALD 0000:0912
; fill_rect_cells: solid fill of an eight-pixel-cell rectangle in the active video mode
fill_rect_cells:
    push bp
    rr mov, bp, sp
    push di
    push si
    push ds
    mov ax, GFX_DATA  ; reloc
    mov ds, ax
    push es
    mov ax, 0xb800
    cmp word [GFX.video_mode], 1
    jle short L092B
    mov ax, 0xa000
L092B:
    mov es, ax
    mov bx, word [bp + 6]
    mov ax, word [bp + 8]
    shl ax, 1
    shl ax, 1
    shl ax, 1
    mov cx, word [bp + 0xa]
    mov dx, word [bp + 0xc]
    shl dx, 1
    shl dx, 1
    shl dx, 1
    mov word [GFX.fill_rows], dx
    mov dx, 0x28
    cmp word [GFX.video_mode], 2
    je short L097D
    shl dx, 1
    shl bx, 1
    cmp word [GFX.video_mode], 0
    jne short L0963
    shr ax, 1
    jmp short L097D
    nop
L0963:
    shl dx, 1
    shl cx, 1
    shl bx, 1
    cmp word [GFX.video_mode], 1
    jne short L0977
    shr ax, 1
    shr ax, 1
    jmp short L097D
    nop
L0977:
    shl dx, 1
    shl cx, 1
    shl bx, 1
L097D:
    mov word [GFX.fill_row_stride], dx
    mul dx
    rr add, ax, bx
    rr mov, di, ax
    mov word [GFX.fill_row_count], cx
    cmp word [GFX.video_mode], 2
    je short L09FC
    mov dx, word [GFX.fill_rows]
    mov ax, word [bp + 0xe]
    rr mov, ah, al
    cmp word [GFX.video_mode], 3
    je short L09C0
    shl al, 1
    shl al, 1
    shl al, 1
    shl al, 1
    rr or, al, ah
    rr mov, ah, al
    cmp word [GFX.video_mode], 1
    je short L09C0
    and ax, 0x3333
    shl al, 1
    shl al, 1
    rr or, al, ah
    rr mov, ah, al
L09C0:
    rr mov, si, di
    mov cx, word [GFX.fill_row_count]
    rep stosw
    rr mov, di, si
    add di, word [GFX.fill_row_stride]
    cmp word [GFX.video_mode], 3
    je short L09F7
    cmp word [GFX.video_mode], 1
    jne short L09E9
    add di, 0x1f60
    jns short L09F7
    sub di, 0x7f60
    jmp short L09F7
    nop
L09E9:
    add di, 0x1fb0
    test dx, 1
    je short L09F7
    sub di, 0x3fb0
L09F7:
    dec dx
    jne short L09C0
    je short L0A28
L09FC:
    mov dx, 0x3ce
    mov ax, 0x205
    out dx, al
    inc dx
    rr mov, al, ah
    out dx, al
    dec dx
    mov ax, 0xff08
    out dx, al
    inc dx
    rr mov, al, ah
    out dx, al
    mov dx, word [GFX.fill_rows]
    mov ax, word [bp + 0xe]
L0A17:
    rr mov, si, di
    mov cx, word [GFX.fill_row_count]
    rep stosb
    rr mov, di, si
    add di, word [GFX.fill_row_stride]
    dec dx
    jne short L0A17
L0A28:
    pop es
    pop ds
    pop si
    pop di
    pop bp
    retf

; FUNCTION: DONALD 0000:0A2E
; far_copy: rep movsw far copy (src, dst, len)
far_copy:
    push bp
    rr mov, bp, sp
    push di
    push si
    push ds
    mov ax, GFX_DATA  ; reloc
    mov ds, ax
    mov si, word [bp + 6]
    mov dx, word [bp + 8]
    mov di, word [bp + 0xa]
    mov ax, word [bp + 0xc]
    push es
    mov es, ax
    mov cx, word [bp + 0xe]
    mov bx, word [bp + 0x10]
    mov ds, dx
    shr cx, 1
    je short L0A56
    rep movsw
L0A56:
    jae short L0A59
    movsb
L0A59:
    rr or, bx, bx
    je short L0A65
L0A5D:
    mov cx, 0x8000
    rep movsw
    dec bx
    jne short L0A5D
L0A65:
    pop es
    pop ds
    pop si
    pop di
    pop bp
    retf

; FUNCTION: DONALD 0000:0A6B
; present_buffer: copies the off-screen buffer to video memory (EGA planes via 3C4/3CE)
present_buffer:
    push bp
    rr mov, bp, sp
    push di
    push si
    push ds
    mov ax, GFX_DATA  ; reloc
    mov ds, ax
    mov si, word [bp + 6]
    mov ax, word [bp + 8]
    push es
    mov es, ax
    mov ax, word [bp + 0xa]
    mov cx, 0x1f40
    mov ds, ax
    mov di, 0
    mov dx, 0x3ce
    mov ax, 0x205
    out dx, al
    inc dx
    rr mov, al, ah
    out dx, al
    dec dx
    mov al, 8
    out dx, al
    inc dx
L0A9A:
    mov ax, 0x80
    out dx, al
    mov al, byte [di]
    mov bl, byte [es:si]
    rr mov, al, bl
    shr al, 1
    shr al, 1
    shr al, 1
    shr al, 1
    mov byte [di], al
    mov al, byte [di]
    mov ax, 0x40
    out dx, al
    mov byte [di], bl
    inc si
    mov ax, 0x20
    out dx, al
    mov al, byte [di]
    mov bl, byte [es:si]
    rr mov, al, bl
    shr al, 1
    shr al, 1
    shr al, 1
    shr al, 1
    mov byte [di], al
    mov al, byte [di]
    mov ax, 0x10
    out dx, al
    mov byte [di], bl
    inc si
    mov ax, 8
    out dx, al
    mov al, byte [di]
    mov bl, byte [es:si]
    rr mov, al, bl
    shr al, 1
    shr al, 1
    shr al, 1
    shr al, 1
    mov byte [di], al
    mov al, byte [di]
    mov ax, 4
    out dx, al
    mov byte [di], bl
    inc si
    mov ax, 2
    out dx, al
    mov al, byte [di]
    mov bl, byte [es:si]
    rr mov, al, bl
    shr al, 1
    shr al, 1
    shr al, 1
    shr al, 1
    mov byte [di], al
    mov al, byte [di]
    mov ax, 1
    out dx, al
    mov byte [di], bl
    inc si
    inc di
    loop L0A9A
    dec dx
    mov ax, 8
    out dx, al
    inc dx
    rr mov, al, ah
    out dx, al
    pop es
    pop ds
    pop si
    pop di
    pop bp
    retf
; Inline CS scratch remains accessible after the sprite decoder changes DS.
ega_forward_left_minus1: ; 0B24: left clip column minus one
    dw 0
ega_forward_right_minus1: ; 0B26: exclusive right clip column minus one
    dw 0
ega_forward_bottom_offset: ; 0B28: exclusive bottom scanline times 40
    dw 0
ega_forward_bottom_y: ; 0B2A: exclusive bottom scanline
    dw 0
ega_forward_top_y: ; 0B2C: first allowed scanline
    dw 0

; FUNCTION: DONALD 0000:0B2E
; sprite_put_ega: draw_sprite, EGA
sprite_put_ega:
    push bp
    rr mov, bp, sp
    push di
    push si
    push ds
    mov ax, GFX_DATA  ; reloc
    mov ds, ax
    push es
    mov dx, 0x28
    mov ax, word [GFX.ega_clip_y2]
    mov word [cs:GFX_CODE(ega_forward_bottom_y)], ax
    mul dl
    mov word [cs:GFX_CODE(ega_forward_bottom_offset)], ax
    mov ax, word [GFX.ega_clip_y1]
    mov word [cs:GFX_CODE(ega_forward_top_y)], ax
    mov di, word [bp + 6]
    mov ax, word [bp + 8]
    mov es, ax
    mov si, word [bp + 0xa]
    mov ax, word [bp + 0xc]
    mov word [GFX.ega_sprite_src_segment], ax
    mov ax, word [bp + 0xe]
    mov word [GFX.ega_sprite_x_pixel], ax
    sar ax, 1
    sar ax, 1
    sar ax, 1
    mov word [GFX.ega_sprite_x_byte], ax
    mov dx, word [bp + 0x10]
    mov ax, word [GFX.ega_clip_x1]
    dec ax
    mov word [cs:GFX_CODE(ega_forward_left_minus1)], ax
    mov ax, word [GFX.ega_clip_x2]
    dec ax
    mov word [cs:GFX_CODE(ega_forward_right_minus1)], ax
    mov bp, ds
    mov ax, word [GFX.ega_sprite_src_segment]
    mov ds, ax
    inc si
    lodsw
    rr mov, bx, ax
    and bx, 0xff
    inc bx
    inc si
    cmp dx, word [cs:GFX_CODE(ega_forward_bottom_y)]
    jge short L0BAB
    rr mov, cx, dx
    sub cx, word [cs:GFX_CODE(ega_forward_top_y)]
    jns short L0BBB
    neg cx
    rr cmp, cx, bx
    jl short L0BAE
L0BAB:
    jmp near L0C80
L0BAE:
    lodsw
    test ah, 0x40
    je short L0BAE
    loop L0BAE
    mov dx, word [cs:GFX_CODE(ega_forward_top_y)]
L0BBB:
    mov ds, bp
    mov ax, 0x28
    mul dx
    rr add, di, ax
    add di, word [GFX.ega_sprite_x_byte]
    mov cx, word [GFX.ega_sprite_x_pixel]
    and cx, 7
    mov bx, word [GFX.ega_sprite_x_byte]
    mov dx, 0x3ce
    mov ax, 0x205
    out dx, al
    inc dx
    rr mov, al, ah
    out dx, al
    dec dx
    mov al, 8
    out dx, al
    inc dx
    mov ax, word [GFX.ega_sprite_src_segment]
    cmp word [GFX.sprite_underlay], 1
    jne short L0BF0
    jmp near L0C86
L0BF0:
    push ds
    mov ds, ax
    rr mov, bp, di
L0BF5:
    push bx
L0BF6:
    mov al, byte [es:di]
    lodsb
    rr or, cl, cl
    jne short L0C3C
    cmp bx, word [cs:GFX_CODE(ega_forward_right_minus1)]
    jg short L0C39
    cmp bx, word [cs:GFX_CODE(ega_forward_left_minus1)]
    jle short L0C39
    out dx, al
    lodsb
    mov byte [es:di], al
L0C11:
    shl al, 1
    jae short L0BF6
    inc di
    inc bx
    shl al, 1
    jae short L0BF6
    shl al, 1
    jb short L0C7E
    add bp, 0x28
    cmp bp, word [cs:GFX_CODE(ega_forward_bottom_offset)]
    jae short L0C7E
    rr mov, di, bp
    pop bx
    rr mov, ax, bp
    rr sub, ax, bx
    cmp ax, word [cs:GFX_CODE(ega_forward_bottom_offset)]
    jae short L0C7F
    jmp short L0BF5
L0C39:
    lodsb
    jmp short L0C11
L0C3C:
    rr xor, ah, ah
    xchg al, ah
    shr ax, cl
    cmp bx, word [cs:GFX_CODE(ega_forward_right_minus1)]
    jg short L0C79
    cmp bx, word [cs:GFX_CODE(ega_forward_left_minus1)]
    jle short L0C79
    rr mov, ch, al
    mov al, byte [es:di]
    rr mov, al, ah
    out dx, al
    lodsb
    mov byte [es:di], al
L0C5C:
    cmp bx, word [cs:GFX_CODE(ega_forward_right_minus1)]
    jge short L0C11
    cmp bx, word [cs:GFX_CODE(ega_forward_left_minus1)]
    jl short L0C11
    mov ah, byte [es:di + 1]
    xchg al, ch
    out dx, al
    xchg al, ch
    mov byte [es:di + 1], al
    jmp short L0C11
L0C79:
    rr mov, ch, al
    lodsb
    jmp short L0C5C
L0C7E:
    pop bx
L0C7F:
    pop ds
L0C80:
    pop es
    pop ds
    pop si
    pop di
    pop bp
    retf
L0C86:
    push ds
    mov ds, ax
    mov dx, 0x3ce
    mov al, 5
    out dx, al
    inc dx
    mov al, 0xa
    out dx, al
    dec dx
    mov al, 2
    out dx, al
    inc dx
    rr xor, al, al
    out dx, al
    dec dx
    mov al, 8
    out dx, al
    inc dx
    rr mov, bp, di
L0CA2:
    push bx
L0CA3:
    rr or, cl, cl
    jne short L0CE0
    cmp bx, 0x28
    jae short L0CDD
    lodsb
    and al, byte [es:di]
    out dx, al
    lodsb
    mov byte [es:di], al
L0CB5:
    shl al, 1
    jae short L0CA3
    inc di
    inc bx
    shl al, 1
    jae short L0CA3
    shl al, 1
    jb short L0C7E
    add bp, 0x28
    cmp bp, word [cs:GFX_CODE(ega_forward_bottom_offset)]
    jae short L0C7E
    rr mov, di, bp
    pop bx
    rr mov, ax, bp
    rr sub, ax, bx
    cmp ax, word [cs:GFX_CODE(ega_forward_bottom_offset)]
    jae short L0C7F
    jmp short L0CA2
L0CDD:
    lodsb
    jmp short L0CB5
L0CE0:
    lodsb
    rr xor, ah, ah
    xchg al, ah
    shr ax, cl
    cmp bx, word [cs:GFX_CODE(ega_forward_right_minus1)]
    jg short L0D17
    rr mov, ch, al
    and ah, byte [es:di]
    rr mov, al, ah
    out dx, al
    lodsb
    mov byte [es:di], al
L0CFA:
    cmp bx, word [cs:GFX_CODE(ega_forward_right_minus1)]
    jge short L0CB5
    cmp bx, word [cs:GFX_CODE(ega_forward_left_minus1)]
    jl short L0CB5
    xchg al, ch
    and al, byte [es:di + 1]
    out dx, al
    xchg al, ch
    mov byte [es:di + 1], al
    jmp short L0CB5
L0D17:
    rr mov, ch, al
    lodsb
    jmp short L0CFA

; FUNCTION: DONALD 0000:0D1C
; cga_shift_rows: moves the converted CGA rows into place (small-window mode)
cga_shift_rows:
    push bp
    rr mov, bp, sp
    push di
    push si
    push ds
    mov ax, GFX_DATA  ; reloc
    mov ds, ax
    mov bx, word [bp + 6]
    rr mov, si, bx
    rr mov, di, si
    mov ax, word [bp + 8]
    push es
    mov es, ax
    mov ds, ax
    add si, 0x3e40
    add di, 0x7c80
    cld
L0D3F:
    mov cx, 0x20
    rep movsw
    sub si, 0x80
    sub di, 0xc0
    rr cmp, di, bx
    jne short L0D3F
    pop es
    pop ds
    pop si
    pop di
    pop bp
    retf

; FUNCTION: DONALD 0000:0D56
; pack_rect: packs a screen rectangle into a buffer, returns its size
pack_rect:
    push bp
    rr mov, bp, sp
    push di
    push si
    push ds
    mov ax, GFX_DATA  ; reloc
    mov ds, ax
    push es
    mov si, word [bp + 6]
    mov ax, word [bp + 8]
    mov word [GFX.pack_src_segment], ax
    mov di, word [bp + 0xa]
    mov word [GFX.pack_dst_start], di
    mov ax, word [bp + 0xc]
    mov es, ax
    mov dx, word [bp + 0xe]
    mov ax, word [bp + 0x10]
    mov byte [GFX.pack_rows], al
    mov bx, word [bp + 0x12]
    cmp word [GFX.video_mode], 2
    je short L0DBF
    mov dh, byte [GFX.pack_rows]
    cmp word [GFX.video_mode], 0
    je short L0DAB
    mov ds, word [GFX.pack_src_segment]
L0D99:
    rr mov, cl, dl
    rr xor, ch, ch
    rep movsw
    rr add, si, bx
    dec dh
    jne short L0D99
L0DA5:
    pop es
    pop ds
    pop si
    pop di
    pop bp
    retf
L0DAB:
    mov ds, word [GFX.pack_src_segment]
L0DAF:
    rr mov, cl, dl
    rr xor, ch, ch
L0DB3:
    lodsw
    stosb
    loop L0DB3
    rr add, si, bx
    dec dh
    jne short L0DAF
    je short L0DA5
L0DBF:
    push ds
    rr mov, bp, si
    mov word [GFX.pack_width], dx
L0DC6:
    mov dx, word [GFX.pack_width]
    mov byte [GFX.pack_columns_left], dl
L0DCE:
    rr mov, si, bp
    push ds
    mov ax, word [GFX.pack_src_segment]
    mov ds, ax
    lodsw
    xchg al, ah
    rr mov, bx, ax
    lodsw
    xchg al, ah
    rr mov, bp, si
    pop ds
    mov si, GFX.pack_colour_masks
    mov cx, 0x10
L0DE7:
    mov byte [si], ch
    inc si
    loop L0DE7
    mov ch, 0x80
L0DEE:
    call take_nibble
    mov si, GFX.pack_colour_masks
    rr add, si, dx
    or byte [si], ch
    shr ch, 1
    je short L0E05
    cmp ch, 8
    jne short L0DEE
    rr mov, bx, ax
    jmp short L0DEE
L0E05:
    mov si, GFX.pack_colour_masks
    mov bx, 0xf
    rr xor, al, al
L0E0D:
    or al, byte [bx + si]
    dec bx
    jne short L0E0D
    rr or, al, al
    je short L0E2B
    mov cx, 1
    inc si
L0E1A:
    lodsb
    rr or, al, al
    je short L0E23
    stosb
    rr mov, al, cl
    stosb
L0E23:
    inc cx
    cmp cx, 0x10
    jb short L0E1A
    jae short L0E2D
L0E2B:
    stosb
    stosb
L0E2D:
    dec di
    mov al, 0x80
    or byte [es:di], al
    inc di
    dec byte [GFX.pack_columns_left]
    jne short L0DCE
    dec di
    mov al, 0x40
    or byte [es:di], al
    inc di
    add bp, 0xa0
    sub bp, word [GFX.pack_width]
    sub bp, word [GFX.pack_width]
    sub bp, word [GFX.pack_width]
    sub bp, word [GFX.pack_width]
    dec byte [GFX.pack_rows]
    je short L0E5E
    jmp near L0DC6
L0E5E:
    dec di
    mov al, 0x20
    or byte [es:di], al
    pop ds
    inc di
    rr mov, ax, di
    sub ax, word [GFX.pack_dst_start]
    jmp near L0DA5
; take_nibble: dl = top 4 bits of bx, bx <<= 4
; FUNCTION: DONALD 0000:0E6F
; Near helper: DL = high nibble of BX; BX <<= 4.
take_nibble:
    rr xor, dx, dx
    shl bx, 1
    rcl dl, 1
    shl bx, 1
    rcl dl, 1
    shl bx, 1
    rcl dl, 1
    shl bx, 1
    rcl dl, 1
    ret

; FUNCTION: DONALD 0000:0E82
; gfx_fill_rect: (x, y, w, h, colour)
gfx_fill_rect:
    push bp
    rr mov, bp, sp
    push di
    push si
    push ds
    mov ax, GFX_DATA  ; reloc
    mov ds, ax
    push es
    mov di, word [bp + 6]
    shr di, 1
    mov bx, word [bp + 8]
    rr mov, ax, bx
    and al, 0xfc
    mov dx, 0x28
    mul dl
    rr add, di, ax
    rr mov, dx, bx
    and dx, 3
    je short L0EB0
    rr mov, cx, dx
L0EAA:
    add di, 0x2000
    loop L0EAA
L0EB0:
    mov ax, word [bp + 0xa]
    inc ax
    mov word [GFX.tandy_fill_count], ax
    mov ax, word [bp + 0xc]
    mov word [GFX.tandy_fill_rows_minus1], ax
    mov ax, word [bp + 0xe]
    rr mov, ah, al
    mov cx, 4
    shl al, cl
    rr or, al, ah
    rr mov, ah, al
    mov word [GFX.tandy_fill_colour], ax
    mov bx, 0xb800
    mov es, bx
    mov bx, word [GFX.tandy_fill_rows_minus1]
L0ED7:
    mov cx, word [GFX.tandy_fill_count]
    rep stosb
    sub di, word [GFX.tandy_fill_count]
    inc dl
    and dl, 3
    je short L0EF1
    add di, 0x2000
    dec bx
    jns short L0ED7
    js short L0EF8
L0EF1:
    sub di, 0x5f60
    dec bx
    jns short L0ED7
L0EF8:
    pop es
    pop ds
    pop si
    pop di
    pop bp
    retf

; FUNCTION: DONALD 0000:0EFE
; dos_free_kb: int 21h AH=48h probe; returns free conventional memory in KB
dos_free_kb:
    push bp
    rr mov, bp, sp
    push di
    push si
    push ds
    mov ax, GFX_DATA  ; reloc
    mov ds, ax
    mov ah, 0x48
    mov bx, 0xa000
    int 0x21
    jb short L0F20
    push es
    mov es, ax
    mov ah, 0x49
    int 0x21
    pop es
    mov ax, 0x280
    jmp short L0F27
    nop
L0F20:
    rr mov, ax, bx
    mov cx, 6
    shr ax, cl
L0F27:
    pop ds
    pop si
    pop di
    pop bp
    retf

; FUNCTION: DONALD 0000:0F2C
; cmp_unpack_planar: decodes a .CMP picture (EGA/Tandy layout), see docs/CMP.md
cmp_unpack_planar:
    push bp
    rr mov, bp, sp
    push di
    push si
    push ds
    mov ax, GFX_DATA  ; reloc
    mov ds, ax
    push es
    mov si, word [bp + 6]
    mov ax, word [bp + 8]
    mov di, word [bp + 0xa]
    mov dx, word [bp + 0xc]
    mov es, dx
    mov ds, ax
    jmp short L0F52
    nop
L0F4B:
    inc si
    mov ax, word [si]
    inc si
    jmp short L0F63
    nop
L0F52:
    mov dx, 0x7d00
L0F55:
    rr xor, bx, bx
    rr xor, ax, ax
    mov al, byte [si]
    rr or, al, al
    je short L0F4B
    jns short L0F64
    neg al
L0F63:
    dec bx
L0F64:
    rr mov, cx, ax
L0F66:
    inc si
    mov al, byte [si]
L0F69:
    stosb
    dec dx
    je short L0F7D
    test bx, 1
    jne short L0F78
    loop L0F66
    inc si
    jmp short L0F55
L0F78:
    loop L0F69
    inc si
    jmp short L0F55
L0F7D:
    pop es
    pop ds
    pop si
    pop di
    pop bp
    retf

; FUNCTION: DONALD 0000:0F83
; cmp_unpack_cga: decodes a .CMP picture (CGA layout), see docs/CMP.md
cmp_unpack_cga:
    push bp
    rr mov, bp, sp
    push di
    push si
    push ds
    mov ax, GFX_DATA  ; reloc
    mov ds, ax
    push es
    mov si, word [bp + 6]
    mov ax, word [bp + 8]
    mov di, word [bp + 0xa]
    mov dx, word [bp + 0xc]
    mov es, dx
    mov ds, ax
    jmp short L0FA9
    nop
L0FA2:
    inc si
    mov ax, word [si]
    inc si
    jmp short L0FBC
    nop
L0FA9:
    mov dx, 0x7d00
    mov bl, 0xc8
L0FAE:
    rr sub, bh, bh
    rr sub, ax, ax
    mov al, byte [si]
    rr or, al, al
    je short L0FA2
    jns short L0FBE
    neg al
L0FBC:
    dec bh
L0FBE:
    rr mov, cx, ax
L0FC0:
    inc si
    mov al, byte [si]
L0FC3:
    mov byte [es:di], al
    add di, 0xa0
    dec bl
    je short L0FE0
L0FCE:
    dec dx
    je short L0FE8
    test bh, 1
    jne short L0FDB
    loop L0FC0
    inc si
    jmp short L0FAE
L0FDB:
    loop L0FC3
    inc si
    jmp short L0FAE
L0FE0:
    mov bl, 0xc8
    sub di, 0x7cff
    jmp short L0FCE
L0FE8:
    pop es
    pop ds
    pop si
    pop di
    pop bp
    retf

; FUNCTION: DONALD 0000:0FEE
; enable_ints: sti
enable_ints:
    sti
    retf

; FUNCTION: DONALD 0000:0FF0
; disable_ints: cli
disable_ints:
    cli
    retf

; FUNCTION: DONALD 0000:0FF2
; set_palette16: loads a 16-entry palette table
set_palette16:
    push bp
    rr mov, bp, sp
    push di
    push si
    push ds
    mov ax, GFX_DATA  ; reloc
    mov ds, ax
    cmp word [GFX.video_mode], 0
    jne short L1066
    mov si, word [bp + 6]
    mov ax, word [bp + 8]
    push es
    mov es, ax
    mov di, GFX.cga_even_palette
    mov cx, 0x20
L1013:
    mov al, byte [es:si]
    mov byte [di], al
    inc si
    inc di
    loop L1013
    mov si, GFX.cga_even_pixels
    mov di, GFX.cga_odd_pixels
    rr xor, cl, cl
    rr xor, dx, dx
L1026:
    rr xor, ah, ah
    rr mov, al, cl
    shr al, 1
    shr al, 1
    shr al, 1
    shr al, 1
    rr mov, dl, al
    rr mov, al, cl
    and al, 0xf
    mov bx, GFX.cga_even_palette
    rr add, bx, dx
    mov ch, byte [bx]
    rr sub, bx, dx
    shl ch, 1
    shl ch, 1
    rr add, bx, ax
    or ch, byte [bx + 0x10]
    rr sub, bx, ax
    mov byte [si], ch
    inc si
    rr add, bx, dx
    mov ch, byte [bx + 0x10]
    rr sub, bx, dx
    shl ch, 1
    shl ch, 1
    rr add, bx, ax
    or ch, byte [bx]
    mov byte [di], ch
    inc di
    inc cl
    jne short L1026
    pop es
L1066:
    pop ds
    pop si
    pop di
    pop bp
    retf

; FUNCTION: DONALD 0000:106B
; cga_convert: 4-bit pixels -> CGA 2-bit via xlat table
cga_convert:
    push bp
    rr mov, bp, sp
    push di
    push si
    push ds
    mov ax, GFX_DATA  ; reloc
    mov ds, ax
    push es
    mov si, word [bp + 6]
    mov ax, word [bp + 8]
    mov word [GFX.cga_convert_src_segment], ax
    mov di, word [bp + 0xa]
    mov dx, word [bp + 0xc]
    mov bx, word [bp + 0xe]
    mov byte [GFX.cga_convert_row_count], bl
    mov cx, word [bp + 0x10]
    rr mov, bp, dx
    rr xor, dh, dh
L1094:
    mov bx, GFX.cga_even_pixels
L1097:
    mov dl, byte [GFX.cga_convert_row_count]
L109B:
    mov ax, word [GFX.cga_convert_src_segment]
    mov es, ax
    mov al, byte [es:si]
    inc si
    xlatb
    shl al, 1
    shl al, 1
    shl al, 1
    shl al, 1
    rr mov, ah, al
    mov al, byte [es:si]
    xlatb
    inc si
    rr or, al, ah
    mov es, bp
    stosb
    dec dl
    je short L10C2
    loop L109B
    jmp short L10CC
    nop
L10C2:
    xor dh, 1
    je short L1094
    mov bx, GFX.cga_odd_pixels
    jmp short L1097
L10CC:
    pop es
    pop ds
    pop si
    pop di
    pop bp
    retf

; FUNCTION: DONALD 0000:10D2
; convert_cga_pixels_and_masks: in-place 4bpp -> CGA pixel byte plus transparency-mask byte
convert_cga_pixels_and_masks:
    push bp
    rr mov, bp, sp
    push di
    push si
    push ds
    mov ax, GFX_DATA  ; reloc
    mov ds, ax
    mov si, word [bp + 6]
    mov ax, word [bp + 8]
    push es
    mov es, ax
    mov cx, 0x3e80
    rr xor, dx, dx
    mov ax, word [bp + 0xa]
    mov byte [GFX.cga_convert_row_count], 0x50
    rr or, ax, ax
    je short L10FC
    mov byte [GFX.cga_convert_row_count], 4
L10FC:
    mov bx, GFX.cga_even_pixels
L10FF:
    mov dl, byte [GFX.cga_convert_row_count]
L1103:
    mov al, byte [es:si]
    xlatb
    shl al, 1
    shl al, 1
    shl al, 1
    shl al, 1
    rr mov, ah, al
    mov al, byte [es:si + 1]
    xlatb
    rr or, al, ah
    xchg byte [es:si], al
    inc si
    rr xor, ah, ah
    test al, 0xf0
    je short L1125
    or ah, 0xc0
L1125:
    test al, 0xf
    je short L112C
    or ah, 0x30
L112C:
    mov al, byte [es:si]
    test al, 0xf0
    je short L1136
    or ah, 0xc
L1136:
    test al, 0xf
    je short L113D
    or ah, 3
L113D:
    not ah
    mov byte [es:si], ah
    inc si
    dec dl
    je short L114C
    loop L1103
    jmp short L1159
    nop
L114C:
    dec cx
    je short L1159
    xor dh, 1
    je short L10FC
    mov bx, GFX.cga_odd_pixels
    jmp short L10FF
L1159:
    pop es
    pop ds
    pop si
    pop di
    pop bp
    retf

; FUNCTION: DONALD 0000:115F
; normalize_ptr: far pointer normalisation (offset < 16)
normalize_ptr:
    push bp
    rr mov, bp, sp
    push di
    push si
    push ds
    mov ax, GFX_DATA  ; reloc
    mov ds, ax
    mov ax, word [bp + 6]
    mov dx, word [bp + 8]
L1170:
    cmp ax, strict word 0x10
    jb short L117B
    inc dx
    sub ax, strict word 0x10
    jne short L1170
L117B:
    pop ds
    pop si
    pop di
    pop bp
    retf

; FUNCTION: DONALD 0000:1180
; dos_putc: int 21h AH=06h
dos_putc:
    push bp
    rr mov, bp, sp
    push di
    push si
    push ds
    mov ax, GFX_DATA  ; reloc
    mov ds, ax
    mov dl, byte [bp + 6]
    mov ah, 6
    int 0x21
    pop ds
    pop si
    pop di
    pop bp
    retf

; FUNCTION: DONALD 0000:1197
; rand8: shift-register random byte (state at GFX_DATA:027B)
rand8:
    push bp
    rr mov, bp, sp
    push di
    push si
    push ds
    mov ax, GFX_DATA  ; reloc
    mov ds, ax
    push es
    mov ax, GFX_DATA  ; reloc
    mov es, ax
    mov si, GFX.random_seed
    rr xor, ah, ah
    mov al, byte [es:si]
    shr al, 1
    shr al, 1
    rcl byte [es:si + 2], 1
    rcl byte [es:si + 1], 1
    cmc
    sbb al, byte [es:si]
    shr al, 1
    rcr byte [es:si], 1
    mov al, byte [es:si]
    xor al, byte [es:si + 1]
    pop es
    pop ds
    pop si
    pop di
    pop bp
    retf
; Inline CS scratch remains accessible after the sprite decoder changes DS.
ega_mirror_left_minus1: ; 11D2: left clip column minus one
    dw 0
ega_mirror_right_minus1: ; 11D4: exclusive right clip column minus one
    dw 0
ega_mirror_bottom_offset: ; 11D6: exclusive bottom scanline times 40
    dw 0
ega_mirror_bottom_y: ; 11D8: exclusive bottom scanline
    dw 0
ega_mirror_top_y: ; 11DA: first allowed scanline
    dw 0

; FUNCTION: DONALD 0000:11DC
; sprite_mirror_ega: horizontally mirrored transparent EGA sprite
sprite_mirror_ega:
    push bp
    rr mov, bp, sp
    push di
    push si
    push ds
    mov ax, GFX_DATA  ; reloc
    mov ds, ax
    push es
    mov dx, 0x28
    mov ax, word [GFX.ega_clip_y2]
    mov word [cs:GFX_CODE(ega_mirror_bottom_y)], ax
    mul dl
    mov word [cs:GFX_CODE(ega_mirror_bottom_offset)], ax
    mov ax, word [GFX.ega_clip_y1]
    mov word [cs:GFX_CODE(ega_mirror_top_y)], ax
    mov di, word [bp + 6]
    mov ax, word [bp + 8]
    mov es, ax
    mov si, word [bp + 0xa]
    mov ax, word [bp + 0xc]
    mov word [GFX.ega_mirror_src_segment], ax
    mov ax, word [bp + 0xe]
    mov word [GFX.ega_mirror_x_pixel], ax
    sar ax, 1
    sar ax, 1
    sar ax, 1
    mov word [GFX.ega_mirror_x_byte], ax
    mov dx, word [bp + 0x10]
    mov ax, word [GFX.ega_clip_x1]
    dec ax
    mov word [cs:GFX_CODE(ega_mirror_left_minus1)], ax
    mov ax, word [GFX.ega_clip_x2]
    dec ax
    mov word [cs:GFX_CODE(ega_mirror_right_minus1)], ax
    mov bp, ds
    mov bx, word [GFX.ega_mirror_src_segment]
    mov ds, bx
    inc si
    lodsw
    mov ds, bp
    mov byte [GFX.ega_mirror_width], ah
    mov ds, bx
    rr mov, bx, ax
    and bx, 0xff
    inc bx
    inc si
    cmp dx, word [cs:GFX_CODE(ega_mirror_bottom_y)]
    jge short L1262
    rr mov, cx, dx
    sub cx, word [cs:GFX_CODE(ega_mirror_top_y)]
    jns short L1272
    neg cx
    rr cmp, cx, bx
    jl short L1265
L1262:
    jmp near L1380
L1265:
    lodsw
    test ah, 0x40
    je short L1265
    loop L1265
    mov dx, word [cs:GFX_CODE(ega_mirror_top_y)]
L1272:
    mov ds, bp
    mov ax, 0x28
    mul dx
    rr add, di, ax
    add di, word [GFX.ega_mirror_x_byte]
    mov al, byte [GFX.ega_mirror_width]
    rr xor, ah, ah
    dec ax
    rr add, di, ax
    mov cx, word [GFX.ega_mirror_x_pixel]
    and cx, 7
    mov bx, word [GFX.ega_mirror_x_byte]
    rr add, bx, ax
    mov ax, word [GFX.ega_mirror_src_segment]
    cmp word [GFX.sprite_underlay], 1
    jne short L12A1
    jmp near L1386
L12A1:
    push ds
    mov ds, ax
    mov dx, 0x3ce
    mov ax, 0x205
    out dx, al
    inc dx
    rr mov, al, ah
    out dx, al
    dec dx
    mov al, 8
    out dx, al
    inc dx
    rr mov, bp, di
L12B6:
    push bx
L12B7:
    mov al, byte [es:di]
    lodsb
    rr or, cl, cl
    jne short L131F
    cmp bx, word [cs:GFX_CODE(ega_mirror_right_minus1)]
    jg short L131C
    cmp bx, word [cs:GFX_CODE(ega_mirror_left_minus1)]
    jle short L131C
    shl al, 1
    rcr ah, 1
    shl al, 1
    rcr ah, 1
    shl al, 1
    rcr ah, 1
    shl al, 1
    rcr ah, 1
    shl al, 1
    rcr ah, 1
    shl al, 1
    rcr ah, 1
    shl al, 1
    rcr ah, 1
    shl al, 1
    rcr ah, 1
    rr mov, al, ah
    out dx, al
    lodsb
    mov byte [es:di], al
L12F4:
    shl al, 1
    jae short L12B7
    dec di
    dec bx
    shl al, 1
    jae short L12B7
    shl al, 1
    jb short L137E
    add bp, 0x28
    cmp bp, word [cs:GFX_CODE(ega_mirror_bottom_offset)]
    jae short L137E
    rr mov, di, bp
    pop bx
    rr mov, ax, bp
    rr sub, ax, bx
    cmp ax, word [cs:GFX_CODE(ega_mirror_bottom_offset)]
    jae short L137F
    jmp short L12B6
L131C:
    lodsb
    jmp short L12F4
L131F:
    shl al, 1
    rcr ah, 1
    shl al, 1
    rcr ah, 1
    shl al, 1
    rcr ah, 1
    shl al, 1
    rcr ah, 1
    shl al, 1
    rcr ah, 1
    shl al, 1
    rcr ah, 1
    shl al, 1
    rcr ah, 1
    shl al, 1
    rcr ah, 1
    shr ax, cl
    cmp bx, word [cs:GFX_CODE(ega_mirror_right_minus1)]
    jg short L1379
    cmp bx, word [cs:GFX_CODE(ega_mirror_left_minus1)]
    jle short L1379
    rr mov, ch, al
    mov al, byte [es:di]
    rr mov, al, ah
    out dx, al
    lodsb
    mov byte [es:di], al
L135B:
    cmp bx, word [cs:GFX_CODE(ega_mirror_right_minus1)]
    jge short L12F4
    cmp bx, word [cs:GFX_CODE(ega_mirror_left_minus1)]
    jl short L12F4
    mov ah, byte [es:di + 1]
    xchg al, ch
    out dx, al
    xchg al, ch
    mov byte [es:di + 1], al
    jmp near L12F4
L1379:
    rr mov, ch, al
    lodsb
    jmp short L135B
L137E:
    pop bx
L137F:
    pop ds
L1380:
    pop es
    pop ds
    pop si
    pop di
    pop bp
    retf
L1386:
    push ds
    mov ds, ax
    mov dx, 0x3ce
    mov ax, 0xa05
    out dx, al
    inc dx
    rr mov, al, ah
    out dx, al
    dec dx
    mov al, 2
    out dx, al
    inc dx
    rr xor, al, al
    out dx, al
    dec dx
    mov al, 8
    out dx, al
    inc dx
    rr mov, bp, di
L13A3:
    push bx
L13A4:
    rr or, cl, cl
    jne short L1408
    cmp bx, word [cs:GFX_CODE(ega_mirror_right_minus1)]
    jg short L1405
    lodsb
    shl al, 1
    rcr ah, 1
    shl al, 1
    rcr ah, 1
    shl al, 1
    rcr ah, 1
    shl al, 1
    rcr ah, 1
    shl al, 1
    rcr ah, 1
    shl al, 1
    rcr ah, 1
    shl al, 1
    rcr ah, 1
    shl al, 1
    rcr ah, 1
    and ah, byte [es:di]
    rr mov, al, ah
    out dx, al
    lodsb
    mov byte [es:di], al
L13DA:
    shl al, 1
    jae short L13A4
    dec di
    dec bx
    shl al, 1
    jae short L13A4
    shl al, 1
    jb short L137E
    add bp, 0x28
    cmp bp, word [cs:GFX_CODE(ega_mirror_bottom_offset)]
    jae short L137E
    rr mov, di, bp
    pop bx
    rr mov, ax, bp
    rr sub, ax, bx
    cmp ax, word [cs:GFX_CODE(ega_mirror_bottom_offset)]
    jae short L1402
    jmp short L13A3
L1402:
    jmp near L137F
L1405:
    lodsb
    jmp short L13DA
L1408:
    lodsb
    shl al, 1
    rcr ah, 1
    shl al, 1
    rcr ah, 1
    shl al, 1
    rcr ah, 1
    shl al, 1
    rcr ah, 1
    shl al, 1
    rcr ah, 1
    shl al, 1
    rcr ah, 1
    shl al, 1
    rcr ah, 1
    shl al, 1
    rcr ah, 1
    shr ax, cl
    cmp bx, word [cs:GFX_CODE(ega_mirror_right_minus1)]
    jg short L145C
    rr mov, ch, al
    and ah, byte [es:di]
    rr mov, al, ah
    out dx, al
    lodsb
    mov byte [es:di], al
L143E:
    cmp bx, word [cs:GFX_CODE(ega_mirror_right_minus1)]
    jge short L13DA
    cmp bx, word [cs:GFX_CODE(ega_mirror_left_minus1)]
    jl short L13DA
    xchg al, ch
    and al, byte [es:di + 1]
    out dx, al
    xchg al, ch
    mov byte [es:di + 1], al
    jmp near L13DA
L145C:
    rr mov, ch, al
    lodsb
    jmp short L143E

; FUNCTION: DONALD 0000:1461
; dos_set_drive: int 21h AH=0Eh
dos_set_drive:
    push bp
    rr mov, bp, sp
    push di
    push si
    push ds
    mov ax, GFX_DATA  ; reloc
    mov ds, ax
    mov dx, word [bp + 6]
    mov ah, 0xe
    int 0x21
    pop ds
    pop si
    pop di
    pop bp
    retf

; FUNCTION: DONALD 0000:1478
; cga_select_palette: int 10h AH=0Bh BH=1
cga_select_palette:
    push bp
    rr mov, bp, sp
    push di
    push si
    push ds
    mov ax, GFX_DATA  ; reloc
    mov ds, ax
    mov bx, word [bp + 6]
    mov bh, 1
    mov ah, 0xb
    int 0x10
    pop ds
    pop si
    pop di
    pop bp
    retf

; FUNCTION: DONALD 0000:1491
; set_palette_reg: EGA attribute controller register (index, value)
set_palette_reg:
    push bp
    rr mov, bp, sp
    push di
    push si
    push ds
    mov ax, GFX_DATA  ; reloc
    mov ds, ax
    mov bx, word [bp + 6]
    mov cx, word [bp + 8]
    mov ax, 0x40
    mov es, ax
    mov dx, word [es:BDA_CRTC_PORT]
    add dl, 6
    push dx
    cli
    in al, dx
    mov dl, 0xc0
    rr mov, al, bl
    out dx, al
    rr mov, al, cl
    out dx, al
    pop dx
    in al, dx
    mov dl, 0xc0
    mov al, 0x20
    out dx, al
    sti
    pop ds
    pop si
    pop di
    pop bp
    retf

; FUNCTION: DONALD 0000:14C7
; set_video_type: stores g_videoMode in the graphics driver (GFX_DATA:0286)
set_video_type:
    push bp
    rr mov, bp, sp
    push di
    push si
    push ds
    mov ax, GFX_DATA  ; reloc
    mov ds, ax
    mov ax, word [bp + 6]
    mov word [GFX.video_mode], ax
    pop ds
    pop si
    pop di
    pop bp
    retf

; FUNCTION: DONALD 0000:14DD
; set_bios_mode: int 10h AH=00h
set_bios_mode:
    push bp
    rr mov, bp, sp
    push di
    push si
    push ds
    mov ax, GFX_DATA  ; reloc
    mov ds, ax
    mov ax, word [bp + 6]
    rr xor, ah, ah
    int 0x10
    pop ds
    pop si
    pop di
    pop bp
    retf
; Transparent-pixel preservation masks: each zero input pixel preserves
; the corresponding destination field; nonzero input pixels clear that field.
tandy_transparency_masks: ; 14F4: two 4-bit pixels per index; zero nibble -> preservation mask 0xF
    db 0xFF,0xF0,0xF0,0xF0,0xF0,0xF0,0xF0,0xF0,0xF0,0xF0,0xF0,0xF0,0xF0,0xF0,0xF0,0xF0
    db 0x0F,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
    db 0x0F,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
    db 0x0F,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
    db 0x0F,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
    db 0x0F,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
    db 0x0F,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
    db 0x0F,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
    db 0x0F,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
    db 0x0F,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
    db 0x0F,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
    db 0x0F,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
    db 0x0F,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
    db 0x0F,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
    db 0x0F,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
    db 0x0F,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
cga_transparency_masks: ; 15F4: four 2-bit pixels per index; zero pixel -> preservation mask 3
    db 0xFF,0xFC,0xFC,0xFC,0xF3,0xF0,0xF0,0xF0,0xF3,0xF0,0xF0,0xF0,0xF3,0xF0,0xF0,0xF0
    db 0xCF,0xCC,0xCC,0xCC,0xC3,0xC0,0xC0,0xC0,0xC3,0xC0,0xC0,0xC0,0xC3,0xC0,0xC0,0xC0
    db 0xCF,0xCC,0xCC,0xCC,0xC3,0xC0,0xC0,0xC0,0xC3,0xC0,0xC0,0xC0,0xC3,0xC0,0xC0,0xC0
    db 0xCF,0xCC,0xCC,0xCC,0xC3,0xC0,0xC0,0xC0,0xC3,0xC0,0xC0,0xC0,0xC3,0xC0,0xC0,0xC0
    db 0x3F,0x3C,0x3C,0x3C,0x33,0x30,0x30,0x30,0x33,0x30,0x30,0x30,0x33,0x30,0x30,0x30
    db 0x0F,0x0C,0x0C,0x0C,0x03,0x00,0x00,0x00,0x03,0x00,0x00,0x00,0x03,0x00,0x00,0x00
    db 0x0F,0x0C,0x0C,0x0C,0x03,0x00,0x00,0x00,0x03,0x00,0x00,0x00,0x03,0x00,0x00,0x00
    db 0x0F,0x0C,0x0C,0x0C,0x03,0x00,0x00,0x00,0x03,0x00,0x00,0x00,0x03,0x00,0x00,0x00
    db 0x3F,0x3C,0x3C,0x3C,0x33,0x30,0x30,0x30,0x33,0x30,0x30,0x30,0x33,0x30,0x30,0x30
    db 0x0F,0x0C,0x0C,0x0C,0x03,0x00,0x00,0x00,0x03,0x00,0x00,0x00,0x03,0x00,0x00,0x00
    db 0x0F,0x0C,0x0C,0x0C,0x03,0x00,0x00,0x00,0x03,0x00,0x00,0x00,0x03,0x00,0x00,0x00
    db 0x0F,0x0C,0x0C,0x0C,0x03,0x00,0x00,0x00,0x03,0x00,0x00,0x00,0x03,0x00,0x00,0x00
    db 0x3F,0x3C,0x3C,0x3C,0x33,0x30,0x30,0x30,0x33,0x30,0x30,0x30,0x33,0x30,0x30,0x30
    db 0x0F,0x0C,0x0C,0x0C,0x03,0x00,0x00,0x00,0x03,0x00,0x00,0x00,0x03,0x00,0x00,0x00
    db 0x0F,0x0C,0x0C,0x0C,0x03,0x00,0x00,0x00,0x03,0x00,0x00,0x00,0x03,0x00,0x00,0x00
    db 0x0F,0x0C,0x0C,0x0C,0x03,0x00,0x00,0x00,0x03,0x00,0x00,0x00,0x03,0x00,0x00,0x00
packed_right_clipped: ; 16F4: rightmost packed output byte is partial after clipping
    dw 0
packed_left_clipped: ; 16F6: leftmost packed output byte is partial after clipping
    dw 0
packed_clip_reserved: ; 16F8: unreferenced two-byte slot; no CS or other static references
    dw 0

; FUNCTION: DONALD 0000:16FA
; sprite_put_cga: draw_sprite, CGA/Tandy buffer
sprite_put_cga:
    push bp
    rr mov, bp, sp
    push di
    push si
    push ds
    mov ax, GFX_DATA  ; reloc
    mov ds, ax
    cmp word [GFX.video_mode], 0
    jne short L170F
    jmp near L1975
L170F:
    push es
    mov di, word [bp + 6]
    mov ax, word [bp + 8]
    mov es, ax
    mov si, word [bp + 0xa]
    mov ax, word [bp + 0xc]
    mov word [GFX.packed_src_segment], ax
    mov bx, word [bp + 0xe]
    mov ax, word [bp + 0x10]
    mov word [GFX.packed_y_or_row_skip], ax
    mov ax, word [GFX.clip_x1]
    shl ax, 1
    shl ax, 1
    rr add, di, ax
    mov byte [GFX.packed_subpixel_shift], 0
    sar bx, 1
    rcl byte [GFX.packed_subpixel_shift], 1
    rr sub, bx, ax
    mov word [GFX.packed_x_or_bank_wrap], bx
    mov ax, word [GFX.clip_x2]
    sub ax, word [GFX.clip_x1]
    mov word [GFX.packed_clip_columns], ax
    push ds
    inc si
    mov ax, word [GFX.packed_src_segment]
    mov ds, ax
    lodsw
    inc si
    pop ds
    inc al
    push ax
    and ax, 0xff
    mov word [GFX.packed_rows], ax
    pop ax
    xchg ah, al
    and ax, 0xff
    shl ax, 1
    shl ax, 1
    mov word [GFX.packed_width], ax
    mov word [GFX.packed_source_width], ax
    mov ax, word [GFX.packed_y_or_row_skip]
    sub ax, word [GFX.clip_y1]
    jns short L17A0
    neg ax
    cmp ax, word [GFX.packed_rows]
    jae short L17CE
    mov dx, word [GFX.packed_width]
    mul dl
    rr add, si, ax
    mov ax, word [GFX.packed_rows]
    add ax, word [GFX.packed_y_or_row_skip]
    sub ax, word [GFX.clip_y1]
    js short L1805
    mov word [GFX.packed_rows], ax
    mov ax, word [GFX.clip_y1]
    mov word [GFX.packed_y_or_row_skip], ax
L17A0:
    mov ax, word [GFX.clip_y2]
    sub ax, word [GFX.packed_y_or_row_skip]
    js short L1805
    je short L1805
    cmp ax, word [GFX.packed_rows]
    jae short L17B4
    mov word [GFX.packed_rows], ax
L17B4:
    mov word [cs:GFX_CODE(packed_left_clipped)], 0
    mov ax, word [GFX.packed_x_or_bank_wrap]
    rr or, ax, ax
    jns short L17DC
    add word [GFX.packed_width], ax
    neg ax
    rr add, si, ax
    cmp ax, word [GFX.packed_source_width]
L17CE:
    jae short L1805
    rr xor, ax, ax
    mov word [GFX.packed_x_or_bank_wrap], ax
    mov word [cs:GFX_CODE(packed_left_clipped)], 1
L17DC:
    mov ax, word [GFX.packed_clip_columns]
    shl ax, 1
    shl ax, 1
    sub ax, word [GFX.packed_x_or_bank_wrap]
    js short L1805
    je short L1805
    mov word [cs:GFX_CODE(packed_right_clipped)], 0
    cmp ax, word [GFX.packed_width]
    jae short L1808
    mov word [GFX.packed_width], ax
    mov word [cs:GFX_CODE(packed_right_clipped)], 1
    jmp short L1808
    nop
L1805:
    jmp near L188A
L1808:
    mov ax, word [GFX.packed_y_or_row_skip]
    rr mov, bx, ax
    and ax, 0xfc
    shl ax, 1
    shl ax, 1
    shl ax, 1
    rr mov, dx, ax
    shl ax, 1
    shl ax, 1
    rr add, ax, dx
    add ax, word [GFX.packed_x_or_bank_wrap]
    and bx, 3
    je short L182E
    rr mov, cx, bx
L1829:
    add ah, 0x20
    loop L1829
L182E:
    rr add, di, ax
    mov ax, 0x2000
    sub ax, word [GFX.packed_width]
    mov word [GFX.packed_y_or_row_skip], ax
    mov dx, word [GFX.packed_src_segment]
    rr mov, ah, bl
    rr xor, bx, bx
    cmp byte [GFX.packed_subpixel_shift], 1
    je short L1890
    cmp word [GFX.sprite_underlay], 1
    jne short L1853
    jmp near L1939
L1853:
    mov cx, word [GFX.packed_width]
    mov bp, ds
    mov ds, dx
L185B:
    lodsb
    rr mov, bl, al
    mov bl, byte [cs:bx + GFX_CODE(tandy_transparency_masks)]
    and bl, byte [es:di]
    rr or, al, bl
    stosb
    loop L185B
    mov ds, bp
    add si, word [GFX.packed_source_width]
    sub si, word [GFX.packed_width]
    add di, word [GFX.packed_y_or_row_skip]
    inc ah
    and ah, 3
    jne short L1884
    sub di, 0x7f60
L1884:
    dec word [GFX.packed_rows]
    jne short L1853
L188A:
    pop es
    pop ds
    pop si
    pop di
    pop bp
    retf
L1890:
    xchg al, ah
    mov word [GFX.packed_scanline_phase], ax
L1895:
    mov cx, word [GFX.packed_width]
    mov bp, ds
    mov ds, dx
    cmp word [cs:GFX_CODE(packed_left_clipped)], 0
    je short L18D0
    mov al, byte [si - 1]
    rr xor, ah, ah
    rr mov, bx, ax
    mov bl, byte [cs:bx + GFX_CODE(tandy_transparency_masks)]
    xchg al, ah
    xchg bl, bh
    shr ax, 1
    shr ax, 1
    shr ax, 1
    shr ax, 1
    shr bx, 1
    shr bx, 1
    shr bx, 1
    shr bx, 1
    or bl, 0xf
    and bl, byte [es:di]
    rr or, al, bl
    mov byte [es:di], ah
L18D0:
    lodsb
    rr xor, ah, ah
    rr mov, bx, ax
    mov bl, byte [cs:bx + GFX_CODE(tandy_transparency_masks)]
    xchg al, ah
    xchg bl, bh
    shr ax, 1
    shr ax, 1
    shr ax, 1
    shr ax, 1
    shr bx, 1
    shr bx, 1
    shr bx, 1
    shr bx, 1
    or bx, 0xf00f
    and bh, byte [es:di]
    rr or, ah, bh
    xchg al, ah
    stosb
    cmp cx, 1
    je short L192F
L18FF:
    and bl, byte [es:di]
    rr or, ah, bl
    mov byte [es:di], ah
    loop L18D0
L1909:
    mov ds, bp
    add si, word [GFX.packed_source_width]
    sub si, word [GFX.packed_width]
    add di, word [GFX.packed_y_or_row_skip]
    inc word [GFX.packed_scanline_phase]
    and word [GFX.packed_scanline_phase], 3
    jne short L1926
    sub di, 0x7f60
L1926:
    dec word [GFX.packed_rows]
    je short L1972
    jmp near L1895
L192F:
    cmp word [cs:GFX_CODE(packed_right_clipped)], 0
    je short L18FF
    jmp short L1909
L1939:
    mov cx, word [GFX.packed_width]
    mov bp, ds
    mov ds, dx
L1941:
    lodsb
    rr xor, bh, bh
    mov bl, byte [es:di]
    mov bh, byte [cs:bx + GFX_CODE(tandy_transparency_masks)]
    rr and, al, bh
    rr or, al, bl
    stosb
    loop L1941
    mov ds, bp
    add si, word [GFX.packed_source_width]
    sub si, word [GFX.packed_width]
    add di, word [GFX.packed_y_or_row_skip]
    inc ah
    and ah, 3
    jne short L196C
    sub di, 0x7f60
L196C:
    dec word [GFX.packed_rows]
    jne short L1939
L1972:
    jmp near L188A
L1975:
    push es
    mov di, word [bp + 6]
    mov ax, word [bp + 8]
    mov es, ax
    mov si, word [bp + 0xa]
    mov ax, word [bp + 0xc]
    mov word [GFX.packed_src_segment], ax
    mov bx, word [bp + 0xe]
    mov ax, word [bp + 0x10]
    mov word [GFX.packed_y_or_row_skip], ax
    mov ax, word [GFX.clip_x1]
    shl ax, 1
    rr add, di, ax
    mov byte [GFX.packed_subpixel_shift], bl
    and byte [GFX.packed_subpixel_shift], 3
    shl byte [GFX.packed_subpixel_shift], 1
    sar bx, 1
    sar bx, 1
    rr sub, bx, ax
    mov word [GFX.packed_x_or_bank_wrap], bx
    mov ax, word [GFX.clip_x2]
    sub ax, word [GFX.clip_x1]
    mov word [GFX.packed_clip_columns], ax
    push ds
    inc si
    mov ax, word [GFX.packed_src_segment]
    mov ds, ax
    lodsw
    inc si
    rr mov, bx, si
    pop ds
    inc al
    push ax
    and ax, 0xff
    mov word [GFX.packed_rows], ax
    rr mov, dx, ax
    pop ax
    xchg ah, al
    and ax, 0xff
    shl ax, 1
    mov word [GFX.packed_width], ax
    mov word [GFX.packed_source_width], ax
    rr xor, ah, ah
    mul dl
    rr add, bx, ax
    mov ax, word [GFX.packed_y_or_row_skip]
    sub ax, word [GFX.clip_y1]
    jns short L1A17
    neg ax
    cmp ax, word [GFX.packed_rows]
    jb short L19F7
    jmp near L1A83
L19F7:
    mov dx, word [GFX.packed_width]
    mul dl
    rr add, si, ax
    rr add, bx, ax
    mov ax, word [GFX.packed_rows]
    add ax, word [GFX.packed_y_or_row_skip]
    sub ax, word [GFX.clip_y1]
    js short L1A83
    mov word [GFX.packed_rows], ax
    mov ax, word [GFX.clip_y1]
    mov word [GFX.packed_y_or_row_skip], ax
L1A17:
    mov ax, word [GFX.clip_y2]
    sub ax, word [GFX.packed_y_or_row_skip]
    js short L1A83
    je short L1A83
    cmp ax, word [GFX.packed_rows]
    jae short L1A2B
    mov word [GFX.packed_rows], ax
L1A2B:
    mov word [cs:GFX_CODE(packed_left_clipped)], 0
    mov ax, word [GFX.packed_x_or_bank_wrap]
    rr or, ax, ax
    jns short L1A5C
    add word [GFX.packed_width], ax
    neg ax
    rr add, si, ax
    rr add, bx, ax
    cmp ax, word [GFX.packed_source_width]
    ja short L1A83
    jne short L1A52
    mov al, byte [GFX.packed_subpixel_shift]
    rr or, al, al
    je short L1A83
L1A52:
    rr xor, ax, ax
    mov word [GFX.packed_x_or_bank_wrap], ax
    inc word [cs:GFX_CODE(packed_left_clipped)]
L1A5C:
    mov ax, word [GFX.packed_clip_columns]
    shl ax, 1
    sub ax, word [GFX.packed_x_or_bank_wrap]
    js short L1A83
    je short L1A83
    mov word [cs:GFX_CODE(packed_right_clipped)], 0
    cmp ax, word [GFX.packed_width]
    ja short L1A86
    mov word [GFX.packed_width], ax
    mov word [cs:GFX_CODE(packed_right_clipped)], 1
    jmp short L1A86
    nop
L1A83:
    jmp near L1B1A
L1A86:
    mov ax, word [GFX.packed_y_or_row_skip]
    mov word [GFX.packed_scanline_phase], ax
    and ax, 0xfe
    mov dx, 0x28
    mul dl
    add ax, word [GFX.packed_x_or_bank_wrap]
    test word [GFX.packed_scanline_phase], 1
    je short L1AA3
    add ah, 0x20
L1AA3:
    rr add, di, ax
    mov ax, 0x2000
    sub ax, word [GFX.packed_width]
    mov word [GFX.packed_y_or_row_skip], ax
    mov ax, word [GFX.packed_width]
    sub ax, strict word 0x50
    add ax, 0x2000
    mov word [GFX.packed_x_or_bank_wrap], ax
    mov dx, word [GFX.packed_src_segment]
    cmp word [GFX.sprite_underlay], 1
    je short L1B1D
    cmp byte [GFX.packed_subpixel_shift], 0
    je short L1AD0
    jmp near L1B70
L1AD0:
    mov cx, word [GFX.packed_width]
    mov bp, ds
    mov ds, dx
L1AD8:
    mov ah, byte [bx]
    inc bx
    and ah, byte [es:di]
    lodsb
    rr or, al, ah
    stosb
    loop L1AD8
    mov ds, bp
    add si, word [GFX.packed_source_width]
    sub si, word [GFX.packed_width]
    add bx, word [GFX.packed_source_width]
    sub bx, word [GFX.packed_width]
    mov ax, word [GFX.packed_scanline_phase]
    and ax, strict word 1
    xor ax, strict word 1
    mov word [GFX.packed_scanline_phase], ax
    je short L1B10
    add di, word [GFX.packed_y_or_row_skip]
    dec word [GFX.packed_rows]
    jne short L1AD0
    je short L1B1A
L1B10:
    sub di, word [GFX.packed_x_or_bank_wrap]
    dec word [GFX.packed_rows]
    jne short L1AD0
L1B1A:
    jmp near L188A
L1B1D:
    mov cx, word [GFX.packed_width]
    mov bp, ds
    mov ds, dx
    rr xor, bx, bx
L1B27:
    mov bl, byte [es:di]
    mov ah, byte [cs:bx + GFX_CODE(cga_transparency_masks)]
    lodsb
    rr and, al, ah
    rr or, al, bl
    stosb
    loop L1B27
    mov ds, bp
    add si, word [GFX.packed_source_width]
    sub si, word [GFX.packed_width]
    add bx, word [GFX.packed_source_width]
    sub bx, word [GFX.packed_width]
    mov ax, word [GFX.packed_scanline_phase]
    and ax, strict word 1
    xor ax, strict word 1
    mov word [GFX.packed_scanline_phase], ax
    je short L1B63
    add di, word [GFX.packed_y_or_row_skip]
    dec word [GFX.packed_rows]
    jne short L1B1D
    je short L1B1A
L1B63:
    sub di, word [GFX.packed_x_or_bank_wrap]
    dec word [GFX.packed_rows]
    jne short L1B1D
    jmp near L188A
L1B70:
    mov cx, word [GFX.packed_width]
    rr mov, ch, cl
    mov cl, byte [GFX.packed_subpixel_shift]
    mov bp, ds
    mov ds, dx
    cmp word [cs:GFX_CODE(packed_left_clipped)], 0
    je short L1B9F
    mov dx, word [es:di]
    mov ah, byte [bx - 1]
    mov al, 0xff
    stc
    rcr ax, cl
    rr and, dl, al
    mov ah, byte [si - 1]
    rr xor, al, al
    shr ax, cl
    rr or, dl, al
    mov byte [es:di], dl
L1B9F:
    rr or, ch, ch
    je short L1BCA
L1BA3:
    mov dx, word [es:di]
    mov ah, byte [bx]
    inc bx
    mov al, 0xff
    stc
    rcr ax, cl
    xchg al, ah
    rr and, dx, ax
    lodsb
    rr mov, ah, al
    rr xor, al, al
    shr ax, cl
    xchg al, ah
    cmp ch, 1
    je short L1BF9
L1BC0:
    rr or, dx, ax
    mov word [es:di], dx
    inc di
    dec ch
    jne short L1BA3
L1BCA:
    mov dx, ds
    mov ds, bp
    add si, word [GFX.packed_source_width]
    sub si, word [GFX.packed_width]
    add bx, word [GFX.packed_source_width]
    sub bx, word [GFX.packed_width]
    mov ax, word [GFX.packed_scanline_phase]
    and ax, strict word 1
    xor ax, strict word 1
    mov word [GFX.packed_scanline_phase], ax
    je short L1C09
    add di, word [GFX.packed_y_or_row_skip]
    dec word [GFX.packed_rows]
    je short L1C13
L1BF6:
    jmp near L1B70
L1BF9:
    cmp word [cs:GFX_CODE(packed_right_clipped)], 0
    je short L1BC0
    rr or, dl, al
    mov byte [es:di], dl
    inc di
    jmp short L1BCA
L1C09:
    sub di, word [GFX.packed_x_or_bank_wrap]
    dec word [GFX.packed_rows]
    jne short L1BF6
L1C13:
    jmp near L188A
tandy_swap_nibbles: ; 1C16: ((index & 15) << 4) | (index >> 4), used by mirrored Tandy sprites
    db 0x00,0x10,0x20,0x30,0x40,0x50,0x60,0x70,0x80,0x90,0xA0,0xB0,0xC0,0xD0,0xE0,0xF0
    db 0x01,0x11,0x21,0x31,0x41,0x51,0x61,0x71,0x81,0x91,0xA1,0xB1,0xC1,0xD1,0xE1,0xF1
    db 0x02,0x12,0x22,0x32,0x42,0x52,0x62,0x72,0x82,0x92,0xA2,0xB2,0xC2,0xD2,0xE2,0xF2
    db 0x03,0x13,0x23,0x33,0x43,0x53,0x63,0x73,0x83,0x93,0xA3,0xB3,0xC3,0xD3,0xE3,0xF3
    db 0x04,0x14,0x24,0x34,0x44,0x54,0x64,0x74,0x84,0x94,0xA4,0xB4,0xC4,0xD4,0xE4,0xF4
    db 0x05,0x15,0x25,0x35,0x45,0x55,0x65,0x75,0x85,0x95,0xA5,0xB5,0xC5,0xD5,0xE5,0xF5
    db 0x06,0x16,0x26,0x36,0x46,0x56,0x66,0x76,0x86,0x96,0xA6,0xB6,0xC6,0xD6,0xE6,0xF6
    db 0x07,0x17,0x27,0x37,0x47,0x57,0x67,0x77,0x87,0x97,0xA7,0xB7,0xC7,0xD7,0xE7,0xF7
    db 0x08,0x18,0x28,0x38,0x48,0x58,0x68,0x78,0x88,0x98,0xA8,0xB8,0xC8,0xD8,0xE8,0xF8
    db 0x09,0x19,0x29,0x39,0x49,0x59,0x69,0x79,0x89,0x99,0xA9,0xB9,0xC9,0xD9,0xE9,0xF9
    db 0x0A,0x1A,0x2A,0x3A,0x4A,0x5A,0x6A,0x7A,0x8A,0x9A,0xAA,0xBA,0xCA,0xDA,0xEA,0xFA
    db 0x0B,0x1B,0x2B,0x3B,0x4B,0x5B,0x6B,0x7B,0x8B,0x9B,0xAB,0xBB,0xCB,0xDB,0xEB,0xFB
    db 0x0C,0x1C,0x2C,0x3C,0x4C,0x5C,0x6C,0x7C,0x8C,0x9C,0xAC,0xBC,0xCC,0xDC,0xEC,0xFC
    db 0x0D,0x1D,0x2D,0x3D,0x4D,0x5D,0x6D,0x7D,0x8D,0x9D,0xAD,0xBD,0xCD,0xDD,0xED,0xFD
    db 0x0E,0x1E,0x2E,0x3E,0x4E,0x5E,0x6E,0x7E,0x8E,0x9E,0xAE,0xBE,0xCE,0xDE,0xEE,0xFE
    db 0x0F,0x1F,0x2F,0x3F,0x4F,0x5F,0x6F,0x7F,0x8F,0x9F,0xAF,0xBF,0xCF,0xDF,0xEF,0xFF

; FUNCTION: DONALD 0000:1D16
; sprite_mirror_packed: horizontally mirrored transparent CGA/Tandy sprite
sprite_mirror_packed:
    push bp
    rr mov, bp, sp
    push di
    push si
    push ds
    mov ax, GFX_DATA  ; reloc
    mov ds, ax
    mov word [cs:GFX_CODE(packed_left_clipped)], 0
    cmp word [GFX.video_mode], 0
    jne short L1D32
    jmp near L1FD3
L1D32:
    push es
    mov di, word [bp + 6]
    mov ax, word [bp + 8]
    mov word [GFX.packed_dst_segment], ax
    mov si, word [bp + 0xa]
    mov ax, word [bp + 0xc]
    mov word [GFX.packed_src_segment], ax
    mov bx, word [bp + 0xe]
    mov ax, word [bp + 0x10]
    mov word [GFX.packed_y_or_row_skip], ax
    mov ax, word [GFX.clip_x1]
    shl ax, 1
    shl ax, 1
    rr add, di, ax
    mov byte [GFX.packed_subpixel_shift], 0
    sar bx, 1
    rcl byte [GFX.packed_subpixel_shift], 1
    rr sub, bx, ax
    mov word [GFX.packed_x_or_bank_wrap], bx
    mov ax, word [GFX.clip_x2]
    sub ax, word [GFX.clip_x1]
    mov word [GFX.packed_clip_columns], ax
    push ds
    inc si
    mov ax, word [GFX.packed_src_segment]
    mov ds, ax
    lodsw
    inc si
    pop ds
    inc al
    push ax
    and ax, 0xff
    mov word [GFX.packed_rows], ax
    pop ax
    xchg ah, al
    and ax, 0xff
    shl ax, 1
    shl ax, 1
    mov word [GFX.packed_width], ax
    mov word [GFX.packed_source_width], ax
    mov ax, word [GFX.packed_y_or_row_skip]
    sub ax, word [GFX.clip_y1]
    jns short L1DC4
    neg ax
    cmp ax, word [GFX.packed_rows]
    jae short L1E24
    mov dx, word [GFX.packed_width]
    mul dl
    rr add, si, ax
    mov ax, word [GFX.packed_rows]
    add ax, word [GFX.packed_y_or_row_skip]
    sub ax, word [GFX.clip_y1]
    js short L1E24
    mov word [GFX.packed_rows], ax
    mov ax, word [GFX.clip_y1]
    mov word [GFX.packed_y_or_row_skip], ax
L1DC4:
    mov ax, word [GFX.clip_y2]
    sub ax, word [GFX.packed_y_or_row_skip]
    js short L1E24
    je short L1E24
    cmp ax, word [GFX.packed_rows]
    jae short L1DD8
    mov word [GFX.packed_rows], ax
L1DD8:
    mov ax, word [GFX.packed_x_or_bank_wrap]
    rr or, ax, ax
    jns short L1DF5
    add word [GFX.packed_width], ax
    neg ax
    cmp ax, word [GFX.packed_source_width]
    jae short L1E24
    rr xor, ax, ax
    mov word [GFX.packed_x_or_bank_wrap], ax
    inc word [cs:GFX_CODE(packed_left_clipped)]
L1DF5:
    mov ax, word [GFX.packed_clip_columns]
    shl ax, 1
    shl ax, 1
    sub ax, word [GFX.packed_x_or_bank_wrap]
    js short L1E24
    je short L1E24
    mov word [cs:GFX_CODE(packed_right_clipped)], 0
    cmp ax, word [GFX.packed_width]
    ja short L1E27
    add si, word [GFX.packed_width]
    rr sub, si, ax
    mov word [GFX.packed_width], ax
    mov word [cs:GFX_CODE(packed_right_clipped)], 1
    jmp short L1E27
    nop
L1E24:
    jmp near L1EC8
L1E27:
    mov ax, word [GFX.packed_y_or_row_skip]
    rr mov, bx, ax
    and ax, 0xfc
    shl ax, 1
    shl ax, 1
    shl ax, 1
    rr mov, dx, ax
    shl ax, 1
    shl ax, 1
    rr add, ax, dx
    add ax, word [GFX.packed_x_or_bank_wrap]
    and bx, 3
    mov word [GFX.packed_scanline_phase], bx
    je short L1E51
    rr mov, cx, bx
L1E4C:
    add ah, 0x20
    loop L1E4C
L1E51:
    rr add, di, ax
    mov ax, 0x2000
    sub ax, word [GFX.packed_width]
    mov word [GFX.packed_y_or_row_skip], ax
    mov ax, word [GFX.packed_width]
    sub ax, 0xa0
    add ax, 0x6000
    mov word [GFX.packed_x_or_bank_wrap], ax
    mov dx, word [GFX.packed_src_segment]
    dec si
    mov ax, word [GFX.packed_scanline_phase]
    xchg al, ah
    cmp word [GFX.sprite_underlay], 1
    je short L1ECE
    cmp byte [GFX.packed_subpixel_shift], 1
    jne short L1E84
    jmp near L1F15
L1E84:
    rr xor, bx, bx
    mov cx, word [GFX.packed_dst_segment]
    mov es, cx
    mov cx, word [GFX.packed_width]
    rr add, si, cx
    mov bp, ds
    mov ds, dx
L1E96:
    mov bl, byte [si]
    mov bl, byte [cs:bx + GFX_CODE(tandy_swap_nibbles)]
    rr mov, al, bl
    mov bl, byte [cs:bx + GFX_CODE(tandy_transparency_masks)]
    and bl, byte [es:di]
    rr or, al, bl
    stosb
    dec si
    loop L1E96
    mov ds, bp
    add si, word [GFX.packed_source_width]
    add di, word [GFX.packed_y_or_row_skip]
    inc ah
    and ah, 3
    jne short L1EC2
    sub di, 0x7f60
L1EC2:
    dec word [GFX.packed_rows]
    jne short L1E84
L1EC8:
    pop es
    pop ds
    pop si
    pop di
    pop bp
    retf
L1ECE:
    rr xor, bx, bx
    mov cx, word [GFX.packed_dst_segment]
    mov es, cx
    mov cx, word [GFX.packed_width]
    rr add, si, cx
    mov bp, ds
    mov ds, dx
L1EE0:
    mov bl, byte [si]
    mov al, byte [cs:bx + GFX_CODE(tandy_swap_nibbles)]
    mov bl, byte [es:di]
    mov bl, byte [cs:bx + GFX_CODE(tandy_transparency_masks)]
    rr and, al, bl
    or byte [es:di], al
    inc di
    dec si
    loop L1EE0
    mov ds, bp
    add si, word [GFX.packed_source_width]
    add di, word [GFX.packed_y_or_row_skip]
    inc ah
    and ah, 3
    jne short L1F0D
    sub di, 0x7f60
L1F0D:
    dec word [GFX.packed_rows]
    jne short L1ECE
    je short L1EC8
L1F15:
    xchg al, ah
    mov word [GFX.packed_scanline_phase], ax
L1F1A:
    rr xor, bx, bx
    mov cx, word [GFX.packed_dst_segment]
    mov es, cx
    mov cx, word [GFX.packed_width]
    rr add, si, cx
    mov bp, ds
    mov ds, dx
    cmp word [cs:GFX_CODE(packed_left_clipped)], 0
    je short L1F39
    call merge_mirrored_tandy_edge
    rr xor, bh, bh
L1F39:
    mov bl, byte [si]
    mov bl, byte [cs:bx + GFX_CODE(tandy_swap_nibbles)]
    rr mov, ah, bl
    mov dh, byte [cs:bx + GFX_CODE(tandy_transparency_masks)]
    shr dx, 1
    shr dx, 1
    shr dx, 1
    shr dx, 1
    or dx, 0xf00f
    xchg dl, dh
    and dx, word [es:di]
    rr xor, al, al
    shr ax, 1
    shr ax, 1
    shr ax, 1
    shr ax, 1
    xchg al, ah
    rr or, ax, dx
    stosb
    cmp cx, 1
    je short L1FC8
L1F6C:
    mov byte [es:di], ah
    dec si
    loop L1F39
L1F72:
    mov dx, ds
    mov ds, bp
    add si, word [GFX.packed_source_width]
    add di, word [GFX.packed_y_or_row_skip]
    inc word [GFX.packed_scanline_phase]
    and word [GFX.packed_scanline_phase], 3
    jne short L1F8D
    sub di, 0x7f60
L1F8D:
    dec word [GFX.packed_rows]
    jne short L1F1A
    jmp near L1EC8
; merge_mirrored_tandy_edge / merge_mirrored_cga_edge: sprite_mirror_packed helpers that merge one masked pixel byte into es:di
; FUNCTION: DONALD 0000:1F96
; Near helper embedded in sprite_mirror_packed: merges the clipped first shifted nibble.
merge_mirrored_tandy_edge:
    mov bl, byte [si + 1]
    mov bl, byte [cs:bx + GFX_CODE(tandy_swap_nibbles)]
    rr mov, ah, bl
    mov dh, byte [cs:bx + GFX_CODE(tandy_transparency_masks)]
    shr dx, 1
    shr dx, 1
    shr dx, 1
    shr dx, 1
    or dx, 0xf00f
    xchg dl, dh
    and dx, word [es:di]
    rr xor, al, al
    shr ax, 1
    shr ax, 1
    shr ax, 1
    shr ax, 1
    xchg al, ah
    rr or, ax, dx
    mov byte [es:di], ah
    ret
L1FC8:
    cmp word [cs:GFX_CODE(packed_right_clipped)], 0
    je short L1F6C
    dec si
    jmp short L1F72
L1FD3:
    push es
    mov di, word [bp + 6]
    mov ax, word [bp + 8]
    mov word [GFX.packed_dst_segment], ax
    mov si, word [bp + 0xa]
    mov ax, word [bp + 0xc]
    mov word [GFX.packed_src_segment], ax
    mov bx, word [bp + 0xe]
    mov ax, word [bp + 0x10]
    mov word [GFX.packed_y_or_row_skip], ax
    mov ax, word [GFX.clip_x1]
    shl ax, 1
    rr add, di, ax
    mov byte [GFX.packed_subpixel_shift], bl
    and byte [GFX.packed_subpixel_shift], 3
    shl byte [GFX.packed_subpixel_shift], 1
    sar bx, 1
    sar bx, 1
    rr sub, bx, ax
    mov word [GFX.packed_x_or_bank_wrap], bx
    mov ax, word [GFX.clip_x2]
    sub ax, word [GFX.clip_x1]
    mov word [GFX.packed_clip_columns], ax
    push ds
    inc si
    mov ax, word [GFX.packed_src_segment]
    mov ds, ax
    lodsw
    inc si
    rr mov, bx, si
    pop ds
    inc al
    push ax
    and ax, 0xff
    mov word [GFX.packed_rows], ax
    rr mov, dx, ax
    pop ax
    xchg ah, al
    and ax, 0xff
    shl ax, 1
    mov word [GFX.packed_width], ax
    mov word [GFX.packed_source_width], ax
    rr xor, ah, ah
    mul dl
    rr add, bx, ax
    mov ax, word [GFX.packed_y_or_row_skip]
    sub ax, word [GFX.clip_y1]
    jns short L2076
    neg ax
    cmp ax, word [GFX.packed_rows]
    jb short L2056
    jmp near L20E5
L2056:
    mov dx, word [GFX.packed_width]
    mul dl
    rr add, si, ax
    rr add, bx, ax
    mov ax, word [GFX.packed_rows]
    add ax, word [GFX.packed_y_or_row_skip]
    sub ax, word [GFX.clip_y1]
    js short L20E5
    mov word [GFX.packed_rows], ax
    mov ax, word [GFX.clip_y1]
    mov word [GFX.packed_y_or_row_skip], ax
L2076:
    mov ax, word [GFX.clip_y2]
    sub ax, word [GFX.packed_y_or_row_skip]
    js short L20E5
    je short L20E5
    cmp ax, word [GFX.packed_rows]
    jae short L208A
    mov word [GFX.packed_rows], ax
L208A:
    mov ax, word [GFX.packed_x_or_bank_wrap]
    rr or, ax, ax
    jns short L20B2
    add word [GFX.packed_width], ax
    neg ax
    cmp ax, word [GFX.packed_source_width]
    ja short L20E5
    jne short L20A6
    mov al, byte [GFX.packed_subpixel_shift]
    rr or, al, al
    je short L20E5
L20A6:
    rr xor, ax, ax
    mov word [GFX.packed_x_or_bank_wrap], ax
    mov word [cs:GFX_CODE(packed_left_clipped)], 1
L20B2:
    mov ax, word [GFX.packed_clip_columns]
    shl ax, 1
    sub ax, word [GFX.packed_x_or_bank_wrap]
    js short L20E5
    je short L20E5
    mov word [cs:GFX_CODE(packed_right_clipped)], 0
    cmp ax, word [GFX.packed_width]
    ja short L20E8
    add si, word [GFX.packed_width]
    add bx, word [GFX.packed_width]
    rr sub, si, ax
    rr sub, bx, ax
    mov word [GFX.packed_width], ax
    mov word [cs:GFX_CODE(packed_right_clipped)], 1
    jmp short L20E8
    nop
L20E5:
    jmp near L1EC8
L20E8:
    mov ax, word [GFX.packed_y_or_row_skip]
    mov word [GFX.packed_scanline_phase], ax
    and ax, 0xfe
    mov dx, 0x28
    mul dl
    add ax, word [GFX.packed_x_or_bank_wrap]
    test word [GFX.packed_scanline_phase], 1
    je short L2105
    add ah, 0x20
L2105:
    rr add, di, ax
    mov dx, word [GFX.packed_dst_segment]
    mov es, dx
    mov ax, 0x2000
    sub ax, word [GFX.packed_width]
    mov word [GFX.packed_y_or_row_skip], ax
    mov ax, word [GFX.packed_width]
    sub ax, strict word 0x50
    add ah, 0x20
    mov word [GFX.packed_x_or_bank_wrap], ax
    mov dx, word [GFX.packed_src_segment]
    dec si
    dec bx
    mov bp, ds
    cmp word [GFX.sprite_underlay], 1
    je short L2191
    cmp byte [GFX.packed_subpixel_shift], 0
    je short L213C
    jmp near L21E1
L213C:
    mov cx, word [GFX.packed_width]
    rr add, si, cx
    rr add, bx, cx
L2144:
    mov ds, dx
    mov al, byte [si]
    mov ah, byte [bx]
    push bx
    mov bx, GFX.reverse_cga_pixels
    mov ds, bp
    xlatb
    xchg al, ah
    xlatb
    and al, byte [es:di]
    rr or, al, ah
    mov byte [es:di], al
    dec si
    pop bx
    dec bx
    inc di
    loop L2144
    add si, word [GFX.packed_source_width]
    add bx, word [GFX.packed_source_width]
    mov ax, word [GFX.packed_scanline_phase]
    and ax, strict word 1
    xor ax, strict word 1
    mov word [GFX.packed_scanline_phase], ax
    je short L2184
    add di, word [GFX.packed_y_or_row_skip]
    dec word [GFX.packed_rows]
    jne short L213C
    je short L218E
L2184:
    sub di, word [GFX.packed_x_or_bank_wrap]
    dec word [GFX.packed_rows]
    jne short L213C
L218E:
    jmp near L1EC8
L2191:
    mov cx, word [GFX.packed_width]
    rr add, si, cx
    rr xor, bx, bx
L2199:
    mov ds, dx
    mov bl, byte [si]
    mov ds, bp
    mov al, byte [bx + GFX.reverse_cga_pixels]
    mov bl, byte [es:di]
    and al, byte [cs:bx + GFX_CODE(cga_transparency_masks)]
    or byte [es:di], al
    dec si
    inc di
    loop L2199
    add si, word [GFX.packed_source_width]
    add bx, word [GFX.packed_source_width]
    mov ax, word [GFX.packed_scanline_phase]
    and ax, strict word 1
    xor ax, strict word 1
    mov word [GFX.packed_scanline_phase], ax
    je short L21D4
    add di, word [GFX.packed_y_or_row_skip]
    dec word [GFX.packed_rows]
    jne short L2191
    je short L21DE
L21D4:
    sub di, word [GFX.packed_x_or_bank_wrap]
    dec word [GFX.packed_rows]
    jne short L2191
L21DE:
    jmp near L1EC8
L21E1:
    mov cx, word [GFX.packed_width]
    rr add, si, cx
    rr add, bx, cx
    rr mov, ch, cl
    mov cl, byte [GFX.packed_subpixel_shift]
    cmp word [cs:GFX_CODE(packed_left_clipped)], 0
    je short L21FA
    call merge_mirrored_cga_edge
L21FA:
    rr or, ch, ch
    je short L2232
L21FE:
    mov ds, dx
    mov al, byte [si]
    mov ah, byte [bx]
    push bx
    mov bx, GFX.reverse_cga_pixels
    mov ds, bp
    xlatb
    xchg al, ah
    xlatb
    rr mov, bh, al
    mov bl, 0xff
    stc
    rcr bx, cl
    xchg bl, bh
    rr xor, al, al
    shr ax, cl
    xchg al, ah
    and bx, word [es:di]
    cmp ch, 1
    je short L2255
L2225:
    rr or, ax, bx
    mov word [es:di], ax
L222A:
    dec si
    pop bx
    dec bx
    inc di
    dec ch
    jne short L21FE
L2232:
    add si, word [GFX.packed_source_width]
    add bx, word [GFX.packed_source_width]
    mov ax, word [GFX.packed_scanline_phase]
    and ax, strict word 1
    xor ax, strict word 1
    mov word [GFX.packed_scanline_phase], ax
    je short L2264
    add di, word [GFX.packed_y_or_row_skip]
    dec word [GFX.packed_rows]
    jne short L21E1
L2252:
    jmp near L1EC8
L2255:
    cmp word [cs:GFX_CODE(packed_right_clipped)], 0
    je short L2225
    rr or, al, bl
    mov byte [es:di], al
    jmp short L222A
L2264:
    sub di, word [GFX.packed_x_or_bank_wrap]
    dec word [GFX.packed_rows]
    je short L2252
    jmp near L21E1
; FUNCTION: DONALD 0000:2271
; Near helper: reverses and merges the clipped first shifted CGA pixel group.
merge_mirrored_cga_edge:
    mov ds, dx
    mov al, byte [si + 1]
    mov ah, byte [bx + 1]
    push bx
    mov bx, GFX.reverse_cga_pixels
    mov ds, bp
    xlatb
    xchg al, ah
    xlatb
    rr mov, bh, al
    mov bl, 0xff
    stc
    rcr bx, cl
    rr xor, al, al
    shr ax, cl
    and bl, byte [es:di]
    rr or, al, bl
    mov byte [es:di], al
    pop bx
    ret

; FUNCTION: DONALD 0000:2298
; set_text_colours: (fg, bg) for draw_char_*
set_text_colours:
    push bp
    rr mov, bp, sp
    push di
    push si
    push ds
    mov ax, GFX_DATA  ; reloc
    mov ds, ax
    mov al, byte [bp + 6]
    mov byte [GFX.text_fg], al
    mov al, byte [bp + 8]
    mov byte [GFX.text_bg], al
    cmp word [GFX.video_mode], 0
    je short L22E8
    cmp word [GFX.video_mode], 2
    jae short L22E3
    mov bl, byte [GFX.text_fg]
    rr mov, al, bl
    mov cx, 4
    shl bl, cl
    rr or, bl, al
    rr mov, bh, bl
    mov word [GFX.text_fg_pixels], bx
    mov bl, byte [GFX.text_bg]
    rr mov, al, bl
    mov cx, 4
    shl bl, cl
    rr or, bl, al
    rr mov, bh, bl
    mov word [GFX.text_bg_pixels], bx
L22E3:
    pop ds
    pop si
    pop di
    pop bp
    retf
L22E8:
    mov bl, byte [GFX.text_fg]
    and bl, 3
    rr mov, al, bl
    mov dl, byte [GFX.text_bg]
    and dl, 3
    rr mov, ah, dl
    mov cx, 3
L22FD:
    shl al, 1
    shl al, 1
    rr or, bl, al
    shl ah, 1
    shl ah, 1
    rr or, dl, ah
    loop L22FD
    rr mov, bh, bl
    mov word [GFX.text_fg_pixels], bx
    rr mov, dh, dl
    mov word [GFX.text_bg_pixels], dx
    jmp short L22E3

; FUNCTION: DONALD 0000:2319
; draw_char_tandy4bpp: four bytes per row, four interleaved Tandy video banks
draw_char_tandy4bpp:
    push bp
    rr mov, bp, sp
    push di
    push si
    push ds
    mov ax, GFX_DATA  ; reloc
    mov ds, ax
    mov si, word [bp + 6]
    add si, GFX.font_bitmaps
    mov ax, word [bp + 8]
    mov di, word [bp + 0xa]
    rr add, di, ax
    push es
    mov ax, 0xb800
    mov es, ax
    mov word [GFX.text_row_groups], 2
    mov dx, word [GFX.text_fg_pixels]
    mov bp, word [GFX.text_bg_pixels]
L2347:
    mov cx, 4
L234A:
    lodsw
    rr mov, bx, ax
    rr and, ax, dx
    not bx
    rr and, bx, bp
    rr or, ax, bx
    stosw
    lodsw
    rr mov, bx, ax
    rr and, ax, dx
    not bx
    rr and, bx, bp
    rr or, ax, bx
    mov word [es:di], ax
    add di, 0x1ffe
    loop L234A
    sub di, 0x7f60
    dec word [GFX.text_row_groups]
    jne short L2347
    pop es
    pop ds
    pop si
    pop di
    pop bp
    retf

; FUNCTION: DONALD 0000:237A
; draw_char_cga2bpp: two bytes per row, two interleaved CGA video banks
draw_char_cga2bpp:
    push bp
    rr mov, bp, sp
    push di
    push si
    push ds
    mov ax, GFX_DATA  ; reloc
    mov ds, ax
    mov si, word [bp + 6]
    add si, GFX.font_bitmaps
    mov ax, word [bp + 8]
    mov di, word [bp + 0xa]
    rr add, di, ax
    push es
    mov ax, 0xb800
    mov es, ax
    mov dx, 0x2000
    mov bp, word [GFX.text_fg_pixels]
    mov cx, 8
L23A4:
    lodsw
    rr mov, bx, ax
    rr and, ax, bp
    not bx
    and bx, word [GFX.text_bg_pixels]
    rr or, ax, bx
    mov word [es:di], ax
    rr add, di, dx
    xor dx, 0xc050
    loop L23A4
    pop es
    pop ds
    pop si
    pop di
    pop bp
    retf

; FUNCTION: DONALD 0000:23C2
; draw_char_ega: glyph to EGA planes
draw_char_ega:
    push bp
    rr mov, bp, sp
    push di
    push si
    push ds
    mov ax, GFX_DATA  ; reloc
    mov ds, ax
    mov si, word [bp + 6]
    add si, GFX.font_bitmaps
    mov ax, word [bp + 8]
    mov di, word [bp + 0xa]
    rr add, di, ax
    mov bp, es
    mov ax, 0xa000
    mov es, ax
    mov dx, 0x3ce
    mov ax, 0x205
    out dx, al
    inc dx
    rr mov, al, ah
    out dx, al
    dec dx
    mov bl, byte [GFX.text_fg]
    mov bh, byte [GFX.text_bg]
    mov cx, 8
    rr mov, al, cl
    out dx, al
    inc dx
L23FE:
    mov al, byte [si]
    out dx, al
    rr mov, ah, bl
    xchg byte [es:di], ah
    mov al, byte [si]
    not al
    out dx, al
    rr mov, ah, bh
    xchg byte [es:di], ah
    inc si
    add di, 0x28
    loop L23FE
    mov es, bp
    pop ds
    pop si
    pop di
    pop bp
    retf

; FUNCTION: DONALD 0000:241D
; draw_char_vga8bpp: one byte per pixel in linear A000 VGA video memory
draw_char_vga8bpp:
    push bp
    rr mov, bp, sp
    push di
    push si
    push ds
    mov ax, GFX_DATA  ; reloc
    mov ds, ax
    mov si, word [bp + 6]
    add si, GFX.font_bitmaps
    mov ax, word [bp + 8]
    rr mov, di, ax
    mov ax, word [bp + 0xa]
    rr add, di, ax
    mov bp, es
    mov ax, 0xa000
    mov es, ax
    mov bl, 8
    mov dh, byte [GFX.text_fg]
    mov dl, byte [GFX.text_bg]
L244A:
    lodsb
    mov cx, 8
L244E:
    shl al, 1
    jb short L245B
    mov byte [es:di], dl
    inc di
    loop L244E
    jmp short L2461
    nop
L245B:
    mov byte [es:di], dh
    inc di
    loop L244E
L2461:
    add di, 0x138
    dec bl
    jne short L244A
    mov es, bp
    pop ds
    pop si
    pop di
    pop bp
    retf

; FUNCTION: DONALD 0000:2470
; gfx_init: graphics driver init
gfx_init:
    push bp
    rr mov, bp, sp
    push di
    push si
    push ds
    mov ax, GFX_DATA  ; reloc
    mov ds, ax
    push es
    mov ax, ds
    mov es, ax
    cld
    cmp word [GFX.video_mode], 2
    jae short L24D7
    mov si, GFX.font_bitmaps
    add si, 0x3ff
    mov di, GFX.font_bitmaps
    cmp word [GFX.video_mode], 0
    je short L24B2
    add di, 0xffc
L249D:
    mov bl, byte [si]
    call expand_bits4
    call expand_bits4
    sub di, 8
    dec si
    cmp si, GFX.font_bitmaps
    jne short L249D
    jmp short L24D7
    nop
L24B2:
    add di, 0x7fe
L24B6:
    mov bl, byte [si]
    mov cx, 8
    rr xor, ax, ax
L24BD:
    shl ax, 1
    shl ax, 1
    shl bl, 1
    jae short L24C7
    or al, 3
L24C7:
    loop L24BD
    xchg al, ah
    mov word [di], ax
    sub di, 2
    dec si
    cmp si, GFX.font_bitmaps
    jne short L24B6
L24D7:
    pop es
    pop ds
    pop si
    pop di
    pop bp
    retf
; expand_bits4: expand the top 4 bits of bl into 4 nibble pixels (one word) at es:di
; FUNCTION: DONALD 0000:24DD
; Near helper: expand four high bits of BL into four nibble pixels at ES:DI.
expand_bits4:
    rr xor, ax, ax
    shl bl, 1
    jae short L24E5
    or al, 0xf0
L24E5:
    shl bl, 1
    jae short L24EB
    or al, 0xf
L24EB:
    shl bl, 1
    jae short L24F2
    or ah, 0xf0
L24F2:
    shl bl, 1
    jae short L24F9
    or ah, 0xf
L24F9:
    stosw
    ret

; FUNCTION: DONALD 0000:24FB
; set_palette_regs: all 16 attribute registers
set_palette_regs:
    push bp
    rr mov, bp, sp
    push di
    push si
    push ds
    mov ax, GFX_DATA  ; reloc
    mov ds, ax
    cmp word [GFX.video_mode], 1
    jne short L2536
    mov si, word [bp + 6]
    mov ax, word [bp + 8]
    push es
    mov es, ax
    mov cx, 0x10
    mov bl, 0x10
L251B:
    mov dx, 0x3da
    in al, dx
    rr mov, al, bl
    out dx, al
    mov al, byte [es:si]
    mov dx, 0x3de
    out dx, al
    inc bl
    inc si
    loop L251B
    mov dx, 0x3da
    in al, dx
    mov al, 0xf
    out dx, al
    pop es
L2536:
    pop ds
    pop si
    pop di
    pop bp
    retf

; FUNCTION: DONALD 0000:253B
; in_vretrace: 3DA bit 3
in_vretrace:
    push bp
    rr mov, bp, sp
    push di
    push si
    push ds
    mov ax, GFX_DATA  ; reloc
    mov ds, ax
    mov dx, 0x3da
    in al, dx
    and al, 8
    rr xor, ah, ah
    pop ds
    pop si
    pop di
    pop bp
    retf

; FUNCTION: DONALD 0000:2553
; wait_vretrace: waits for (the end of) vertical retrace
wait_vretrace:
    push bp
    rr mov, bp, sp
    push di
    push si
    push ds
    mov ax, GFX_DATA  ; reloc
    mov ds, ax
    mov bl, byte [bp + 6]
    mov dx, 0x3da
    cmp bl, 1
    je short L2575
L2569:
    in al, dx
    test al, 8
    je short L2569
L256E:
    in al, dx
    test al, 8
    jne short L256E
    je short L257F
L2575:
    in al, dx
    test al, 8
    jne short L2575
L257A:
    in al, dx
    test al, 8
    je short L257A
L257F:
    pop ds
    pop si
    pop di
    pop bp
    retf

; FUNCTION: DONALD 0000:2584
; vline: (x, y1, y2, colour)
vline:
    push bp
    rr mov, bp, sp
    push di
    push si
    push ds
    mov ax, GFX_DATA  ; reloc
    mov ds, ax
    push es
    mov di, word [bp + 6]
    mov ax, word [bp + 8]
    mov word [GFX.vline_y1], ax
    mov ax, word [bp + 0xa]
    mov word [GFX.vline_y2], ax
    mov ax, word [bp + 0xc]
    mov word [GFX.vline_colour], ax
    cmp word [GFX.video_mode], 3
    je short L25B6
    cmp word [GFX.video_mode], 0
    jne short L25DD
    jmp near L26A2
L25B6:
    mov ax, 0xa000
    mov es, ax
    mov ax, word [GFX.vline_y1]
    mov dx, 0x140
    mul dx
    rr add, di, ax
    mov cx, word [GFX.vline_y2]
    sub cx, word [GFX.vline_y1]
    inc cx
    mov ax, word [GFX.vline_colour]
L25D1:
    mov byte [es:di], al
    add di, 0x140
    loop L25D1
    jmp near L269C
L25DD:
    cmp word [GFX.video_mode], 1
    je short L262E
    mov dx, 0x3ce
    mov ax, 0x205
    out dx, al
    inc dx
    rr mov, al, ah
    out dx, al
    dec dx
    rr mov, cx, di
    mov ax, 0x8008
    and cx, 7
    je short L25FC
    shr ah, cl
L25FC:
    out dx, al
    inc dx
    rr mov, al, ah
    out dx, al
    dec dx
    mov ax, 0xa000
    mov es, ax
    mov dx, word [GFX.vline_y1]
    mov ax, 0x28
    mul dl
    shr di, 1
    shr di, 1
    shr di, 1
    rr add, di, ax
    mov ax, word [GFX.vline_colour]
L261B:
    mov ah, byte [es:di]
    mov byte [es:di], al
    add di, 0x28
    inc dx
    cmp dx, word [GFX.vline_y2]
    jle short L261B
    jmp short L269C
    nop
L262E:
    mov cx, 4
    shl ax, cl
    or ax, word [GFX.vline_colour]
    mov bx, 0xf
    test di, 1
    jne short L2645
    mov cx, 4
    shl bx, cl
L2645:
    rr and, ax, bx
    mov word [GFX.vline_colour], ax
    not bl
    mov ax, 0xb800
    mov es, ax
    mov ax, word [GFX.vline_y1]
    and al, 0xfc
    mov dx, 0x28
    mul dl
    mov cx, word [GFX.vline_y1]
    and cx, 3
    je short L2669
L2664:
    add ah, 0x20
    loop L2664
L2669:
    shr di, 1
    rr add, di, ax
    mov dx, word [GFX.vline_y1]
    mov cx, word [GFX.vline_y2]
    sub cx, word [GFX.vline_y1]
    inc cx
L267A:
    mov al, byte [es:di]
    rr and, al, bl
    or ax, word [GFX.vline_colour]
    mov byte [es:di], al
    inc dl
    and dl, 3
    je short L2696
    add di, 0x2000
    loop L267A
    jmp short L269C
    nop
L2696:
    sub di, 0x5f60
    loop L267A
L269C:
    pop es
    pop ds
    pop si
    pop di
    pop bp
    retf
L26A2:
    and ax, strict word 3
    mov word [GFX.vline_colour], ax
    shl ax, 1
    shl ax, 1
    or ax, word [GFX.vline_colour]
    rr mov, bx, ax
    mov cx, 4
    shl ax, cl
    rr or, ax, bx
    mov bx, 3
    rr mov, cx, di
    and cx, 3
    xor cx, 3
    je short L26CA
    rr add, cx, cx
    shl bx, cl
L26CA:
    rr and, ax, bx
    mov word [GFX.vline_colour], ax
    not bl
    mov ax, 0xb800
    mov es, ax
    mov ax, word [GFX.vline_y1]
    and al, 0xfe
    mov dx, 0x28
    mul dl
    shr di, 1
    shr di, 1
    rr add, di, ax
    mov dx, word [GFX.vline_y1]
    and dx, 1
    je short L26F3
    add di, 0x2000
L26F3:
    mov cx, word [GFX.vline_y2]
    sub cx, word [GFX.vline_y1]
    inc cx
L26FC:
    mov al, byte [es:di]
    rr and, al, bl
    or ax, word [GFX.vline_colour]
    mov byte [es:di], al
    xor dl, 1
    je short L2715
    add di, 0x2000
    loop L26FC
    jmp short L269C
L2715:
    sub di, 0x1fb0
    loop L26FC
    jmp near L269C

; FUNCTION: DONALD 0000:271E
; set_dac_regs: int 10h AX=1010h
set_dac_regs:
    push bp
    rr mov, bp, sp
    push di
    push si
    push ds
    mov ax, GFX_DATA  ; reloc
    mov ds, ax
    mov si, word [bp + 6]
    mov ax, word [bp + 8]
    push es
    mov es, ax
    mov bx, 0
L2735:
    mov al, byte [es:si]
    rr xor, ah, ah
    shr al, 1
    shr al, 1
    shr al, 1
    shr al, 1
    rr mov, di, ax
    mov ch, byte [di + GFX.dac_levels]
    mov al, byte [es:si]
    and al, 7
    rr mov, di, ax
    mov cl, byte [di + GFX.dac_levels]
    inc si
    mov al, byte [es:si]
    inc si
    rr mov, di, ax
    mov dh, byte [di + GFX.dac_levels]
    mov ax, 0x1010
    int 0x10
    push bx
    shl bx, 1
    shl bx, 1
    shl bx, 1
    shl bx, 1
    mov ax, 0x1010
    int 0x10
    pop bx
    inc bx
    cmp bx, 0x10
    jb short L2735
    pop es
    pop ds
    pop si
    pop di
    pop bp
    retf

; ---- Initialized graphics objects, frame offsets 0026-14B5 ----
segment GFX_DATA
%define GFX_DATA_BASE 0x0026
gfx_data_start:
global _gfx_clip_x1
global _gfx_clip_x2
global _gfx_clip_y1
global _gfx_clip_y2
global _g_randSeed
global _clip_x1
global _clip_x2
global _clip_y1
global _clip_y2
global _g_retraceWait

gfx_assert fill_rows
gfx_fill_rows: ; 0026, word: fill_rect_cells height multiplied by eight
    dw 0x0000

gfx_assert fill_row_stride
gfx_fill_row_stride: ; 0028, word: fill_rect_cells mode stride 40/80/160/320
    dw 0x0000

gfx_assert fill_row_count
gfx_fill_row_count: ; 002A, word: fill_rect_cells STOSB/STOSW count per row
    dw 0x0000

gfx_assert ega_sprite_src_segment
gfx_ega_sprite_src_segment: ; 002C, word: sprite_put_ega source segment
    dw 0x0000

gfx_assert ega_sprite_x_byte
gfx_ega_sprite_x_byte: ; 002E, word: sprite_put_ega arithmetic x>>3
    dw 0x0000

gfx_assert ega_sprite_x_pixel
gfx_ega_sprite_x_pixel: ; 0030, word: sprite_put_ega pixel x; low three bits shift mask
    dw 0x0000

gfx_assert ega_clip_x1
_gfx_clip_x1:
gfx_ega_clip_x1: ; 0032, word: C-visible EGA left clip column
    dw 0x0000

gfx_assert ega_clip_x2
_gfx_clip_x2:
gfx_ega_clip_x2: ; 0034, word: C-visible EGA right clip column, exclusive
    dw 0x0028

gfx_assert ega_clip_y1
_gfx_clip_y1:
gfx_ega_clip_y1: ; 0036, word: C-visible EGA first scanline
    dw 0x0000

gfx_assert ega_clip_y2
_gfx_clip_y2:
gfx_ega_clip_y2: ; 0038, word: C-visible EGA bottom scanline, exclusive
    dw 0x00c8

gfx_assert pack_src_segment
gfx_pack_src_segment: ; 003A, word: pack_rect source segment
    dw 0x0000

gfx_assert pack_dst_start
gfx_pack_dst_start: ; 003C, word: pack_rect initial destination offset used to return encoded size
    dw 0x0000

gfx_assert pack_rows
gfx_pack_rows: ; 003E, byte: pack_rect height byte decremented at row end
    db 0x00

gfx_assert pack_width
gfx_pack_width: ; 003F, word: pack_rect width reused four times in source row advance
    dw 0x0000

gfx_assert pack_columns_left
gfx_pack_columns_left: ; 0041, byte: pack_rect column counter
    db 0x00

gfx_assert pack_colour_masks
gfx_pack_colour_masks: ; 0042, byte[16]: pack_rect clears 16 bytes then accumulates one eight-pixel bit mask per colour
    db 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00

gfx_assert tandy_fill_count
gfx_tandy_fill_count: ; 0052, word: gfx_fill_rect width+1; STOSB count
    dw 0x0000

gfx_assert tandy_fill_rows_minus1
gfx_tandy_fill_rows_minus1: ; 0054, word: gfx_fill_rect height; loop uses JNS after decrement
    dw 0x0000

gfx_assert tandy_fill_colour
gfx_tandy_fill_colour: ; 0056, word: gfx_fill_rect repeated nibble colour word; retained write-only scratch
    dw 0x0000

gfx_assert cga_even_pixels
gfx_cga_even_pixels: ; 0058, byte[256]: set_palette16 generates paired-pixel XLAT map; cga_convert/convert_cga_pixels_and_masks alternate rows
    db 0x00,0x01,0x02,0x03,0x00,0x01,0x02,0x03,0x00,0x01,0x02,0x03,0x00,0x01,0x02,0x03
    db 0x00,0x01,0x02,0x03,0x00,0x01,0x02,0x03,0x00,0x01,0x02,0x03,0x00,0x01,0x02,0x03
    db 0x00,0x01,0x02,0x03,0x00,0x01,0x02,0x03,0x00,0x01,0x02,0x03,0x00,0x01,0x02,0x03
    db 0x00,0x01,0x02,0x03,0x00,0x01,0x02,0x03,0x00,0x01,0x02,0x03,0x00,0x01,0x02,0x03
    db 0x04,0x05,0x06,0x07,0x04,0x05,0x06,0x07,0x04,0x05,0x06,0x07,0x04,0x05,0x06,0x07
    db 0x04,0x05,0x06,0x07,0x04,0x05,0x06,0x07,0x04,0x05,0x06,0x07,0x04,0x05,0x06,0x07
    db 0x04,0x05,0x06,0x07,0x04,0x05,0x06,0x07,0x04,0x05,0x06,0x07,0x04,0x05,0x06,0x07
    db 0x04,0x05,0x06,0x07,0x04,0x05,0x06,0x07,0x04,0x05,0x06,0x07,0x04,0x05,0x06,0x07
    db 0x08,0x09,0x0a,0x0b,0x08,0x09,0x0a,0x0b,0x08,0x09,0x0a,0x0b,0x08,0x09,0x0a,0x0b
    db 0x08,0x09,0x0a,0x0b,0x08,0x09,0x0a,0x0b,0x08,0x09,0x0a,0x0b,0x08,0x09,0x0a,0x0b
    db 0x08,0x09,0x0a,0x0b,0x08,0x09,0x0a,0x0b,0x08,0x09,0x0a,0x0b,0x08,0x09,0x0a,0x0b
    db 0x08,0x09,0x0a,0x0b,0x08,0x09,0x0a,0x0b,0x08,0x09,0x0a,0x0b,0x08,0x09,0x0a,0x0b
    db 0x0c,0x0d,0x0e,0x0f,0x0c,0x0d,0x0e,0x0f,0x0c,0x0d,0x0e,0x0f,0x0c,0x0d,0x0e,0x0f
    db 0x0c,0x0d,0x0e,0x0f,0x0c,0x0d,0x0e,0x0f,0x0c,0x0d,0x0e,0x0f,0x0c,0x0d,0x0e,0x0f
    db 0x0c,0x0d,0x0e,0x0f,0x0c,0x0d,0x0e,0x0f,0x0c,0x0d,0x0e,0x0f,0x0c,0x0d,0x0e,0x0f
    db 0x0c,0x0d,0x0e,0x0f,0x0c,0x0d,0x0e,0x0f,0x0c,0x0d,0x0e,0x0f,0x0c,0x0d,0x0e,0x0f

gfx_assert cga_odd_pixels
gfx_cga_odd_pixels: ; 0158, byte[256]: set_palette16 generates opposite-phase paired-pixel XLAT map
    db 0x00,0x00,0x00,0x00,0x01,0x01,0x01,0x01,0x02,0x02,0x02,0x02,0x03,0x03,0x03,0x03
    db 0x04,0x04,0x04,0x04,0x05,0x05,0x05,0x05,0x06,0x06,0x06,0x06,0x07,0x07,0x07,0x07
    db 0x08,0x08,0x08,0x08,0x09,0x09,0x09,0x09,0x0a,0x0a,0x0a,0x0a,0x0b,0x0b,0x0b,0x0b
    db 0x0c,0x0c,0x0c,0x0c,0x0d,0x0d,0x0d,0x0d,0x0e,0x0e,0x0e,0x0e,0x0f,0x0f,0x0f,0x0f
    db 0x00,0x00,0x00,0x00,0x01,0x01,0x01,0x01,0x02,0x02,0x02,0x02,0x03,0x03,0x03,0x03
    db 0x04,0x04,0x04,0x04,0x05,0x05,0x05,0x05,0x06,0x06,0x06,0x06,0x07,0x07,0x07,0x07
    db 0x08,0x08,0x08,0x08,0x09,0x09,0x09,0x09,0x0a,0x0a,0x0a,0x0a,0x0b,0x0b,0x0b,0x0b
    db 0x0c,0x0c,0x0c,0x0c,0x0d,0x0d,0x0d,0x0d,0x0e,0x0e,0x0e,0x0e,0x0f,0x0f,0x0f,0x0f
    db 0x00,0x00,0x00,0x00,0x01,0x01,0x01,0x01,0x02,0x02,0x02,0x02,0x03,0x03,0x03,0x03
    db 0x04,0x04,0x04,0x04,0x05,0x05,0x05,0x05,0x06,0x06,0x06,0x06,0x07,0x07,0x07,0x07
    db 0x08,0x08,0x08,0x08,0x09,0x09,0x09,0x09,0x0a,0x0a,0x0a,0x0a,0x0b,0x0b,0x0b,0x0b
    db 0x0c,0x0c,0x0c,0x0c,0x0d,0x0d,0x0d,0x0d,0x0e,0x0e,0x0e,0x0e,0x0f,0x0f,0x0f,0x0f
    db 0x00,0x00,0x00,0x00,0x01,0x01,0x01,0x01,0x02,0x02,0x02,0x02,0x03,0x03,0x03,0x03
    db 0x04,0x04,0x04,0x04,0x05,0x05,0x05,0x05,0x06,0x06,0x06,0x06,0x07,0x07,0x07,0x07
    db 0x08,0x08,0x08,0x08,0x09,0x09,0x09,0x09,0x0a,0x0a,0x0a,0x0a,0x0b,0x0b,0x0b,0x0b
    db 0x0c,0x0c,0x0c,0x0c,0x0d,0x0d,0x0d,0x0d,0x0e,0x0e,0x0e,0x0e,0x0f,0x0f,0x0f,0x0f

gfx_assert cga_even_palette
gfx_cga_even_palette: ; 0258, byte[16]: first 16 copied palette entries; high nibble on even rows
    db 0x00,0x00,0x00,0x00,0x01,0x01,0x01,0x01,0x02,0x02,0x02,0x02,0x03,0x03,0x03,0x03

gfx_assert cga_odd_palette
gfx_cga_odd_palette: ; 0268, byte[16]: second 16 copied palette entries; low nibble on even rows
    db 0x00,0x01,0x02,0x03,0x00,0x01,0x02,0x03,0x00,0x01,0x02,0x03,0x00,0x01,0x02,0x03

gfx_assert cga_convert_src_segment
gfx_cga_convert_src_segment: ; 0278, word: cga_convert source segment loaded through ES
    dw 0x0000

gfx_assert cga_convert_row_count
gfx_cga_convert_row_count: ; 027A, byte: cga_convert/convert_cga_pixels_and_masks number of outputs before alternating lookup maps
    db 0x00

gfx_assert random_seed
_g_randSeed:
gfx_random_seed: ; 027B, dword: C time_t seed; rand8 updates its first three bytes as a shift register
    dd 0x98761234

gfx_assert ega_mirror_src_segment
gfx_ega_mirror_src_segment: ; 027F, word: mirrored EGA source segment
    dw 0x0000

gfx_assert ega_mirror_x_byte
gfx_ega_mirror_x_byte: ; 0281, word: mirrored EGA x>>3
    dw 0x0000

gfx_assert ega_mirror_x_pixel
gfx_ega_mirror_x_pixel: ; 0283, word: mirrored EGA original x for bit shift
    dw 0x0000

gfx_assert ega_mirror_width
gfx_ega_mirror_width: ; 0285, byte: sprite header width, positions rightmost destination byte
    db 0x00

gfx_assert video_mode
gfx_video_mode: ; 0286, word: set_video_type writes adapter selector 0=CGA 1=Tandy 2=EGA 3=VGA
    dw 0x0000

gfx_assert clip_x1
_clip_x1:
gfx_clip_x1: ; 0288, word: packed/VGA left edge in eight-pixel columns
    dw 0x0000

gfx_assert clip_x2
_clip_x2:
gfx_clip_x2: ; 028A, word: packed/VGA exclusive right edge in eight-pixel columns
    dw 0x0028

gfx_assert clip_y1
_clip_y1:
gfx_clip_y1: ; 028C, word: packed/VGA first scanline
    dw 0x0000

gfx_assert clip_y2
_clip_y2:
gfx_clip_y2: ; 028E, word: packed/VGA exclusive last scanline
    dw 0x00c8

gfx_assert packed_src_segment
gfx_packed_src_segment: ; 0290, word: source segment saved before switching DS
    dw 0x0000

gfx_assert packed_dst_segment
gfx_packed_dst_segment: ; 0292, word: destination segment; unused compatibility slot in mode 3
    dw 0x0000

gfx_assert packed_x_or_bank_wrap
gfx_packed_x_or_bank_wrap: ; 0294, word: relative x; packed CGA path reuses it as bank-wrap delta
    dw 0x0000

gfx_assert packed_y_or_row_skip
gfx_packed_y_or_row_skip: ; 0296, word: clipped y; packed paths reuse it as row skip
    dw 0x0000

gfx_assert packed_rows
gfx_packed_rows: ; 0298, word: clipped sprite height, decremented per row
    dw 0x0000

gfx_assert packed_width
gfx_packed_width: ; 029A, word: clipped source row width in bytes (packed) or pixels (mode 3)
    dw 0x0000

gfx_assert packed_source_width
gfx_packed_source_width: ; 029C, word: unclipped source row width
    dw 0x0000

gfx_assert packed_scanline_phase
gfx_packed_scanline_phase: ; 029E, word: CGA/Tandy bank counter; unused compatibility slot in mode 3
    dw 0x0000

gfx_assert packed_subpixel_shift
gfx_packed_subpixel_shift: ; 02A0, byte: CGA/Tandy shift bits; mode 3 writes zero but never reads it
    db 0x00

gfx_assert packed_clip_columns
gfx_packed_clip_columns: ; 02A1, word: clip_x2-clip_x1, expanded by pixels/bytes per column
    dw 0x0000

gfx_assert sprite_underlay
gfx_sprite_underlay: ; 02A3, word: value 1 selects destination-preserving underlay branches; no static writer in this game
    dw 0x0000

gfx_assert swap_nibbles_data
gfx_swap_nibbles_data: ; 02A5, byte[256]: formula swaps high/low nibbles; unused DS duplicate of CS table used by mirrored Tandy blits
    db 0x00,0x10,0x20,0x30,0x40,0x50,0x60,0x70,0x80,0x90,0xa0,0xb0,0xc0,0xd0,0xe0,0xf0
    db 0x01,0x11,0x21,0x31,0x41,0x51,0x61,0x71,0x81,0x91,0xa1,0xb1,0xc1,0xd1,0xe1,0xf1
    db 0x02,0x12,0x22,0x32,0x42,0x52,0x62,0x72,0x82,0x92,0xa2,0xb2,0xc2,0xd2,0xe2,0xf2
    db 0x03,0x13,0x23,0x33,0x43,0x53,0x63,0x73,0x83,0x93,0xa3,0xb3,0xc3,0xd3,0xe3,0xf3
    db 0x04,0x14,0x24,0x34,0x44,0x54,0x64,0x74,0x84,0x94,0xa4,0xb4,0xc4,0xd4,0xe4,0xf4
    db 0x05,0x15,0x25,0x35,0x45,0x55,0x65,0x75,0x85,0x95,0xa5,0xb5,0xc5,0xd5,0xe5,0xf5
    db 0x06,0x16,0x26,0x36,0x46,0x56,0x66,0x76,0x86,0x96,0xa6,0xb6,0xc6,0xd6,0xe6,0xf6
    db 0x07,0x17,0x27,0x37,0x47,0x57,0x67,0x77,0x87,0x97,0xa7,0xb7,0xc7,0xd7,0xe7,0xf7
    db 0x08,0x18,0x28,0x38,0x48,0x58,0x68,0x78,0x88,0x98,0xa8,0xb8,0xc8,0xd8,0xe8,0xf8
    db 0x09,0x19,0x29,0x39,0x49,0x59,0x69,0x79,0x89,0x99,0xa9,0xb9,0xc9,0xd9,0xe9,0xf9
    db 0x0a,0x1a,0x2a,0x3a,0x4a,0x5a,0x6a,0x7a,0x8a,0x9a,0xaa,0xba,0xca,0xda,0xea,0xfa
    db 0x0b,0x1b,0x2b,0x3b,0x4b,0x5b,0x6b,0x7b,0x8b,0x9b,0xab,0xbb,0xcb,0xdb,0xeb,0xfb
    db 0x0c,0x1c,0x2c,0x3c,0x4c,0x5c,0x6c,0x7c,0x8c,0x9c,0xac,0xbc,0xcc,0xdc,0xec,0xfc
    db 0x0d,0x1d,0x2d,0x3d,0x4d,0x5d,0x6d,0x7d,0x8d,0x9d,0xad,0xbd,0xcd,0xdd,0xed,0xfd
    db 0x0e,0x1e,0x2e,0x3e,0x4e,0x5e,0x6e,0x7e,0x8e,0x9e,0xae,0xbe,0xce,0xde,0xee,0xfe
    db 0x0f,0x1f,0x2f,0x3f,0x4f,0x5f,0x6f,0x7f,0x8f,0x9f,0xaf,0xbf,0xcf,0xdf,0xef,0xff

gfx_assert reverse_cga_pixels
gfx_reverse_cga_pixels: ; 03A5, byte[256]: four two-bit pixel groups reversed; XLAT in mirrored CGA paths
    db 0x00,0x40,0x80,0xc0,0x10,0x50,0x90,0xd0,0x20,0x60,0xa0,0xe0,0x30,0x70,0xb0,0xf0
    db 0x04,0x44,0x84,0xc4,0x14,0x54,0x94,0xd4,0x24,0x64,0xa4,0xe4,0x34,0x74,0xb4,0xf4
    db 0x08,0x48,0x88,0xc8,0x18,0x58,0x98,0xd8,0x28,0x68,0xa8,0xe8,0x38,0x78,0xb8,0xf8
    db 0x0c,0x4c,0x8c,0xcc,0x1c,0x5c,0x9c,0xdc,0x2c,0x6c,0xac,0xec,0x3c,0x7c,0xbc,0xfc
    db 0x01,0x41,0x81,0xc1,0x11,0x51,0x91,0xd1,0x21,0x61,0xa1,0xe1,0x31,0x71,0xb1,0xf1
    db 0x05,0x45,0x85,0xc5,0x15,0x55,0x95,0xd5,0x25,0x65,0xa5,0xe5,0x35,0x75,0xb5,0xf5
    db 0x09,0x49,0x89,0xc9,0x19,0x59,0x99,0xd9,0x29,0x69,0xa9,0xe9,0x39,0x79,0xb9,0xf9
    db 0x0d,0x4d,0x8d,0xcd,0x1d,0x5d,0x9d,0xdd,0x2d,0x6d,0xad,0xed,0x3d,0x7d,0xbd,0xfd
    db 0x02,0x42,0x82,0xc2,0x12,0x52,0x92,0xd2,0x22,0x62,0xa2,0xe2,0x32,0x72,0xb2,0xf2
    db 0x06,0x46,0x86,0xc6,0x16,0x56,0x96,0xd6,0x26,0x66,0xa6,0xe6,0x36,0x76,0xb6,0xf6
    db 0x0a,0x4a,0x8a,0xca,0x1a,0x5a,0x9a,0xda,0x2a,0x6a,0xaa,0xea,0x3a,0x7a,0xba,0xfa
    db 0x0e,0x4e,0x8e,0xce,0x1e,0x5e,0x9e,0xde,0x2e,0x6e,0xae,0xee,0x3e,0x7e,0xbe,0xfe
    db 0x03,0x43,0x83,0xc3,0x13,0x53,0x93,0xd3,0x23,0x63,0xa3,0xe3,0x33,0x73,0xb3,0xf3
    db 0x07,0x47,0x87,0xc7,0x17,0x57,0x97,0xd7,0x27,0x67,0xa7,0xe7,0x37,0x77,0xb7,0xf7
    db 0x0b,0x4b,0x8b,0xcb,0x1b,0x5b,0x9b,0xdb,0x2b,0x6b,0xab,0xeb,0x3b,0x7b,0xbb,0xfb
    db 0x0f,0x4f,0x8f,0xcf,0x1f,0x5f,0x9f,0xdf,0x2f,0x6f,0xaf,0xef,0x3f,0x7f,0xbf,0xff

gfx_assert font_bitmaps
gfx_font_bitmaps: ; 04A5, byte[4096]: 128 eight-byte 1bpp glyphs in first 1024 bytes; gfx_init expands in place to 2048 CGA or 4096 Tandy bytes
    ; Original 128-character 8x8 font; expanded in place by gfx_init.
    db 0x3f,0x33,0x3f,0x30,0x30,0x70,0xf0,0xe0 ; glyph   0
    db 0x00,0x00,0x00,0x00,0x00,0x00,0x54,0x00 ; glyph   1
    db 0x00,0x1e,0x06,0x0a,0x12,0x20,0x40,0x00 ; glyph   2
    db 0x00,0x08,0x04,0x7e,0x04,0x08,0x00,0x00 ; glyph   3
    db 0x00,0x40,0x20,0x12,0x0a,0x06,0x1e,0x00 ; glyph   4
    db 0x00,0x08,0x08,0x08,0x2a,0x1c,0x08,0x00 ; glyph   5
    db 0x00,0x02,0x04,0x48,0x50,0x60,0x78,0x00 ; glyph   6
    db 0x00,0x10,0x20,0x7e,0x20,0x10,0x00,0x00 ; glyph   7
    db 0x00,0x78,0x60,0x50,0x48,0x04,0x02,0x00 ; glyph   8
    db 0x00,0x00,0x00,0x00,0x00,0xff,0x00,0xff ; glyph   9
    db 0x00,0x02,0x04,0x08,0x90,0x60,0x00,0x00 ; glyph  10
    db 0xff,0xc3,0x99,0xbd,0xbd,0x99,0xc3,0xff ; glyph  11
    db 0x0f,0x07,0x00,0x7d,0xcc,0xcc,0xcc,0x78 ; glyph  12
    db 0x3c,0x66,0x66,0x66,0x3c,0x18,0x7e,0x18 ; glyph  13
    db 0x7f,0x63,0x7f,0x63,0x63,0x67,0xe6,0xc0 ; glyph  14
    db 0x99,0x5a,0x3c,0xe7,0xe7,0x3c,0x5a,0x99 ; glyph  15
    db 0x80,0xe0,0xf8,0xfe,0xf8,0xe0,0x80,0x00 ; glyph  16
    db 0x02,0x0e,0x3e,0xfe,0x3e,0x0e,0x02,0x00 ; glyph  17
    db 0x18,0x3c,0x7e,0x18,0x18,0x7e,0x3c,0x18 ; glyph  18
    db 0x66,0x66,0x66,0x66,0x66,0x00,0x66,0x00 ; glyph  19
    db 0x7f,0xdb,0xdb,0x7b,0x1b,0x1b,0x1b,0x00 ; glyph  20
    db 0x3e,0x63,0x38,0x6c,0x6c,0x38,0xcc,0x78 ; glyph  21
    db 0x00,0x00,0x00,0x00,0x7e,0x7e,0x7e,0x00 ; glyph  22
    db 0x18,0x3c,0x7e,0x18,0x7e,0x3c,0x18,0xff ; glyph  23
    db 0x18,0x3c,0x7e,0x18,0x18,0x18,0x18,0x00 ; glyph  24
    db 0x18,0x18,0x18,0x18,0x7e,0x3c,0x18,0x00 ; glyph  25
    db 0x00,0x18,0x0c,0xfe,0x0c,0x18,0x00,0x00 ; glyph  26
    db 0x00,0x30,0x60,0xfe,0x60,0x30,0x00,0x00 ; glyph  27
    db 0x00,0x00,0xc0,0xc0,0xc0,0xfe,0x00,0x00 ; glyph  28
    db 0x00,0x24,0x66,0xff,0x66,0x24,0x00,0x00 ; glyph  29
    db 0x00,0x18,0x3c,0x7e,0xff,0xff,0x00,0x00 ; glyph  30
    db 0x00,0xff,0xff,0x7e,0x3c,0x18,0x00,0x00 ; glyph  31
    db 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00 ; glyph  32
    db 0x30,0x78,0x78,0x30,0x30,0x00,0x30,0x00 ; glyph  33
    db 0x6c,0x6c,0x6c,0x00,0x00,0x00,0x00,0x00 ; glyph  34
    db 0x6c,0x6c,0xfe,0x6c,0xfe,0x6c,0x6c,0x00 ; glyph  35
    db 0x30,0x7c,0xc0,0x78,0x0c,0xf8,0x30,0x00 ; glyph  36
    db 0x00,0xc6,0xcc,0x18,0x30,0x66,0xc6,0x00 ; glyph  37
    db 0x38,0x6c,0x38,0x76,0xdc,0xcc,0x76,0x00 ; glyph  38
    db 0x60,0x60,0xc0,0x00,0x00,0x00,0x00,0x00 ; glyph  39
    db 0x18,0x30,0x60,0x60,0x60,0x30,0x18,0x00 ; glyph  40
    db 0x60,0x30,0x18,0x18,0x18,0x30,0x60,0x00 ; glyph  41
    db 0x00,0x66,0x3c,0xff,0x3c,0x66,0x00,0x00 ; glyph  42
    db 0x00,0x30,0x30,0xfc,0x30,0x30,0x00,0x00 ; glyph  43
    db 0x00,0x00,0x00,0x00,0x00,0x30,0x30,0x60 ; glyph  44
    db 0x00,0x00,0x00,0xfc,0x00,0x00,0x00,0x00 ; glyph  45
    db 0x00,0x00,0x00,0x00,0x00,0x30,0x30,0x00 ; glyph  46
    db 0x06,0x0c,0x18,0x30,0x60,0xc0,0x80,0x00 ; glyph  47
    db 0x7c,0xc6,0xce,0xde,0xf6,0xe6,0x7c,0x00 ; glyph  48
    db 0x30,0x70,0x30,0x30,0x30,0x30,0xfc,0x00 ; glyph  49
    db 0x78,0xcc,0x0c,0x38,0x60,0xcc,0xfc,0x00 ; glyph  50
    db 0x78,0xcc,0x0c,0x38,0x0c,0xcc,0x78,0x00 ; glyph  51
    db 0x1c,0x3c,0x6c,0xcc,0xfe,0x0c,0x1e,0x00 ; glyph  52
    db 0xfc,0xc0,0xf8,0x0c,0x0c,0xcc,0x78,0x00 ; glyph  53
    db 0x38,0x60,0xc0,0xf8,0xcc,0xcc,0x78,0x00 ; glyph  54
    db 0xfc,0xcc,0x0c,0x18,0x30,0x30,0x30,0x00 ; glyph  55
    db 0x78,0xcc,0xcc,0x78,0xcc,0xcc,0x78,0x00 ; glyph  56
    db 0x78,0xcc,0xcc,0x7c,0x0c,0x18,0x70,0x00 ; glyph  57
    db 0x00,0x30,0x30,0x00,0x00,0x30,0x30,0x00 ; glyph  58
    db 0x00,0x30,0x30,0x00,0x00,0x30,0x30,0x60 ; glyph  59
    db 0x18,0x30,0x60,0xc0,0x60,0x30,0x18,0x00 ; glyph  60
    db 0x00,0x00,0xfc,0x00,0x00,0xfc,0x00,0x00 ; glyph  61
    db 0x60,0x30,0x18,0x0c,0x18,0x30,0x60,0x00 ; glyph  62
    db 0x78,0xcc,0x0c,0x18,0x30,0x00,0x30,0x00 ; glyph  63
    db 0x7c,0xc6,0xde,0xde,0xde,0xc0,0x78,0x00 ; glyph  64
    db 0x30,0x78,0xcc,0xcc,0xfc,0xcc,0xcc,0x00 ; glyph  65
    db 0xfc,0x66,0x66,0x7c,0x66,0x66,0xfc,0x00 ; glyph  66
    db 0x3c,0x66,0xc0,0xc0,0xc0,0x66,0x3c,0x00 ; glyph  67
    db 0xf8,0x6c,0x66,0x66,0x66,0x6c,0xf8,0x00 ; glyph  68
    db 0xfe,0x62,0x68,0x78,0x68,0x62,0xfe,0x00 ; glyph  69
    db 0xfe,0x62,0x68,0x78,0x68,0x60,0xf0,0x00 ; glyph  70
    db 0x3c,0x66,0xc0,0xc0,0xce,0x66,0x3e,0x00 ; glyph  71
    db 0xcc,0xcc,0xcc,0xfc,0xcc,0xcc,0xcc,0x00 ; glyph  72
    db 0x78,0x30,0x30,0x30,0x30,0x30,0x78,0x00 ; glyph  73
    db 0x1e,0x0c,0x0c,0x0c,0xcc,0xcc,0x78,0x00 ; glyph  74
    db 0xe6,0x66,0x6c,0x78,0x6c,0x66,0xe6,0x00 ; glyph  75
    db 0xf0,0x60,0x60,0x60,0x62,0x66,0xfe,0x00 ; glyph  76
    db 0xc6,0xee,0xfe,0xfe,0xd6,0xc6,0xc6,0x00 ; glyph  77
    db 0xc6,0xe6,0xf6,0xde,0xce,0xc6,0xc6,0x00 ; glyph  78
    db 0x38,0x6c,0xc6,0xc6,0xc6,0x6c,0x38,0x00 ; glyph  79
    db 0xfc,0x66,0x66,0x7c,0x60,0x60,0xf0,0x00 ; glyph  80
    db 0x78,0xcc,0xcc,0xcc,0xdc,0x78,0x1c,0x00 ; glyph  81
    db 0xfc,0x66,0x66,0x7c,0x6c,0x66,0xe6,0x00 ; glyph  82
    db 0x78,0xcc,0xe0,0x70,0x1c,0xcc,0x78,0x00 ; glyph  83
    db 0xfc,0xb4,0x30,0x30,0x30,0x30,0x78,0x00 ; glyph  84
    db 0xcc,0xcc,0xcc,0xcc,0xcc,0xcc,0xfc,0x00 ; glyph  85
    db 0xcc,0xcc,0xcc,0xcc,0xcc,0x78,0x30,0x00 ; glyph  86
    db 0xc6,0xc6,0xc6,0xd6,0xfe,0xee,0xc6,0x00 ; glyph  87
    db 0xc6,0xc6,0x6c,0x38,0x38,0x6c,0xc6,0x00 ; glyph  88
    db 0xcc,0xcc,0xcc,0x78,0x30,0x30,0x78,0x00 ; glyph  89
    db 0xfe,0xc6,0x8c,0x18,0x32,0x66,0xfe,0x00 ; glyph  90
    db 0x78,0x60,0x60,0x60,0x60,0x60,0x78,0x00 ; glyph  91
    db 0xc0,0x60,0x30,0x18,0x0c,0x06,0x02,0x00 ; glyph  92
    db 0x78,0x18,0x18,0x18,0x18,0x18,0x78,0x00 ; glyph  93
    db 0x10,0x38,0x6c,0xc6,0x00,0x00,0x00,0x00 ; glyph  94
    db 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0xff ; glyph  95
    db 0x30,0x30,0x18,0x00,0x00,0x00,0x00,0x00 ; glyph  96
    db 0x00,0x00,0x78,0x0c,0x7c,0xcc,0x76,0x00 ; glyph  97
    db 0xe0,0x60,0x60,0x7c,0x66,0x66,0xdc,0x00 ; glyph  98
    db 0x00,0x00,0x78,0xcc,0xc0,0xcc,0x78,0x00 ; glyph  99
    db 0x1c,0x0c,0x0c,0x7c,0xcc,0xcc,0x76,0x00 ; glyph 100
    db 0x00,0x00,0x78,0xcc,0xfc,0xc0,0x78,0x00 ; glyph 101
    db 0x38,0x6c,0x60,0xf0,0x60,0x60,0xf0,0x00 ; glyph 102
    db 0x00,0x00,0x76,0xcc,0xcc,0x7c,0x0c,0xf8 ; glyph 103
    db 0xe0,0x60,0x6c,0x76,0x66,0x66,0xe6,0x00 ; glyph 104
    db 0x30,0x00,0x70,0x30,0x30,0x30,0x78,0x00 ; glyph 105
    db 0x0c,0x00,0x0c,0x0c,0x0c,0xcc,0xcc,0x78 ; glyph 106
    db 0xe0,0x60,0x66,0x6c,0x78,0x6c,0xe6,0x00 ; glyph 107
    db 0x70,0x30,0x30,0x30,0x30,0x30,0x78,0x00 ; glyph 108
    db 0x00,0x00,0xcc,0xfe,0xfe,0xd6,0xc6,0x00 ; glyph 109
    db 0x00,0x00,0xf8,0xcc,0xcc,0xcc,0xcc,0x00 ; glyph 110
    db 0x00,0x00,0x78,0xcc,0xcc,0xcc,0x78,0x00 ; glyph 111
    db 0x00,0x00,0xdc,0x66,0x66,0x7c,0x60,0xf0 ; glyph 112
    db 0x00,0x00,0x76,0xcc,0xcc,0x7c,0x0c,0x1e ; glyph 113
    db 0x00,0x00,0xdc,0x76,0x66,0x60,0xf0,0x00 ; glyph 114
    db 0x00,0x00,0x7c,0xc0,0x78,0x0c,0xf8,0x00 ; glyph 115
    db 0x10,0x30,0x7c,0x30,0x30,0x34,0x18,0x00 ; glyph 116
    db 0x00,0x00,0xcc,0xcc,0xcc,0xcc,0x76,0x00 ; glyph 117
    db 0x00,0x00,0xcc,0xcc,0xcc,0x78,0x30,0x00 ; glyph 118
    db 0x00,0x00,0xc6,0xd6,0xfe,0xfe,0x6c,0x00 ; glyph 119
    db 0x00,0x00,0xc6,0x6c,0x38,0x6c,0xc6,0x00 ; glyph 120
    db 0x00,0x00,0xcc,0xcc,0xcc,0x7c,0x0c,0xf8 ; glyph 121
    db 0x00,0x00,0xfc,0x98,0x30,0x64,0xfc,0x00 ; glyph 122
    db 0x1c,0x30,0x30,0xe0,0x30,0x30,0x1c,0x00 ; glyph 123
    db 0x18,0x18,0x18,0x00,0x18,0x18,0x18,0x00 ; glyph 124
    db 0xe0,0x30,0x30,0x1c,0x30,0x30,0xe0,0x00 ; glyph 125
    db 0x76,0xdc,0x00,0x00,0x00,0x00,0x00,0x00 ; glyph 126
    db 0x00,0x10,0x38,0x6c,0xc6,0xc6,0xfe,0x00 ; glyph 127
    ; Runtime expansion capacity, used by gfx_init (not an unreferenced gap).
    times 128 * (32 - 8) db 0

gfx_assert text_fg
gfx_text_fg: ; 14A5, byte: set_text_colours foreground, EGA/VGA pixel colour
    db 0x00

gfx_assert text_bg
gfx_text_bg: ; 14A6, byte: set_text_colours background
    db 0x00

gfx_assert text_fg_pixels
gfx_text_fg_pixels: ; 14A7, word: replicated foreground CGA two-bit or Tandy nibble pixels
    dw 0x0000

gfx_assert text_bg_pixels
gfx_text_bg_pixels: ; 14A9, word: replicated background CGA two-bit or Tandy nibble pixels
    dw 0x0000

gfx_assert text_row_groups
gfx_text_row_groups: ; 14AB, word: draw_char_tandy4bpp two four-row groups
    dw 0x0000

gfx_assert retrace_wait
_g_retraceWait:
gfx_retrace_wait: ; 14AD, word: C-visible retrace timing count
    dw 0x0000

gfx_assert vline_y1
gfx_vline_y1: ; 14AF, word: vline inclusive first scanline
    dw 0x0000

gfx_assert vline_y2
gfx_vline_y2: ; 14B1, word: vline inclusive last scanline
    dw 0x0000

gfx_assert vline_colour
gfx_vline_colour: ; 14B3, word: vline colour expanded/masked to packed destination pixels
    dw 0x0000

gfx_assert dac_levels
gfx_dac_levels: ; 14B5, byte[1] (DAC table head): six-bit DAC intensities indexed by three-bit colour component; split across OMF modules
    db 0x00
gfx_data_end:
    times (0 / (($ - gfx_data_start) = 0x1490)) db 0
