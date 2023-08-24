
BITS 16
org 0x500

    jmp start

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Macros...

%define lastlink 0

%macro defword 1
%%name: db %1, 0 ; null
%%link: dw lastlink
db (%%link - %%name - 1) ; dont include null in count
%define lastlink %%link
%endmacro

%macro defwordimm 1
%%name: db %1, 0 ; null
%%link: dw lastlink
db ((%%link - %%name - 1) | 0x80) ; dont include null in count
%define lastlink %%link
%endmacro

%macro print 1
    push di
    jmp %%after
%%message: db %1, 0
%%after:
    mov di, %%message
    call internal_print_string
    pop di
%endmacro

%macro nl 0
    call print_newline
%endmacro

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Parameter stack -- register BP

param_stack_base equ 0xf800  ; allows 2k for call stack

init_param_stack:
    mov bp, param_stack_base
    ret

%macro PUSH 1 ; TODO: rename pspush?
    sub bp, 2
    mov [bp], %1
%endmacro

%macro POP 1
    mov %1, [bp]
    add bp, 2
    call check_ps_underflow
%endmacro

check_ps_underflow:
    cmp bp, param_stack_base
    ja .underflow
    ret
.underflow:
    print "stack underflow."
    nl
    jmp _crash

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Words start here...
;;; Convension to use "_" prefixed labels for asm entry to forth words
;;; Taking arguments & return result using the parameter-stack

echo_enabled: dw 0

defword "echo-enabled" ; ( -- addr )
    mov bx, echo_enabled
    PUSH bx
    ret

defword "echo-off"
echo_off:
    mov byte [echo_enabled], 0
    ret

defword "echo-on"
    mov byte [echo_enabled], 1
    ret

defword "welcome"
    print "Welcome to Nick's Forth-like thing..."
    nl
    ret

defword "expect-failed"
    print "Expect failed, got: "
    ret

defword "todo" ;; TODO: need strings so we can avoid these specific messages
    print "TODO: "
    ret

defword "crash"
_crash:
    print "**We have crashed!"
    nl
.loop:
    call echo_off
    call read_char ; avoiding tight loop which spins laptop fans
    jmp .loop

is_startup_complete: dw 0
defword "startup-is-complete" ;; TODO: candidate for hidden word
    mov byte [is_startup_complete], 1
    ret

defword "crash-only-during-startup"
_crash_only_during_startup:
    cmp byte [is_startup_complete], 0
    jz _crash
    ret

defword "+"
_add:
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
    mov al, ' '
    call print_char
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

defword "over"
    POP ax
    POP bx
    PUSH bx
    PUSH ax
    PUSH bx
    ret

defword "drop"
    POP ax
    ret

defword ":"
    jmp colon_intepreter


defwordimm "[']"
    call _word_find
    POP ax
    add ax, 3
    PUSH ax
    call _literal
    ret

defword "0branch"
_0branch:
    pop bx
    POP cx
    cmp cx, 0
    jz .no
    add bx, 2 ; skip over target pointer, and continue
    jmp bx
.no:
    mov bx, [bx]
    jmp bx ; branch to target

defwordimm "br"
    call _word_find
    POP bx
    push bx
    mov ax, _branch
    PUSH ax
    call _compile_comma
    pop bx
    add bx, 3
    mov ax, bx
    PUSH ax
    call __comma
    ret

_branch:
    pop bx
    mov bx, [bx]
    jmp bx


;;; Create dictionary entry for new word, in DI=word-name, uses BX
internal_create_entry:
    push di
    call strlen ; -> AX
    pop di
    push ax ; save length
    call write_string
    mov ax, [dictionary]
    mov bx, [here]
    mov [dictionary], bx
    PUSH ax
    call __comma ; link
    pop ax ; restore length
    call write_byte
    ret

defword "exit"
_exit:
    pop bx ; and ignore
    ret

;;; compile call to execution token on top of stack
defword "compile,"
_compile_comma:
    POP ax
    call internal_write_call ;; TODO: inline
    ret

defword "words"
_words:
    mov bx, [dictionary]
.loop:
    mov cl, [bx+2]
    and cl, 0x7f
    mov ch, 0
    mov di, bx
    sub di, cx
    dec di ; null
    call internal_print_string
    mov al, ' '
    call print_char
    mov bx, [bx] ; traverse link
    cmp bx, 0
    jnz .loop
    call print_newline
    ret

defword "emit"
    POP ax
    call print_char
    ret

defword "char"
    call t_word
    POP bx
    mov ah, 0
    mov al, [bx]
    PUSH ax
    ret

defwordimm "[char]"
    call t_word
    POP bx
    mov ah, 0
    mov al, [bx]
    PUSH ax
    call _literal
    ret

defword "lit"
_lit:
    pop bx
    mov ax, [bx]
    PUSH ax
    add bx, 2
    jmp bx

;;; write a 16-bit word into the heap ; TODO: move this into forth
defword ","
__comma:
    POP ax
    mov bx, [here]
    mov [bx], ax
    add word [here], 2
    ret
    ;; version using more primitive steps... (bit excessive)
    ;; call _here_pointer
    ;; call _fetch
    ;; call _store
    ;; call _lit
    ;; dw 2
    ;; call _here_pointer
    ;; call _fetch
    ;; call _add
    ;; call _here_pointer
    ;; call _store
    ;; ret

defword "here-pointer"
_here_pointer:
    mov bx, here
    PUSH bx
    ret

defword "@"
_fetch:
    POP bx
    mov ax, [bx]
    PUSH ax
    ret

defword "!"
_store:
    POP bx
    POP ax
    mov [bx], ax
    ret

;;defword "word"
t_word: ;; t for transient
    call internal_read_word ;; TODO inline
    mov ax, buffer
    PUSH ax ;; transient buffer; for _find/create
    ret

;;defword "find" -- TODO: make a standard compliant findx
t_find: ;; t for transient
    POP dx
    PUSH dx
    call internal_dictfind ;; TODO: inline
    cmp bx, 0
    jz .missing
    POP dx
    PUSH bx
    ret
.missing:
    print "**No such word: "
    POP di
    call internal_print_string
    nl
    call _crash_only_during_startup
    mov ax, _missing-3 ;; hack to get from the code pointer to the entry pointer
    PUSH ax
    ret

_missing:
    print "**Missing**"
    nl
    ret

defword "constant"
    call t_word
    POP di
    call internal_create_entry
    call _lit
    dw _lit
    call _compile_comma
    call __comma
    call _lit
    dw _exit
    call _compile_comma
    ret

defword "word-find"
_word_find:
    call t_word
    call t_find
    ret

defword "'" ;; should be immediate? NO
_tick:
    call _word_find
    POP bx
    add bx, 3 ;; TODO: factor this +3 pattern to get XT
    PUSH bx
    ret

defword "execute"
    POP bx
    jmp bx

defword "immediate?"
    call _word_find
    call _test_immediate_flag
    ret

defword "test-immediate-flag"
_test_immediate_flag:
    POP bx
    mov al, [bx+2]
    cmp al, 0x80
    ja .yes
    jmp .no
.yes:
    mov ax, 0xffff ; true
    PUSH ax
    ret
.no:
    mov ax, 0 ; false
    PUSH ax
    ret

defword "latest-entry"
_latest_entry:
    mov bx, [dictionary]
    PUSH bx
    ret

defword "immediate"
    call _latest_entry
    call _flip_immediate_flag
    ret

defword "immediate^"
    call _word_find
    call _flip_immediate_flag
    ret

defword "flip-immediate-flag"
_flip_immediate_flag:
    POP bx
    mov al, [bx+2]
    xor al, 0x80
    mov [bx+2], al
    ret

defwordimm "literal"
_literal:
    POP ax
    push ax ; save lit value
    mov ax, _lit
    PUSH ax
    call _compile_comma
    pop ax ; restore lit value
    PUSH ax
    call __comma
    ret

defwordimm "("
.loop:
    call t_word
    POP di
    cmp word [di], ")"
    jz .close
    jmp .loop
.close:
    ret


defword "entry->name"
_entry_name: ;; TODO: use this in dictfind
    POP bx
    mov ch, 0
    mov cl, [bx+2]
    and cl, 0x7f
    mov di, bx
    sub di, cx
    dec di ; subtract 1 more for the null
    PUSH di
    ret

defword "print-string"
_print_string:
    POP dx
    call internal_print_string
    ret

defword "c@"
_c_at:
    POP bx
    mov ah, 0
    mov al, [bx]
    PUSH ax
    ret

defword ".h" ; print byte in hex
_dot_h:
    POP ax
    mov ah, 0
    push ax
    push ax
    ;mov al, '['
    ;call print_char
    ;; hi nibble
    pop di
    and di, 0xf0
    shr di, 4
    mov al, [.hex+di]
    call print_char
    ;; lo nibble
    pop di
    and di, 0xf
    mov al, [.hex+di]
    call print_char
    ;mov al, ']'
    ;call print_char
    mov al, ' '
    call print_char
    ret
.hex db "0123456789abcdef"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; start

start:
    call init_param_stack
    call cls
.loop:
    call t_word
    POP dx
    call try_parse_as_number
    jnz .nan
    PUSH ax
    jmp .loop
.nan:
    PUSH dx
    call t_find
    POP bx
    ;; execute code at bx+3
    add bx, 3
    call bx
    jmp .loop

;;; Try to parse a string as a number
;;; [in DX=string-to-be-tested, out Z=yes-number, DX:AX=number]
;;; [uses BL, SI, BX, CX]
try_parse_as_number: ; TODO: code in forth
    push dx
    call .run
    pop dx
    ret
.run:
    mov si, dx
    mov ax, 0
    mov bh, 0
    mov cx, 10
.loop:
    mov bl, [si]
    cmp bl, 0 ; null
    jnz .continue
    ;; reached null; every char was a digit; return YES
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
internal_dictfind:
    mov di, dx
    call strlen ; ax=len
    mov bx, [dictionary]
.loop:
    mov cl, [bx+2]
    and cl, 0x7f
    cmp al, cl ; 8bit length comapre
    jnz .next
    ;; length matches; compare names
    mov si, dx ; si=sought name
    mov di, bx
    sub di, ax
    dec di ; subtract 1 more for the null
    ;; now di=this entry name
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

colon_intepreter: ; TODO: move this towards forth style
    call t_word
    POP di
    call internal_create_entry
.loop:
    call t_word
    POP dx
    mov di, dx
    call is_semi
    jz .semi
    call try_parse_as_number
    jz .number
    PUSH dx
    call t_find
    call _test_immediate_flag
    POP ax
    cmp ax, 0
    jnz .immediate
    add bx, 3
    mov ax, bx
    PUSH ax
    call _compile_comma
    jmp .loop
.immediate:
    add bx, 3
    call bx
    jmp .loop
.number:
    PUSH ax
    call _literal
    jmp .loop
.semi:
    ;;call write_ret ;; optimization!
    mov ax, _exit
    PUSH ax
    call _compile_comma
    ret

is_semi:
    cmp word [di], ";"
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
    mov ax, 0
    call write_byte ; null
    ret

;;; in AX=absolute-address-to-call
internal_write_call:
    push ax
    mov al, 0xe8 ; x86 encoding for "call"
    call write_byte
    pop ax
    sub ax, [here] ; make it relative
    sub ax, 2
    PUSH ax
    call __comma
    ret

;write_ret:
;    mov al, 0xc3 ; x86 encoding for "ret"
;    call write_byte
;    ret

;;; Write byte to [here], in AL=byte, uses BX
write_byte:
    mov bx, [here]
    mov [bx], al
    inc word [here]
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Reading input...

;;; Read word from keyboard into buffer memory -- prefer _word
;;; [uses AX,DI]
internal_read_word:
    mov di, buffer
.skip:
    call read_char
    cmp al, 0x21
    jb .skip ; skip leading white-space
.loop:
    cmp al, 0x21
    jb .done ; stop at white-space
    mov [di], al
    inc di
    call read_char
    jmp .loop
.done:
    mov byte [di], 0 ; null
    ret

read_char:
    call [read_char_indirection]
    cmp byte [echo_enabled], 0
    jz .ret
    call print_char ; echo
.ret:
    ret

read_char_indirection: dw startup_read_char

startup_read_char:
    mov bx, [builtin]
    mov al, [bx]
    cmp al, 0
    jz .interactive
    inc word [builtin]
    ret
.interactive:
    mov word [read_char_indirection], interactive_read_char
    jmp interactive_read_char

builtin: dw builtin_data
builtin_data:
    incbin "src/predefined.f"
    incbin "src/unimplemented.f"
    incbin "src/regression.f"
    incbin "src/my-letter-F.f"
    ;incbin "src/dump.f"
    incbin "src/start.f"
    incbin "src/play.f"
    db 0

;;; Read char from input
;;; [out AL=char-read]
;;; [uses AX]
interactive_read_char:
    mov ah, 0
    int 0x16
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
internal_print_string:
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
    pop di
    pop ax
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


buffer: times 64 db 0 ;; must be before size check. why??

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Size check...

%assign R ($-$$)  ;; Space required for above code
%assign S 23       ;; Number of sectors the bootloader loads
%assign A (S*512) ;; Therefore: Maximum space allowed
;;;%warning "Kernel size" required=R, allowed=A (#sectors=S)
%if R>A
%error "Kernel too big!" required=R, allowed=A (#sectors=S)
%endif

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; buffer & here

dictionary: dw lastlink
here: dw here_start
here_start: ; persistent heap
