main : fastbasic.rom

fastbasic.rom : fastbasic.asm
	./sjasmplus fastbasic.asm -lst=fastbasic.lst

rom : fastbasic.rom
	./openmsx -machine Panasonic_FS-A1GT fastbasic.rom \
	-script fastbasic.tcl -diska disk

