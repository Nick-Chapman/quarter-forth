
    %include "layout.asm"
    bootloader_address equ 0x7c00
    bits 16
    org bootloader_address

    jmp start
    times 0x3e - ($ - $$) db 0x00 ; skip FAT headers

start:
    mov ax, 0
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0

    ;; Note. Sectors are numbered from 1. The bootloader (this file!) is in the 1st sector.
    ;; So the kernel starts at sector 2
    first_non_boot_sector equ 2

    mov ah, 0x02 ; Function: Read Sectors From Drive
    mov ch, 0 ; cylinder
    mov dh, 0 ; head
    mov al, kernel_size_in_sectors ; sector count
    mov cl, first_non_boot_sector ; start sector
    mov bx, kernel_load_address ; dest
    int 0x13

    mov ah, 0x02 ; Function: Read Sectors From Drive
    mov ch, 0 ; cylinder
    mov dh, 0 ; head
    mov al, embedded_size_in_sectors ; sector count
    mov cl, first_non_boot_sector + kernel_size_in_sectors ; start sector
    mov bx, embedded_load_address
    int 0x13

    jmp 0: kernel_load_address

    times 510 - ($ - $$) db 0xff
    dw 0xaa55
