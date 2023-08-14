
;;; TODO
;;; macro to push/pop specific register to param stack
;;; top of dict changing
;;; here, writing, : ;

BITS 16
org 0x500

    jmp start


%define lastlink 0

%macro defword 1
%%name: db %1
%%link: dw lastlink
db (%%link - %%name)
%define lastlink %%link
%endmacro


defword "hello"
    mov di, hello_msg
    call print_msg
    ret
hello_msg: db "{Hello there!}", 13, 0

defword "bye"
    mov di, bye_msg
    call print_msg
    ret
bye_msg: db "{Goodbye!}", 13, 0

defword "hey"
    mov di, hey_msg
    call print_msg
    ret
hey_msg: db "{Hey There!}", 13, 0

defword "+"
    call ps_pop_number
    mov bx, ax
    call ps_pop_number
    add ax, bx
    call ps_push_number
    ret

defword "-"
    call ps_pop_number
    mov bx, ax
    call ps_pop_number
    sub ax, bx
    call ps_push_number
    ret

defword "*"
    call ps_pop_number
    mov bx, ax
    call ps_pop_number
    mul bx ; implict ax
    call ps_push_number
    ret

defword "."
    call ps_pop_number
    call print_number
    call newline
    ret

defword "dup"
    call ps_pop_number
    call ps_push_number
    call ps_push_number
    ret

defword "swap"
    call ps_pop_number
    push ax
    call ps_pop_number
    mov bx, ax
    pop ax
    call ps_push_number
    mov ax, bx
    call ps_push_number
    ret



dictionary equ lastlink


;;; Register Usage
;;; BP - Parameter Stack

;;; Push number(anything) on parameter stack
;;; [in AX=number]
ps_push_number:
    sub bp, 2
    mov [bp], ax
    ret

;;; Pop number(anything) from parameter stack
;;; [out AX=number]
ps_pop_number:
    mov ax, [bp]
    add bp, 2
    ret


start:
    mov bp, 0xf800 ; why here?
    call cls
.loop:
    call read_word

    mov dx, buffer
    call try_parse_as_number
    jnz .nan
    call ps_push_number
    jmp .loop

.nan:
    mov dx, buffer
    call dictfind

    cmp bx, 0
    jz .notfound
    ;; execute code at bx+3
    add bx, 3
    call bx
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
.msg:  db "{NOPE}", 13, 0


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
;;; [in DX=sought-name, out BX=entry/0]
;;; [uses SI, DI, BX, CX]
dictfind:
    mov di, dx
    call strlen ; ax=len
    mov bx, dictionary
.loop:
    cmp al, [bx+2] ; hmm, 8bit length comapre
    jnz .next
    ;; length matches; compare names
    mov si, dx ; si=sought name
    mov di, bx
    sub di, ax ; di=this entry name
    mov cx, ax ; length
    push ax
    call cmp_n
    pop ax
    jnz .next
    ret ; BX=entry
.next:
    mov bx, [bx] ; traverse link
    cmp bx, 0
    jnz .loop
    ret ; BX=0 - not found

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
    ret ; Z - matches
.ret:
    ret ; NZ - diff

;;; Compute length of a null-terminated string
;;; [in DI=string; out AX=length]
;;; [consumes DI; uses BL]
strlen:
    mov ax, 0
.loop:
    mov bl, [di]
    cmp bl, 0
    jz .ret
    inc ax
    inc di
    jmp .loop
.ret:
    ret

;;; Read word from keyboard into buffer memory
;;; [uses AX,DI]
read_word:
    mov di, buffer
.skip:
    call [read_char]
    call write_char ; echo
    cmp al, 0x21
    jb .skip ; skip leading white-space
.loop:
    cmp al, 0x21
    jb .done ; stop at white-space
    mov [di], al
    inc di
    call [read_char]
    call write_char ; echo
    jmp .loop
.done:
    mov byte [di], 0 ; add null terminator
    ret

;;; Write char to output; special case 13 as 10(NL);13(CR)
;;; [in AL=char]
;;; [consumes AL; uses AH BH]
write_char: ; in AL
    cmp al, 13
    jz .nl_cr
    cmp al, 10
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


read_char: dw startup_read_char

startup_read_char:
    mov bx, [builtin]
    mov al, [bx]
    cmp al, 0
    jz .interactive
    inc word [builtin]
    ret
.interactive:
    mov word [read_char], interactive_read_char
    jmp interactive_read_char

builtin: dw builtin_data
builtin_data:
    incbin "builtin.forth"
    db 0

;;; Read char from input
;;; [out AL=char-read]
;;; [uses AX]
interactive_read_char:
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
