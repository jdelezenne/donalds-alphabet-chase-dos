; tasm.inc: encodings that TASM/MASM chose and NASM does not emit by itself.
; rr OP, dst, src  ->  the "reg, r/m" opcode form (8B/33/03/...), which TASM uses for register-register ops.
%define R16_ax 0
%define R16_cx 1
%define R16_dx 2
%define R16_bx 3
%define R16_sp 4
%define R16_bp 5
%define R16_si 6
%define R16_di 7
%define R8_al 0
%define R8_cl 1
%define R8_dl 2
%define R8_bl 3
%define R8_ah 4
%define R8_ch 5
%define R8_dh 6
%define R8_bh 7
%define OPW_add 0x03
%define OPW_or  0x0B
%define OPW_adc 0x13
%define OPW_sbb 0x1B
%define OPW_and 0x23
%define OPW_sub 0x2B
%define OPW_xor 0x33
%define OPW_cmp 0x3B
%define OPW_mov 0x8B
%define OPB_add 0x02
%define OPB_or  0x0A
%define OPB_adc 0x12
%define OPB_sbb 0x1A
%define OPB_and 0x22
%define OPB_sub 0x2A
%define OPB_xor 0x32
%define OPB_cmp 0x3A
%define OPB_mov 0x8A
%macro rr 3
%ifdef R16_%2
    db OPW_%1, 0xC0 | (R16_%2 << 3) | R16_%3
%else
    db OPB_%1, 0xC0 | (R8_%2 << 3) | R8_%3
%endif
%endmacro
