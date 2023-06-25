
section .text
    global _start
foo:
    add ebx, eax
    ret
_start:
    mov eax, 42
    mov ebx, 13
    call foo
    mov eax, 1
    int 0x80
