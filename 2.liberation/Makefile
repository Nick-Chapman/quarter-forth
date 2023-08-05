
# hello world in boot sector

top: run

dump: hello.img
	xxd hello.img

run: hello.img
	qemu-system-i386 -hda hello.img

hello.img: hello.asm
	nasm hello.asm -Werror -o hello.img || rm hello.img
