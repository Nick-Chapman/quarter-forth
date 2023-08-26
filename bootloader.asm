
    BITS 16

org 0x7c00

    jmp start
    times 0x3e - ($ - $$) db 0x00 ; skip FAT headers

start:
    mov ax, 0
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0

    mov ah, 0x02 ; Function: Read Sectors From Drive
    mov al, 25 ; sector count (see size check at end of kernel.asm)
    mov ch, 0 ; cylinder
    mov cl, 2 ; sector
    mov dh, 0 ; head
    mov bx, 0x500 ; destination address
    int 0x13

    jmp 0:0x500

    times 510 - ($ - $$) db 0xff
    dw 0xaa55
