
BITS 16
org 0x500

    jmp start

;;; Register Usage
;;; BP - Parameter Stack

;;; Push to parameter stack
%macro PUSH 1
    sub bp, 2
    mov [bp], %1
%endmacro

;;; Pop from parameter stack
%macro POP 1
    mov %1, [bp]
    add bp, 2
%endmacro


%define lastlink 0

%macro defword 1
%%name: db %1
%%link: dw lastlink
db (%%link - %%name)
%define lastlink %%link
%endmacro


%macro echo 1
    jmp %%after
%%message: db %1, 13, 0
%%after:
    mov di, %%message
    call print_msg
%endmacro


defword "hello"
    echo "{Hello!}"
    ret

defword "bye"
    echo "{Bye!}"
    ret

defword "hey"
    echo "{Hey!}"
    ret


defword "+"
    POP bx
    POP ax
    add ax, bx
    PUSH ax
    ret

defword "-"
    POP bx
    POP ax
    sub ax, bx
    PUSH ax
    ret

defword "*"
    POP bx
    POP ax
    mul bx ; implict ax
    PUSH ax
    ret

defword "."
    POP ax
    call print_number
    call newline
    ret

defword "dup"
    POP ax
    PUSH ax
    PUSH ax
    ret

defword "swap"
    POP bx
    POP ax
    PUSH bx
    PUSH ax
    ret

defword ":"
    jmp colon_intepreter


dictionary: dw lastlink


start:
    mov bp, 0xf800 ; why here?
    call cls
.loop:
    call read_word

    mov dx, buffer
    call try_parse_as_number
    jnz .nan
    PUSH ax
    jmp .loop

.nan:
    mov dx, buffer
    call dictfind

    cmp bx, 0
    jz .missing
    ;; execute code at bx+3
    add bx, 3
    call bx
    jmp .loop
.missing:
    echo "{Nope}"
    jmp .loop

newline:
    mov al, 13
    call write_char
    ret



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
    mov bx, [dictionary]
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


colon_intepreter:
    call read_word
    mov di, buffer
    call create_entry
.loop:
    call read_word
    mov dx, buffer
    mov di, dx

    call is_semi
    jz .semi

    call dictfind
    cmp bx, 0
    jz .missing

    add bx, 3
    mov ax, bx
    call write_call
    jmp .loop

.semi:
    ;echo "{SEMI!}"
    call write_ret
    ret

.missing:
    echo "{Nope}"
    jmp .loop

is_semi:
    cmp word [di], ";"
    ret

;;; Create dictionary entry for new word, in DI=word-name, uses BX
create_entry:
    push di
    call strlen ; -> AX
    pop di

    push ax ; save length
    call write_string

    mov ax, [dictionary]
    mov bx, [here]
    mov [dictionary], bx
    call write_word16 ; link

    pop ax ; restore length
    call write_byte
    ret


;;; Write string to [here], in DI=string, AX=length, consumes DI; use CX
write_string:
    mov cx, ax
.loop:
    cmp cx, 0
    jz .done
    mov ax, [di]
    call write_byte
    inc di
    dec cx
    jmp .loop
.done:
    ret

;;; in AX=absolute-address-to-call
write_call:
    push ax
    mov al, 0xe8 ; x86 encoding for "call"
    call write_byte
    pop ax
    sub ax, [here]
    sub ax, 2
    call write_word16
    ret

write_ret:
    mov al, 0xc3 ; x86 encoding for "ret"
    call write_byte
    ret

;;; Write byte to [here], in AL=byte, uses BX
write_byte:
    mov bx, [here]
    mov [bx], al
    inc word [here]
    ret

;;; Write word16 to [here], in AX=word16, uses BX
write_word16:
    mov bx, [here]
    mov [bx], ax
    add word [here], 2
    ret


buffer: times 64 db 0

here: dw here_start
here_start: