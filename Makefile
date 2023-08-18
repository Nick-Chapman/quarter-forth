
top: _build run

dump: _build _build/kernel.img
	xxd _build/kernel.img

image: _build/disk.img

run: _build/disk.img
	@echo Runing QEMU
	@qemu-system-i386 -hda _build/disk.img

units = bootloader kernel
images = $(patsubst %, _build/%.img, $(units))

_build/disk.img: $(images)
	@echo Creating disk image
	@cat $^ > $@

_build/%.img: src/%.asm Makefile
	@echo Assembling $<
	@nasm -o $@ $<

_build/kernel.img : src/predefined.f src/regression.f

_build: ; @mkdir -p $@
