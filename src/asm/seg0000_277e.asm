; Module 0000:277E: hand-written graphics assembly, _TEXT part 4/5 (split by relocation-table order).
; SEGMENT: DONALD 0000 277E-2A15
; Purpose: window save/restore blits.
bits 16
%include "tasm.inc"
%include "gfx_data.inc"
%define GFX_TEXT_BASE 0x277e

segment GFX_DATA public align=2 class=DATA use16   ; far data of the graphics modules (starts at 0B7F:000E)
segment _TEXT public align=1 class=CODE use16
gfx_text_start:

global _save_window
_save_window equ save_window
global _blit_generic
_blit_generic equ blit_generic
; FUNCTION: DONALD 0000:277E
; save_window: window background save/blit (x, y, w, h, buf)
save_window:
    push bp
    rr mov, bp, sp
    push di
    push si
    push ds
    mov ax, GFX_DATA  ; reloc
    mov ds, ax
    mov si, word [bp + 6]
    mov dx, word [bp + 8]
    mov bx, word [bp + 0xa]
    mov cx, word [bp + 0xc]
    shl cx, 1
    shl cx, 1
    shl cx, 1
    mov di, word [bp + 0xe]
    push di
    mov ax, word [bp + 0x10]
    push es
    mov es, ax
    cmp word [GFX.video_mode], 0
    je short L27E7
    cmp word [GFX.video_mode], 1
    je short L2817
    cmp word [GFX.video_mode], 2
    jne short L27BD
    jmp near L2863
L27BD:
    shl si, 1
    shl si, 1
    shl si, 1
    mov ax, 0xa00
    mul dx
    rr add, si, ax
    rr mov, dx, cx
    shl bx, 1
    shl bx, 1
    mov ax, 0xa000
    mov ds, ax
L27D5:
    rr mov, cx, bx
    rep movsw
    rr sub, si, bx
    rr sub, si, bx
    add si, 0x140
    dec dx
    jne short L27D5
    jmp near L28A6
L27E7:
    shl si, 1
    mov ax, 0x140
    mul dx
    rr add, si, ax
    rr mov, dx, cx
    mov ax, 0xb800
    mov ds, ax
L27F7:
    rr mov, cx, bx
    rep movsw
    rr sub, si, bx
    rr sub, si, bx
    add si, 0x2000
    rr mov, cx, bx
    rep movsw
    rr sub, si, bx
    rr sub, si, bx
    sub si, 0x1fb0
    sub dx, 2
    jne short L27F7
    jmp near L28A6
L2817:
    shl si, 1
    shl si, 1
    mov ax, 0x140
    mul dx
    rr add, si, ax
    rr mov, dx, cx
    shl bx, 1
    mov ax, 0xb800
    mov ds, ax
L282B:
    rr mov, cx, bx
    rep movsw
    rr sub, si, bx
    rr sub, si, bx
    add si, 0x2000
    rr mov, cx, bx
    rep movsw
    rr sub, si, bx
    rr sub, si, bx
    add si, 0x2000
    rr mov, cx, bx
    rep movsw
    rr sub, si, bx
    rr sub, si, bx
    add si, 0x2000
    rr mov, cx, bx
    rep movsw
    rr sub, si, bx
    rr sub, si, bx
    sub si, 0x5f60
    sub dx, 4
    jne short L282B
    jmp short L28A6
    nop
L2863:
    mov ax, 0x140
    mul dx
    rr add, si, ax
    mov ax, 0xa000
    mov ds, ax
    mov dx, 0x3ce
    mov ax, 0x205
    out dx, al
    inc dx
    rr mov, al, ah
    out dx, al
    dec dx
    mov al, 4
    out dx, al
    inc dx
    rr mov, ah, cl
L2881:
    rr mov, cl, bl
L2883:
    rr xor, al, al
    out dx, al
    mov al, byte [si]
    stosb
    mov al, 1
    out dx, al
    mov al, byte [si]
    stosb
    mov al, 2
    out dx, al
    mov al, byte [si]
    stosb
    mov al, 3
    out dx, al
    movsb
    dec cl
    jne short L2883
    rr sub, si, bx
    add si, 0x28
    dec ah
    jne short L2881
L28A6:
    pop es
    rr mov, ax, di
    pop di
    rr sub, ax, di
    pop ds
    pop si
    pop di
    pop bp
    retf
blit_src_segment: ; 28B1: source segment saved in CS while DS is the source
    dw 0

; FUNCTION: DONALD 0000:28B3
; blit_generic: sprite/picture blit for CGA/Tandy (x, y, w, rows, src)
blit_generic:
    push bp
    rr mov, bp, sp
    push di
    push si
    push ds
    mov ax, GFX_DATA  ; reloc
    mov ds, ax
    mov di, word [bp + 6]
    mov dx, word [bp + 8]
    mov bx, word [bp + 0xa]
    mov cx, word [bp + 0xc]
    shl cx, 1
    shl cx, 1
    shl cx, 1
    mov si, word [bp + 0xe]
    mov ax, word [bp + 0x10]
    mov word [cs:GFX_CODE(blit_src_segment)], ax
    push es
    cmp word [GFX.video_mode], 0
    je short L2923
    cmp word [GFX.video_mode], 1
    je short L2959
    cmp word [GFX.video_mode], 2
    jne short L28F3
    jmp near L29AB
L28F3:
    shl di, 1
    shl di, 1
    shl di, 1
    mov ax, 0xa00
    mul dx
    rr add, di, ax
    rr mov, dx, cx
    shl bx, 1
    shl bx, 1
    mov ax, 0xa000
    mov es, ax
    mov ax, word [cs:GFX_CODE(blit_src_segment)]
    mov ds, ax
L2911:
    rr mov, cx, bx
    rep movsw
    rr sub, di, bx
    rr sub, di, bx
    add di, 0x140
    dec dx
    jne short L2911
    jmp near L2A09
L2923:
    shl di, 1
    mov ax, 0x140
    mul dx
    rr add, di, ax
    rr mov, dx, cx
    mov ax, 0xb800
    mov es, ax
    mov ax, word [cs:GFX_CODE(blit_src_segment)]
    mov ds, ax
L2939:
    rr mov, cx, bx
    rep movsw
    rr sub, di, bx
    rr sub, di, bx
    add di, 0x2000
    rr mov, cx, bx
    rep movsw
    rr sub, di, bx
    rr sub, di, bx
    sub di, 0x1fb0
    sub dx, 2
    jne short L2939
    jmp near L2A09
L2959:
    shl di, 1
    shl di, 1
    mov ax, 0x140
    mul dx
    rr add, di, ax
    rr mov, dx, cx
    shl bx, 1
    mov ax, 0xb800
    mov es, ax
    mov ax, word [cs:GFX_CODE(blit_src_segment)]
    mov ds, ax
L2973:
    rr mov, cx, bx
    rep movsw
    rr sub, di, bx
    rr sub, di, bx
    add di, 0x2000
    rr mov, cx, bx
    rep movsw
    rr sub, di, bx
    rr sub, di, bx
    add di, 0x2000
    rr mov, cx, bx
    rep movsw
    rr sub, di, bx
    rr sub, di, bx
    add di, 0x2000
    rr mov, cx, bx
    rep movsw
    rr sub, di, bx
    rr sub, di, bx
    sub di, 0x5f60
    sub dx, 4
    jne short L2973
    jmp short L2A09
    nop
L29AB:
    mov ax, 0x140
    mul dx
    rr add, di, ax
    mov ax, 0xa000
    mov es, ax
    mov dx, 0x3ce
    mov ax, 5
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
    rr mov, bh, bl
    mov dl, 0xc4
    mov al, 2
    out dx, al
    inc dx
    mov ax, word [cs:GFX_CODE(blit_src_segment)]
    mov ds, ax
L29D9:
    mov al, 1
    out dx, al
    lodsb
    xchg byte [es:di], al
    mov al, 2
    out dx, al
    lodsb
    xchg byte [es:di], al
    mov al, 4
    out dx, al
    lodsb
    xchg byte [es:di], al
    mov al, 8
    out dx, al
    mov al, byte [es:di]
    movsb
    dec bl
    jne short L29D9
    rr mov, bl, bh
    rr mov, al, bl
    rr xor, ah, ah
    rr sub, di, ax
    add di, 0x28
    loop L29D9
    mov al, 0xf
    out dx, al
L2A09:
    pop es
    pop ds
    pop si
    pop di
    pop bp
    retf
; The following workspace is used by the next OMF code fragment, sprite_put_m3.
m3_forward_skip_left: ; 2A0F: pixels to skip at left of each RLE source row
    dw 0
m3_forward_skip_right: ; 2A11: pixels to skip at right of each RLE source row
    dw 0
m3_forward_draw_width: ; 2A13: clipped pixels to draw in each RLE row
    dw 0
