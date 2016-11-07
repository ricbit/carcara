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
        ret

        align   04000h
        end


