; Module 0512: hand-written sound/music driver assembly.
; SEGMENT: DONALD 0512 0001-0558
; Purpose: sound driver: int 8 (PIT) hook, tune byte-stream player, tick counter.
bits 16
%include "tasm.inc"

; The module begins at paragraph offset 1 in retail, 9 in the alternate build.
; Label differences are absolute assembly-time constants: these CS operands must
; NOT acquire OMF fixups. Only the original mov ax,SND_TEXT operands relocate.
%ifdef DONALD_ALT
SND_MODULE_BASE equ 9
%else
SND_MODULE_BASE equ 1
%endif
%define SND_OFFSET(symbol) ((symbol) - snd_module_begin + SND_MODULE_BASE)

segment SND_TEXT public align=1 class=CODE use16
snd_module_begin:

global _snd_get_option
_snd_get_option equ snd_get_option
global _snd_set_option
_snd_set_option equ snd_set_option
global _snd_init
_snd_init equ snd_init
global _snd_shutdown
_snd_shutdown equ snd_shutdown
global _snd_play
_snd_play equ snd_play
global _snd_stop
_snd_stop equ snd_stop
global _ctrlc_install
_ctrlc_install equ ctrlc_install
global _ctrlc_remove
_ctrlc_remove equ ctrlc_remove
global _kbbreak_install
_kbbreak_install equ kbbreak_install
global _kbbreak_remove
_kbbreak_remove equ kbbreak_remove
global _timer_ticks
_timer_ticks equ timer_ticks

; Driver state, CS:0001..00ED (237 bytes in both objects).
; Saved DOS vectors are offset:segment word pairs, written by AH=35h vector
; queries and read by AH=25h restores. Timer and keyboard ISRs also far-jump
; through their corresponding complete four-byte vectors.
snd_old_timer_vector:            ; far interrupt pointer, INT 08h
.offset:                dw 0
.segment:               dw 0
ctrlc_old_vector:                ; far interrupt pointer, INT 23h
.offset:                dw 0
.segment:               dw 0
kbbreak_old_vector:              ; far interrupt pointer, INT 09h
.offset:                dw 0
.segment:               dw 0
snd_chain_reload:       dw 0     ; word copied into chain_count; init sets 15
snd_chain_count:        dw 0     ; word load/store, low byte tested/decremented
snd_stream_pointer:             ; current tune far byte pointer, loaded into ES:SI
.offset:                dw 0
.segment:               dw 0
snd_stream_position:    dw 0     ; byte index in current tune; held in BX
snd_pending_pointer:            ; far byte pointer supplied to snd_play
.offset:                dw 0
.segment:               dw 0
snd_playing:            db 0     ; byte flag: a tune is active
snd_start_pending:      db 0     ; byte flag: adopt pending_pointer on next tick
snd_stop_pending:       db 0     ; byte flag: stop tune on next tick
snd_read_note:          db 0     ; byte flag: fetch next note instead of counting
snd_duration_scale:     db 0     ; unsigned byte multiplier for note duration
; CS:0020..0021 has no reads, writes, exported symbol, or pointer construction.
; Exhaustive CS accesses are scalar fields, saved vectors, and the bounded
; note lookup at CS:0024+2*note (note 0..95). Preserve these two zero bytes as
; unreferenced reserved storage; there is no evidence for an additional field.
snd_reserved_state:     times 2 db 0
snd_duration_left:      dw 0     ; signed word countdown, decremented/tested

; Exactly 96 unsigned PIT channel-2 divisors. The parser rejects note >95,
; multiplies the remaining index by two, and reads one word. Index 0 is a rest;
; indices 1..95 are the literal descending pitch divisors, not byte opcodes.
snd_note_divisors:
    dw 0x0000, 0xfdff, 0xefa2, 0xe241, 0xd582, 0xc998, 0xbe3d, 0xb38a ; notes 00..07
    dw 0xa97c, 0x9ff2, 0x96fc, 0x8e89, 0x8683, 0x7ef7, 0x77d9, 0x7121 ; notes 08..15
    dw 0x6ac7, 0x64c6, 0x5f1f, 0x59ca, 0x54be, 0x4ffd, 0x4b7e, 0x4742 ; notes 16..23
    dw 0x4342, 0x3f7b, 0x3bdb, 0x388f, 0x3562, 0x3263, 0x2f8f, 0x2ce4 ; notes 24..31
    dw 0x2a5f, 0x27fe, 0x25c0, 0x23a1, 0x21a1, 0x1fbe, 0x1df6, 0x1c48 ; notes 32..39
    dw 0x1ab1, 0x1932, 0x17c8, 0x1672, 0x1530, 0x13ff, 0x12e0, 0x11d1 ; notes 40..47
    dw 0x10d1, 0x0fdf, 0x0efb, 0x0e24, 0x0d59, 0x0c99, 0x0be4, 0x0b39 ; notes 48..55
    dw 0x0a98, 0x0a00, 0x0970, 0x08e8, 0x0868, 0x07f0, 0x077e, 0x0712 ; notes 56..63
    dw 0x06ac, 0x064c, 0x05f2, 0x059d, 0x054c, 0x0500, 0x04b8, 0x0474 ; notes 64..71
    dw 0x0434, 0x03f8, 0x03bf, 0x0382, 0x0356, 0x0326, 0x02f9, 0x02ce ; notes 72..79
    dw 0x02a6, 0x0280, 0x025c, 0x023a, 0x021a, 0x01fc, 0x01df, 0x01c4 ; notes 80..87
    dw 0x01ab, 0x0193, 0x017c, 0x0167, 0x0153, 0x0140, 0x012e, 0x011d ; notes 88..95
snd_note_divisors_end:
SND_NOTE_COUNT equ (snd_note_divisors_end - snd_note_divisors) / 2

snd_loop_count_1:       db 0     ; CDh/CEh counted-loop byte
snd_loop_count_2:       db 0     ; D1h/D2h counted-loop byte
snd_ticks:              dw 0     ; signed word tick counter, wraps after 291
kbbreak_ctrl_down:      db 0     ; zero or Ctrl make scan code (1Dh)
kbbreak_left_shift_down: db 0    ; zero or left Shift make scan code (2Ah)
kbbreak_right_shift_down: db 0   ; zero or right Shift make scan code (36h)
snd_option:             dw 0     ; signed option word; -1/0 skip timed decrement
snd_option_ticks:       db 0     ; modulo-256 tick divider for snd_option
snd_data_end:

; Function range: 0512:00EE..0102 (end exclusive), 20 bytes.
; FUNCTION: DONALD 0512:00EE
; snd_get_option: music option word (set by snd_set_option)
snd_get_option:
    push bp
    rr mov, bp, sp
    push di
    push si
    push ds
    mov ax, SND_TEXT  ; reloc
    mov ds, ax
    mov ax, word [cs:SND_OFFSET(snd_option)]
    pop ds
    pop si
    pop di
    pop bp
    retf

; Function range: 0512:0102..0119 (end exclusive), 23 bytes.
; FUNCTION: DONALD 0512:0102
; snd_set_option: music option word: -1 default, else argv[1] / 60
snd_set_option:
    push bp
    rr mov, bp, sp
    push di
    push si
    push ds
    mov ax, SND_TEXT  ; reloc
    mov ds, ax
    mov ax, word [bp + 6]
    mov word [cs:SND_OFFSET(snd_option)], ax
    pop ds
    pop si
    pop di
    pop bp
    retf

; Function range: 0512:0119..0173 (end exclusive), 90 bytes.
; FUNCTION: DONALD 0512:0119
; snd_timer_isr: advance the tune on every PIT interrupt; chain the old int 8
; once per 16 interrupts. Every 256 ticks the option byte counter reaches zero.
snd_timer_isr:
    push ds
    push ax
    mov ax, SND_TEXT             ; segment relocation, as in the original ISR
    mov ds, ax
    push ax
    dec byte [cs:SND_OFFSET(snd_option_ticks)]
    jne short .count_tick
    mov ax, word [cs:SND_OFFSET(snd_option)]
    cmp ax, strict word -1
    je short .count_tick
    cmp ax, strict word 0
    je short .count_tick
    dec ax
    mov word [cs:SND_OFFSET(snd_option)], ax
.count_tick:
    pop ax
    mov ax, word [cs:SND_OFFSET(snd_ticks)]
    inc ax
    cmp ax, 0x123
    jle short .store_tick
    rr xor, ax, ax
.store_tick:
    mov word [cs:SND_OFFSET(snd_ticks)], ax
    call snd_music_tick
    mov ax, word [cs:SND_OFFSET(snd_chain_count)]
    rr or, al, al
    jne short .acknowledge
    mov ax, word [cs:SND_OFFSET(snd_chain_reload)]
    mov word [cs:SND_OFFSET(snd_chain_count)], ax
    pop ax
    pop ds
    jmp far [cs:SND_OFFSET(snd_old_timer_vector)]
.acknowledge:
    dec al
    mov word [cs:SND_OFFSET(snd_chain_count)], ax
    mov al, 0x20
    out 0x20, al                 ; PIC end-of-interrupt when not chaining
    pop ax
    pop ds
    iret

; Function range: 0512:0173..033F (end exclusive), 460 bytes.
; FUNCTION: DONALD 0512:0173
; snd_music_tick: ES:SI traverses the tune, BX is its saved byte offset.
; Notes 00h..5Fh index the PIT-divisor table; high-bit bytes are commands.
snd_music_tick:
    cmp byte [cs:SND_OFFSET(snd_start_pending)], 0
    je short .check_playing
    mov byte [cs:SND_OFFSET(snd_playing)], 1
    mov byte [cs:SND_OFFSET(snd_read_note)], 1
    mov byte [cs:SND_OFFSET(snd_start_pending)], 0
    mov byte [cs:SND_OFFSET(snd_stop_pending)], 0
    mov ax, word [cs:SND_OFFSET(snd_pending_pointer.offset)]
    mov word [cs:SND_OFFSET(snd_stream_pointer.offset)], ax
    mov ax, word [cs:SND_OFFSET(snd_pending_pointer.segment)]
    mov word [cs:SND_OFFSET(snd_stream_pointer.segment)], ax
    mov word [cs:SND_OFFSET(snd_stream_position)], 0
.check_playing:
    cmp byte [cs:SND_OFFSET(snd_playing)], 0
    jne short .save_registers
    jmp near .return
.save_registers:
    push es
    push si
    push bx
    push dx
    mov bx, word [cs:SND_OFFSET(snd_stream_position)]
    cmp byte [cs:SND_OFFSET(snd_read_note)], 0
    jne short .load_stream
    jmp near .count_duration
.load_stream:
    mov es, word [cs:SND_OFFSET(snd_stream_pointer.segment)]
    mov si, word [cs:SND_OFFSET(snd_stream_pointer.offset)]
    rr add, si, bx
.read_command:
    mov al, byte [es:si]
    rr or, al, al
    js short .loop_1_end
    cmp al, SND_NOTE_COUNT - 1
    jle short .lookup_note
    jmp near .stop
.lookup_note:
    push di
    rr xor, ah, ah
    shl ax, 1
    rr mov, di, ax
    mov ax, word [cs:word di + SND_OFFSET(snd_note_divisors)] ; retain TASM's disp16
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
    mul byte [cs:SND_OFFSET(snd_duration_scale)]
    dec ax
    mov word [cs:SND_OFFSET(snd_duration_left)], ax
    inc si
    add bx, byte 2
    mov byte [cs:SND_OFFSET(snd_read_note)], 0
    jmp near .save_position

.loop_1_end:                     ; CEh: decrement loop 1, then backtrack/skip
    cmp al, 0xce
    jne short .loop_1_set
    dec byte [cs:SND_OFFSET(snd_loop_count_1)]
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
    mov byte [cs:SND_OFFSET(snd_loop_count_1)], al
    inc si
    add bx, byte 2
    jmp near .read_command
.loop_2_end:                     ; D2h: second independent counted loop
    cmp al, 0xd2
    jne short .loop_2_set
    dec byte [cs:SND_OFFSET(snd_loop_count_2)]
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
    mov byte [cs:SND_OFFSET(snd_loop_count_2)], al
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
    mov byte [cs:SND_OFFSET(snd_duration_scale)], al
    inc si
    add bx, byte 2
    jmp near .read_command
.decrease_scale:                ; E8h: preserve the original OF/ZF tests
    cmp al, 0xe8
    jne short .increase_scale
    inc si
    mov al, byte [es:si]
    sub byte [cs:SND_OFFSET(snd_duration_scale)], al
    jno short .decrease_done
    jne short .decrease_done
    mov byte [cs:SND_OFFSET(snd_duration_scale)], 1
.decrease_done:
    inc si
    add bx, byte 2
    jmp near .read_command
.increase_scale:                ; E9h: add, using FFh on signed overflow
    cmp al, 0xe9
    jne short .end_command
    inc si
    mov al, byte [es:si]
    add byte [cs:SND_OFFSET(snd_duration_scale)], al
    jno short .increase_done
    mov byte [cs:SND_OFFSET(snd_duration_scale)], 0xff
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
    dec word [cs:SND_OFFSET(snd_duration_left)]
    jns short .check_stop
    cmp word [cs:SND_OFFSET(snd_duration_left)], byte -1
    je short .check_stop
    mov byte [cs:SND_OFFSET(snd_read_note)], 1
.check_stop:
    cmp byte [cs:SND_OFFSET(snd_stop_pending)], 0
    je short .save_position
.stop:
    mov byte [cs:SND_OFFSET(snd_playing)], 0
    mov byte [cs:SND_OFFSET(snd_stop_pending)], 0
    call snd_speaker_disable
.save_position:
    mov word [cs:SND_OFFSET(snd_stream_position)], bx
    pop dx
    pop bx
    pop si
    pop es
.return:
    ret

; Function range: 0512:033F..0346 (end exclusive), 7 bytes.
; FUNCTION: DONALD 0512:033F
; snd_speaker_enable: connect PIT channel 2 to the PC speaker.
snd_speaker_enable:
    in al, 0x61
    or al, 3
    out 0x61, al
    ret

; Function range: 0512:0346..034D (end exclusive), 7 bytes.
; FUNCTION: DONALD 0512:0346
; snd_speaker_disable: gate off the speaker and PIT channel 2.
snd_speaker_disable:
    in al, 0x61
    and al, 0xfc
    out 0x61, al
    ret

; Function range: 0512:034D..0354 (end exclusive), 7 bytes.
; FUNCTION: DONALD 0512:034D
; snd_program_divisor: send the low and high bytes of AX to PIT channel 2.
snd_program_divisor:
    out 0x42, al
    rr mov, al, ah
    out 0x42, al
    ret

; Function range: 0512:0354..0398 (end exclusive), 68 bytes.
; FUNCTION: DONALD 0512:0354
; snd_init: hooks int 8, PIT channel 0 at 1000h
snd_init:
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
    mov word [cs:SND_OFFSET(snd_old_timer_vector.offset)], bx
    mov word [cs:SND_OFFSET(snd_old_timer_vector.segment)], es
    mov word [cs:SND_OFFSET(snd_chain_reload)], 0xf
    mov word [cs:SND_OFFSET(snd_chain_count)], 0
    mov dx, SND_OFFSET(snd_timer_isr)
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

; Function range: 0512:0398..03CD (end exclusive), 53 bytes.
; FUNCTION: DONALD 0512:0398
; snd_shutdown: restores int 8 and the PIT, speaker off
snd_shutdown:
    push bp
    rr mov, bp, sp
    push di
    push si
    push ds
    mov ax, SND_TEXT  ; reloc
    mov ds, ax
    mov dx, word [cs:SND_OFFSET(snd_old_timer_vector.offset)]
    mov bx, word [cs:SND_OFFSET(snd_old_timer_vector.segment)]
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

; Function range: 0512:03CD..03F1 (end exclusive), 36 bytes.
; FUNCTION: DONALD 0512:03CD
; snd_play: starts a tune (far pointer to a byte stream)
snd_play:
    push bp
    rr mov, bp, sp
    push di
    push si
    push ds
    mov ax, SND_TEXT  ; reloc
    mov ds, ax
    mov ax, word [bp + 6]
    mov word [cs:SND_OFFSET(snd_pending_pointer.offset)], ax
    mov ax, word [bp + 8]
    mov word [cs:SND_OFFSET(snd_pending_pointer.segment)], ax
    mov byte [cs:SND_OFFSET(snd_start_pending)], 1
    pop ds
    pop si
    pop di
    pop bp
    retf

; Function range: 0512:03F1..0407 (end exclusive), 22 bytes.
; FUNCTION: DONALD 0512:03F1
; snd_stop: sets the stop flag
snd_stop:
    push bp
    rr mov, bp, sp
    push di
    push si
    push ds
    mov ax, SND_TEXT  ; reloc
    mov ds, ax
    mov byte [cs:SND_OFFSET(snd_stop_pending)], 1
    pop ds
    pop si
    pop di
    pop bp
    retf

; Function range: 0512:0407..0430 (end exclusive), 41 bytes.
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
    mov word [cs:SND_OFFSET(ctrlc_old_vector.offset)], bx
    mov word [cs:SND_OFFSET(ctrlc_old_vector.segment)], es
    mov dx, SND_OFFSET(ctrlc_isr)
    mov al, 0x23
    mov ah, 0x25
    int 0x21
    pop ds
    pop si
    pop di
    pop bp
    retf

; Function range: 0512:0430..043A (end exclusive), 10 bytes.
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

; Function range: 0512:043A..045C (end exclusive), 34 bytes.
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
    mov dx, word [cs:SND_OFFSET(ctrlc_old_vector.offset)]
    mov bx, word [cs:SND_OFFSET(ctrlc_old_vector.segment)]
    mov ds, bx
    mov al, 0x23
    mov ah, 0x25
    int 0x21
    pop ds
    pop si
    pop di
    pop bp
    retf

; Function range: 0512:045C..0485 (end exclusive), 41 bytes.
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
    mov word [cs:SND_OFFSET(kbbreak_old_vector.offset)], bx
    mov word [cs:SND_OFFSET(kbbreak_old_vector.segment)], es
    mov dx, SND_OFFSET(kbbreak_isr)
    mov al, 9
    mov ah, 0x25
    int 0x21
    pop ds
    pop si
    pop di
    pop bp
    retf

; Function range: 0512:0485..0522 (end exclusive), 157 bytes.
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
    mov byte [cs:SND_OFFSET(kbbreak_ctrl_down)], al
    jmp short .left_shift
    nop                         ; original short-jump padding
.ctrl_up:
    mov byte [cs:SND_OFFSET(kbbreak_ctrl_down)], 0
.left_shift:
    cmp al, 0x2a
    jne short .right_shift
    rr cmp, ah, al
    jne short .left_shift_up
    mov byte [cs:SND_OFFSET(kbbreak_left_shift_down)], al
    jmp short .right_shift
    nop
.left_shift_up:
    mov byte [cs:SND_OFFSET(kbbreak_left_shift_down)], 0
.right_shift:
    cmp al, 0x36
    jne short .ctrl_combinations
    rr cmp, ah, al
    jne short .right_shift_up
    mov byte [cs:SND_OFFSET(kbbreak_right_shift_down)], al
    jmp short .ctrl_combinations
    nop
.right_shift_up:
    mov byte [cs:SND_OFFSET(kbbreak_right_shift_down)], 0
.ctrl_combinations:
    test byte [cs:SND_OFFSET(kbbreak_ctrl_down)], 0xff
    je short .left_shift_combination
    cmp al, 0x45                 ; Ctrl-NumLock (pause)
    je short .swallow
    cmp al, 0x1f                 ; Ctrl-S
    je short .swallow
    cmp al, 0x2e                 ; Ctrl-C
    je short .swallow
.left_shift_combination:
    test byte [cs:SND_OFFSET(kbbreak_left_shift_down)], 0xff
    je short .right_shift_combination
    cmp al, 0x37                 ; Shift-PrintScreen
    je short .swallow
.right_shift_combination:
    test byte [cs:SND_OFFSET(kbbreak_right_shift_down)], 0xff
    je short .chain
    cmp al, 0x37
    je short .swallow
.chain:
    pop ax
    pop ds
    sti
    jmp far [cs:SND_OFFSET(kbbreak_old_vector)]
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

; Function range: 0512:0522..0544 (end exclusive), 34 bytes.
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
    mov dx, word [cs:SND_OFFSET(kbbreak_old_vector.offset)]
    mov bx, word [cs:SND_OFFSET(kbbreak_old_vector.segment)]
    mov ds, bx
    mov al, 9
    mov ah, 0x25
    int 0x21
    pop ds
    pop si
    pop di
    pop bp
    retf

; Function range: 0512:0544..0558 (end exclusive), 20 bytes.
; FUNCTION: DONALD 0512:0544
; timer_ticks: tick counter maintained by the int 8 handler
timer_ticks:
    push bp
    rr mov, bp, sp
    push di
    push si
    push ds
    mov ax, SND_TEXT  ; reloc
    mov ds, ax
    mov ax, word [cs:SND_OFFSET(snd_ticks)]
    pop ds
    pop si
    pop di
    pop bp
    retf

snd_module_end:
