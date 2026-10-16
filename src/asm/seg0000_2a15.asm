; Module 0000:2A15: hand-written graphics assembly, _TEXT part 5/5 (split by relocation-table order).
; SEGMENT: DONALD 0000 2A15-2DAB
bits 16
%include "tasm.inc"

segment GFX_DATA public align=2 class=DATA use16   ; far data of the graphics modules (starts at 0B7F:000E)
segment _TEXT public align=1 class=CODE use16

global _fn_0000_2A15
_fn_0000_2A15 equ L2A15
global _fn_0000_2BE0
_fn_0000_2BE0 equ L2BE0
; FUNCTION: DONALD 0000:2A15
L2A15:
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
    mov word [0x14bd], ax
    mov bx, word [bp + 0xe]
    mov ax, word [bp + 0x10]
    mov word [0x14c3], ax
    mov ax, word [0x288]
    shl ax, 1
    shl ax, 1
    shl ax, 1
    rr add, di, ax
    mov byte [0x14cd], 0
    rr sub, bx, ax
    mov word [0x14c1], bx
    mov ax, word [0x28a]
    sub ax, word [0x288]
    mov word [0x14ce], ax
    push ds
    inc si
    mov ax, word [0x14bd]
    mov ds, ax
    lodsw
    inc si
    pop ds
    inc al
    push ax
    and ax, 0xff
    mov word [0x14c5], ax
    pop ax
    xchg ah, al
    and ax, 0xff
    shl ax, 1
    shl ax, 1
    shl ax, 1
    mov word [0x14c7], ax
    mov word [0x14c9], ax
    mov ax, word [0x14c3]
    sub ax, word [0x28c]
    jns short L2ACA
    add word [0x14c5], ax
    jg short L2A93
    jmp near L2B35
L2A93:
    neg ax
    rr mov, dx, ax
    mov ax, word [0x14c7]
    mov word [cs:0x2a0f], ax
    push di
    push es
    rr mov, di, si
    mov ax, word [0x14bd]
    mov es, ax
L2AA7:
    mov cx, word [cs:0x2a0f]
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
    mov ax, word [0x28c]
    mov word [0x14c3], ax
L2ACA:
    mov ax, word [0x28e]
    sub ax, word [0x14c3]
    js short L2B35
    je short L2B35
    cmp ax, word [0x14c5]
    jae short L2ADE
    mov word [0x14c5], ax
L2ADE:
    mov word [cs:0x2a0f], 0
    mov ax, word [0x14c1]
    rr or, ax, ax
    jns short L2B01
    add word [0x14c7], ax
    neg ax
    mov word [cs:0x2a0f], ax
    cmp ax, word [0x14c9]
    jae short L2B35
    rr xor, ax, ax
    mov word [0x14c1], ax
L2B01:
    mov word [cs:0x2a11], 0
    mov ax, word [0x14ce]
    shl ax, 1
    shl ax, 1
    shl ax, 1
    sub ax, word [0x14c1]
    js short L2B35
    je short L2B35
    cmp ax, word [0x14c7]
    jae short L2B38
    mov word [0x14c7], ax
    mov ax, word [0x14c9]
    sub ax, word [cs:0x2a0f]
    sub ax, word [0x14c7]
    mov word [cs:0x2a11], ax
    jmp short L2B38
    db 0x90
L2B35:
    jmp near L2BD4
L2B38:
    mov ax, word [0x14c3]
    mov dx, 0x140
    mul dx
    add ax, word [0x14c1]
    rr add, di, ax
    rr mov, bp, di
    mov ax, word [0x14c7]
    mov word [cs:0x2a13], ax
    mov dx, word [0x14c5]
    mov ax, word [0x14bd]
    mov ds, ax
    rr xor, ax, ax
    mov bx, es
L2B5C:
    mov cx, word [cs:0x2a0f]
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
    add cx, word [cs:0x2a13]
    jle short L2BA1
L2B8F:
    lodsb
    rr or, al, al
    je short L2B9A
    stosb
    loop L2B8F
    jmp short L2BA1
    db 0x90
L2B9A:
    lodsb
    rr add, di, ax
    rr sub, cx, ax
    jg short L2B8F
L2BA1:
    add cx, word [cs:0x2a11]
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
    db 0x00,0x00,0x00,0x00,0x00,0x00

; FUNCTION: DONALD 0000:2BE0
L2BE0:
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
    mov word [0x14d0], ax
    mov bx, word [bp + 0xe]
    mov ax, word [bp + 0x10]
    mov word [0x14d6], ax
    mov ax, word [0x288]
    shl ax, 1
    shl ax, 1
    shl ax, 1
    rr add, di, ax
    mov byte [0x14e0], 0
    rr sub, bx, ax
    mov word [0x14d4], bx
    mov ax, word [0x28a]
    sub ax, word [0x288]
    mov word [0x14e1], ax
    push ds
    inc si
    mov ax, word [0x14d0]
    mov ds, ax
    lodsw
    inc si
    pop ds
    inc al
    push ax
    and ax, 0xff
    mov word [0x14d8], ax
    pop ax
    xchg ah, al
    and ax, 0xff
    shl ax, 1
    shl ax, 1
    shl ax, 1
    mov word [0x14da], ax
    mov word [0x14dc], ax
    mov ax, word [0x14d6]
    sub ax, word [0x28c]
    jns short L2C95
    add word [0x14d8], ax
    jg short L2C5E
    jmp near L2D00
L2C5E:
    neg ax
    rr mov, dx, ax
    mov ax, word [0x14da]
    mov word [cs:0x2bda], ax
    push di
    push es
    rr mov, di, si
    mov ax, word [0x14d0]
    mov es, ax
L2C72:
    mov cx, word [cs:0x2bda]
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
    mov ax, word [0x28c]
    mov word [0x14d6], ax
L2C95:
    mov ax, word [0x28e]
    sub ax, word [0x14d6]
    js short L2D00
    je short L2D00
    cmp ax, word [0x14d8]
    jae short L2CA9
    mov word [0x14d8], ax
L2CA9:
    mov word [cs:0x2bda], 0
    mov ax, word [0x14d4]
    rr or, ax, ax
    jns short L2CCC
    add word [0x14da], ax
    neg ax
    mov word [cs:0x2bda], ax
    cmp ax, word [0x14dc]
    jae short L2D00
    rr xor, ax, ax
    mov word [0x14d4], ax
L2CCC:
    mov word [cs:0x2bdc], 0
    mov ax, word [0x14e1]
    shl ax, 1
    shl ax, 1
    shl ax, 1
    sub ax, word [0x14d4]
    js short L2D00
    je short L2D00
    cmp ax, word [0x14da]
    jae short L2D03
    mov word [0x14da], ax
    mov ax, word [0x14dc]
    sub ax, word [cs:0x2bda]
    sub ax, word [0x14da]
    mov word [cs:0x2bdc], ax
    jmp short L2D03
    db 0x90
L2D00:
    jmp near L2DA5
L2D03:
    mov ax, word [0x14d6]
    mov dx, 0x140
    mul dx
    add ax, word [0x14d4]
    rr add, di, ax
    mov ax, word [0x14da]
    mov word [cs:0x2bde], ax
    rr add, di, ax
    dec di
    rr mov, bp, di
    mov dx, word [0x14d8]
    mov ax, word [0x14d0]
    mov ds, ax
    rr xor, ax, ax
    mov bx, es
L2D2A:
    mov cx, word [cs:0x2bdc]
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
    add cx, word [cs:0x2bde]
    jle short L2D72
L2D5D:
    lodsb
    rr or, al, al
    je short L2D6B
    mov byte [es:di], al
    dec di
    loop L2D5D
    jmp short L2D72
    db 0x90
L2D6B:
    lodsb
    rr sub, di, ax
    rr sub, cx, ax
    jg short L2D5D
L2D72:
    add cx, word [cs:0x2bda]
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
