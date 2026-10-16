; Module 0000:01C9: hand-written graphics assembly, _TEXT part 1/5 (split by relocation-table order).
; SEGMENT: DONALD 0000 01C9-0217
bits 16
%include "tasm.inc"

segment GFX_DATA public align=2 class=DATA use16   ; far data of the graphics modules (starts at 0B7F:000E)
segment _TEXT public align=1 class=CODE use16

global _fn_0000_01C9
_fn_0000_01C9 equ L01C9
global _fn_0000_01E8
_fn_0000_01E8 equ L01E8
global _fn_0000_01FE
_fn_0000_01FE equ L01FE
; FUNCTION: DONALD 0000:01C9
L01C9:
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
L01E8:
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
L01FE:
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
