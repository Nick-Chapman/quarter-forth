
    BITS 16

org 0x7c00

start:
    mov ax, 0
    mov es, ax ; cant set es to literal

    mov ah, 0x02 ; Function: Read Sectros From Drive
    mov al, 2 ; sector count
    mov ch, 0 ; cylinder
    mov cl, 2 ; sector
    mov dh, 0 ; head
    mov bx, 0x500 ; destination address
    int 0x13
    jmp 0:0x500

    times 510 - ($ - $$) db 0xff
    dw 0xaa55
