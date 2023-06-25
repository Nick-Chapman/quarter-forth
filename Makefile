
# hello world in boot sector
top: hello.img
	xxd hello.img

run: hello.img
	qemu-system-i386 -hda hello.img

hello.img: hello.asm
	nasm hello.asm -Werror -o hello.img || rm hello.img


# buckle up...
brun: buckle.exe
	./buckle.exe ; echo $$?

buckle.exe: buckle.o
	ld -o buckle.exe buckle.o

buckle.o: buckle.asm
	nasm -f elf64 buckle.asm
