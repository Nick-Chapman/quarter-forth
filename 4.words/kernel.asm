
BITS 16
org 0x500

start:
    call cls
.loop:
    call read_word
    call write_word
    jmp .loop

write_word: ; at buffer (adding square brackets)
    mov bp, buffer
    mov al, '['
    call write_char
.loop:
    mov al, [bp]
    cmp al, 0 ; stop at null terminator
    je .done
    call write_char
    inc bp
    jmp .loop
.done:
    mov al, ']'
    call write_char
    ret

read_word: ; into buffer
    mov bp, buffer
.skip:
    call read_char
    call write_char ; echo
    cmp al, 0x21
    jb .skip ; skip whitespace
.loop:
    cmp al, 0x21
    jb .done ; if white
    mov [bp], al
    inc bp
    call read_char
    call write_char ; echo
    jmp .loop
.done:
    mov byte [bp], 0 ; add null terminator
    ret

write_char: ; in AL
    mov ah, 0x0e ; Function: Teletype output
    mov bh, 0
    int 0x10
    ret

read_char: ; into AL
    mov ah, 0
    int 0x16
    ret

cls:
    mov ax, 0x0003 ; AH=0 AL=3 video mode 80x25
    int 0x10
    ret

buffer:
