
run: buckle.exe
	./buckle.exe ; echo $$?

buckle.exe: buckle.o
	ld -o buckle.exe buckle.o

buckle.o: buckle.asm
	nasm -f elf64 buckle.asm
