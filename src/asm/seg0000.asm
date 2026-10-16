; Module 0000: hand-written assembly (bootstrapped by tools/asm2nasm.py, then annotated).
; SEGMENT: DONALD 0000 01C9-2DAB
bits 16
org 0x01C9
%include "tasm.inc"


; FUNCTION: DONALD 0000:01C9
L01C9:
    push bp
    rr mov, bp, sp
    push di
    push si
    push ds
    mov ax, 0xb7f  ; reloc
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
    mov ax, 0xb7f  ; reloc
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
    mov ax, 0xb7f  ; reloc
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

; FUNCTION: DONALD 0000:0217
L0217:
    push bp
    rr mov, bp, sp
    push di
    push si
    push ds
    mov ax, 0xb7f  ; reloc
    mov ds, ax
    push es
    mov ax, word [bp + 6]
    mov word [0xe], ax
    mov ax, word [bp + 8]
    mov word [0x10], ax
    mov cx, word [bp + 0xa]
    mov word [0x12], cx
    mov ax, word [bp + 0xc]
    mov word [0x14], ax
    cmp word [0x286], 3
    je short L0254
    cmp word [0x286], 2
    je short L026F
    cmp word [0x286], 1
    je short L02AF
    jmp near L02F5
L0254:
    mov ax, 0xa000
    mov es, ax
    mov ax, word [0x10]
    mov dx, 0x140
    mul dx
    add ax, word [0xe]
    rr mov, di, ax
    mov ax, word [0x14]
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
    mov ax, word [0x10]
    mul dl
    mov bx, word [0xe]
    shr bx, 1
    shr bx, 1
    shr bx, 1
    rr add, ax, bx
    rr mov, di, ax
    mov ax, 0xa000
    mov es, ax
    mov cx, word [0x12]
    mov ax, word [0x14]
L02A6:
    mov ah, byte [es:di]
    stosb
    loop L02A6
    jmp short L02EF
    db 0x90
L02AF:
    mov cx, 4
    shl al, cl
    or ax, word [0x14]
    rr mov, ah, al
    mov word [0x14], ax
    mov ax, 0xb800
    mov es, ax
    mov ax, word [0x10]
    and al, 0xfc
    mov dx, 0x28
    mul dl
    mov dx, word [0xe]
    shr dx, 1
    rr add, ax, dx
    mov dx, word [0x10]
    and dx, 3
    je short L02E4
    rr mov, cx, dx
L02DF:
    add ah, 0x20
    loop L02DF
L02E4:
    rr mov, di, ax
    mov cx, word [0x12]
    mov ax, word [0x14]
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
    mov word [0x14], ax
    shl al, 1
    shl al, 1
    or ax, word [0x14]
    rr mov, bl, al
    mov cl, 4
    shl al, cl
    rr or, al, bl
    rr mov, ah, al
    mov word [0x14], ax
    mov ax, 0xb800
    mov es, ax
    mov ax, word [0x10]
    and al, 0xfe
    mov dx, 0x28
    mul dl
    mov dx, word [0xe]
    shr dx, 1
    shr dx, 1
    rr add, ax, dx
    mov dx, word [0x10]
    and dx, 1
    je short L0335
    add ah, 0x20
L0335:
    rr mov, di, ax
    mov cx, word [0x12]
    mov ax, word [0x14]
    rep stosb
    jmp short L02EF

; FUNCTION: DONALD 0000:0342
L0342:
    push bp
    rr mov, bp, sp
    push di
    push si
    push ds
    mov ax, 0xb7f  ; reloc
    mov ds, ax
    push es
    mov si, word [bp + 6]
    mov ax, word [bp + 8]
    mov word [0x16], ax
    mov di, word [bp + 0xa]
    mov ax, word [bp + 0xc]
    mov es, ax
    mov ax, word [bp + 0xe]
    shl ax, 1
    cmp word [0x286], 2
    je short L037F
    shl ax, 1
    cmp word [0x286], 0
    je short L037F
    shl ax, 1
    cmp word [0x286], 1
    je short L037F
    shl ax, 1
L037F:
    mov word [0x18], ax
    mov ax, word [bp + 0x10]
    mov word [0x1c], ax
    mov ax, word [bp + 0x12]
    shl ax, 1
    cmp word [0x286], 2
    je short L03A8
    shl ax, 1
    cmp word [0x286], 0
    je short L03A8
    shl ax, 1
    cmp word [0x286], 1
    je short L03A8
    shl ax, 1
L03A8:
    mov word [0x20], ax
    mov ax, word [bp + 0x14]
    mov word [0x22], ax
    call L042E
    pop es
    pop ds
    pop si
    pop di
    pop bp
    retf

; FUNCTION: DONALD 0000:03BA
L03BA:
    push bp
    rr mov, bp, sp
    push di
    push si
    push ds
    mov ax, 0xb7f  ; reloc
    mov ds, ax
    push es
    mov si, word [bp + 6]
    mov ax, word [bp + 8]
    mov word [0x16], ax
    mov di, word [bp + 0xa]
    mov ax, word [bp + 0xc]
    mov es, ax
    mov ax, word [bp + 0xe]
    cmp word [0x286], 2
    je short L03F5
    shl ax, 1
    cmp word [0x286], 0
    je short L03F5
    shl ax, 1
    cmp word [0x286], 1
    je short L03F5
    shl ax, 1
L03F5:
    mov word [0x18], ax
    mov ax, word [bp + 0x10]
    mov word [0x1c], ax
    mov ax, word [bp + 0x12]
    cmp word [0x286], 2
    je short L041C
    shl ax, 1
    cmp word [0x286], 0
    je short L041C
    shl ax, 1
    cmp word [0x286], 1
    je short L041C
    shl ax, 1
L041C:
    mov word [0x20], ax
    mov ax, word [bp + 0x14]
    mov word [0x22], ax
    call L042E
    pop es
    pop ds
    pop si
    pop di
    pop bp
    retf
L042E:
    cmp word [0x286], 0
    jne short L0438
    jmp near L05D9
L0438:
    cmp word [0x286], 2
    je short L0442
    jmp short L04B6
    db 0x90
L0442:
    mov ax, word [0x20]
    add ax, word [0x18]
    cmp ax, strict word 0x29
    jb short L0458
    mov ax, 0x28
    sub ax, word [0x18]
    mov word [0x20], ax
L0458:
    mov ax, word [0x1c]
    add ax, word [0x22]
    cmp ax, 0xc9
    jb short L046E
    mov ax, 0xc8
    sub ax, word [0x1c]
    mov word [0x22], ax
L046E:
    mov ax, word [0x18]
    cmp ax, strict word 0x28
    jae short L04B3
    mov ax, word [0x1c]
    cmp ax, 0xc8
    jae short L04B3
    mov dx, 0x28
    mul dl
    add ax, word [0x18]
    rr add, di, ax
    rr add, si, ax
L048B:
    mov dx, 0x3ce
    mov ax, 0x105
    out dx, al
    inc dx
    rr mov, al, ah
    out dx, al
    mov bx, word [0x20]
    mov dx, word [0x22]
    mov ax, word [0x16]
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
    cmp word [0x286], 1
    je short L04C0
    jmp near L0565
L04C0:
    mov ax, word [0x20]
    add ax, word [0x18]
    cmp ax, 0xa1
    jb short L04D6
    mov ax, 0xa0
    sub ax, word [0x18]
    mov word [0x20], ax
L04D6:
    mov ax, word [0x1c]
    add ax, word [0x22]
    cmp ax, 0xc9
    jb short L04EC
    mov ax, 0xc8
    sub ax, word [0x1c]
    mov word [0x22], ax
L04EC:
    mov ax, word [0x18]
    cmp ax, 0xa0
    jae short L04B3
    mov ax, word [0x1c]
    cmp ax, 0xc8
    jae short L0564
    rr mov, bx, ax
    and ax, 0xfc
    mov dx, 0x28
    mul dl
    add ax, word [0x18]
    and bx, 3
    je short L0518
    rr mov, cx, ax
    mov ax, 0x2000
    mul bx
    rr add, ax, cx
L0518:
    rr add, di, ax
    rr add, si, ax
    mov dx, word [0x20]
    mov ax, 0x2000
    rr sub, ax, dx
    mov word [0x1c], ax
    rr mov, ax, dx
    sub ax, 0xa0
    add ah, 0x60
    shr dx, 1
    mov word [0x20], dx
    mov dx, word [0x16]
L053A:
    mov cx, word [0x20]
    push ds
    mov ds, dx
    rep movsw
    pop ds
    inc bx
    and bx, 3
    je short L055A
    add si, word [0x1c]
    add di, word [0x1c]
    dec word [0x22]
    jne short L053A
    je short L0564
L055A:
    rr sub, si, ax
    rr sub, di, ax
    dec word [0x22]
    jne short L053A
L0564:
    ret
L0565:
    mov ax, word [0x20]
    add ax, word [0x18]
    cmp ax, 0x141
    jb short L057B
    mov ax, 0x140
    sub ax, word [0x18]
    mov word [0x20], ax
L057B:
    mov ax, word [0x1c]
    add ax, word [0x22]
    cmp ax, 0xc9
    jb short L0591
    mov ax, 0xc8
    sub ax, word [0x1c]
    mov word [0x22], ax
L0591:
    mov ax, word [0x18]
    cmp ax, 0x140
    jae short L0564
    mov ax, word [0x1c]
    cmp ax, 0xc8
    jae short L0564
    rr mov, bx, ax
    mov dx, 0x140
    mul dx
    add ax, word [0x18]
    rr add, di, ax
    rr add, si, ax
    mov bx, 0x140
    mov dx, word [0x20]
    rr sub, bx, dx
    shr dx, 1
    mov word [0x20], dx
    mov dx, word [0x16]
L05C3:
    mov cx, word [0x20]
    push ds
    mov ds, dx
    rep movsw
    pop ds
    rr add, si, bx
    rr add, di, bx
    dec word [0x22]
    jne short L05C3
    jmp short L0564
L05D9:
    mov ax, word [0x20]
    add ax, word [0x18]
    cmp ax, strict word 0x51
    jb short L05EF
    mov ax, 0x50
    sub ax, word [0x18]
    mov word [0x20], ax
L05EF:
    mov ax, word [0x1c]
    add ax, word [0x22]
    cmp ax, 0xc9
    jb short L0605
    mov ax, 0xc8
    sub ax, word [0x1c]
    mov word [0x22], ax
L0605:
    mov ax, word [0x18]
    cmp ax, strict word 0x50
    jae short L0676
    mov ax, word [0x1c]
    cmp ax, 0xc8
    jae short L0676
    rr mov, bx, ax
    and ax, 0xfe
    mov dx, 0x28
    mul dl
    add ax, word [0x18]
    and bx, 1
    je short L062B
    add ah, 0x20
L062B:
    rr add, di, ax
    rr add, si, ax
    mov dx, word [0x20]
    mov ax, 0x2000
    rr sub, ax, dx
    mov word [0x1c], ax
    rr mov, ax, dx
    sub ax, strict word 0x50
    add ah, 0x20
    shr dx, 1
    mov word [0x20], dx
    mov dx, word [0x16]
L064D:
    mov cx, word [0x20]
    push ds
    mov ds, dx
    rep movsw
    pop ds
    xor bx, 1
    je short L066C
    add si, word [0x1c]
    add di, word [0x1c]
    dec word [0x22]
    jne short L064D
    je short L0676
L066C:
    rr sub, si, ax
    rr sub, di, ax
    dec word [0x22]
    jne short L064D
L0676:
    ret

; FUNCTION: DONALD 0000:0677
L0677:
    push bp
    rr mov, bp, sp
    push di
    push si
    push ds
    mov ax, 0xb7f  ; reloc
    mov ds, ax
    push es
    mov ax, word [bp + 6]
    cmp word [0x286], 2
    je short L06AA
    shl ax, 1
    cmp word [0x286], 0
    je short L06AA
    shl ax, 1
    cmp word [0x286], 1
    je short L06AA
    mov bx, word [bp + 0x14]
    cmp bx, 0xa000
    jne short L06AA
    shl ax, 1
L06AA:
    mov word [0x18], ax
    mov ax, word [bp + 8]
    shl ax, 1
    shl ax, 1
    shl ax, 1
    mov word [0x1c], ax
    mov ax, word [bp + 0xa]
    cmp word [0x286], 2
    je short L06E0
    shl ax, 1
    cmp word [0x286], 0
    je short L06E0
    shl ax, 1
    cmp word [0x286], 1
    je short L06E0
    mov bx, word [bp + 0x18]
    cmp bx, 0xa000
    jne short L06E0
    shl ax, 1
L06E0:
    mov word [0x1a], ax
    mov ax, word [bp + 0xc]
    shl ax, 1
    shl ax, 1
    shl ax, 1
    mov word [0x1e], ax
    mov ax, word [bp + 0xe]
    cmp word [0x286], 2
    je short L0704
    shl ax, 1
    cmp word [0x286], 0
    je short L0704
    shl ax, 1
L0704:
    mov word [0x20], ax
    mov ax, word [bp + 0x10]
    shl ax, 1
    shl ax, 1
    shl ax, 1
    mov word [0x22], ax
    mov ax, word [bp + 0x12]
    mov word [0x24], ax
    mov ax, word [bp + 0x14]
    mov word [0x16], ax
    mov di, word [bp + 0x16]
    mov ax, word [bp + 0x18]
    mov es, ax
    mov ax, word [0x1c]
    mov dx, 0x28
    cmp word [0x286], 3
    jne short L073F
    cmp word [0x16], 0xa000
    jne short L073F
    mov dx, 0x140
L073F:
    mul dx
    add ax, word [0x18]
    add word [0x24], ax
    mov ax, word [0x1e]
    mov dx, 0x28
    cmp word [0x286], 3
    jne short L0761
    cmp word [0x16], 0xa000
    jne short L0761
    mov dx, 0x140
L0761:
    mul dx
    add ax, word [0x1a]
    rr add, di, ax
    mov si, word [0x24]
    cmp word [0x286], 1
    je short L07C0
    ja short L0779
    jmp near L0872
L0779:
    cmp word [0x286], 3
    je short L0786
    call L048B
    jmp near L086C
L0786:
    mov ax, es
    cmp ax, word [0x16]
    jne short L07C3
    mov bp, 0x140
    cmp ax, 0xa000
    je short L079D
    mov bp, 0xa0
    shr word [0x20], 1
L079D:
    mov dx, word [0x22]
    mov bx, word [0x20]
    mov ax, word [0x16]
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
    db 0x90
L07C3:
    cmp word [0x16], 0xa000
    je short L07F9
    mov dx, word [0x22]
    mov bx, word [0x20]
    mov ax, word [0x16]
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
    db 0x90
L07F9:
    mov dx, word [0x22]
    mov bx, word [0x20]
    mov ax, word [0x16]
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
    db 0x90
L0827:
    rr sub, bx, bx
    mov ax, 0x2000
    sub ax, word [0x20]
    mov word [0x1c], ax
    mov ax, word [0x20]
    sub ax, 0xa0
    add ax, 0x6000
    mov dx, word [0x16]
L0840:
    mov cx, word [0x20]
    shr cx, 1
    push ds
    mov ds, dx
    rep movsw
    pop ds
    inc bx
    and bx, 3
    je short L0862
    add si, word [0x1c]
    add di, word [0x1c]
    dec word [0x22]
    jne short L0840
    je short L086C
L0862:
    rr sub, si, ax
    rr sub, di, ax
    dec word [0x22]
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
    sub ax, word [0x20]
    mov word [0x1c], ax
    mov ax, word [0x20]
    sub ax, strict word 0x50
    add ax, 0x2000
    mov dx, word [0x16]
L088B:
    mov cx, word [0x20]
    shr cx, 1
    push ds
    mov ds, dx
    rep movsw
    pop ds
    inc bx
    and bx, 1
    je short L08AD
    add si, word [0x1c]
    add di, word [0x1c]
    dec word [0x22]
    jne short L088B
    je short L08B7
L08AD:
    rr sub, si, ax
    rr sub, di, ax
    dec word [0x22]
    jne short L088B
L08B7:
    jmp short L086C

; FUNCTION: DONALD 0000:08B9
L08B9:
    push bp
    rr mov, bp, sp
    push di
    push si
    push ds
    mov ax, 0xb7f  ; reloc
    mov ds, ax
    push es
    mov ax, 0xb800
    mov es, ax
    mov di, 0
    mov cx, 0x2000
    cmp word [0x286], 0
    je short L0908
    shl ch, 1
    cmp word [0x286], 1
    je short L0908
    mov ax, 0xa000
    mov es, ax
    cmp word [0x286], 2
    je short L08F1
    shl ch, 1
    jmp short L0908
    db 0x90
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
L0912:
    push bp
    rr mov, bp, sp
    push di
    push si
    push ds
    mov ax, 0xb7f  ; reloc
    mov ds, ax
    push es
    mov ax, 0xb800
    cmp word [0x286], 1
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
    mov word [0x26], dx
    mov dx, 0x28
    cmp word [0x286], 2
    je short L097D
    shl dx, 1
    shl bx, 1
    cmp word [0x286], 0
    jne short L0963
    shr ax, 1
    jmp short L097D
    db 0x90
L0963:
    shl dx, 1
    shl cx, 1
    shl bx, 1
    cmp word [0x286], 1
    jne short L0977
    shr ax, 1
    shr ax, 1
    jmp short L097D
    db 0x90
L0977:
    shl dx, 1
    shl cx, 1
    shl bx, 1
L097D:
    mov word [0x28], dx
    mul dx
    rr add, ax, bx
    rr mov, di, ax
    mov word [0x2a], cx
    cmp word [0x286], 2
    je short L09FC
    mov dx, word [0x26]
    mov ax, word [bp + 0xe]
    rr mov, ah, al
    cmp word [0x286], 3
    je short L09C0
    shl al, 1
    shl al, 1
    shl al, 1
    shl al, 1
    rr or, al, ah
    rr mov, ah, al
    cmp word [0x286], 1
    je short L09C0
    and ax, 0x3333
    shl al, 1
    shl al, 1
    rr or, al, ah
    rr mov, ah, al
L09C0:
    rr mov, si, di
    mov cx, word [0x2a]
    rep stosw
    rr mov, di, si
    add di, word [0x28]
    cmp word [0x286], 3
    je short L09F7
    cmp word [0x286], 1
    jne short L09E9
    add di, 0x1f60
    jns short L09F7
    sub di, 0x7f60
    jmp short L09F7
    db 0x90
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
    mov dx, word [0x26]
    mov ax, word [bp + 0xe]
L0A17:
    rr mov, si, di
    mov cx, word [0x2a]
    rep stosb
    rr mov, di, si
    add di, word [0x28]
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
L0A2E:
    push bp
    rr mov, bp, sp
    push di
    push si
    push ds
    mov ax, 0xb7f  ; reloc
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
L0A6B:
    push bp
    rr mov, bp, sp
    push di
    push si
    push ds
    mov ax, 0xb7f  ; reloc
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
    db 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00

; FUNCTION: DONALD 0000:0B2E
L0B2E:
    push bp
    rr mov, bp, sp
    push di
    push si
    push ds
    mov ax, 0xb7f  ; reloc
    mov ds, ax
    push es
    mov dx, 0x28
    mov ax, word [0x38]
    mov word [cs:0xb2a], ax
    mul dl
    mov word [cs:0xb28], ax
    mov ax, word [0x36]
    mov word [cs:0xb2c], ax
    mov di, word [bp + 6]
    mov ax, word [bp + 8]
    mov es, ax
    mov si, word [bp + 0xa]
    mov ax, word [bp + 0xc]
    mov word [0x2c], ax
    mov ax, word [bp + 0xe]
    mov word [0x30], ax
    sar ax, 1
    sar ax, 1
    sar ax, 1
    mov word [0x2e], ax
    mov dx, word [bp + 0x10]
    mov ax, word [0x32]
    dec ax
    mov word [cs:0xb24], ax
    mov ax, word [0x34]
    dec ax
    mov word [cs:0xb26], ax
    mov bp, ds
    mov ax, word [0x2c]
    mov ds, ax
    inc si
    lodsw
    rr mov, bx, ax
    and bx, 0xff
    inc bx
    inc si
    cmp dx, word [cs:0xb2a]
    jge short L0BAB
    rr mov, cx, dx
    sub cx, word [cs:0xb2c]
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
    mov dx, word [cs:0xb2c]
L0BBB:
    mov ds, bp
    mov ax, 0x28
    mul dx
    rr add, di, ax
    add di, word [0x2e]
    mov cx, word [0x30]
    and cx, 7
    mov bx, word [0x2e]
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
    mov ax, word [0x2c]
    cmp word [0x2a3], 1
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
    cmp bx, word [cs:0xb26]
    jg short L0C39
    cmp bx, word [cs:0xb24]
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
    cmp bp, word [cs:0xb28]
    jae short L0C7E
    rr mov, di, bp
    pop bx
    rr mov, ax, bp
    rr sub, ax, bx
    cmp ax, word [cs:0xb28]
    jae short L0C7F
    jmp short L0BF5
L0C39:
    lodsb
    jmp short L0C11
L0C3C:
    rr xor, ah, ah
    xchg al, ah
    shr ax, cl
    cmp bx, word [cs:0xb26]
    jg short L0C79
    cmp bx, word [cs:0xb24]
    jle short L0C79
    rr mov, ch, al
    mov al, byte [es:di]
    rr mov, al, ah
    out dx, al
    lodsb
    mov byte [es:di], al
L0C5C:
    cmp bx, word [cs:0xb26]
    jge short L0C11
    cmp bx, word [cs:0xb24]
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
    cmp bp, word [cs:0xb28]
    jae short L0C7E
    rr mov, di, bp
    pop bx
    rr mov, ax, bp
    rr sub, ax, bx
    cmp ax, word [cs:0xb28]
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
    cmp bx, word [cs:0xb26]
    jg short L0D17
    rr mov, ch, al
    and ah, byte [es:di]
    rr mov, al, ah
    out dx, al
    lodsb
    mov byte [es:di], al
L0CFA:
    cmp bx, word [cs:0xb26]
    jge short L0CB5
    cmp bx, word [cs:0xb24]
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
L0D1C:
    push bp
    rr mov, bp, sp
    push di
    push si
    push ds
    mov ax, 0xb7f  ; reloc
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
L0D56:
    push bp
    rr mov, bp, sp
    push di
    push si
    push ds
    mov ax, 0xb7f  ; reloc
    mov ds, ax
    push es
    mov si, word [bp + 6]
    mov ax, word [bp + 8]
    mov word [0x3a], ax
    mov di, word [bp + 0xa]
    mov word [0x3c], di
    mov ax, word [bp + 0xc]
    mov es, ax
    mov dx, word [bp + 0xe]
    mov ax, word [bp + 0x10]
    mov byte [0x3e], al
    mov bx, word [bp + 0x12]
    cmp word [0x286], 2
    je short L0DBF
    mov dh, byte [0x3e]
    cmp word [0x286], 0
    je short L0DAB
    mov ds, word [0x3a]
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
    mov ds, word [0x3a]
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
    mov word [0x3f], dx
L0DC6:
    mov dx, word [0x3f]
    mov byte [0x41], dl
L0DCE:
    rr mov, si, bp
    push ds
    mov ax, word [0x3a]
    mov ds, ax
    lodsw
    xchg al, ah
    rr mov, bx, ax
    lodsw
    xchg al, ah
    rr mov, bp, si
    pop ds
    mov si, 0x42
    mov cx, 0x10
L0DE7:
    mov byte [si], ch
    inc si
    loop L0DE7
    mov ch, 0x80
L0DEE:
    call L0E6F
    mov si, 0x42
    rr add, si, dx
    or byte [si], ch
    shr ch, 1
    je short L0E05
    cmp ch, 8
    jne short L0DEE
    rr mov, bx, ax
    jmp short L0DEE
L0E05:
    mov si, 0x42
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
    dec byte [0x41]
    jne short L0DCE
    dec di
    mov al, 0x40
    or byte [es:di], al
    inc di
    add bp, 0xa0
    sub bp, word [0x3f]
    sub bp, word [0x3f]
    sub bp, word [0x3f]
    sub bp, word [0x3f]
    dec byte [0x3e]
    je short L0E5E
    jmp near L0DC6
L0E5E:
    dec di
    mov al, 0x20
    or byte [es:di], al
    pop ds
    inc di
    rr mov, ax, di
    sub ax, word [0x3c]
    jmp near L0DA5
L0E6F:
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
L0E82:
    push bp
    rr mov, bp, sp
    push di
    push si
    push ds
    mov ax, 0xb7f  ; reloc
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
    mov word [0x52], ax
    mov ax, word [bp + 0xc]
    mov word [0x54], ax
    mov ax, word [bp + 0xe]
    rr mov, ah, al
    mov cx, 4
    shl al, cl
    rr or, al, ah
    rr mov, ah, al
    mov word [0x56], ax
    mov bx, 0xb800
    mov es, bx
    mov bx, word [0x54]
L0ED7:
    mov cx, word [0x52]
    rep stosb
    sub di, word [0x52]
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
L0EFE:
    push bp
    rr mov, bp, sp
    push di
    push si
    push ds
    mov ax, 0xb7f  ; reloc
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
    db 0x90
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
L0F2C:
    push bp
    rr mov, bp, sp
    push di
    push si
    push ds
    mov ax, 0xb7f  ; reloc
    mov ds, ax
    push es
    mov si, word [bp + 6]
    mov ax, word [bp + 8]
    mov di, word [bp + 0xa]
    mov dx, word [bp + 0xc]
    mov es, dx
    mov ds, ax
    jmp short L0F52
    db 0x90
L0F4B:
    inc si
    mov ax, word [si]
    inc si
    jmp short L0F63
    db 0x90
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
L0F83:
    push bp
    rr mov, bp, sp
    push di
    push si
    push ds
    mov ax, 0xb7f  ; reloc
    mov ds, ax
    push es
    mov si, word [bp + 6]
    mov ax, word [bp + 8]
    mov di, word [bp + 0xa]
    mov dx, word [bp + 0xc]
    mov es, dx
    mov ds, ax
    jmp short L0FA9
    db 0x90
L0FA2:
    inc si
    mov ax, word [si]
    inc si
    jmp short L0FBC
    db 0x90
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
L0FEE:
    sti
    retf

; FUNCTION: DONALD 0000:0FF0
L0FF0:
    cli
    retf

; FUNCTION: DONALD 0000:0FF2
L0FF2:
    push bp
    rr mov, bp, sp
    push di
    push si
    push ds
    mov ax, 0xb7f  ; reloc
    mov ds, ax
    cmp word [0x286], 0
    jne short L1066
    mov si, word [bp + 6]
    mov ax, word [bp + 8]
    push es
    mov es, ax
    mov di, 0x258
    mov cx, 0x20
L1013:
    mov al, byte [es:si]
    mov byte [di], al
    inc si
    inc di
    loop L1013
    mov si, 0x58
    mov di, 0x158
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
    mov bx, 0x258
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
L106B:
    push bp
    rr mov, bp, sp
    push di
    push si
    push ds
    mov ax, 0xb7f  ; reloc
    mov ds, ax
    push es
    mov si, word [bp + 6]
    mov ax, word [bp + 8]
    mov word [0x278], ax
    mov di, word [bp + 0xa]
    mov dx, word [bp + 0xc]
    mov bx, word [bp + 0xe]
    mov byte [0x27a], bl
    mov cx, word [bp + 0x10]
    rr mov, bp, dx
    rr xor, dh, dh
L1094:
    mov bx, 0x58
L1097:
    mov dl, byte [0x27a]
L109B:
    mov ax, word [0x278]
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
    db 0x90
L10C2:
    xor dh, 1
    je short L1094
    mov bx, 0x158
    jmp short L1097
L10CC:
    pop es
    pop ds
    pop si
    pop di
    pop bp
    retf

; FUNCTION: DONALD 0000:10D2
L10D2:
    push bp
    rr mov, bp, sp
    push di
    push si
    push ds
    mov ax, 0xb7f  ; reloc
    mov ds, ax
    mov si, word [bp + 6]
    mov ax, word [bp + 8]
    push es
    mov es, ax
    mov cx, 0x3e80
    rr xor, dx, dx
    mov ax, word [bp + 0xa]
    mov byte [0x27a], 0x50
    rr or, ax, ax
    je short L10FC
    mov byte [0x27a], 4
L10FC:
    mov bx, 0x58
L10FF:
    mov dl, byte [0x27a]
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
    db 0x90
L114C:
    dec cx
    je short L1159
    xor dh, 1
    je short L10FC
    mov bx, 0x158
    jmp short L10FF
L1159:
    pop es
    pop ds
    pop si
    pop di
    pop bp
    retf

; FUNCTION: DONALD 0000:115F
L115F:
    push bp
    rr mov, bp, sp
    push di
    push si
    push ds
    mov ax, 0xb7f  ; reloc
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
L1180:
    push bp
    rr mov, bp, sp
    push di
    push si
    push ds
    mov ax, 0xb7f  ; reloc
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
L1197:
    push bp
    rr mov, bp, sp
    push di
    push si
    push ds
    mov ax, 0xb7f  ; reloc
    mov ds, ax
    push es
    mov ax, 0xb7f  ; reloc
    mov es, ax
    mov si, 0x27b
    rr xor, ah, ah
    mov al, byte [es:si]
    shr al, 1
    shr al, 1
    db 0x26,0xD0,0x54,0x02  ; rcl byte ptr es:[si + 2]
    db 0x26,0xD0,0x54,0x01  ; rcl byte ptr es:[si + 1]
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
    db 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00

; FUNCTION: DONALD 0000:11DC
L11DC:
    push bp
    rr mov, bp, sp
    push di
    push si
    push ds
    mov ax, 0xb7f  ; reloc
    mov ds, ax
    push es
    mov dx, 0x28
    mov ax, word [0x38]
    mov word [cs:0x11d8], ax
    mul dl
    mov word [cs:0x11d6], ax
    mov ax, word [0x36]
    mov word [cs:0x11da], ax
    mov di, word [bp + 6]
    mov ax, word [bp + 8]
    mov es, ax
    mov si, word [bp + 0xa]
    mov ax, word [bp + 0xc]
    mov word [0x27f], ax
    mov ax, word [bp + 0xe]
    mov word [0x283], ax
    sar ax, 1
    sar ax, 1
    sar ax, 1
    mov word [0x281], ax
    mov dx, word [bp + 0x10]
    mov ax, word [0x32]
    dec ax
    mov word [cs:0x11d2], ax
    mov ax, word [0x34]
    dec ax
    mov word [cs:0x11d4], ax
    mov bp, ds
    mov bx, word [0x27f]
    mov ds, bx
    inc si
    lodsw
    mov ds, bp
    mov byte [0x285], ah
    mov ds, bx
    rr mov, bx, ax
    and bx, 0xff
    inc bx
    inc si
    cmp dx, word [cs:0x11d8]
    jge short L1262
    rr mov, cx, dx
    sub cx, word [cs:0x11da]
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
    mov dx, word [cs:0x11da]
L1272:
    mov ds, bp
    mov ax, 0x28
    mul dx
    rr add, di, ax
    add di, word [0x281]
    mov al, byte [0x285]
    rr xor, ah, ah
    dec ax
    rr add, di, ax
    mov cx, word [0x283]
    and cx, 7
    mov bx, word [0x281]
    rr add, bx, ax
    mov ax, word [0x27f]
    cmp word [0x2a3], 1
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
    cmp bx, word [cs:0x11d4]
    jg short L131C
    cmp bx, word [cs:0x11d2]
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
    cmp bp, word [cs:0x11d6]
    jae short L137E
    rr mov, di, bp
    pop bx
    rr mov, ax, bp
    rr sub, ax, bx
    cmp ax, word [cs:0x11d6]
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
    cmp bx, word [cs:0x11d4]
    jg short L1379
    cmp bx, word [cs:0x11d2]
    jle short L1379
    rr mov, ch, al
    mov al, byte [es:di]
    rr mov, al, ah
    out dx, al
    lodsb
    mov byte [es:di], al
L135B:
    cmp bx, word [cs:0x11d4]
    jge short L12F4
    cmp bx, word [cs:0x11d2]
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
    cmp bx, word [cs:0x11d4]
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
    cmp bp, word [cs:0x11d6]
    jae short L137E
    rr mov, di, bp
    pop bx
    rr mov, ax, bp
    rr sub, ax, bx
    cmp ax, word [cs:0x11d6]
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
    cmp bx, word [cs:0x11d4]
    jg short L145C
    rr mov, ch, al
    and ah, byte [es:di]
    rr mov, al, ah
    out dx, al
    lodsb
    mov byte [es:di], al
L143E:
    cmp bx, word [cs:0x11d4]
    jge short L13DA
    cmp bx, word [cs:0x11d2]
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
L1461:
    push bp
    rr mov, bp, sp
    push di
    push si
    push ds
    mov ax, 0xb7f  ; reloc
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
L1478:
    push bp
    rr mov, bp, sp
    push di
    push si
    push ds
    mov ax, 0xb7f  ; reloc
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
L1491:
    push bp
    rr mov, bp, sp
    push di
    push si
    push ds
    mov ax, 0xb7f  ; reloc
    mov ds, ax
    mov bx, word [bp + 6]
    mov cx, word [bp + 8]
    mov ax, 0x40
    mov es, ax
    mov dx, word [es:0x63]
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
L14C7:
    push bp
    rr mov, bp, sp
    push di
    push si
    push ds
    mov ax, 0xb7f  ; reloc
    mov ds, ax
    mov ax, word [bp + 6]
    mov word [0x286], ax
    pop ds
    pop si
    pop di
    pop bp
    retf

; FUNCTION: DONALD 0000:14DD
L14DD:
    push bp
    rr mov, bp, sp
    push di
    push si
    push ds
    mov ax, 0xb7f  ; reloc
    mov ds, ax
    mov ax, word [bp + 6]
    rr xor, ah, ah
    int 0x10
    pop ds
    pop si
    pop di
    pop bp
    retf
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
    db 0x00,0x00,0x00,0x00,0x00,0x00

; FUNCTION: DONALD 0000:16FA
L16FA:
    push bp
    rr mov, bp, sp
    push di
    push si
    push ds
    mov ax, 0xb7f  ; reloc
    mov ds, ax
    cmp word [0x286], 0
    jne short L170F
    jmp near L1975
L170F:
    push es
    mov di, word [bp + 6]
    mov ax, word [bp + 8]
    mov es, ax
    mov si, word [bp + 0xa]
    mov ax, word [bp + 0xc]
    mov word [0x290], ax
    mov bx, word [bp + 0xe]
    mov ax, word [bp + 0x10]
    mov word [0x296], ax
    mov ax, word [0x288]
    shl ax, 1
    shl ax, 1
    rr add, di, ax
    mov byte [0x2a0], 0
    sar bx, 1
    db 0xD0,0x16,0xA0,0x02  ; rcl byte ptr [0x2a0]
    rr sub, bx, ax
    mov word [0x294], bx
    mov ax, word [0x28a]
    sub ax, word [0x288]
    mov word [0x2a1], ax
    push ds
    inc si
    mov ax, word [0x290]
    mov ds, ax
    lodsw
    inc si
    pop ds
    inc al
    push ax
    and ax, 0xff
    mov word [0x298], ax
    pop ax
    xchg ah, al
    and ax, 0xff
    shl ax, 1
    shl ax, 1
    mov word [0x29a], ax
    mov word [0x29c], ax
    mov ax, word [0x296]
    sub ax, word [0x28c]
    jns short L17A0
    neg ax
    cmp ax, word [0x298]
    jae short L17CE
    mov dx, word [0x29a]
    mul dl
    rr add, si, ax
    mov ax, word [0x298]
    add ax, word [0x296]
    sub ax, word [0x28c]
    js short L1805
    mov word [0x298], ax
    mov ax, word [0x28c]
    mov word [0x296], ax
L17A0:
    mov ax, word [0x28e]
    sub ax, word [0x296]
    js short L1805
    je short L1805
    cmp ax, word [0x298]
    jae short L17B4
    mov word [0x298], ax
L17B4:
    mov word [cs:0x16f6], 0
    mov ax, word [0x294]
    rr or, ax, ax
    jns short L17DC
    add word [0x29a], ax
    neg ax
    rr add, si, ax
    cmp ax, word [0x29c]
L17CE:
    jae short L1805
    rr xor, ax, ax
    mov word [0x294], ax
    mov word [cs:0x16f6], 1
L17DC:
    mov ax, word [0x2a1]
    shl ax, 1
    shl ax, 1
    sub ax, word [0x294]
    js short L1805
    je short L1805
    mov word [cs:0x16f4], 0
    cmp ax, word [0x29a]
    jae short L1808
    mov word [0x29a], ax
    mov word [cs:0x16f4], 1
    jmp short L1808
    db 0x90
L1805:
    jmp near L188A
L1808:
    mov ax, word [0x296]
    rr mov, bx, ax
    and ax, 0xfc
    shl ax, 1
    shl ax, 1
    shl ax, 1
    rr mov, dx, ax
    shl ax, 1
    shl ax, 1
    rr add, ax, dx
    add ax, word [0x294]
    and bx, 3
    je short L182E
    rr mov, cx, bx
L1829:
    add ah, 0x20
    loop L1829
L182E:
    rr add, di, ax
    mov ax, 0x2000
    sub ax, word [0x29a]
    mov word [0x296], ax
    mov dx, word [0x290]
    rr mov, ah, bl
    rr xor, bx, bx
    cmp byte [0x2a0], 1
    je short L1890
    cmp word [0x2a3], 1
    jne short L1853
    jmp near L1939
L1853:
    mov cx, word [0x29a]
    mov bp, ds
    mov ds, dx
L185B:
    lodsb
    rr mov, bl, al
    mov bl, byte [cs:bx + 0x14f4]
    and bl, byte [es:di]
    rr or, al, bl
    stosb
    loop L185B
    mov ds, bp
    add si, word [0x29c]
    sub si, word [0x29a]
    add di, word [0x296]
    inc ah
    and ah, 3
    jne short L1884
    sub di, 0x7f60
L1884:
    dec word [0x298]
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
    mov word [0x29e], ax
L1895:
    mov cx, word [0x29a]
    mov bp, ds
    mov ds, dx
    cmp word [cs:0x16f6], 0
    je short L18D0
    mov al, byte [si - 1]
    rr xor, ah, ah
    rr mov, bx, ax
    mov bl, byte [cs:bx + 0x14f4]
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
    mov bl, byte [cs:bx + 0x14f4]
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
    add si, word [0x29c]
    sub si, word [0x29a]
    add di, word [0x296]
    inc word [0x29e]
    and word [0x29e], 3
    jne short L1926
    sub di, 0x7f60
L1926:
    dec word [0x298]
    je short L1972
    jmp near L1895
L192F:
    cmp word [cs:0x16f4], 0
    je short L18FF
    jmp short L1909
L1939:
    mov cx, word [0x29a]
    mov bp, ds
    mov ds, dx
L1941:
    lodsb
    rr xor, bh, bh
    mov bl, byte [es:di]
    mov bh, byte [cs:bx + 0x14f4]
    rr and, al, bh
    rr or, al, bl
    stosb
    loop L1941
    mov ds, bp
    add si, word [0x29c]
    sub si, word [0x29a]
    add di, word [0x296]
    inc ah
    and ah, 3
    jne short L196C
    sub di, 0x7f60
L196C:
    dec word [0x298]
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
    mov word [0x290], ax
    mov bx, word [bp + 0xe]
    mov ax, word [bp + 0x10]
    mov word [0x296], ax
    mov ax, word [0x288]
    shl ax, 1
    rr add, di, ax
    mov byte [0x2a0], bl
    and byte [0x2a0], 3
    shl byte [0x2a0], 1
    sar bx, 1
    sar bx, 1
    rr sub, bx, ax
    mov word [0x294], bx
    mov ax, word [0x28a]
    sub ax, word [0x288]
    mov word [0x2a1], ax
    push ds
    inc si
    mov ax, word [0x290]
    mov ds, ax
    lodsw
    inc si
    rr mov, bx, si
    pop ds
    inc al
    push ax
    and ax, 0xff
    mov word [0x298], ax
    rr mov, dx, ax
    pop ax
    xchg ah, al
    and ax, 0xff
    shl ax, 1
    mov word [0x29a], ax
    mov word [0x29c], ax
    rr xor, ah, ah
    mul dl
    rr add, bx, ax
    mov ax, word [0x296]
    sub ax, word [0x28c]
    jns short L1A17
    neg ax
    cmp ax, word [0x298]
    jb short L19F7
    jmp near L1A83
L19F7:
    mov dx, word [0x29a]
    mul dl
    rr add, si, ax
    rr add, bx, ax
    mov ax, word [0x298]
    add ax, word [0x296]
    sub ax, word [0x28c]
    js short L1A83
    mov word [0x298], ax
    mov ax, word [0x28c]
    mov word [0x296], ax
L1A17:
    mov ax, word [0x28e]
    sub ax, word [0x296]
    js short L1A83
    je short L1A83
    cmp ax, word [0x298]
    jae short L1A2B
    mov word [0x298], ax
L1A2B:
    mov word [cs:0x16f6], 0
    mov ax, word [0x294]
    rr or, ax, ax
    jns short L1A5C
    add word [0x29a], ax
    neg ax
    rr add, si, ax
    rr add, bx, ax
    cmp ax, word [0x29c]
    ja short L1A83
    jne short L1A52
    mov al, byte [0x2a0]
    rr or, al, al
    je short L1A83
L1A52:
    rr xor, ax, ax
    mov word [0x294], ax
    inc word [cs:0x16f6]
L1A5C:
    mov ax, word [0x2a1]
    shl ax, 1
    sub ax, word [0x294]
    js short L1A83
    je short L1A83
    mov word [cs:0x16f4], 0
    cmp ax, word [0x29a]
    ja short L1A86
    mov word [0x29a], ax
    mov word [cs:0x16f4], 1
    jmp short L1A86
    db 0x90
L1A83:
    jmp near L1B1A
L1A86:
    mov ax, word [0x296]
    mov word [0x29e], ax
    and ax, 0xfe
    mov dx, 0x28
    mul dl
    add ax, word [0x294]
    test word [0x29e], 1
    je short L1AA3
    add ah, 0x20
L1AA3:
    rr add, di, ax
    mov ax, 0x2000
    sub ax, word [0x29a]
    mov word [0x296], ax
    mov ax, word [0x29a]
    sub ax, strict word 0x50
    add ax, 0x2000
    mov word [0x294], ax
    mov dx, word [0x290]
    cmp word [0x2a3], 1
    je short L1B1D
    cmp byte [0x2a0], 0
    je short L1AD0
    jmp near L1B70
L1AD0:
    mov cx, word [0x29a]
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
    add si, word [0x29c]
    sub si, word [0x29a]
    add bx, word [0x29c]
    sub bx, word [0x29a]
    mov ax, word [0x29e]
    and ax, strict word 1
    xor ax, strict word 1
    mov word [0x29e], ax
    je short L1B10
    add di, word [0x296]
    dec word [0x298]
    jne short L1AD0
    je short L1B1A
L1B10:
    sub di, word [0x294]
    dec word [0x298]
    jne short L1AD0
L1B1A:
    jmp near L188A
L1B1D:
    mov cx, word [0x29a]
    mov bp, ds
    mov ds, dx
    rr xor, bx, bx
L1B27:
    mov bl, byte [es:di]
    mov ah, byte [cs:bx + 0x15f4]
    lodsb
    rr and, al, ah
    rr or, al, bl
    stosb
    loop L1B27
    mov ds, bp
    add si, word [0x29c]
    sub si, word [0x29a]
    add bx, word [0x29c]
    sub bx, word [0x29a]
    mov ax, word [0x29e]
    and ax, strict word 1
    xor ax, strict word 1
    mov word [0x29e], ax
    je short L1B63
    add di, word [0x296]
    dec word [0x298]
    jne short L1B1D
    je short L1B1A
L1B63:
    sub di, word [0x294]
    dec word [0x298]
    jne short L1B1D
    jmp near L188A
L1B70:
    mov cx, word [0x29a]
    rr mov, ch, cl
    mov cl, byte [0x2a0]
    mov bp, ds
    mov ds, dx
    cmp word [cs:0x16f6], 0
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
    add si, word [0x29c]
    sub si, word [0x29a]
    add bx, word [0x29c]
    sub bx, word [0x29a]
    mov ax, word [0x29e]
    and ax, strict word 1
    xor ax, strict word 1
    mov word [0x29e], ax
    je short L1C09
    add di, word [0x296]
    dec word [0x298]
    je short L1C13
L1BF6:
    jmp near L1B70
L1BF9:
    cmp word [cs:0x16f4], 0
    je short L1BC0
    rr or, dl, al
    mov byte [es:di], dl
    inc di
    jmp short L1BCA
L1C09:
    sub di, word [0x294]
    dec word [0x298]
    jne short L1BF6
L1C13:
    jmp near L188A
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
L1D16:
    push bp
    rr mov, bp, sp
    push di
    push si
    push ds
    mov ax, 0xb7f  ; reloc
    mov ds, ax
    mov word [cs:0x16f6], 0
    cmp word [0x286], 0
    jne short L1D32
    jmp near L1FD3
L1D32:
    push es
    mov di, word [bp + 6]
    mov ax, word [bp + 8]
    mov word [0x292], ax
    mov si, word [bp + 0xa]
    mov ax, word [bp + 0xc]
    mov word [0x290], ax
    mov bx, word [bp + 0xe]
    mov ax, word [bp + 0x10]
    mov word [0x296], ax
    mov ax, word [0x288]
    shl ax, 1
    shl ax, 1
    rr add, di, ax
    mov byte [0x2a0], 0
    sar bx, 1
    db 0xD0,0x16,0xA0,0x02  ; rcl byte ptr [0x2a0]
    rr sub, bx, ax
    mov word [0x294], bx
    mov ax, word [0x28a]
    sub ax, word [0x288]
    mov word [0x2a1], ax
    push ds
    inc si
    mov ax, word [0x290]
    mov ds, ax
    lodsw
    inc si
    pop ds
    inc al
    push ax
    and ax, 0xff
    mov word [0x298], ax
    pop ax
    xchg ah, al
    and ax, 0xff
    shl ax, 1
    shl ax, 1
    mov word [0x29a], ax
    mov word [0x29c], ax
    mov ax, word [0x296]
    sub ax, word [0x28c]
    jns short L1DC4
    neg ax
    cmp ax, word [0x298]
    jae short L1E24
    mov dx, word [0x29a]
    mul dl
    rr add, si, ax
    mov ax, word [0x298]
    add ax, word [0x296]
    sub ax, word [0x28c]
    js short L1E24
    mov word [0x298], ax
    mov ax, word [0x28c]
    mov word [0x296], ax
L1DC4:
    mov ax, word [0x28e]
    sub ax, word [0x296]
    js short L1E24
    je short L1E24
    cmp ax, word [0x298]
    jae short L1DD8
    mov word [0x298], ax
L1DD8:
    mov ax, word [0x294]
    rr or, ax, ax
    jns short L1DF5
    add word [0x29a], ax
    neg ax
    cmp ax, word [0x29c]
    jae short L1E24
    rr xor, ax, ax
    mov word [0x294], ax
    inc word [cs:0x16f6]
L1DF5:
    mov ax, word [0x2a1]
    shl ax, 1
    shl ax, 1
    sub ax, word [0x294]
    js short L1E24
    je short L1E24
    mov word [cs:0x16f4], 0
    cmp ax, word [0x29a]
    ja short L1E27
    add si, word [0x29a]
    rr sub, si, ax
    mov word [0x29a], ax
    mov word [cs:0x16f4], 1
    jmp short L1E27
    db 0x90
L1E24:
    jmp near L1EC8
L1E27:
    mov ax, word [0x296]
    rr mov, bx, ax
    and ax, 0xfc
    shl ax, 1
    shl ax, 1
    shl ax, 1
    rr mov, dx, ax
    shl ax, 1
    shl ax, 1
    rr add, ax, dx
    add ax, word [0x294]
    and bx, 3
    mov word [0x29e], bx
    je short L1E51
    rr mov, cx, bx
L1E4C:
    add ah, 0x20
    loop L1E4C
L1E51:
    rr add, di, ax
    mov ax, 0x2000
    sub ax, word [0x29a]
    mov word [0x296], ax
    mov ax, word [0x29a]
    sub ax, 0xa0
    add ax, 0x6000
    mov word [0x294], ax
    mov dx, word [0x290]
    dec si
    mov ax, word [0x29e]
    xchg al, ah
    cmp word [0x2a3], 1
    je short L1ECE
    cmp byte [0x2a0], 1
    jne short L1E84
    jmp near L1F15
L1E84:
    rr xor, bx, bx
    mov cx, word [0x292]
    mov es, cx
    mov cx, word [0x29a]
    rr add, si, cx
    mov bp, ds
    mov ds, dx
L1E96:
    mov bl, byte [si]
    mov bl, byte [cs:bx + 0x1c16]
    rr mov, al, bl
    mov bl, byte [cs:bx + 0x14f4]
    and bl, byte [es:di]
    rr or, al, bl
    stosb
    dec si
    loop L1E96
    mov ds, bp
    add si, word [0x29c]
    add di, word [0x296]
    inc ah
    and ah, 3
    jne short L1EC2
    sub di, 0x7f60
L1EC2:
    dec word [0x298]
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
    mov cx, word [0x292]
    mov es, cx
    mov cx, word [0x29a]
    rr add, si, cx
    mov bp, ds
    mov ds, dx
L1EE0:
    mov bl, byte [si]
    mov al, byte [cs:bx + 0x1c16]
    mov bl, byte [es:di]
    mov bl, byte [cs:bx + 0x14f4]
    rr and, al, bl
    or byte [es:di], al
    inc di
    dec si
    loop L1EE0
    mov ds, bp
    add si, word [0x29c]
    add di, word [0x296]
    inc ah
    and ah, 3
    jne short L1F0D
    sub di, 0x7f60
L1F0D:
    dec word [0x298]
    jne short L1ECE
    je short L1EC8
L1F15:
    xchg al, ah
    mov word [0x29e], ax
L1F1A:
    rr xor, bx, bx
    mov cx, word [0x292]
    mov es, cx
    mov cx, word [0x29a]
    rr add, si, cx
    mov bp, ds
    mov ds, dx
    cmp word [cs:0x16f6], 0
    je short L1F39
    call L1F96
    rr xor, bh, bh
L1F39:
    mov bl, byte [si]
    mov bl, byte [cs:bx + 0x1c16]
    rr mov, ah, bl
    mov dh, byte [cs:bx + 0x14f4]
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
    add si, word [0x29c]
    add di, word [0x296]
    inc word [0x29e]
    and word [0x29e], 3
    jne short L1F8D
    sub di, 0x7f60
L1F8D:
    dec word [0x298]
    jne short L1F1A
    jmp near L1EC8
L1F96:
    mov bl, byte [si + 1]
    mov bl, byte [cs:bx + 0x1c16]
    rr mov, ah, bl
    mov dh, byte [cs:bx + 0x14f4]
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
    cmp word [cs:0x16f4], 0
    je short L1F6C
    dec si
    jmp short L1F72
L1FD3:
    push es
    mov di, word [bp + 6]
    mov ax, word [bp + 8]
    mov word [0x292], ax
    mov si, word [bp + 0xa]
    mov ax, word [bp + 0xc]
    mov word [0x290], ax
    mov bx, word [bp + 0xe]
    mov ax, word [bp + 0x10]
    mov word [0x296], ax
    mov ax, word [0x288]
    shl ax, 1
    rr add, di, ax
    mov byte [0x2a0], bl
    and byte [0x2a0], 3
    shl byte [0x2a0], 1
    sar bx, 1
    sar bx, 1
    rr sub, bx, ax
    mov word [0x294], bx
    mov ax, word [0x28a]
    sub ax, word [0x288]
    mov word [0x2a1], ax
    push ds
    inc si
    mov ax, word [0x290]
    mov ds, ax
    lodsw
    inc si
    rr mov, bx, si
    pop ds
    inc al
    push ax
    and ax, 0xff
    mov word [0x298], ax
    rr mov, dx, ax
    pop ax
    xchg ah, al
    and ax, 0xff
    shl ax, 1
    mov word [0x29a], ax
    mov word [0x29c], ax
    rr xor, ah, ah
    mul dl
    rr add, bx, ax
    mov ax, word [0x296]
    sub ax, word [0x28c]
    jns short L2076
    neg ax
    cmp ax, word [0x298]
    jb short L2056
    jmp near L20E5
L2056:
    mov dx, word [0x29a]
    mul dl
    rr add, si, ax
    rr add, bx, ax
    mov ax, word [0x298]
    add ax, word [0x296]
    sub ax, word [0x28c]
    js short L20E5
    mov word [0x298], ax
    mov ax, word [0x28c]
    mov word [0x296], ax
L2076:
    mov ax, word [0x28e]
    sub ax, word [0x296]
    js short L20E5
    je short L20E5
    cmp ax, word [0x298]
    jae short L208A
    mov word [0x298], ax
L208A:
    mov ax, word [0x294]
    rr or, ax, ax
    jns short L20B2
    add word [0x29a], ax
    neg ax
    cmp ax, word [0x29c]
    ja short L20E5
    jne short L20A6
    mov al, byte [0x2a0]
    rr or, al, al
    je short L20E5
L20A6:
    rr xor, ax, ax
    mov word [0x294], ax
    mov word [cs:0x16f6], 1
L20B2:
    mov ax, word [0x2a1]
    shl ax, 1
    sub ax, word [0x294]
    js short L20E5
    je short L20E5
    mov word [cs:0x16f4], 0
    cmp ax, word [0x29a]
    ja short L20E8
    add si, word [0x29a]
    add bx, word [0x29a]
    rr sub, si, ax
    rr sub, bx, ax
    mov word [0x29a], ax
    mov word [cs:0x16f4], 1
    jmp short L20E8
    db 0x90
L20E5:
    jmp near L1EC8
L20E8:
    mov ax, word [0x296]
    mov word [0x29e], ax
    and ax, 0xfe
    mov dx, 0x28
    mul dl
    add ax, word [0x294]
    test word [0x29e], 1
    je short L2105
    add ah, 0x20
L2105:
    rr add, di, ax
    mov dx, word [0x292]
    mov es, dx
    mov ax, 0x2000
    sub ax, word [0x29a]
    mov word [0x296], ax
    mov ax, word [0x29a]
    sub ax, strict word 0x50
    add ah, 0x20
    mov word [0x294], ax
    mov dx, word [0x290]
    dec si
    dec bx
    mov bp, ds
    cmp word [0x2a3], 1
    je short L2191
    cmp byte [0x2a0], 0
    je short L213C
    jmp near L21E1
L213C:
    mov cx, word [0x29a]
    rr add, si, cx
    rr add, bx, cx
L2144:
    mov ds, dx
    mov al, byte [si]
    mov ah, byte [bx]
    push bx
    mov bx, 0x3a5
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
    add si, word [0x29c]
    add bx, word [0x29c]
    mov ax, word [0x29e]
    and ax, strict word 1
    xor ax, strict word 1
    mov word [0x29e], ax
    je short L2184
    add di, word [0x296]
    dec word [0x298]
    jne short L213C
    je short L218E
L2184:
    sub di, word [0x294]
    dec word [0x298]
    jne short L213C
L218E:
    jmp near L1EC8
L2191:
    mov cx, word [0x29a]
    rr add, si, cx
    rr xor, bx, bx
L2199:
    mov ds, dx
    mov bl, byte [si]
    mov ds, bp
    mov al, byte [bx + 0x3a5]
    mov bl, byte [es:di]
    and al, byte [cs:bx + 0x15f4]
    or byte [es:di], al
    dec si
    inc di
    loop L2199
    add si, word [0x29c]
    add bx, word [0x29c]
    mov ax, word [0x29e]
    and ax, strict word 1
    xor ax, strict word 1
    mov word [0x29e], ax
    je short L21D4
    add di, word [0x296]
    dec word [0x298]
    jne short L2191
    je short L21DE
L21D4:
    sub di, word [0x294]
    dec word [0x298]
    jne short L2191
L21DE:
    jmp near L1EC8
L21E1:
    mov cx, word [0x29a]
    rr add, si, cx
    rr add, bx, cx
    rr mov, ch, cl
    mov cl, byte [0x2a0]
    cmp word [cs:0x16f6], 0
    je short L21FA
    call L2271
L21FA:
    rr or, ch, ch
    je short L2232
L21FE:
    mov ds, dx
    mov al, byte [si]
    mov ah, byte [bx]
    push bx
    mov bx, 0x3a5
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
    add si, word [0x29c]
    add bx, word [0x29c]
    mov ax, word [0x29e]
    and ax, strict word 1
    xor ax, strict word 1
    mov word [0x29e], ax
    je short L2264
    add di, word [0x296]
    dec word [0x298]
    jne short L21E1
L2252:
    jmp near L1EC8
L2255:
    cmp word [cs:0x16f4], 0
    je short L2225
    rr or, al, bl
    mov byte [es:di], al
    jmp short L222A
L2264:
    sub di, word [0x294]
    dec word [0x298]
    je short L2252
    jmp near L21E1
L2271:
    mov ds, dx
    mov al, byte [si + 1]
    mov ah, byte [bx + 1]
    push bx
    mov bx, 0x3a5
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
L2298:
    push bp
    rr mov, bp, sp
    push di
    push si
    push ds
    mov ax, 0xb7f  ; reloc
    mov ds, ax
    mov al, byte [bp + 6]
    mov byte [0x14a5], al
    mov al, byte [bp + 8]
    mov byte [0x14a6], al
    cmp word [0x286], 0
    je short L22E8
    cmp word [0x286], 2
    jae short L22E3
    mov bl, byte [0x14a5]
    rr mov, al, bl
    mov cx, 4
    shl bl, cl
    rr or, bl, al
    rr mov, bh, bl
    mov word [0x14a7], bx
    mov bl, byte [0x14a6]
    rr mov, al, bl
    mov cx, 4
    shl bl, cl
    rr or, bl, al
    rr mov, bh, bl
    mov word [0x14a9], bx
L22E3:
    pop ds
    pop si
    pop di
    pop bp
    retf
L22E8:
    mov bl, byte [0x14a5]
    and bl, 3
    rr mov, al, bl
    mov dl, byte [0x14a6]
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
    mov word [0x14a7], bx
    rr mov, dh, dl
    mov word [0x14a9], dx
    jmp short L22E3

; FUNCTION: DONALD 0000:2319
L2319:
    push bp
    rr mov, bp, sp
    push di
    push si
    push ds
    mov ax, 0xb7f  ; reloc
    mov ds, ax
    mov si, word [bp + 6]
    add si, 0x4a5
    mov ax, word [bp + 8]
    mov di, word [bp + 0xa]
    rr add, di, ax
    push es
    mov ax, 0xb800
    mov es, ax
    mov word [0x14ab], 2
    mov dx, word [0x14a7]
    mov bp, word [0x14a9]
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
    dec word [0x14ab]
    jne short L2347
    pop es
    pop ds
    pop si
    pop di
    pop bp
    retf

; FUNCTION: DONALD 0000:237A
L237A:
    push bp
    rr mov, bp, sp
    push di
    push si
    push ds
    mov ax, 0xb7f  ; reloc
    mov ds, ax
    mov si, word [bp + 6]
    add si, 0x4a5
    mov ax, word [bp + 8]
    mov di, word [bp + 0xa]
    rr add, di, ax
    push es
    mov ax, 0xb800
    mov es, ax
    mov dx, 0x2000
    mov bp, word [0x14a7]
    mov cx, 8
L23A4:
    lodsw
    rr mov, bx, ax
    rr and, ax, bp
    not bx
    and bx, word [0x14a9]
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
L23C2:
    push bp
    rr mov, bp, sp
    push di
    push si
    push ds
    mov ax, 0xb7f  ; reloc
    mov ds, ax
    mov si, word [bp + 6]
    add si, 0x4a5
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
    mov bl, byte [0x14a5]
    mov bh, byte [0x14a6]
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
L241D:
    push bp
    rr mov, bp, sp
    push di
    push si
    push ds
    mov ax, 0xb7f  ; reloc
    mov ds, ax
    mov si, word [bp + 6]
    add si, 0x4a5
    mov ax, word [bp + 8]
    rr mov, di, ax
    mov ax, word [bp + 0xa]
    rr add, di, ax
    mov bp, es
    mov ax, 0xa000
    mov es, ax
    mov bl, 8
    mov dh, byte [0x14a5]
    mov dl, byte [0x14a6]
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
    db 0x90
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
L2470:
    push bp
    rr mov, bp, sp
    push di
    push si
    push ds
    mov ax, 0xb7f  ; reloc
    mov ds, ax
    push es
    mov ax, ds
    mov es, ax
    cld
    cmp word [0x286], 2
    jae short L24D7
    mov si, 0x4a5
    add si, 0x3ff
    mov di, 0x4a5
    cmp word [0x286], 0
    je short L24B2
    add di, 0xffc
L249D:
    mov bl, byte [si]
    call L24DD
    call L24DD
    sub di, 8
    dec si
    cmp si, 0x4a5
    jne short L249D
    jmp short L24D7
    db 0x90
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
    cmp si, 0x4a5
    jne short L24B6
L24D7:
    pop es
    pop ds
    pop si
    pop di
    pop bp
    retf
L24DD:
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
L24FB:
    push bp
    rr mov, bp, sp
    push di
    push si
    push ds
    mov ax, 0xb7f  ; reloc
    mov ds, ax
    cmp word [0x286], 1
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
L253B:
    push bp
    rr mov, bp, sp
    push di
    push si
    push ds
    mov ax, 0xb7f  ; reloc
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
L2553:
    push bp
    rr mov, bp, sp
    push di
    push si
    push ds
    mov ax, 0xb7f  ; reloc
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
L2584:
    push bp
    rr mov, bp, sp
    push di
    push si
    push ds
    mov ax, 0xb7f  ; reloc
    mov ds, ax
    push es
    mov di, word [bp + 6]
    mov ax, word [bp + 8]
    mov word [0x14af], ax
    mov ax, word [bp + 0xa]
    mov word [0x14b1], ax
    mov ax, word [bp + 0xc]
    mov word [0x14b3], ax
    cmp word [0x286], 3
    je short L25B6
    cmp word [0x286], 0
    jne short L25DD
    jmp near L26A2
L25B6:
    mov ax, 0xa000
    mov es, ax
    mov ax, word [0x14af]
    mov dx, 0x140
    mul dx
    rr add, di, ax
    mov cx, word [0x14b1]
    sub cx, word [0x14af]
    inc cx
    mov ax, word [0x14b3]
L25D1:
    mov byte [es:di], al
    add di, 0x140
    loop L25D1
    jmp near L269C
L25DD:
    cmp word [0x286], 1
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
    mov dx, word [0x14af]
    mov ax, 0x28
    mul dl
    shr di, 1
    shr di, 1
    shr di, 1
    rr add, di, ax
    mov ax, word [0x14b3]
L261B:
    mov ah, byte [es:di]
    mov byte [es:di], al
    add di, 0x28
    inc dx
    cmp dx, word [0x14b1]
    jle short L261B
    jmp short L269C
    db 0x90
L262E:
    mov cx, 4
    shl ax, cl
    or ax, word [0x14b3]
    mov bx, 0xf
    test di, 1
    jne short L2645
    mov cx, 4
    shl bx, cl
L2645:
    rr and, ax, bx
    mov word [0x14b3], ax
    not bl
    mov ax, 0xb800
    mov es, ax
    mov ax, word [0x14af]
    and al, 0xfc
    mov dx, 0x28
    mul dl
    mov cx, word [0x14af]
    and cx, 3
    je short L2669
L2664:
    add ah, 0x20
    loop L2664
L2669:
    shr di, 1
    rr add, di, ax
    mov dx, word [0x14af]
    mov cx, word [0x14b1]
    sub cx, word [0x14af]
    inc cx
L267A:
    mov al, byte [es:di]
    rr and, al, bl
    or ax, word [0x14b3]
    mov byte [es:di], al
    inc dl
    and dl, 3
    je short L2696
    add di, 0x2000
    loop L267A
    jmp short L269C
    db 0x90
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
    mov word [0x14b3], ax
    shl ax, 1
    shl ax, 1
    or ax, word [0x14b3]
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
    mov word [0x14b3], ax
    not bl
    mov ax, 0xb800
    mov es, ax
    mov ax, word [0x14af]
    and al, 0xfe
    mov dx, 0x28
    mul dl
    shr di, 1
    shr di, 1
    rr add, di, ax
    mov dx, word [0x14af]
    and dx, 1
    je short L26F3
    add di, 0x2000
L26F3:
    mov cx, word [0x14b1]
    sub cx, word [0x14af]
    inc cx
L26FC:
    mov al, byte [es:di]
    rr and, al, bl
    or ax, word [0x14b3]
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
L271E:
    push bp
    rr mov, bp, sp
    push di
    push si
    push ds
    mov ax, 0xb7f  ; reloc
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
    mov ch, byte [di + 0x14b5]
    mov al, byte [es:si]
    and al, 7
    rr mov, di, ax
    mov cl, byte [di + 0x14b5]
    inc si
    mov al, byte [es:si]
    inc si
    rr mov, di, ax
    mov dh, byte [di + 0x14b5]
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

; FUNCTION: DONALD 0000:277E
L277E:
    push bp
    rr mov, bp, sp
    push di
    push si
    push ds
    mov ax, 0xb7f  ; reloc
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
    cmp word [0x286], 0
    je short L27E7
    cmp word [0x286], 1
    je short L2817
    cmp word [0x286], 2
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
    db 0x90
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
    db 0x00,0x00

; FUNCTION: DONALD 0000:28B3
L28B3:
    push bp
    rr mov, bp, sp
    push di
    push si
    push ds
    mov ax, 0xb7f  ; reloc
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
    mov word [cs:0x28b1], ax
    push es
    cmp word [0x286], 0
    je short L2923
    cmp word [0x286], 1
    je short L2959
    cmp word [0x286], 2
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
    mov ax, word [cs:0x28b1]
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
    mov ax, word [cs:0x28b1]
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
    mov ax, word [cs:0x28b1]
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
    db 0x90
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
    mov ax, word [cs:0x28b1]
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
    db 0x00,0x00,0x00,0x00,0x00,0x00

; FUNCTION: DONALD 0000:2A15
L2A15:
    push bp
    rr mov, bp, sp
    push di
    push si
    push ds
    mov ax, 0xb7f  ; reloc
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
    mov ax, 0xb7f  ; reloc
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
