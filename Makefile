main : fastbasic.bin

fastbasic.bin : fastbasic.asm
	./sjasmplus fastbasic.asm -lst=fastbasic.lst

rom : fastbasic.bin
	cp fastbasic.bin disk/rbasic.bin
	./openmsx -machine Panasonic_FS-A1GT \
	-script fastbasic.tcl -diska disk

