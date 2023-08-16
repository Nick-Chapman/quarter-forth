
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
    call print_string
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
    mul bx ; ax = ax*bx
    PUSH ax
    ret

defword "<"
    POP bx
    POP ax
    cmp ax, bx
    mov ax, 0xffff ; true
    jl isLess
    mov ax, 0 ; false
isLess:
    PUSH ax
    ret

defword "="
    POP bx
    POP ax
    cmp ax, bx
    mov ax, 0xffff ; true
    jz isEq
    mov ax, 0 ; false
isEq:
    PUSH ax
    ret

defword "."
    POP ax
    call print_number
    call print_newline
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


defword "if"
    echo "{IF}"
    ret

defword "then"
    echo "{THEN}"
    ret


dictionary: dw lastlink


start:
    mov bp, 0xf800 ; allows 2k for call stack
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



;;; Try to parse a string as a number
;;; [in DX=string-to-be-tested, out Z=yes-number, DX:AX=number]
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
    call print_char ; echo
    cmp al, 0x21
    jb .skip ; skip leading white-space
.loop:
    cmp al, 0x21
    jb .done ; stop at white-space
    mov [di], al
    inc di
    call [read_char]
    call print_char ; echo
    jmp .loop
.done:
    mov byte [di], 0 ; add null terminator
    ret


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
    ;incbin "small.forth"
    db 0

;;; Read char from input
;;; [out AL=char-read]
;;; [uses AX]
interactive_read_char:
    mov ah, 0
    int 0x16
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

    call try_parse_as_number
    jz .number

    mov dx, buffer
    call dictfind
    cmp bx, 0
    jz .missing

    ;; mov ax, '['
    ;; call print_char
    ;; mov ax, 0
    ;; mov al, [bx+2] ; see size; in prep for ading immediate bit
    ;; call print_number
    ;; mov ax, ']'
    ;; call print_char

    add bx, 3
    mov ax, bx
    call write_call
    jmp .loop

.number:
    call compile_lit_number
    jmp .loop
.semi:
    call write_ret
    ret

.missing:
    echo "{:Nope}"
    jmp .loop

is_semi:
    cmp word [di], ";"
    ret


compile_lit_number:
    push ax ; save lit value
    mov ax, do_lit
    call write_call
    pop ax ; restore lit value
    call write_word16
    ret

do_lit:
    pop bx
    mov ax, [bx]
    PUSH ax
    add bx, 2
    jmp bx


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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Write to [here]

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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Print to output

;;; Print number in decimal format.
;;; in: AX=number
print_number:
    push ax
    push bx
    push dx
    call .go
    pop dx
    pop bx
    pop ax
    ret
.go:
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
    ;; then drop to print this one
.print_digit:
    push ax
    mov al, dl
    add al, '0'
    call print_char
    pop ax
    ret

;;; Print null-terminated string.
;;; in: DI=string
print_string:
    push ax
    push di
.loop:
    mov al, [di]
    cmp al, 0 ; null?
    je .done
    call print_char
    inc di
    jmp .loop
.done:
    pop ax
    pop di
    ret

;;; Print newline to output
print_newline:
    push ax
    mov al, 13
    call print_char
    pop ax
    ret

;;; Print char to output; special case 13 as 10(NL);13(CR)
;;; in: AL=char
print_char:
    push ax
    push bx
    call .go
    pop bx
    pop ax
    ret
.go:
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


;;; Clear screen
cls:
    push ax
    mov ax, 0x0003 ; AH=0 AL=3 video mode 80x25
    int 0x10
    pop ax
    ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Size check...

%assign R ($-$$)  ;; Space required for above code
%assign S 3       ;; Number of sectors the bootloader loads
%assign A (S*512) ;; Therefore: Maximum space allowed
;;;%warning "Kernel size" required=R, allowed=A (#sectors=S)
%if R>A
%error "Kernel too big!" required=R, allowed=A (#sectors=S)
%endif


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; buffer & here

buffer: times 64 db 0

here: dw here_start
here_start: ; persistent heap
