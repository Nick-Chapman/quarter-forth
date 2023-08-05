
# split bootloader + payload

top: dump

dump: disk.img
	xxd disk.img

run: disk.img
	qemu-system-i386 -hda disk.img

units = bootloader payload # $(patsubst %.asm, %, $(wildcard *.asm))

images = $(patsubst %, %.img, $(units))

disk.img: $(images)
	@echo Creating disk image
	@cat $^ > $@

%.img: %.asm Makefile
	@echo Assembling $<
	@nasm -o $@ $<
