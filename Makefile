main : carcara.bin

carcara.bin : carcara.asm
	./sjasmplus carcara.asm -lst=carcara.lst

rom : carcara.bin
	cp carcara.bin disk/carcara.bin
	./openmsx -machine Panasonic_FS-A1GT \
	-script carcara.tcl -diska disk

