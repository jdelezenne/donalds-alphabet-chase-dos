; Module 0000:01C9: hand-written graphics assembly, _TEXT part 1/5 (split by relocation-table order).
; SEGMENT: DONALD 0000 01C9-0217
; Purpose: video BIOS probes (EGA present, text mode, EGA palette select).
bits 16
%include "tasm.inc"
%include "gfx_data.inc"
%define GFX_TEXT_BASE 0x01c9

segment GFX_DATA public align=2 class=DATA use16   ; far data of the graphics modules (starts at 0B7F:000E)
segment _TEXT public align=1 class=CODE use16
gfx_text_start:

global _ega_present
_ega_present equ ega_present
global _set_text_mode
_set_text_mode equ set_text_mode
global _ega_select_palette
_ega_select_palette equ ega_select_palette
; FUNCTION: DONALD 0000:01C9
; ega_present: int 10h AH=12h BL=10h: EGA BIOS present
ega_present:
    push bp
    rr mov, bp, sp
    push di
    push si
    push ds
    mov ax, GFX_DATA  ; reloc
    mov ds, ax
    mov bl, 0x10
    mov ah, 0x12
    int 0x10
    mov ax, 0
    cmp bl, 0x10
    je short L01E3
    inc ax
L01E3:
    pop ds
    pop si
    pop di
    pop bp
    retf

; FUNCTION: DONALD 0000:01E8
; set_text_mode: int 10h mode 3
set_text_mode:
    push bp
    rr mov, bp, sp
    push di
    push si
    push ds
    mov ax, GFX_DATA  ; reloc
    mov ds, ax
    mov ah, 0
    mov al, 3
    int 0x10
    pop ds
    pop si
    pop di
    pop bp
    retf

; FUNCTION: DONALD 0000:01FE
; ega_select_palette: int 10h AH=10h, palette 0/1
ega_select_palette:
    push bp
    rr mov, bp, sp
    push di
    push si
    push ds
    mov ax, GFX_DATA  ; reloc
    mov ds, ax
    mov bh, byte [bp + 6]
    mov ah, 0x10
    mov al, 1
    int 0x10
    pop ds
    pop si
    pop di
    pop bp
    retf
