
# Add numbers and parameter stack

top: _build run

dump: _build _build/kernel.img
	xxd _build/kernel.img

run: _build/disk.img
	@echo Runing QEMU
	@#qemu-system-i386 -hda _build/disk.img
	@#qemu-system-i386 -drive index=0,media=disk,format=raw,file=$<
	@qemu-system-i386 -drive format=raw,file=$<


units = bootloader kernel
images = $(patsubst %, _build/%.img, $(units))

_build/disk.img: $(images)
	@echo Creating disk image
	@cat $^ > $@

_build/%.img: %.asm builtin.forth Makefile
	@echo Assembling $<
	@nasm -o $@ $<

_build: ; @mkdir -p $@
