
image: _build _build/disk.img

dump: _build _build/kernel.img
	xxd _build/kernel.img

run: _build _build/disk.img
	@echo Runing QEMU
	@bash -c 'qemu-system-i386 -hda _build/disk.img -ctrl-grab > /dev/null 2>& 1'

_build/disk.img: _build/bootloader.img _build/kernel.img
	@echo Creating disk image
	@cat $^ > $@

NASM_FLAGS = -Werror

_build/%.img: %.asm Makefile layout.asm
	@echo Assembling $<
	@nasm $(NASM_FLAGS) -o $@ $< || rm -f $@

_build/kernel.img : _build/forth.f

_build/forth.f : forth.list $(wildcard f/*)
	@echo Combining Forth files
	@bash -c 'cat $< | sed s/#.*// | xargs cat > $@' || rm -f $@

_build: ; @mkdir -p $@

burn: _build/disk.img
	dd if=$< of=/dev/sdb
