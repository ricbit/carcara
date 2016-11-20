; Carcara Fast BASIC 
; by Ricardo Bittencourt 2016

        output  fastbasic.bin

        org     0C800h - 7

; --------------------------------------------------------------------------
; BIOS calls and variables.

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
int_to_single   equ     02FCBh
dac_to_stack    equ     02EB1h
single_multiply equ     0325Ch

; --------------------------------------------------------------------------
; ROM header and start code.

        db      0FEh
        dw      start
        dw      program_end
        dw      start

start:
        ld      ix, hook_hntpl
        ld      (ix+0), 0C3h
        ld      (ix+1), low hook_handler
        ld      (ix+2), high hook_handler
        ret

hook_handler:
        ; Check for multiplication
        cp      07Ch
        ret     nz
        ; Check for integer operand
        ld      b, a
        ld      a, (valtyp)
        cp      2
        ld      a, b
        ret     nz
        ; Eat away return address
        pop     bc

        ; Push values
        ld      hl, (dac+2)
        push    hl
        ld      hl, 0202h
        push    hl
        ld      hl, apply_operator
        push    hl

        ; Return directly to next token evaluation
        ld      hl, (basic_temp3)
        jp      next_token

apply_operator:
        ; Is operand integer?
        ld      a, (valtyp)
        cp      2
        jp      nz, 04D22h
        ; Get operands
        ld      hl, (dac+2)
        pop     de
        pop     bc
        ; Save operands in case of overflow
        push    hl
        push    bc
        ; Save sign of result
        ld      a, h
        xor     b
        ex      af, af
        ; Take absolute value of operand 1
        bit     7, h
        jr      z, 1f
        ld      de, hl
        or      a
        sbc     hl, hl
        sbc     hl, de
1:
        ; Take absolute value of operand 2
        bit     7, b
        jr      z, 1f
        ex      de, hl
        or      a
        sbc     hl, hl
        sbc     hl, bc
        ld      bc, hl
        ex      de, hl
1:
        ; Multiply
        muluw   hl, bc
        ; Overflow? (ans>=0x8000?)
        ld      a, 080h
        and     h
        or      d
        or      e
        jr      nz, overflow
        ; Restore sign of result
        ex      af, af
        rlca
        jr      nc, 1f
        ex      de, hl
        or      a
        sbc     hl, hl
        sbc     hl, de
1:
        ; Clean stack, place result in DAC and return
        pop     bc
        pop     bc
        ld      (dac+2), hl
        ret
overflow:
        ; Promote to single
        pop     hl
        call    int_to_single
        pop     hl
        call    dac_to_stack
        call    int_to_single
        pop     bc
        pop     de
        jp      single_multiply

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
        ret     p
        ; Slot is extended
        ld      c, a
        inc     hl
        inc     hl
        inc     hl
        inc     hl
        ld      a, (hl)
        and     1100b
        or      c
        ret

savesign:       db      0

program_end:
        end


