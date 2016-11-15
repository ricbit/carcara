; Fast BASIC using GR8NET.
; by Ricardo Bittencourt 2016

        output  fastbasic.rom

        org     04000h

; --------------------------------------------------------------------------
; BIOS calls and variables.

bdos_call       equ     0F37Dh
rslreg          equ     00138h
exptbl          equ     0FCC1h
enaslt          equ     00024h
stktop          equ     0F674h
chgcpu          equ     00180h
hook_hntpl      equ     0FF6Bh
next_token      equ     04C67h
dac             equ     0F7F6h
basic_temp3     equ     0F69Dh
infix_eval      equ     04D22h
valtyp          equ     0F663h

; --------------------------------------------------------------------------
; ROM header and start code.

        db      41h, 42h
        dw      start
        align   16

start:
        call    whereami
        ret

whereami:
        ; Where am I
        call    rslreg
        rrca
        rrca
        and     3
        ld      c, a
        ld      b ,0
        ld      hl, exptbl
        add     hl, bc
        or      (hl)
        jp      p, 1f
        ; Slot is extended
        ld      c, a
        inc     hl
        inc     hl
        inc     hl
        inc     hl
        ld      a, (hl)
        and     1100b
        or      c
1:
        ld      ix, hook_hntpl
        ld      (ix+0), 0F7h
        ld      (ix+1), a
        ld      (ix+2), low hook_handler
        ld      (ix+3), high hook_handler
        ld      (ix+4), 0C9h
        ret

hook_handler:
        ; check stage
        ld      hl, 7
        add     hl, sp
        bit     6, (hl)
        jr      z, apply_operator
        ; check for multiplication
        cp      07Ch
        ret     nz
        ld      b, a
        ld      a, (valtyp)
        cp      2
        ld      a, b
        ret     nz
        ; eat away the return address
        exx
        pop     hl
        pop     de
        pop     bc
        exx
        pop     bc

        ; push values
        ld      hl, (dac+2)
        push    hl
        ld      hl, 0202h
        push    hl
        ;ld      hl, hook_hntpl
        ld      hl, 04D22h
        push    hl
        ld      hl, (basic_temp3)
        ; return directly to next token evaluation
        ld      bc, next_token
        push    bc
        exx
        push    bc
        push    de
        push    hl
        exx
        ret

apply_operator:
        ret

        align   04000h
        end


