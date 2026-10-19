; Module 0512: hand-written sound/music driver assembly.
; SEGMENT: DONALD 0512 0001-0558
; Purpose: sound driver: int 8 (PIT) hook, tune byte-stream player, tick counter.
bits 16
%include "tasm.inc"

; Literal offsets into this segment (TASM-style hard-coded cs: data/ISR offsets). The alternate build (game/DONALD)
; places the module 8 bytes further into its paragraph, so they move by 8 there.
%ifdef DONALD_ALT
%define CSO(n) ((n) + 8)
%else
%define CSO(n) (n)
%endif

segment SND_TEXT public align=1 class=CODE use16   ; starts at 0512:0001, right after shutdown()'s retf

global _snd_get_option
_snd_get_option equ L00EE
global _snd_set_option
_snd_set_option equ L0102
global _snd_init
_snd_init equ L0354
global _snd_shutdown
_snd_shutdown equ L0398
global _snd_play
_snd_play equ L03CD
global _snd_stop
_snd_stop equ L03F1
global _ctrlc_install
_ctrlc_install equ ctrlc_install
global _ctrlc_remove
_ctrlc_remove equ ctrlc_remove
global _kbbreak_install
_kbbreak_install equ kbbreak_install
global _kbbreak_remove
_kbbreak_remove equ kbbreak_remove
global _timer_ticks
_timer_ticks equ L0544

    db 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
    db 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
    db 0x00,0x00,0x00,0x00,0x00,0x00,0xFF,0xFD,0xA2,0xEF,0x41,0xE2,0x82,0xD5,0x98,0xC9
    db 0x3D,0xBE,0x8A,0xB3,0x7C,0xA9,0xF2,0x9F,0xFC,0x96,0x89,0x8E,0x83,0x86,0xF7,0x7E
    db 0xD9,0x77,0x21,0x71,0xC7,0x6A,0xC6,0x64,0x1F,0x5F,0xCA,0x59,0xBE,0x54,0xFD,0x4F
    db 0x7E,0x4B,0x42,0x47,0x42,0x43,0x7B,0x3F,0xDB,0x3B,0x8F,0x38,0x62,0x35,0x63,0x32
    db 0x8F,0x2F,0xE4,0x2C,0x5F,0x2A,0xFE,0x27,0xC0,0x25,0xA1,0x23,0xA1,0x21,0xBE,0x1F
    db 0xF6,0x1D,0x48,0x1C,0xB1,0x1A,0x32,0x19,0xC8,0x17,0x72,0x16,0x30,0x15,0xFF,0x13
    db 0xE0,0x12,0xD1,0x11,0xD1,0x10,0xDF,0x0F,0xFB,0x0E,0x24,0x0E,0x59,0x0D,0x99,0x0C
    db 0xE4,0x0B,0x39,0x0B,0x98,0x0A,0x00,0x0A,0x70,0x09,0xE8,0x08,0x68,0x08,0xF0,0x07
    db 0x7E,0x07,0x12,0x07,0xAC,0x06,0x4C,0x06,0xF2,0x05,0x9D,0x05,0x4C,0x05,0x00,0x05
    db 0xB8,0x04,0x74,0x04,0x34,0x04,0xF8,0x03,0xBF,0x03,0x82,0x03,0x56,0x03,0x26,0x03
    db 0xF9,0x02,0xCE,0x02,0xA6,0x02,0x80,0x02,0x5C,0x02,0x3A,0x02,0x1A,0x02,0xFC,0x01
    db 0xDF,0x01,0xC4,0x01,0xAB,0x01,0x93,0x01,0x7C,0x01,0x67,0x01,0x53,0x01,0x40,0x01
    db 0x2E,0x01,0x1D,0x01,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00

; FUNCTION: DONALD 0512:00EE
; snd_get_option: music option word (set by snd_set_option)
L00EE:
    push bp
    rr mov, bp, sp
    push di
    push si
    push ds
    mov ax, SND_TEXT  ; reloc
    mov ds, ax
    mov ax, word [cs:CSO(0xeb)]
    pop ds
    pop si
    pop di
    pop bp
    retf

; FUNCTION: DONALD 0512:0102
; snd_set_option: music option word: -1 default, else argv[1] / 60
L0102:
    push bp
    rr mov, bp, sp
    push di
    push si
    push ds
    mov ax, SND_TEXT  ; reloc
    mov ds, ax
    mov ax, word [bp + 6]
    mov word [cs:CSO(0xeb)], ax
    pop ds
    pop si
    pop di
    pop bp
    retf

; State/data operands are absolute offsets in the original CS frame, not OMF
; label fixups. Keep CSO() here: the alternate executable shifts them by 8.
%define SND_OLD_TIMER       CSO(0x01)  ; saved int 8 far vector
%define SND_CHAIN_RELOAD    CSO(0x0d)
%define SND_CHAIN_COUNT     CSO(0x0f)
%define SND_STREAM_OFF      CSO(0x11)
%define SND_STREAM_SEG      CSO(0x13)
%define SND_STREAM_POS      CSO(0x15)
%define SND_PENDING_OFF     CSO(0x17)
%define SND_PENDING_SEG     CSO(0x19)
%define SND_PLAYING         CSO(0x1b)
%define SND_START_PENDING   CSO(0x1c)
%define SND_STOP_PENDING    CSO(0x1d)
%define SND_READ_NOTE       CSO(0x1e)
%define SND_DURATION_SCALE  CSO(0x1f)
%define SND_DURATION_LEFT   CSO(0x22)
%define SND_NOTE_DIVISORS   CSO(0x24)
%define SND_LOOP_COUNT_1    CSO(0xe4)
%define SND_LOOP_COUNT_2    CSO(0xe5)
%define SND_TICKS           CSO(0xe6)
%define SND_OPTION          CSO(0xeb)
%define SND_OPTION_TICKS    CSO(0xed)

; FUNCTION: DONALD 0512:0119
; snd_timer_isr: advance the tune on every PIT interrupt; chain the old int 8
; once per 16 interrupts. Every 256 ticks the option byte counter reaches zero.
snd_timer_isr:
    push ds
    push ax
    mov ax, SND_TEXT             ; segment relocation, as in the original ISR
    mov ds, ax
    push ax
    dec byte [cs:SND_OPTION_TICKS]
    jne short .count_tick
    mov ax, word [cs:SND_OPTION]
    cmp ax, strict word -1
    je short .count_tick
    cmp ax, strict word 0
    je short .count_tick
    dec ax
    mov word [cs:SND_OPTION], ax
.count_tick:
    pop ax
    mov ax, word [cs:SND_TICKS]
    inc ax
    cmp ax, 0x123
    jle short .store_tick
    rr xor, ax, ax
.store_tick:
    mov word [cs:SND_TICKS], ax
    call snd_music_tick
    mov ax, word [cs:SND_CHAIN_COUNT]
    rr or, al, al
    jne short .acknowledge
    mov ax, word [cs:SND_CHAIN_RELOAD]
    mov word [cs:SND_CHAIN_COUNT], ax
    pop ax
    pop ds
    jmp far [cs:SND_OLD_TIMER]
.acknowledge:
    dec al
    mov word [cs:SND_CHAIN_COUNT], ax
    mov al, 0x20
    out 0x20, al                 ; PIC end-of-interrupt when not chaining
    pop ax
    pop ds
    iret

; FUNCTION: DONALD 0512:0173
; snd_music_tick: ES:SI traverses the tune, BX is its saved byte offset.
; Notes 00h..5Fh index the PIT-divisor table; high-bit bytes are commands.
snd_music_tick:
    cmp byte [cs:SND_START_PENDING], 0
    je short .check_playing
    mov byte [cs:SND_PLAYING], 1
    mov byte [cs:SND_READ_NOTE], 1
    mov byte [cs:SND_START_PENDING], 0
    mov byte [cs:SND_STOP_PENDING], 0
    mov ax, word [cs:SND_PENDING_OFF]
    mov word [cs:SND_STREAM_OFF], ax
    mov ax, word [cs:SND_PENDING_SEG]
    mov word [cs:SND_STREAM_SEG], ax
    mov word [cs:SND_STREAM_POS], 0
.check_playing:
    cmp byte [cs:SND_PLAYING], 0
    jne short .save_registers
    jmp near .return
.save_registers:
    push es
    push si
    push bx
    push dx
    mov bx, word [cs:SND_STREAM_POS]
    cmp byte [cs:SND_READ_NOTE], 0
    jne short .load_stream
    jmp near .count_duration
.load_stream:
    mov es, word [cs:SND_STREAM_SEG]
    mov si, word [cs:SND_STREAM_OFF]
    rr add, si, bx
.read_command:
    mov al, byte [es:si]
    rr or, al, al
    js short .loop_1_end
    cmp al, 0x5f
    jle short .lookup_note
    jmp near .stop
.lookup_note:
    push di
    rr xor, ah, ah
    shl ax, 1
    rr mov, di, ax
    mov ax, word [cs:word di + SND_NOTE_DIVISORS] ; retain TASM's disp16
    pop di
.play_divisor:
    rr or, ax, ax
    je short .rest
    call snd_program_divisor
    call snd_speaker_enable
    jmp short .read_duration
    nop                         ; original short-jump padding
.rest:
    call snd_speaker_disable
.read_duration:
    inc si
    rr xor, ah, ah
    mov al, byte [es:si]
    inc al
    mul byte [cs:SND_DURATION_SCALE]
    dec ax
    mov word [cs:SND_DURATION_LEFT], ax
    inc si
    add bx, byte 2
    mov byte [cs:SND_READ_NOTE], 0
    jmp near .save_position

.loop_1_end:                     ; CEh: decrement loop 1, then backtrack/skip
    cmp al, 0xce
    jne short .loop_1_set
    dec byte [cs:SND_LOOP_COUNT_1]
    jne short .loop_1_backtrack
    add si, byte 3
    add bx, byte 3
    jmp short .read_command
.loop_1_backtrack:
    inc si
    mov ax, word [es:si]
    inc bx
    rr sub, si, ax
    rr sub, bx, ax
    jno short .loop_1_continue
    jmp near .stop
.loop_1_continue:
    jmp short .read_command
.loop_1_set:                     ; CDh: load a repeat count (zero becomes one)
    cmp al, 0xcd
    jne short .loop_2_end
    inc si
    mov al, byte [es:si]
    rr or, al, al
    jne short .store_loop_1
    mov al, 1
.store_loop_1:
    mov byte [cs:SND_LOOP_COUNT_1], al
    inc si
    add bx, byte 2
    jmp near .read_command
.loop_2_end:                     ; D2h: second independent counted loop
    cmp al, 0xd2
    jne short .loop_2_set
    dec byte [cs:SND_LOOP_COUNT_2]
    jne short .loop_2_backtrack
    add si, byte 3
    add bx, byte 3
    jmp near .read_command
.loop_2_backtrack:
    inc si
    mov ax, word [es:si]
    inc bx
    rr sub, si, ax
    rr sub, bx, ax
    jno short .loop_2_continue
    jmp near .stop
.loop_2_continue:
    jmp near .read_command
.loop_2_set:                     ; D1h: load the second repeat count
    cmp al, 0xd1
    jne short .frequency
    inc si
    mov al, byte [es:si]
    rr or, al, al
    jne short .store_loop_2
    mov al, 1
.store_loop_2:
    mov byte [cs:SND_LOOP_COUNT_2], al
    inc si
    add bx, byte 2
    jmp near .read_command
.frequency:                     ; E6h: PIT clock / frequency word -> divisor
    cmp al, 0xe6
    jne short .duration_scale
    inc si
    mov dx, 0x12
    mov ax, 0x34dc               ; DX:AX = 1,193,180 Hz
    div word [es:si]
    inc si
    add bx, byte 2
    jmp near .play_divisor
.duration_scale:                ; E2h: set ticks per duration unit
    cmp al, 0xe2
    jne short .decrease_scale
    inc si
    mov al, byte [es:si]
    rr or, al, al
    jne short .store_scale
    mov al, 1
.store_scale:
    mov byte [cs:SND_DURATION_SCALE], al
    inc si
    add bx, byte 2
    jmp near .read_command
.decrease_scale:                ; E8h: preserve the original OF/ZF tests
    cmp al, 0xe8
    jne short .increase_scale
    inc si
    mov al, byte [es:si]
    sub byte [cs:SND_DURATION_SCALE], al
    jno short .decrease_done
    jne short .decrease_done
    mov byte [cs:SND_DURATION_SCALE], 1
.decrease_done:
    inc si
    add bx, byte 2
    jmp near .read_command
.increase_scale:                ; E9h: add, using FFh on signed overflow
    cmp al, 0xe9
    jne short .end_command
    inc si
    mov al, byte [es:si]
    add byte [cs:SND_DURATION_SCALE], al
    jno short .increase_done
    mov byte [cs:SND_DURATION_SCALE], 0xff
.increase_done:
    inc si
    add bx, byte 2
    jmp near .read_command
.end_command:                   ; FFh is consumed; unknown commands also stop
    cmp al, 0xff
    jne short .stop
    inc bx
    jmp short .stop
    nop                         ; original short-jump padding

.count_duration:
    dec word [cs:SND_DURATION_LEFT]
    jns short .check_stop
    cmp word [cs:SND_DURATION_LEFT], byte -1
    je short .check_stop
    mov byte [cs:SND_READ_NOTE], 1
.check_stop:
    cmp byte [cs:SND_STOP_PENDING], 0
    je short .save_position
.stop:
    mov byte [cs:SND_PLAYING], 0
    mov byte [cs:SND_STOP_PENDING], 0
    call snd_speaker_disable
.save_position:
    mov word [cs:SND_STREAM_POS], bx
    pop dx
    pop bx
    pop si
    pop es
.return:
    ret

; FUNCTION: DONALD 0512:033F
; snd_speaker_enable: connect PIT channel 2 to the PC speaker.
snd_speaker_enable:
    in al, 0x61
    or al, 3
    out 0x61, al
    ret

; FUNCTION: DONALD 0512:0346
; snd_speaker_disable: gate off the speaker and PIT channel 2.
snd_speaker_disable:
    in al, 0x61
    and al, 0xfc
    out 0x61, al
    ret

; FUNCTION: DONALD 0512:034D
; snd_program_divisor: send the low and high bytes of AX to PIT channel 2.
snd_program_divisor:
    out 0x42, al
    rr mov, al, ah
    out 0x42, al
    ret

; FUNCTION: DONALD 0512:0354
; snd_init: hooks int 8, PIT channel 0 at 1000h
L0354:
    push bp
    rr mov, bp, sp
    push di
    push si
    push ds
    mov ax, SND_TEXT  ; reloc
    mov ds, ax
    mov al, 8
    mov ah, 0x35
    int 0x21
    mov word [cs:CSO(1)], bx
    mov word [cs:CSO(3)], es
    mov word [cs:CSO(0xd)], 0xf
    mov word [cs:CSO(0xf)], 0
    mov dx, CSO(0x119)
    mov al, 8
    mov ah, 0x25
    int 0x21
    mov al, 0x36
    out 0x43, al
    mov ax, 0x1000
    out 0x40, al
    rr mov, al, ah
    out 0x40, al
    pop ds
    pop si
    pop di
    pop bp
    retf

; FUNCTION: DONALD 0512:0398
; snd_shutdown: restores int 8 and the PIT, speaker off
L0398:
    push bp
    rr mov, bp, sp
    push di
    push si
    push ds
    mov ax, SND_TEXT  ; reloc
    mov ds, ax
    mov dx, word [cs:CSO(1)]
    mov bx, word [cs:CSO(3)]
    mov ds, bx
    mov al, 8
    mov ah, 0x25
    int 0x21
    mov al, 0x36
    out 0x43, al
    mov ax, 0
    out 0x40, al
    rr mov, al, ah
    out 0x40, al
    in al, 0x61
    and al, 0xfc
    out 0x61, al
    pop ds
    pop si
    pop di
    pop bp
    retf

; FUNCTION: DONALD 0512:03CD
; snd_play: starts a tune (far pointer to a byte stream)
L03CD:
    push bp
    rr mov, bp, sp
    push di
    push si
    push ds
    mov ax, SND_TEXT  ; reloc
    mov ds, ax
    mov ax, word [bp + 6]
    mov word [cs:CSO(0x17)], ax
    mov ax, word [bp + 8]
    mov word [cs:CSO(0x19)], ax
    mov byte [cs:CSO(0x1c)], 1
    pop ds
    pop si
    pop di
    pop bp
    retf

; FUNCTION: DONALD 0512:03F1
; snd_stop: sets the stop flag
L03F1:
    push bp
    rr mov, bp, sp
    push di
    push si
    push ds
    mov ax, SND_TEXT  ; reloc
    mov ds, ax
    mov byte [cs:CSO(0x1d)], 1
    pop ds
    pop si
    pop di
    pop bp
    retf

; FUNCTION: DONALD 0512:0407
; ctrlc_install: save int 23h and point it at an IRET stub (Ctrl-C ignored)
ctrlc_install:
    push bp
    rr mov, bp, sp
    push di
    push si
    push ds
    mov ax, SND_TEXT  ; reloc
    mov ds, ax
    mov al, 0x23
    mov ah, 0x35
    int 0x21
    mov word [cs:CSO(5)], bx
    mov word [cs:CSO(7)], es
    mov dx, CSO(0x430)
    mov al, 0x23
    mov ah, 0x25
    int 0x21
    pop ds
    pop si
    pop di
    pop bp
    retf

; FUNCTION: DONALD 0512:0430
; ctrlc_isr: suppress DOS Ctrl-C while preserving the interrupted registers.
ctrlc_isr:
    push ds
    push ax
    mov ax, SND_TEXT             ; segment relocation
    mov ds, ax
    pop ax
    pop ds
    iret

; FUNCTION: DONALD 0512:043A
; ctrlc_remove: restore the saved int 23h
ctrlc_remove:
    push bp
    rr mov, bp, sp
    push di
    push si
    push ds
    mov ax, SND_TEXT  ; reloc
    mov ds, ax
    mov dx, word [cs:CSO(5)]
    mov bx, word [cs:CSO(7)]
    mov ds, bx
    mov al, 0x23
    mov ah, 0x25
    int 0x21
    pop ds
    pop si
    pop di
    pop bp
    retf

; FUNCTION: DONALD 0512:045C
; kbbreak_install: save int 9 and chain a keyboard filter that swallows ScrollLock/SysRq/Ctrl-Break combos
kbbreak_install:
    push bp
    rr mov, bp, sp
    push di
    push si
    push ds
    mov ax, SND_TEXT  ; reloc
    mov ds, ax
    mov al, 9
    mov ah, 0x35
    int 0x21
    mov word [cs:CSO(9)], bx
    mov word [cs:CSO(0xb)], es
    mov dx, CSO(0x485)
    mov al, 9
    mov ah, 0x25
    int 0x21
    pop ds
    pop si
    pop di
    pop bp
    retf

%define KB_OLD_VECTOR    CSO(0x09)
%define KB_CTRL_DOWN     CSO(0xe8)
%define KB_LSHIFT_DOWN   CSO(0xe9)
%define KB_RSHIFT_DOWN   CSO(0xea)

; FUNCTION: DONALD 0512:0485
; kbbreak_isr: filter Scroll Lock/SysRq, Ctrl-NumLock/S/C and Shift-PrintScreen.
; AH retains the make/break bit while AL holds the seven-bit scan code.
kbbreak_isr:
    push ds
    push ax
    mov ax, SND_TEXT             ; segment relocation
    mov ds, ax
    cli
    cld
    in al, 0x60
    rr mov, ah, al
    and al, 0x7f
    cmp al, 0x46                 ; Scroll Lock / Ctrl-Break scan code
    je short .swallow
    cmp al, 0x54                 ; SysRq
    je short .swallow
    cmp al, 0x1d                 ; Ctrl: record both press and release
    jne short .left_shift
    rr cmp, ah, al
    jne short .ctrl_up
    mov byte [cs:KB_CTRL_DOWN], al
    jmp short .left_shift
    nop                         ; original short-jump padding
.ctrl_up:
    mov byte [cs:KB_CTRL_DOWN], 0
.left_shift:
    cmp al, 0x2a
    jne short .right_shift
    rr cmp, ah, al
    jne short .left_shift_up
    mov byte [cs:KB_LSHIFT_DOWN], al
    jmp short .right_shift
    nop
.left_shift_up:
    mov byte [cs:KB_LSHIFT_DOWN], 0
.right_shift:
    cmp al, 0x36
    jne short .ctrl_combinations
    rr cmp, ah, al
    jne short .right_shift_up
    mov byte [cs:KB_RSHIFT_DOWN], al
    jmp short .ctrl_combinations
    nop
.right_shift_up:
    mov byte [cs:KB_RSHIFT_DOWN], 0
.ctrl_combinations:
    test byte [cs:KB_CTRL_DOWN], 0xff
    je short .left_shift_combination
    cmp al, 0x45                 ; Ctrl-NumLock (pause)
    je short .swallow
    cmp al, 0x1f                 ; Ctrl-S
    je short .swallow
    cmp al, 0x2e                 ; Ctrl-C
    je short .swallow
.left_shift_combination:
    test byte [cs:KB_LSHIFT_DOWN], 0xff
    je short .right_shift_combination
    cmp al, 0x37                 ; Shift-PrintScreen
    je short .swallow
.right_shift_combination:
    test byte [cs:KB_RSHIFT_DOWN], 0xff
    je short .chain
    cmp al, 0x37
    je short .swallow
.chain:
    pop ax
    pop ds
    sti
    jmp far [cs:KB_OLD_VECTOR]
.swallow:
    in al, 0x61
    rr mov, ah, al
    or al, 0x80                 ; pulse the keyboard acknowledgement bit
    out 0x61, al
    xchg al, ah
    out 0x61, al
    mov al, 0x20
    out 0x20, al                ; PIC end-of-interrupt without BIOS chaining
    pop ax
    pop ds
    iret

; FUNCTION: DONALD 0512:0522
; kbbreak_remove: restore the saved int 9
kbbreak_remove:
    push bp
    rr mov, bp, sp
    push di
    push si
    push ds
    mov ax, SND_TEXT  ; reloc
    mov ds, ax
    mov dx, word [cs:CSO(9)]
    mov bx, word [cs:CSO(0xb)]
    mov ds, bx
    mov al, 9
    mov ah, 0x25
    int 0x21
    pop ds
    pop si
    pop di
    pop bp
    retf

; FUNCTION: DONALD 0512:0544
; timer_ticks: tick counter maintained by the int 8 handler
L0544:
    push bp
    rr mov, bp, sp
    push di
    push si
    push ds
    mov ax, SND_TEXT  ; reloc
    mov ds, ax
    mov ax, word [cs:CSO(0xe6)]
    pop ds
    pop si
    pop di
    pop bp
    retf
