
# Add numbers and parameter stack

top: run

dump: _build _build/kernel.img
	xxd _build/kernel.img

run: _build _build/disk.img
	qemu-system-i386 -hda _build/disk.img

units = bootloader kernel
images = $(patsubst %, _build/%.img, $(units))

_build/disk.img: $(images)
	@echo Creating disk image
	@cat $^ > $@

_build/%.img: %.asm Makefile
	@echo Assembling $<
	@nasm -o $@ $<

_build: ; @mkdir -p $@
