; Module 0000:0217: hand-written graphics assembly, _TEXT part 2/5 (split by relocation-table order).
; SEGMENT: DONALD 0000 0217-08B9
; Purpose: EGA span/rectangle primitives.
bits 16
%include "tasm.inc"
%include "gfx_data.inc"
%define GFX_TEXT_BASE 0x0217

segment GFX_DATA public align=2 class=DATA use16   ; far data of the graphics modules (starts at 0B7F:000E)
segment _TEXT public align=1 class=CODE use16
gfx_text_start:

global _hspan
_hspan equ hspan
global _copy_rect
_copy_rect equ copy_rect
global _copy_rect_ega
_copy_rect_ega equ copy_rect_ega
global _blit_ega_core
_blit_ega_core equ blit_ega_core
; FUNCTION: DONALD 0000:0217
; hspan: horizontal EGA span (x, y, n, colour)
hspan:
    push bp
    rr mov, bp, sp
    push di
    push si
    push ds
    mov ax, GFX_DATA  ; reloc
    mov ds, ax
    push es
    mov ax, word [bp + 6]
    mov word [GFX.hspan_x], ax
    mov ax, word [bp + 8]
    mov word [GFX.hspan_y], ax
    mov cx, word [bp + 0xa]
    mov word [GFX.hspan_count], cx
    mov ax, word [bp + 0xc]
    mov word [GFX.hspan_colour], ax
    cmp word [GFX.video_mode], 3
    je short L0254
    cmp word [GFX.video_mode], 2
    je short L026F
    cmp word [GFX.video_mode], 1
    je short L02AF
    jmp near L02F5
L0254:
    mov ax, 0xa000
    mov es, ax
    mov ax, word [GFX.hspan_y]
    mov dx, 0x140
    mul dx
    add ax, word [GFX.hspan_x]
    rr mov, di, ax
    mov ax, word [GFX.hspan_colour]
    rep stosb
    jmp near L02EF
L026F:
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
    dec dx
    mov dx, 0x28
    mov ax, word [GFX.hspan_y]
    mul dl
    mov bx, word [GFX.hspan_x]
    shr bx, 1
    shr bx, 1
    shr bx, 1
    rr add, ax, bx
    rr mov, di, ax
    mov ax, 0xa000
    mov es, ax
    mov cx, word [GFX.hspan_count]
    mov ax, word [GFX.hspan_colour]
L02A6:
    mov ah, byte [es:di]
    stosb
    loop L02A6
    jmp short L02EF
    nop
L02AF:
    mov cx, 4
    shl al, cl
    or ax, word [GFX.hspan_colour]
    rr mov, ah, al
    mov word [GFX.hspan_colour], ax
    mov ax, 0xb800
    mov es, ax
    mov ax, word [GFX.hspan_y]
    and al, 0xfc
    mov dx, 0x28
    mul dl
    mov dx, word [GFX.hspan_x]
    shr dx, 1
    rr add, ax, dx
    mov dx, word [GFX.hspan_y]
    and dx, 3
    je short L02E4
    rr mov, cx, dx
L02DF:
    add ah, 0x20
    loop L02DF
L02E4:
    rr mov, di, ax
    mov cx, word [GFX.hspan_count]
    mov ax, word [GFX.hspan_colour]
    rep stosb
L02EF:
    pop es
    pop ds
    pop si
    pop di
    pop bp
    retf
L02F5:
    and ax, strict word 3
    mov word [GFX.hspan_colour], ax
    shl al, 1
    shl al, 1
    or ax, word [GFX.hspan_colour]
    rr mov, bl, al
    mov cl, 4
    shl al, cl
    rr or, al, bl
    rr mov, ah, al
    mov word [GFX.hspan_colour], ax
    mov ax, 0xb800
    mov es, ax
    mov ax, word [GFX.hspan_y]
    and al, 0xfe
    mov dx, 0x28
    mul dl
    mov dx, word [GFX.hspan_x]
    shr dx, 1
    shr dx, 1
    rr add, ax, dx
    mov dx, word [GFX.hspan_y]
    and dx, 1
    je short L0335
    add ah, 0x20
L0335:
    rr mov, di, ax
    mov cx, word [GFX.hspan_count]
    mov ax, word [GFX.hspan_colour]
    rep stosb
    jmp short L02EF

; FUNCTION: DONALD 0000:0342
; copy_rect: rectangle copy (src, dst, x, y, w, h); scales x/w by the video mode, then copy_rect_core
copy_rect:
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
    mov word [GFX.copy_src_segment], ax
    mov di, word [bp + 0xa]
    mov ax, word [bp + 0xc]
    mov es, ax
    mov ax, word [bp + 0xe]
    shl ax, 1
    cmp word [GFX.video_mode], 2
    je short L037F
    shl ax, 1
    cmp word [GFX.video_mode], 0
    je short L037F
    shl ax, 1
    cmp word [GFX.video_mode], 1
    je short L037F
    shl ax, 1
L037F:
    mov word [GFX.copy_src_x], ax
    mov ax, word [bp + 0x10]
    mov word [GFX.copy_src_y_or_row_skip], ax
    mov ax, word [bp + 0x12]
    shl ax, 1
    cmp word [GFX.video_mode], 2
    je short L03A8
    shl ax, 1
    cmp word [GFX.video_mode], 0
    je short L03A8
    shl ax, 1
    cmp word [GFX.video_mode], 1
    je short L03A8
    shl ax, 1
L03A8:
    mov word [GFX.copy_width], ax
    mov ax, word [bp + 0x14]
    mov word [GFX.copy_rows], ax
    call copy_rect_core
    pop es
    pop ds
    pop si
    pop di
    pop bp
    retf

; FUNCTION: DONALD 0000:03BA
; copy_rect_ega: EGA rectangle copy (src, dst, x, y, w, h)
copy_rect_ega:
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
    mov word [GFX.copy_src_segment], ax
    mov di, word [bp + 0xa]
    mov ax, word [bp + 0xc]
    mov es, ax
    mov ax, word [bp + 0xe]
    cmp word [GFX.video_mode], 2
    je short L03F5
    shl ax, 1
    cmp word [GFX.video_mode], 0
    je short L03F5
    shl ax, 1
    cmp word [GFX.video_mode], 1
    je short L03F5
    shl ax, 1
L03F5:
    mov word [GFX.copy_src_x], ax
    mov ax, word [bp + 0x10]
    mov word [GFX.copy_src_y_or_row_skip], ax
    mov ax, word [bp + 0x12]
    cmp word [GFX.video_mode], 2
    je short L041C
    shl ax, 1
    cmp word [GFX.video_mode], 0
    je short L041C
    shl ax, 1
    cmp word [GFX.video_mode], 1
    je short L041C
    shl ax, 1
L041C:
    mov word [GFX.copy_width], ax
    mov ax, word [bp + 0x14]
    mov word [GFX.copy_rows], ax
    call copy_rect_core
    pop es
    pop ds
    pop si
    pop di
    pop bp
    retf
; copy_rect_core: clip to 40x200 and dispatch per mode (copy_rect_ega_latch = EGA write mode 1)
; FUNCTION: DONALD 0000:042E
; Near dispatcher; includes the EGA latch entry and shared return paths.
copy_rect_core:
    cmp word [GFX.video_mode], 0
    jne short L0438
    jmp near L05D9
L0438:
    cmp word [GFX.video_mode], 2
    je short L0442
    jmp short L04B6
    nop
L0442:
    mov ax, word [GFX.copy_width]
    add ax, word [GFX.copy_src_x]
    cmp ax, strict word 0x29
    jb short L0458
    mov ax, 0x28
    sub ax, word [GFX.copy_src_x]
    mov word [GFX.copy_width], ax
L0458:
    mov ax, word [GFX.copy_src_y_or_row_skip]
    add ax, word [GFX.copy_rows]
    cmp ax, 0xc9
    jb short L046E
    mov ax, 0xc8
    sub ax, word [GFX.copy_src_y_or_row_skip]
    mov word [GFX.copy_rows], ax
L046E:
    mov ax, word [GFX.copy_src_x]
    cmp ax, strict word 0x28
    jae short L04B3
    mov ax, word [GFX.copy_src_y_or_row_skip]
    cmp ax, 0xc8
    jae short L04B3
    mov dx, 0x28
    mul dl
    add ax, word [GFX.copy_src_x]
    rr add, di, ax
    rr add, si, ax
; FUNCTION: DONALD 0000:048B
; Near entry nested in copy_rect_core; EGA mode-1 latch copy, returns via shared 0564.
copy_rect_ega_latch:
    mov dx, 0x3ce
    mov ax, 0x105
    out dx, al
    inc dx
    rr mov, al, ah
    out dx, al
    mov bx, word [GFX.copy_width]
    mov dx, word [GFX.copy_rows]
    mov ax, word [GFX.copy_src_segment]
    mov ds, ax
L04A3:
    rr mov, cx, bx
    rep movsb
    mov ax, 0x28
    rr sub, ax, bx
    rr add, si, ax
    rr add, di, ax
    dec dx
    jne short L04A3
L04B3:
    jmp near L0564
L04B6:
    cmp word [GFX.video_mode], 1
    je short L04C0
    jmp near L0565
L04C0:
    mov ax, word [GFX.copy_width]
    add ax, word [GFX.copy_src_x]
    cmp ax, 0xa1
    jb short L04D6
    mov ax, 0xa0
    sub ax, word [GFX.copy_src_x]
    mov word [GFX.copy_width], ax
L04D6:
    mov ax, word [GFX.copy_src_y_or_row_skip]
    add ax, word [GFX.copy_rows]
    cmp ax, 0xc9
    jb short L04EC
    mov ax, 0xc8
    sub ax, word [GFX.copy_src_y_or_row_skip]
    mov word [GFX.copy_rows], ax
L04EC:
    mov ax, word [GFX.copy_src_x]
    cmp ax, 0xa0
    jae short L04B3
    mov ax, word [GFX.copy_src_y_or_row_skip]
    cmp ax, 0xc8
    jae short L0564
    rr mov, bx, ax
    and ax, 0xfc
    mov dx, 0x28
    mul dl
    add ax, word [GFX.copy_src_x]
    and bx, 3
    je short L0518
    rr mov, cx, ax
    mov ax, 0x2000
    mul bx
    rr add, ax, cx
L0518:
    rr add, di, ax
    rr add, si, ax
    mov dx, word [GFX.copy_width]
    mov ax, 0x2000
    rr sub, ax, dx
    mov word [GFX.copy_src_y_or_row_skip], ax
    rr mov, ax, dx
    sub ax, 0xa0
    add ah, 0x60
    shr dx, 1
    mov word [GFX.copy_width], dx
    mov dx, word [GFX.copy_src_segment]
L053A:
    mov cx, word [GFX.copy_width]
    push ds
    mov ds, dx
    rep movsw
    pop ds
    inc bx
    and bx, 3
    je short L055A
    add si, word [GFX.copy_src_y_or_row_skip]
    add di, word [GFX.copy_src_y_or_row_skip]
    dec word [GFX.copy_rows]
    jne short L053A
    je short L0564
L055A:
    rr sub, si, ax
    rr sub, di, ax
    dec word [GFX.copy_rows]
    jne short L053A
L0564:
    ret
L0565:
    mov ax, word [GFX.copy_width]
    add ax, word [GFX.copy_src_x]
    cmp ax, 0x141
    jb short L057B
    mov ax, 0x140
    sub ax, word [GFX.copy_src_x]
    mov word [GFX.copy_width], ax
L057B:
    mov ax, word [GFX.copy_src_y_or_row_skip]
    add ax, word [GFX.copy_rows]
    cmp ax, 0xc9
    jb short L0591
    mov ax, 0xc8
    sub ax, word [GFX.copy_src_y_or_row_skip]
    mov word [GFX.copy_rows], ax
L0591:
    mov ax, word [GFX.copy_src_x]
    cmp ax, 0x140
    jae short L0564
    mov ax, word [GFX.copy_src_y_or_row_skip]
    cmp ax, 0xc8
    jae short L0564
    rr mov, bx, ax
    mov dx, 0x140
    mul dx
    add ax, word [GFX.copy_src_x]
    rr add, di, ax
    rr add, si, ax
    mov bx, 0x140
    mov dx, word [GFX.copy_width]
    rr sub, bx, dx
    shr dx, 1
    mov word [GFX.copy_width], dx
    mov dx, word [GFX.copy_src_segment]
L05C3:
    mov cx, word [GFX.copy_width]
    push ds
    mov ds, dx
    rep movsw
    pop ds
    rr add, si, bx
    rr add, di, bx
    dec word [GFX.copy_rows]
    jne short L05C3
    jmp short L0564
L05D9:
    mov ax, word [GFX.copy_width]
    add ax, word [GFX.copy_src_x]
    cmp ax, strict word 0x51
    jb short L05EF
    mov ax, 0x50
    sub ax, word [GFX.copy_src_x]
    mov word [GFX.copy_width], ax
L05EF:
    mov ax, word [GFX.copy_src_y_or_row_skip]
    add ax, word [GFX.copy_rows]
    cmp ax, 0xc9
    jb short L0605
    mov ax, 0xc8
    sub ax, word [GFX.copy_src_y_or_row_skip]
    mov word [GFX.copy_rows], ax
L0605:
    mov ax, word [GFX.copy_src_x]
    cmp ax, strict word 0x50
    jae short L0676
    mov ax, word [GFX.copy_src_y_or_row_skip]
    cmp ax, 0xc8
    jae short L0676
    rr mov, bx, ax
    and ax, 0xfe
    mov dx, 0x28
    mul dl
    add ax, word [GFX.copy_src_x]
    and bx, 1
    je short L062B
    add ah, 0x20
L062B:
    rr add, di, ax
    rr add, si, ax
    mov dx, word [GFX.copy_width]
    mov ax, 0x2000
    rr sub, ax, dx
    mov word [GFX.copy_src_y_or_row_skip], ax
    rr mov, ax, dx
    sub ax, strict word 0x50
    add ah, 0x20
    shr dx, 1
    mov word [GFX.copy_width], dx
    mov dx, word [GFX.copy_src_segment]
L064D:
    mov cx, word [GFX.copy_width]
    push ds
    mov ds, dx
    rep movsw
    pop ds
    xor bx, 1
    je short L066C
    add si, word [GFX.copy_src_y_or_row_skip]
    add di, word [GFX.copy_src_y_or_row_skip]
    dec word [GFX.copy_rows]
    jne short L064D
    je short L0676
L066C:
    rr sub, si, ax
    rr sub, di, ax
    dec word [GFX.copy_rows]
    jne short L064D
L0676:
    ret

; FUNCTION: DONALD 0000:0677
; blit_ega_core: EGA latch blit used by blit_ega
blit_ega_core:
    push bp
    rr mov, bp, sp
    push di
    push si
    push ds
    mov ax, GFX_DATA  ; reloc
    mov ds, ax
    push es
    mov ax, word [bp + 6]
    cmp word [GFX.video_mode], 2
    je short L06AA
    shl ax, 1
    cmp word [GFX.video_mode], 0
    je short L06AA
    shl ax, 1
    cmp word [GFX.video_mode], 1
    je short L06AA
    mov bx, word [bp + 0x14]
    cmp bx, 0xa000
    jne short L06AA
    shl ax, 1
L06AA:
    mov word [GFX.copy_src_x], ax
    mov ax, word [bp + 8]
    shl ax, 1
    shl ax, 1
    shl ax, 1
    mov word [GFX.copy_src_y_or_row_skip], ax
    mov ax, word [bp + 0xa]
    cmp word [GFX.video_mode], 2
    je short L06E0
    shl ax, 1
    cmp word [GFX.video_mode], 0
    je short L06E0
    shl ax, 1
    cmp word [GFX.video_mode], 1
    je short L06E0
    mov bx, word [bp + 0x18]
    cmp bx, 0xa000
    jne short L06E0
    shl ax, 1
L06E0:
    mov word [GFX.copy_dst_x], ax
    mov ax, word [bp + 0xc]
    shl ax, 1
    shl ax, 1
    shl ax, 1
    mov word [GFX.copy_dst_y], ax
    mov ax, word [bp + 0xe]
    cmp word [GFX.video_mode], 2
    je short L0704
    shl ax, 1
    cmp word [GFX.video_mode], 0
    je short L0704
    shl ax, 1
L0704:
    mov word [GFX.copy_width], ax
    mov ax, word [bp + 0x10]
    shl ax, 1
    shl ax, 1
    shl ax, 1
    mov word [GFX.copy_rows], ax
    mov ax, word [bp + 0x12]
    mov word [GFX.copy_src_offset], ax
    mov ax, word [bp + 0x14]
    mov word [GFX.copy_src_segment], ax
    mov di, word [bp + 0x16]
    mov ax, word [bp + 0x18]
    mov es, ax
    mov ax, word [GFX.copy_src_y_or_row_skip]
    mov dx, 0x28
    cmp word [GFX.video_mode], 3
    jne short L073F
    cmp word [GFX.copy_src_segment], 0xa000
    jne short L073F
    mov dx, 0x140
L073F:
    mul dx
    add ax, word [GFX.copy_src_x]
    add word [GFX.copy_src_offset], ax
    mov ax, word [GFX.copy_dst_y]
    mov dx, 0x28
    cmp word [GFX.video_mode], 3
    jne short L0761
    cmp word [GFX.copy_src_segment], 0xa000
    jne short L0761
    mov dx, 0x140
L0761:
    mul dx
    add ax, word [GFX.copy_dst_x]
    rr add, di, ax
    mov si, word [GFX.copy_src_offset]
    cmp word [GFX.video_mode], 1
    je short L07C0
    ja short L0779
    jmp near L0872
L0779:
    cmp word [GFX.video_mode], 3
    je short L0786
    call copy_rect_ega_latch
    jmp near L086C
L0786:
    mov ax, es
    cmp ax, word [GFX.copy_src_segment]
    jne short L07C3
    mov bp, 0x140
    cmp ax, 0xa000
    je short L079D
    mov bp, 0xa0
    shr word [GFX.copy_width], 1
L079D:
    mov dx, word [GFX.copy_rows]
    mov bx, word [GFX.copy_width]
    mov ax, word [GFX.copy_src_segment]
    mov ds, ax
L07AA:
    rr mov, cx, bx
    rep movsw
    rr mov, ax, bx
    shl ax, 1
    rr sub, si, ax
    rr sub, di, ax
    rr add, si, bp
    rr add, di, bp
    dec dx
    jne short L07AA
    jmp near L086C
L07C0:
    jmp short L0827
    nop
L07C3:
    cmp word [GFX.copy_src_segment], 0xa000
    je short L07F9
    mov dx, word [GFX.copy_rows]
    mov bx, word [GFX.copy_width]
    mov ax, word [GFX.copy_src_segment]
    mov ds, ax
L07D8:
    rr mov, cx, bx
L07DA:
    lodsb
    rr mov, ah, al
    and ax, 0xff0
    stosw
    loop L07DA
    rr mov, ax, bx
    rr sub, si, ax
    shl ax, 1
    rr sub, di, ax
    add si, 0xa0
    add di, 0x140
    dec dx
    jne short L07D8
    jmp short L086C
    nop
L07F9:
    mov dx, word [GFX.copy_rows]
    mov bx, word [GFX.copy_width]
    mov ax, word [GFX.copy_src_segment]
    mov ds, ax
L0806:
    rr mov, cx, bx
L0808:
    lodsw
    and ax, 0xff0
    rr or, al, ah
    stosb
    loop L0808
    rr mov, ax, bx
    rr sub, di, ax
    shl ax, 1
    rr sub, si, ax
    add si, 0x140
    add di, 0xa0
    dec dx
    jne short L0806
    jmp short L086C
    nop
L0827:
    rr sub, bx, bx
    mov ax, 0x2000
    sub ax, word [GFX.copy_width]
    mov word [GFX.copy_src_y_or_row_skip], ax
    mov ax, word [GFX.copy_width]
    sub ax, 0xa0
    add ax, 0x6000
    mov dx, word [GFX.copy_src_segment]
L0840:
    mov cx, word [GFX.copy_width]
    shr cx, 1
    push ds
    mov ds, dx
    rep movsw
    pop ds
    inc bx
    and bx, 3
    je short L0862
    add si, word [GFX.copy_src_y_or_row_skip]
    add di, word [GFX.copy_src_y_or_row_skip]
    dec word [GFX.copy_rows]
    jne short L0840
    je short L086C
L0862:
    rr sub, si, ax
    rr sub, di, ax
    dec word [GFX.copy_rows]
    jne short L0840
L086C:
    pop es
    pop ds
    pop si
    pop di
    pop bp
    retf
L0872:
    rr sub, bx, bx
    mov ax, 0x2000
    sub ax, word [GFX.copy_width]
    mov word [GFX.copy_src_y_or_row_skip], ax
    mov ax, word [GFX.copy_width]
    sub ax, strict word 0x50
    add ax, 0x2000
    mov dx, word [GFX.copy_src_segment]
L088B:
    mov cx, word [GFX.copy_width]
    shr cx, 1
    push ds
    mov ds, dx
    rep movsw
    pop ds
    inc bx
    and bx, 1
    je short L08AD
    add si, word [GFX.copy_src_y_or_row_skip]
    add di, word [GFX.copy_src_y_or_row_skip]
    dec word [GFX.copy_rows]
    jne short L088B
    je short L08B7
L08AD:
    rr sub, si, ax
    rr sub, di, ax
    dec word [GFX.copy_rows]
    jne short L088B
L08B7:
    jmp short L086C

; ---- Initialized graphics objects, frame offsets 000E-0025 ----
segment GFX_DATA
%define GFX_DATA_BASE 0x000e
gfx_data_start:

gfx_assert hspan_x
gfx_hspan_x: ; 000E, word: hspan x argument; pixel/byte start
    dw 0x0000

gfx_assert hspan_y
gfx_hspan_y: ; 0010, word: hspan y argument; scanline
    dw 0x0000

gfx_assert hspan_count
gfx_hspan_count: ; 0012, word: hspan count argument; REP count
    dw 0x0000

gfx_assert hspan_colour
gfx_hspan_colour: ; 0014, word: hspan colour, expanded to repeated CGA/Tandy pixels
    dw 0x0000

gfx_assert copy_src_segment
gfx_copy_src_segment: ; 0016, word: copy_rect/blit_ega_core source segment
    dw 0x0000

gfx_assert copy_src_x
gfx_copy_src_x: ; 0018, word: source x in mode-dependent bytes
    dw 0x0000

gfx_assert copy_dst_x
gfx_copy_dst_x: ; 001A, word: blit_ega_core destination x in bytes
    dw 0x0000

gfx_assert copy_src_y_or_row_skip
gfx_copy_src_y_or_row_skip: ; 001C, word: source y, reused as banked row skip after clipping
    dw 0x0000

gfx_assert copy_dst_y
gfx_copy_dst_y: ; 001E, word: blit_ega_core destination scanline
    dw 0x0000

gfx_assert copy_width
gfx_copy_width: ; 0020, word: clipped row width; converted to words for MOVSW
    dw 0x0000

gfx_assert copy_rows
gfx_copy_rows: ; 0022, word: clipped row count; decremented in copy loops
    dw 0x0000

gfx_assert copy_src_offset
gfx_copy_src_offset: ; 0024, word: source offset plus computed scanline displacement
    dw 0x0000
gfx_data_end:
    times (0 / (($ - gfx_data_start) = 0x0018)) db 0
