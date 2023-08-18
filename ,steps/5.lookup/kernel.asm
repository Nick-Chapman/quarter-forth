
BITS 16
org 0x500

    jmp start


hello:
.name: db "hello"
.link: dw 0 ; no more
.size: db (.link - .name)
.code:
    mov di, .msg
    call print_msg
    ret
.msg: db "Hello there!", 13, 0


bye:
.name: db "bye"
.link: dw hello.link ; previous
.size: db (.link - .name)
.code:
    mov di, .msg
    call print_msg
    ret
.msg: db "Goodbye!", 13, 0

dictionary equ bye.link ; last one


start:
    call cls
.loop:
    call read_word
    mov dx, buffer
    call dictfind
    cmp bp, 0
    jz .notfound
    ;; execute code at bp+3
    add bp, 3
    call bp
    jmp .loop
.notfound:
    mov di, .notfound_msg
    call print_msg
    jmp .loop
.notfound_msg:  db '{nope!}', 13, 0


dictfind: ; in: dx=name,  out: bp=entry/0
    mov bp, dictionary
    mov di, dx
    call strlen ; cx=len
    mov bx, cx
.loop:
    cmp bl, [bp+2] ; hmm, 8bit length comapre
    jnz .skip
    ;; length matches; compare names
    mov si, dx ; sought name
    mov di, bp
    sub di, cx ; this entry name
    mov cx, bx ; length
    call cmp_n
    jz .ret
.skip:
    mov bp, [bp] ; traverse link
    cmp bp, 0
    jnz .loop
.ret:
    ret


print_msg: ; in: di=null-terminated-string
.loop:
    mov al, [di]
    cmp al, 0 ; stop at null terminator
    je .done
    call write_char
    inc di
    jmp .loop
.done:
    ret

cmp_n: ; compare n(in cx) bytes at *si and *di (flag set if same)
.loop:
    mov al, [si]
    cmp al, [di]
    jnz .ret
    inc si
    inc di
    dec cx
    jnz .loop
    ret
.ret:
    ret


strlen: ; in: di=null-terminated-string, out: cx=len
    mov cx, 0
.loop:
    mov al, [di]
    cmp al, 0
    jz .ret
    inc cx
    inc di
    jmp .loop
.ret:
    ret


read_word: ; into buffer
    mov bp, buffer
.skip:
    call read_char
    call write_char ; echo
    cmp al, 0x21
    jb .skip ; skip white
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
    cmp al, 13
    jz .nl_cr
.raw:
    mov ah, 0x0e ; Function: Teletype output
    mov bh, 0
    int 0x10
    ret
.nl_cr:
    mov al, 10 ; NL
    call .raw
    mov al, 13 ; CR
    jmp .raw


read_char: ; into AL
    mov ah, 0
    int 0x16
    ret


cls:
    mov ax, 0x0003 ; AH=0 AL=3 video mode 80x25
    int 0x10
    ret


buffer:
