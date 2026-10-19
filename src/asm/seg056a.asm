; Module 056A: hand-written keyboard interrupt assembly.
; SEGMENT: DONALD 056A 0000-058B (alternate paragraph bias: 8 bytes).
; A queue entry is a word: translated key number in AL, Shift/Ctrl/Alt in AH.
bits 16
%include "tasm.inc"

; These are literal CS-relative offsets in the original TASM object. Subtract
; our module base so NASM does not add an OMF offset fixup. Only the alternate
; executable places this module eight bytes into its paragraph.
%ifdef DONALD_ALT
KBD_PARAGRAPH_BIAS equ 8
%else
KBD_PARAGRAPH_BIAS equ 0
%endif
%define KBD_CSO(object) ((object - kbd_text_base) + KBD_PARAGRAPH_BIAS)
%define KBD_DSO(object) (object - kbd_data_base)
%define KBD_KEY_BIT(key) (1 << ((key) & 7))

KBD_MOD_SHIFT equ 0x0100
KBD_MOD_CTRL  equ 0x0200
KBD_MOD_ALT   equ 0x0400
KBD_LOCK_CAPS equ 1
KBD_LOCK_NUM  equ 2

; Policy bits consumed by IRQ1, including the per-key BIOS chaining table.
KBD_ALLOW_REPEAT          equ 0x0001
KBD_DISTINCT_E0_KEYS      equ 0x0002
KBD_CHAIN_DEFAULT        equ 0x0004
KBD_CHAIN_CTRL_S         equ 0x0008
KBD_CHAIN_CTRL_ALT_ADJUST equ 0x0010
KBD_CHAIN_CTRL_C         equ 0x0020
KBD_CHAIN_SCROLL_LOCK    equ 0x0040
KBD_CHAIN_PAUSE          equ 0x0080
KBD_CHAIN_CTRL_BREAK     equ 0x0100

; Driver key numbers, not BIOS scan codes. E0 keys have distinct numbers until
; the compatibility translation is selected by clearing KBD_DISTINCT_E0_KEYS.
KEY_CTRL_BREAK  equ 0x00
KEY_MINUS       equ 0x0c
KEY_EQUALS      equ 0x0d
KEY_CAPS_LOCK   equ 0x1e
KEY_S           equ 0x20
KEY_ENTER       equ 0x2b
KEY_LEFT_SHIFT  equ 0x2c
KEY_C           equ 0x30
KEY_SLASH       equ 0x37
KEY_RIGHT_SHIFT equ 0x39
KEY_LEFT_CTRL   equ 0x3a
KEY_LEFT_ALT    equ 0x3c
KEY_RIGHT_ALT   equ 0x3e
KEY_RIGHT_CTRL  equ 0x40
KEY_INSERT      equ 0x4b
KEY_DELETE      equ 0x4c
KEY_LEFT        equ 0x4f
KEY_HOME        equ 0x50
KEY_END         equ 0x51
KEY_UP          equ 0x53
KEY_DOWN        equ 0x54
KEY_PAGE_UP     equ 0x55
KEY_PAGE_DOWN   equ 0x56
KEY_RIGHT       equ 0x59
KEY_NUM_LOCK    equ 0x5a
KEY_KP_HOME     equ 0x5b
KEY_KP_LEFT     equ 0x5c
KEY_KP_END      equ 0x5d
KEY_KP_DIVIDE   equ 0x5f
KEY_KP_UP       equ 0x60
KEY_KP_DOWN     equ 0x62
KEY_KP_INSERT   equ 0x63
KEY_KP_PAGE_UP  equ 0x65
KEY_KP_RIGHT    equ 0x66
KEY_KP_PAGE_DOWN equ 0x67
KEY_KP_DELETE   equ 0x68
KEY_KP_MINUS    equ 0x69
KEY_KP_PLUS     equ 0x6a
KEY_KP_ENTER    equ 0x6c
KEY_ESCAPE      equ 0x6e
KEY_PRINT_SCREEN equ 0x7c
KEY_SCROLL_LOCK equ 0x7d
KEY_INVALID     equ 0x7f

KBD_BITMAP_BYTES equ 16       ; 128 translated-key bits, indexed key >> 3
KBD_QUEUE_WORDS  equ 64       ; ring keeps one slot empty: 63 queued presses
KBD_QUEUE_BYTES  equ KBD_QUEUE_WORDS * 2
KBD_QUEUE_MASK   equ KBD_QUEUE_BYTES - 1
KBD_SCAN_RELEASE equ 0x80
KBD_SCAN_E0      equ 0xe0
KBD_SCAN_E1      equ 0xe1
BIOS_DATA_SEGMENT equ 0x40
BIOS_SHIFT_FLAGS equ 0x17
BIOS_LEFT_MODIFIERS equ 0x18
BIOS_ENHANCED_FLAGS equ 0x96

segment KBD_TEXT public align=1 class=CODE use16
kbd_text_base:

global _kbd_hit
_kbd_hit equ kbd_hit
global _kbd_flush
_kbd_flush equ kbd_flush
global _kbd_getcode
_kbd_getcode equ kbd_getcode
global _kbd_getchar
_kbd_getchar equ kbd_getchar
global _kbd_install
_kbd_install equ kbd_install
global _kbd_remove
_kbd_remove equ kbd_remove

; 0000-0007: byte masks for the bit number (key & 7), used by getchar.
kbd_bit_masks:
    db 1, 2, 4, 8, 16, 32, 64, 128
kbd_bit_masks_end:

; 0008-0021: 13 packed key/modifier words; 0022-003B: parallel policy words.
; SCASW deliberately probes count+1 words. Its rejected terminal iteration
; reads the first policy word; it is not a fourteenth key or a separate sentinel.
kbd_bios_policy_keys:
    dw KEY_S | KBD_MOD_CTRL
    dw KEY_S | KBD_MOD_CTRL | KBD_MOD_SHIFT
    dw KEY_MINUS | KBD_MOD_CTRL | KBD_MOD_ALT
    dw KEY_EQUALS | KBD_MOD_CTRL | KBD_MOD_ALT | KBD_MOD_SHIFT
    dw KEY_KP_PLUS | KBD_MOD_CTRL | KBD_MOD_ALT
    dw KEY_KP_MINUS | KBD_MOD_CTRL | KBD_MOD_ALT
    dw KEY_C | KBD_MOD_CTRL
    dw KEY_C | KBD_MOD_CTRL | KBD_MOD_SHIFT
    dw KEY_SCROLL_LOCK
    dw KEY_SCROLL_LOCK | KBD_MOD_SHIFT
    dw KEY_NUM_LOCK | KBD_MOD_CTRL
    dw KEY_NUM_LOCK | KBD_MOD_CTRL | KBD_MOD_SHIFT
    dw KEY_CTRL_BREAK | KBD_MOD_CTRL
kbd_bios_policy_keys_end:
KBD_POLICY_KEY_COUNT equ (kbd_bios_policy_keys_end - kbd_bios_policy_keys) / 2
kbd_bios_policy_masks:
    dw KBD_CHAIN_CTRL_S, KBD_CHAIN_CTRL_S
    dw KBD_CHAIN_CTRL_ALT_ADJUST, KBD_CHAIN_CTRL_ALT_ADJUST
    dw KBD_CHAIN_CTRL_ALT_ADJUST, KBD_CHAIN_CTRL_ALT_ADJUST
    dw KBD_CHAIN_CTRL_C, KBD_CHAIN_CTRL_C
    dw KBD_CHAIN_SCROLL_LOCK, KBD_CHAIN_SCROLL_LOCK
    dw KBD_CHAIN_PAUSE, KBD_CHAIN_PAUSE
    dw KBD_CHAIN_CTRL_BREAK
kbd_bios_policy_masks_end:

; 003C-003F: optional far callback on Escape; checked by its segment word.
; This program leaves it null. CALL FAR [offset] proves the two-word layout.
kbd_escape_callback:
    .offset:  dw 0
    .segment: dw 0

; 0040-006F: parallel 16-byte arrays: E0 scan, distinct key, compatible key.
; SCASB probes 17 bytes, rejecting the final iteration which overlaps the first
; translated key. The original post-SCASB DI is one byte past the matching scan.
kbd_e0_scans:
    db 0x38, 0x1d, 0x52, 0x53, 0x4b, 0x47, 0x4f, 0x48
    db 0x50, 0x49, 0x51, 0x4d, 0x35, 0x1c, 0x37, 0x46
kbd_e0_scans_end:
KBD_E0_KEY_COUNT equ kbd_e0_scans_end - kbd_e0_scans
kbd_e0_distinct_keys:
    db KEY_RIGHT_ALT, KEY_RIGHT_CTRL, KEY_INSERT, KEY_DELETE
    db KEY_LEFT, KEY_HOME, KEY_END, KEY_UP
    db KEY_DOWN, KEY_PAGE_UP, KEY_PAGE_DOWN, KEY_RIGHT
    db KEY_KP_DIVIDE, KEY_KP_ENTER, KEY_PRINT_SCREEN, KEY_CTRL_BREAK
kbd_e0_distinct_keys_end:
kbd_e0_compatible_keys:
    db KEY_LEFT_ALT, KEY_LEFT_CTRL, KEY_KP_INSERT, KEY_KP_DELETE
    db KEY_KP_LEFT, KEY_KP_HOME, KEY_KP_END, KEY_KP_UP
    db KEY_KP_DOWN, KEY_KP_PAGE_UP, KEY_KP_PAGE_DOWN, KEY_KP_RIGHT
    db KEY_SLASH, KEY_ENTER, KEY_PRINT_SCREEN, KEY_CTRL_BREAK
kbd_e0_compatible_keys_end:

; 0070-00EF: ring of packed key/modifier words. Indices are byte offsets.
kbd_queue:
    times KBD_QUEUE_WORDS dw 0
kbd_queue_end:
kbd_queue_read_offset:           ; 00F0: advanced by getcode
    dw 0
kbd_queue_write_offset:          ; 00F2: advanced by IRQ1; flush copies read here
    dw 0
kbd_irq_policy:                  ; 00F4: IRQ-local snapshot of KBD_DATA policy
    dw KBD_CHAIN_CTRL_ALT_ADJUST | KBD_CHAIN_CTRL_BREAK
kbd_lock_flags:                  ; 00F6: bit 0 Caps Lock, bit 1 Num Lock
    dw 0

; 00F8-0150: 89 byte entries indexed directly by the non-E0 Set-1 scan code.
; Values are the driver key numbers used by all three bitmaps and ASCII tables.
; The original routine has no upper-bound check for scans above 58h.
kbd_scan_to_key:
    db 0x7f,0x6e,0x02,0x03,0x04,0x05,0x06,0x07 ; scans 00-07
    db 0x08,0x09,0x0a,0x0b,0x0c,0x0d,0x0f,0x10 ; scans 08-0F
    db 0x11,0x12,0x13,0x14,0x15,0x16,0x17,0x18 ; scans 10-17
    db 0x19,0x1a,0x1b,0x1c,0x2b,0x3a,0x1f,0x20 ; scans 18-1F
    db 0x21,0x22,0x23,0x24,0x25,0x26,0x27,0x28 ; scans 20-27
    db 0x29,0x01,0x2c,0x1d,0x2e,0x2f,0x30,0x31 ; scans 28-2F
    db 0x32,0x33,0x34,0x35,0x36,0x37,0x39,0x64 ; scans 30-37
    db 0x3c,0x3d,0x1e,0x70,0x71,0x72,0x73,0x74 ; scans 38-3F
    db 0x75,0x76,0x77,0x78,0x79,0x5a,0x7d,0x5b ; scans 40-47
    db 0x60,0x65,0x69,0x5c,0x61,0x66,0x6a,0x5d ; scans 48-4F
    db 0x62,0x67,0x63,0x68,0x7f,0x7f,0x7f,0x7a ; scans 50-57
    db 0x7b                                    ; scan 58 (F12)
kbd_scan_to_key_end:
KBD_SCAN_TABLE_BYTES equ kbd_scan_to_key_end - kbd_scan_to_key

; 0151-0160: set bits are exactly A-Z (driver codes 11-1A, 1F-27, 2E-34).
; getchar uses this for Ctrl-letter folding; IRQ1 tests it for Caps Lock.
kbd_letter_bitmap:
    db 0x00,0x00,0xfe,0x87,0xff,0xc0,0x1f,0x00
    times KBD_BITMAP_BYTES - 8 db 0
kbd_letter_bitmap_end:
; 0161-0170: numeric-pad navigation/digit keys affected by Num Lock.
; Set bits: 5B,5C,5D,60,61,62,63,65,66,67,68.
kbd_numlock_bitmap:
    times 11 db 0
    db 0x38,0xef,0x01,0x00,0x00
kbd_numlock_bitmap_end:
; 0171-0180: one make/break state bit for every translated key number.
kbd_pressed_keys:
    times KBD_BITMAP_BYTES db 0
kbd_pressed_keys_end:
kbd_e0_pending:                  ; 0181: next scan belongs to E0 sequence
    db 0
kbd_pause_bytes_remaining:       ; 0182: E1 sequence countdown
    db 0
kbd_previous_irq9:               ; 0183-0186: saved DOS vector (offset:segment)
    .offset:  dw 0
    .segment: dw 0
kbd_previous_int23:              ; 0187-018A: saved DOS Ctrl-Break vector
    .offset:  dw 0
    .segment: dw 0
; 018B-0193: modifiers/locks always chained to BIOS, then an impossible key.
kbd_bios_modifier_keys:
    db KEY_CAPS_LOCK, KEY_LEFT_SHIFT, KEY_RIGHT_SHIFT, KEY_LEFT_CTRL
    db KEY_LEFT_ALT, KEY_RIGHT_ALT, KEY_RIGHT_CTRL, KEY_NUM_LOCK
kbd_bios_modifier_keys_end:
kbd_modifier_scan_sentinel:
    db 0x80                     ; cannot be a translated 7-bit key
KBD_MODIFIER_SCAN_COUNT equ kbd_modifier_scan_sentinel + 1 - kbd_bios_modifier_keys

; FUNCTION: DONALD 056A:0194
; kbd_hit: nonzero when the queue has an unread key
kbd_hit:
    mov ax, word [cs:KBD_CSO(kbd_queue_read_offset)]
    xor ax, word [cs:KBD_CSO(kbd_queue_write_offset)]
    retf
kbd_hit_end:

; FUNCTION: DONALD 056A:019E
; kbd_flush: discard unread keys by moving write offset back to read offset
kbd_flush:
    push ax
    mov ax, word [cs:KBD_CSO(kbd_queue_read_offset)]
    mov word [cs:KBD_CSO(kbd_queue_write_offset)], ax
    pop ax
    retf
kbd_flush_end:

; FUNCTION: DONALD 056A:01A9
; kbd_getcode: wait for and pop a packed translated-key/modifier word
kbd_getcode:
    push di
.wait_for_key:
    mov ax, word [cs:KBD_CSO(kbd_queue_read_offset)]
    cmp ax, word [cs:KBD_CSO(kbd_queue_write_offset)]
    je short .wait_for_key
    rr mov, di, ax
    mov ax, word [cs:word di + KBD_CSO(kbd_queue)]  ; retain TASM disp16
    add di, 2
    and di, KBD_QUEUE_MASK
    mov word [cs:KBD_CSO(kbd_queue_read_offset)], di
    rr or, ax, ax
    pop di
    retf
kbd_getcode_end:

; FUNCTION: DONALD 056A:01CB
; kbd_getchar: translate the packed key to ASCII or a high-bit special code
kbd_getchar:
    push bx
    push cx
    push si
    call (seg kbd_getcode):kbd_getcode  ; reloc
    cmp al, KEY_ESCAPE
    je short .escape
    cmp al, KBD_ASCII_KEY_COUNT
    jae short .non_ascii
    rr mov, bx, ax
    and bx, 0x3f
    test ah, KBD_MOD_SHIFT >> 8
    jne short .shifted_ascii
    mov al, byte [cs:bx + KBD_CSO(kbd_ascii_unshifted)]
    jmp short .apply_control
    nop
.shifted_ascii:
    mov al, byte [cs:bx + KBD_CSO(kbd_ascii_shifted)]
.apply_control:
    test ah, KBD_MOD_CTRL >> 8
    je short .done
    rr mov, si, bx
    and si, 7
    mov cl, byte [cs:word si + KBD_CSO(kbd_bit_masks)]  ; retain TASM disp16
    shr bx, 1
    shr bx, 1
    shr bx, 1
    test byte [cs:bx + KBD_CSO(kbd_letter_bitmap)], cl
    je short .done
    and al, 0x1f
    jmp short .done
    nop
.non_ascii:
    or al, 0x80
    jmp short .done
    nop
.escape:
    mov al, 0x1b
.done:
    pop si
    pop cx
    pop bx
    retf
kbd_getchar_end:

; 021E-025B and 025C-0299: 62 byte ASCII entries, indexed by driver key.
; Zero means the key has no ASCII character. Only codes below 3Eh use these.
kbd_ascii_unshifted:
    db 0, '`', '1234567890-=', 0, 8, 9
    db 'qwertyuiop[]', 0x5c, 0, 'asdfghjkl;', 0x27, 0, 13, 0, 0
    db 'zxcvbnm,./', 0, 0, 0, 0, 0, ' '
kbd_ascii_unshifted_end:
kbd_ascii_shifted:
    db 0, '~', '!@#$%^&*()_+', 0, 8, 9
    db 'QWERTYUIOP{}|', 0, 'ASDFGHJKL:', 0x22, 0, 13, 0, 0
    db 'ZXCVBNM<>?', 0, 0, 0, 0, 0, ' '
kbd_ascii_shifted_end:
KBD_ASCII_KEY_COUNT equ kbd_ascii_unshifted_end - kbd_ascii_unshifted

; FUNCTION: DONALD 056A:029A
; kbd_install: hooks int 9 and int 23h
kbd_install:
    push ax
    push bx
    push ds
    push dx
    push es
    mov ax, BIOS_DATA_SEGMENT
    mov es, ax
    mov al, byte [es:BIOS_SHIFT_FLAGS]
    test al, 0x40
    je short .check_num_lock
    or word [cs:KBD_CSO(kbd_lock_flags)], KBD_LOCK_CAPS
.check_num_lock:
    test al, 0x20
    je short .check_left_shift
    or word [cs:KBD_CSO(kbd_lock_flags)], KBD_LOCK_NUM
.check_left_shift:
    test al, 2
    je short .read_other_modifiers
    or byte [cs:KBD_CSO(kbd_pressed_keys) + (KEY_LEFT_SHIFT >> 3)], KBD_KEY_BIT(KEY_LEFT_SHIFT)
.read_other_modifiers:
    and al, 1
    shl al, 1
    rr mov, ah, al
    mov al, byte [es:BIOS_LEFT_MODIFIERS]
    shl al, 1
    shl al, 1
    and al, 0xc
    rr or, ah, al
    mov al, byte [es:BIOS_ENHANCED_FLAGS]
    test al, 8
    je short .save_modifier_bits
    or ah, 0x40
.save_modifier_bits:
    mov byte [cs:KBD_CSO(kbd_pressed_keys) + (KEY_LEFT_CTRL >> 3)], ah
    test al, 4
    je short .check_e0_prefix
    or byte [cs:KBD_CSO(kbd_pressed_keys) + (KEY_RIGHT_CTRL >> 3)], KBD_KEY_BIT(KEY_RIGHT_CTRL)
.check_e0_prefix:
    test al, 2
    je short .check_pause_prefix
    mov byte [cs:KBD_CSO(kbd_e0_pending)], 1
.check_pause_prefix:
    test al, 1
    je short .install_vectors
    mov byte [cs:KBD_CSO(kbd_pause_bytes_remaining)], 2
.install_vectors:
    mov ax, 0x3509
    int 0x21
    mov word [cs:KBD_CSO(kbd_previous_irq9)], bx
    mov word [cs:KBD_CSO(kbd_previous_irq9.segment)], es
    mov bx, cs
    mov ds, bx
    mov dx, KBD_CSO(kbd_irq9)
    mov ax, 0x2509
    int 0x21
    mov ax, 0x3523
    int 0x21
    mov word [cs:KBD_CSO(kbd_previous_int23)], bx
    mov word [cs:KBD_CSO(kbd_previous_int23.segment)], es
    mov bx, cs
    mov ds, bx
    mov dx, KBD_CSO(kbd_ignore_ctrl_break)
    mov ax, 0x2523
    int 0x21
    pop es
    pop dx
    pop ds
    pop bx
    pop ax
    retf
kbd_install_end:

; FUNCTION: DONALD 056A:0342
; kbd_irq9: update key state and queue, then chain to BIOS or acknowledge IRQ1.
; KBD_CSO uses local label differences, preserving literal offsets without fixups.
; DX is kbd_bios_chain_policy; BL is zero for key releases.
kbd_irq9:
    push ax
    push bx
    push cx
    push di
    push ds
    push dx
    push es
    push si

    ; Refresh Caps Lock / Num Lock flags from the BIOS data area.
    and word [cs:KBD_CSO(kbd_lock_flags)], byte -4
    mov ax, BIOS_DATA_SEGMENT
    mov es, ax
    test byte [es:BIOS_SHIFT_FLAGS], 0x40
    je short .check_num_lock
    or word [cs:KBD_CSO(kbd_lock_flags)], KBD_LOCK_CAPS
.check_num_lock:
    test byte [es:BIOS_SHIFT_FLAGS], 0x20
    je short .read_policy
    or word [cs:KBD_CSO(kbd_lock_flags)], KBD_LOCK_NUM
.read_policy:
    mov ax, KBD_DATA             ; segment relocation
    mov ds, ax
    mov ax, word [KBD_DSO(kbd_bios_chain_policy)]
    mov word [cs:KBD_CSO(kbd_irq_policy)], ax
    mov dx, word [cs:KBD_CSO(kbd_irq_policy)]
    mov ax, cs
    mov ds, ax
    mov es, ax
    cld
    rr xor, ah, ah
    mov bx, 0x101
    in al, 0x60

    ; E1 starts a three-byte Pause subsequence; E0 marks an extended scan code.
    cmp al, KBD_SCAN_E1
    jne short .check_pause_sequence
    mov byte [cs:KBD_CSO(kbd_pause_bytes_remaining)], 3
.check_pause_sequence:
    cmp byte [cs:KBD_CSO(kbd_pause_bytes_remaining)], 0
    je short .check_extended_prefix
    dec byte [cs:KBD_CSO(kbd_pause_bytes_remaining)]
    test dx, KBD_CHAIN_PAUSE
    jne short .chain_prefix
    jmp near .acknowledge_irq
.check_extended_prefix:
    cmp al, KBD_SCAN_E0
    jne short .check_release
    mov byte [cs:KBD_CSO(kbd_e0_pending)], 1
.chain_prefix:
    jmp near .chain_bios
.check_release:
    test al, KBD_SCAN_RELEASE
    je short .translate_scan_code
    rr xor, bl, bl
    and al, 0x7f
.translate_scan_code:
    cmp byte [cs:KBD_CSO(kbd_e0_pending)], 0
    je short .translate_normal
    mov byte [cs:KBD_CSO(kbd_e0_pending)], 0
    mov byte [cs:KBD_CSO(kbd_extended_key)], 1
    mov di, KBD_CSO(kbd_e0_scans)
    mov cx, KBD_E0_KEY_COUNT + 1
    repne scasb
    mov al, byte [di + (kbd_e0_distinct_keys - kbd_e0_scans - 1)]
    rr or, cx, cx
    jne short .update_key_state
    mov byte [cs:KBD_CSO(kbd_extended_key)], 0
    jmp near .acknowledge_irq
.translate_normal:
    rr mov, di, ax
    mov al, byte [cs:di + KBD_CSO(kbd_scan_to_key)]
.update_key_state:
    ; Save the translation-table position and update the pressed-key bitmap.
    mov word [cs:KBD_CSO(kbd_translation_position)], di
    rr mov, di, ax
    shr di, 1
    shr di, 1
    shr di, 1
    rr mov, cl, al
    and cl, 7
    shl bl, cl
    shl bh, cl
    not bh
    mov cl, byte [cs:di + KBD_CSO(kbd_pressed_keys)]
    rr and, cl, bl
    and byte [cs:di + KBD_CSO(kbd_pressed_keys)], bh
    or byte [cs:di + KBD_CSO(kbd_pressed_keys)], bl

    ; Pack Ctrl, Alt and Shift into AH, alongside the translated key in AL.
    test byte [cs:KBD_CSO(kbd_pressed_keys) + (KEY_LEFT_CTRL >> 3)], KBD_KEY_BIT(KEY_LEFT_CTRL)
    jne short .set_ctrl
    test byte [cs:KBD_CSO(kbd_pressed_keys) + (KEY_RIGHT_CTRL >> 3)], KBD_KEY_BIT(KEY_RIGHT_CTRL)
    je short .check_alt
.set_ctrl:
    or ah, KBD_MOD_CTRL >> 8
.check_alt:
    test byte [cs:KBD_CSO(kbd_pressed_keys) + (KEY_LEFT_ALT >> 3)], KBD_KEY_BIT(KEY_LEFT_ALT) | KBD_KEY_BIT(KEY_RIGHT_ALT)
    je short .check_extended_translation
    or ah, KBD_MOD_ALT >> 8
.check_extended_translation:
    cmp byte [cs:KBD_CSO(kbd_extended_key)], 0
    je short .check_shift
    mov byte [cs:KBD_CSO(kbd_extended_key)], 0
    test dx, KBD_DISTINCT_E0_KEYS
    jne short .check_shift
    mov si, word [cs:KBD_CSO(kbd_translation_position)]
    mov al, byte [si + (kbd_e0_compatible_keys - kbd_e0_scans - 1)]
    ; Preserve the original signed absolute-address comparison (not an index).
    cmp si, 0x21
    jge short .check_repeat
.check_shift:
    test byte [cs:KBD_CSO(kbd_pressed_keys) + (KEY_LEFT_SHIFT >> 3)], KBD_KEY_BIT(KEY_LEFT_SHIFT)
    jne short .set_shift
    test byte [cs:KBD_CSO(kbd_pressed_keys) + (KEY_RIGHT_SHIFT >> 3)], KBD_KEY_BIT(KEY_RIGHT_SHIFT)
    je short .check_caps_lock
.set_shift:
    or ah, KBD_MOD_SHIFT >> 8
.check_caps_lock:
    test word [cs:KBD_CSO(kbd_lock_flags)], KBD_LOCK_CAPS
    je short .check_num_lock_translation
    ; Original code tests CH, which is not the bit mask calculated in BL/BH.
    ; Do not repair this behavior while recovering source.
    test byte [cs:di + KBD_CSO(kbd_letter_bitmap)], ch
    je short .check_num_lock_translation
    xor ah, KBD_MOD_SHIFT >> 8
.check_num_lock_translation:
    test word [cs:KBD_CSO(kbd_lock_flags)], KBD_LOCK_NUM
    je short .check_repeat
    test byte [cs:di + KBD_CSO(kbd_numlock_bitmap)], ch
    je short .check_repeat
    xor ah, KBD_MOD_SHIFT >> 8
.check_repeat:
    test dx, KBD_ALLOW_REPEAT
    jne short .check_ctrl_alt_delete
    rr or, cl, cl
    je short .check_ctrl_alt_delete
    jmp near .acknowledge_irq
.check_ctrl_alt_delete:
    cmp ax, KEY_KP_DELETE | KBD_MOD_CTRL | KBD_MOD_ALT
    je short .chain_special_key
    cmp ax, KEY_DELETE | KBD_MOD_CTRL | KBD_MOD_ALT
    jne short .queue_key_press
.chain_special_key:
    jmp short .chain_bios
    nop
.queue_key_press:
    rr or, bl, bl
    je short .chain_bios
    mov di, word [cs:KBD_CSO(kbd_queue_write_offset)]
    rr mov, si, di
    add di, 2
    and di, KBD_QUEUE_MASK
    cmp di, word [cs:KBD_CSO(kbd_queue_read_offset)]
    je short .check_special_keys
    ; Keep the original 16-bit displacement even when it fits in eight bits.
    mov word [cs:word si + KBD_CSO(kbd_queue)], ax
    mov word [cs:KBD_CSO(kbd_queue_write_offset)], di
.check_special_keys:
    mov di, KBD_CSO(kbd_bios_modifier_keys)
    mov cx, KBD_MODIFIER_SCAN_COUNT
    repne scasb
    rr or, cx, cx
    jne short .chain_bios
    cmp ax, KEY_S | KBD_MOD_CTRL
    je short .toggle_control_flag
    cmp ax, KEY_S | KBD_MOD_CTRL | KBD_MOD_SHIFT
    jne short .check_escape_callback
.toggle_control_flag:
    push ds
    push ax
    mov ax, KBD_DATA             ; segment relocation
    mov ds, ax
    xor word [KBD_DSO(kbd_ctrl_s_toggle)], 1
    pop ax
    pop ds
.check_escape_callback:
    cmp al, KEY_ESCAPE
    jne short .check_bios_policy
    cmp word [cs:KBD_CSO(kbd_escape_callback.segment)], 0
    je short .check_bios_policy
    call far [cs:KBD_CSO(kbd_escape_callback)]
.check_bios_policy:
    ; Look for a per-key policy mask before applying the default chain bit.
    mov di, KBD_CSO(kbd_bios_policy_keys)
    mov cx, (KBD_POLICY_KEY_COUNT + 1) * 2
    shr cx, 1
    repne scasw
    rr or, cx, cx
    je short .check_default_policy
    mov bx, word [di + (kbd_bios_policy_masks - kbd_bios_policy_keys - 2)]
    rr and, bx, dx
    jne short .chain_bios
    jmp short .acknowledge_irq
    nop
.check_default_policy:
    test dx, KBD_CHAIN_DEFAULT
    je short .acknowledge_irq
.chain_bios:
    ; The BIOS handler owns acknowledgement when this path is selected.
    pop si
    pop es
    pop dx
    pop ds
    pop di
    pop cx
    pop bx
    pop ax
    sti
    jmp far [cs:KBD_CSO(kbd_previous_irq9)]
.acknowledge_irq:
    ; Pulse the keyboard controller, clear the BIOS E0 flag, then send PIC EOI.
    in al, 0x61
    rr mov, ah, al
    or al, 0x80
    out 0x61, al
    xchg al, ah
    out 0x61, al
    mov ax, BIOS_DATA_SEGMENT
    mov es, ax
    mov al, byte [es:BIOS_ENHANCED_FLAGS]
    and al, 0xfd
    mov byte [es:BIOS_ENHANCED_FLAGS], al
    mov al, 0x20
    out 0x20, al
    pop si
    pop es
    pop dx
    pop ds
    pop di
    pop cx
    pop bx
    pop ax
    iret
kbd_irq9_end:

; ISR scratch state at 056A:055E-0560, not executable code.
kbd_extended_key:
    db 0
kbd_translation_position:
    dw 0

; FUNCTION: DONALD 056A:0561
; kbd_ignore_ctrl_break: installed as INT 23h to suppress DOS Ctrl-Break handling.
kbd_ignore_ctrl_break:
    iret
kbd_ignore_ctrl_break_end:

; FUNCTION: DONALD 056A:0562
; kbd_remove: restores int 9 and int 23h
kbd_remove:
    push ax
    push ds
    push dx
    mov dx, word [cs:KBD_CSO(kbd_previous_int23.segment)]
    mov ds, dx
    mov dx, word [cs:KBD_CSO(kbd_previous_int23)]
    mov ax, 0x2523
    int 0x21
    mov dx, word [cs:KBD_CSO(kbd_previous_irq9.segment)]
    mov ds, dx
    mov dx, word [cs:KBD_CSO(kbd_previous_irq9)]
    mov ax, 0x2509
    int 0x21
    pop dx
    pop ds
    pop ax
    retf

kbd_remove_end:
kbd_text_end:

segment KBD_DATA public align=16 class=DATA use16   ; frame 0CCD, after GFX_DATA
kbd_data_base:
; These first three bytes are the tail of the mode-3 mirrored-sprite workspace.
; That routine addresses them through GFX_DATA's paragraph frame: GFX:14E0
; aliases KBD_DATA:0000 and GFX:14E1 aliases KBD_DATA:0001. Preserve the alias.
m3_mirror_subpixel_shift:        ; byte, written 0; mode 3 does not read it
    db 0
m3_mirror_clip_columns:          ; unaligned word, clip_x2 - clip_x1
    dw 0
kbd_word_alignment_pad:          ; unreferenced byte before word variables
    db 0
kbd_ctrl_s_toggle:               ; word XORed with 1 on Ctrl-S / Ctrl-Shift-S
    dw 1
kbd_bios_chain_policy:           ; word read at every keyboard interrupt
    dw KBD_CHAIN_CTRL_ALT_ADJUST
kbd_data_end:
