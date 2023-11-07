
default = full

build: build-$(default)
run: run-$(default)

build-%: _build _build/disk-%.img
	@ echo -n

run-%: _build _build/disk-%.img
	@ echo 'Runing QEMU'
	@ bash -c 'qemu-system-i386 -hda _build/disk-$*.img -ctrl-grab > /dev/null 2>& 1'

.PRECIOUS:_build/disk-%.img
_build/disk-%.img: _build/bootloader.img _build/kernel-%.img
	@ echo 'Creating disk image: $@'
	@ cat $^ > $@ || rm -f $@

NASM_FLAGS = -Werror

_build/bootloader.img: x86/bootloader.asm x86/layout.asm
	@ echo 'Assembling $<'
	@ nasm $(NASM_FLAGS) -o $@ $< || rm -f $@

.PRECIOUS:_build/kernel-%.img
_build/kernel-%.img: x86/kernel.asm x86/layout.asm _build/%.f
	@ echo 'Assembling $< ($*)'
	@ nasm $(NASM_FLAGS) -o $@ $< -dFORTH="'_build/$*.f'" || rm -f $@


.PRECIOUS:_build/%.f
_build/%.f : %.list $(wildcard f/*)
	@ echo 'Combining Forth files: $<'
	@ bash -c 'cat $< | sed s/#.*// | xargs cat > $@' || rm -f $@

_build: ; @mkdir -p $@

burn-%: _build/disk-%.img
	dd if=$< of=/dev/sdb
