BITS 16
org 0x7c00

start:
    mov ax, 0
    mov es, ax ;cant set es to literal

    mov ah, 0x13 ;write string
    mov al, 1 ;write mode: update cursor
    mov bp, msg ; message
    mov cx, (msg_end - msg) ;number of chars
    mov bl, 0xe ;colour: yellow
    mov bh, 0 ;page number? must be 0?
    mov dh, 8 ;row
    mov dl, 1 ;column

    int 0x10
loop:
    jmp loop

msg:
    db "Hello World!"
msg_end:

    times 510 - ($ - $$) db 0xff
    dw 0xaa55
