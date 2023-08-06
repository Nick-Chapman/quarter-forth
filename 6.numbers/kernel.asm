
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
.msg: db "{Hello there!}", 13, 0

bye:
.name: db "bye"
.link: dw hello.link ; previous
.size: db (.link - .name)
.code:
    mov di, .msg
    call print_msg
    ret
.msg: db "{Goodbye!}", 13, 0

dictionary equ bye.link ; last one


start:
    call cls
.loop:
    call read_word

    mov dx, buffer
    call try_parse_as_number
    jnz .nan

    call print_number
    call newline
    jmp .loop

.nan:
    mov dx, buffer
    call dictfind

    cmp bp, 0
    jz .notfound
    ;; execute code at bp+3
    add bp, 3
    call bp
    jmp .loop
.notfound:
    call print_nope
    jmp .loop


newline:
    mov al, 13
    call write_char
    ret

;;; [uses DI]]
print_nope:
    mov di, .msg
    call print_msg
    ret
.msg:  db "{NOPE}", 0


;;; Print a number in decimal
;;; [in AX=number]
;;; [uses BX, DX]
print_number:
    mov bx, 10
.nest:
    mov dx, 0
    div bx ; ax=ax/10; dx=ax%10
    cmp ax, 0 ; last digit?
    jz .print_digit ; YES, so print it
    ;; NO, deal with more significant digits first
    push dx
    call .nest
    pop dx
    ;; drop to print this one
.print_digit:
    push ax
    mov al, dl
    add al, '0'
    call write_char
    pop ax
    ret


;;; Try to parse a string as a number
;;; [in DX=string-to-be-tested, out Z=yes-number, AX=number]
;;; [uses BL, SI, BX, CX]
try_parse_as_number:
    mov si, dx
    mov ax, 0
    mov bh, 0
    mov cx, 10
.loop:
    mov bl, [si]
    cmp bl, 0 ; null
    jnz .continue
    ;; reached null-terminator; every char was a digit; return YES
    ret
.continue:
    mul cx ; [ax = ax*10]
    ;; current char is a digit?
    sub bl, '0'
    jc .no
    cmp bl, 10
    jnc .no
    ;; yes: accumulate digit
    add ax, bx
    inc si
    jmp .loop
.no:
    cmp bl, 0 ; return NO
    ret


;;; Lookup word in dictionary, return entry if found or 0 otherwise
;;; [in DX=sought-name, out BP=entry/0]
;;; [uses SI, DI, BX, CX]
dictfind:
    mov bp, dictionary
    mov di, dx
    call strlen ; cx=len
    mov bx, cx
.loop:
    cmp cl, [bp+2] ; hmm, 8bit length comapre
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

;;; Print message to output.
;;; [in DI=message(null terminated)]
;;; [consumes DI, uses AX]
print_msg:
.loop:
    mov al, [di]
    cmp al, 0 ; null?
    je .done
    call write_char
    inc di
    jmp .loop
.done:
    ret

;;; Compare n bytes at two pointers
;;; [in CX=n, SI/DI=pointers-to-things-to-compare, out Z=same]
;;; [consumes SI, DI, CX; uses AL]
cmp_n:
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

;;; Compute length of a null-terminated string
;;; [in DI=string; out CX=length]
;;; [consumes DI; uses AL]
strlen:
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

;;; Read word from keyboard into buffer memory
;;; [uses AX,BP]
read_word:
    mov bp, buffer
.skip:
    call read_char
    call write_char ; echo
    cmp al, 0x21
    jb .skip ; skip leading white-space
.loop:
    cmp al, 0x21
    jb .done ; stop at white-space
    mov [bp], al
    inc bp
    call read_char
    call write_char ; echo
    jmp .loop
.done:
    mov byte [bp], 0 ; add null terminator
    ret

;;; Write char to output; special case 13 as 10(NL);13(CR)
;;; [in AL=char]
;;; [consumes AL; uses AH BH]
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

;;; Read char from input
;;; [out AL=char-read]
;;; [uses AX]
read_char:
    mov ah, 0
    int 0x16
    ret

;;; Clear screen
;;; [uses AX]
cls:
    mov ax, 0x0003 ; AH=0 AL=3 video mode 80x25
    int 0x10
    ret


buffer:
