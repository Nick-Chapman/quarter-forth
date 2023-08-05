
# split bootloader + payload

top: dump

dump: _build _build/disk.img
	xxd _build/disk.img

run: _build _build/disk.img
	qemu-system-i386 -hda _build/disk.img

units = bootloader payload
images = $(patsubst %, _build/%.img, $(units))

_build/disk.img: $(images)
	@echo Creating disk image
	@cat $^ > $@

_build/%.img: %.asm Makefile
	@echo Assembling $<
	@nasm -o $@ $<

_build: ; @mkdir -p $@
