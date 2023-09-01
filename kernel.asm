
BITS 16
org 0x500

    jmp start

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Macros: print/nl

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
;;; parameter stack macros

%macro PUSH 1 ; TODO: rename pspush?
    sub bp, 2
    mov [bp], %1
%endmacro

check_ps_underflow:
    cmp bp, param_stack_base
    jb .ok
    sub bp, 2
    mov word [bp], 0
    print "stack underflow."
    nl
    call _crash_only_during_startup
.ok:
    ret

%macro POP 1
    call check_ps_underflow
    mov %1, [bp]
    add bp, 2
%endmacro

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; ASM code...

echo_enabled: dw 0

start:
    call init_param_stack
    call cls
.loop:
    call _word
    call _dup
    POP dx
    call try_parse_as_number
    jnz .nan
    PUSH ax
    call _swap
    call _drop
    jmp .loop
.nan:
    PUSH dx
    call _find
    POP bx
    cmp bx, 0
    jz .missing
    call _drop
    call bx
    jmp .loop
.missing:
    print "**(Kernel:start) No such word: "
    POP di
    call internal_print_string
    nl
    call _crash_only_during_startup
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

;;; Compare n bytes at two pointers
;;; [in CX=n, SI/DI=pointers-to-things-to-compare, out Z=same]
;;; [consumes SI, DI, CX; uses AL]
internal_cmp_n: ;; CX/SI/DI --> Z
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

;;; Reading input...
internal_read_char: ; -> AL
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

;;; Read char from input
;;; [out AL=char-read]
;;; [uses AX]
interactive_read_char:
    mov ah, 0
    int 0x16
    ret

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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Parameter stack -- register BP

param_stack_base equ 0xf800  ; allows 2k for call stack

init_param_stack:
    mov bp, param_stack_base
    ret

;;; Read word from keyboard into buffer memory -- prefer _word
;;; [uses AX,DI]
internal_read_word:
    mov di, buffer
.skip:
    ;;call internal_read_char
    call .key
    POP ax
    cmp al, 0x21
    jb .skip ; skip leading white-space
.loop:
    cmp al, 0x21
    jb .done ; stop at white-space
    mov [di], al
    inc di
    ;;call internal_read_char
    call .key
    POP ax
    jmp .loop
.done:
    mov byte [di], 0 ; null
    ret
.key:
    ;; Here we are calling from low-level ASM to a _forth word
    ;; And so we must preserve the registers being used here.
    ;; Failure to do this was the cause of the assumed string literal bug.
    push ax
    push di
    call _key
    pop di
    pop ax
    ret

;;; Compute length of a null-terminated string
;;; [in DI=string; out AX=length]
;;; [consumes DI; uses BL]
internal_strlen:
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

;;; Write byte to [here], in AL=byte, uses BX
internal_write_byte:
    mov bx, [here]
    mov [bx], al
    inc word [here]
    ret

colon_intepreter: ; TODO: move this towards forth style
    call _word
    call _create_entry
.loop:
    call _word
    POP dx
    mov di, dx
    call is_semi
    jz .semi
    call try_parse_as_number
    jz .number
    PUSH dx
    call _safe_find
    call _dup
    call _test_immediate_flag
    POP ax
    cmp ax, 0
    jnz .immediate
    call _write_abs_call
    jmp .loop
.immediate:
    POP bx
    call bx
    jmp .loop
.number:
    PUSH ax
    call _literal
    jmp .loop
.semi:
    call _write_ret ;; optimization!
    ret

is_semi:
    cmp word [di], ";"
    ret

;;; Lookup word in dictionary, return entry if found or 0 otherwise
;;; [in DX=sought-name, out BX=entry/0]
;;; [uses SI, DI, BX, CX]
internal_dictfind: ; (DX --> BX)
    mov di, dx
    PUSH di
    call _strlen ; ax=len
    POP ax
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
    call internal_cmp_n
    pop ax
    jnz .next
    add bx, 3 ; entry->xt
    ret ; BX=xt
.next:
    mov bx, [bx] ; traverse link
    cmp bx, 0
    jnz .loop
    ret ; BX=0 - not found


%assign X ($-$$)
;%warning X "- After ASM"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; primitive word defs start here
;;; Code in forth-style ASM (args/return on parameter-stack)
;;; Use '_" prefix for labels

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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; key

key_indirect: dw _key0

_key0: ; original
    call internal_read_char
    mov ah, 0
    PUSH ax
    ret

defword "key"
_key:
    jmp [key_indirect]

defword "set-key" ; ( ax -- )
    POP ax
    mov [key_indirect], ax
    ret

defword "get-key" ; ( -- ax )
    mov ax, [key_indirect]
    PUSH ax
    ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; echo-control, messages, startup, crash

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

defword "crash"
_crash:
    print "**We have crashed!"
    nl
.loop:
    call echo_off
    call internal_read_char ; avoiding tight loop which spins laptop fans
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Output

defword "emit" ; ( byte -- ) ; emit ascii char
    POP ax
    call print_char
    ret

defword "."
_dot:
    POP ax
    call print_number
    mov al, ' '
    call print_char
    ret

defword ".h" ; ( byte -- ) ; emit as 2-digit hex ; TODO: in forth
_dot_h:
    POP ax
    mov ah, 0
    push ax
    push ax
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
    ;;mov al, ' '
    ;;call print_char
    ret
.hex db "0123456789abcdef"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Stack manipulation

defword "dup"
_dup:
    POP ax
    PUSH ax
    PUSH ax
    ret

defword "swap"
_swap:
    POP bx
    POP ax
    PUSH bx
    PUSH ax
    ret

defword "over"
_over:
    POP ax
    POP bx
    PUSH bx
    PUSH ax
    PUSH bx
    ret

defword "drop"
_drop:
    POP ax
    ret

defword ">r"
    POP ax
    pop bx
    push ax
    jmp bx

defword "r>"
    pop bx
    pop ax
    PUSH ax
    jmp bx

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Numerics...

defword "/2" ; (n -- n) TODO: should not be a prim
_div2:
    POP ax
    shr ax, 1
    PUSH ax
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Control flow


defword "0branch"
_0branch:
    pop bx
    POP cx
    cmp cx, 0
    jz .no
    add bx, 2 ; skip over target pointer, and continue
    jmp bx
.no:
    add bx, [bx] ; add relative offset (backpatched in by "then")
    jmp bx ; branch to target

defword "0branch,"
    call _lit
    dw _0branch
    call _write_abs_call
    ret

defword "exit"
_exit:
    pop bx ; and ignore
    ret

defword "branchA"
_branchA: ;; TODO: deprecate, prefer _branchR. currently used by string-lit comp
    pop bx
    mov bx, [bx]
    jmp bx

;;;defword "branchA" ; when call from Forth
_branchR:
    pop bx
    add bx, [bx]
    jmp bx

defwordimm "tail"
    call _word
    call _safe_find
    call _lit
    dw _branchA ;; TODO: goal, use _branchR
    call _write_abs_call
    ;;call _abs_to_rel ;; NOPE, doesn't work
    call _comma ; TODO: need to call _abs_to_rel before commaring!
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Fetch and store

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

defword "c@"
_c_fetch:
    POP bx
    mov ah, 0
    mov al, [bx]
    PUSH ax
    ret

defword "c!"
_c_store:
    POP bx
    POP ax
    mov [bx], al
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; heap...

defword "sp" ; ( -- a )
    mov ax, bp
    PUSH ax
    ret

defword "sp0" ; ( -- a )
    mov ax, param_stack_base
    PUSH ax
    ret

here: dw here_start
defword "here-pointer"
_here_pointer:
    mov bx, here
    PUSH bx
    ret

defword "c," ;; TODO: check standard & test
_write_byte:
    POP al
    call internal_write_byte ;; TODO: inline
    ret

;;; write a 16-bit word into the heap
defword ","
_comma:
    POP ax
    mov bx, [here]
    mov [bx], ax
    add word [here], 2
    ret

defword "execute"
    POP bx
    jmp bx

defword "immediate?" ;; TODO: dont expose this...
    call _word
    call _safe_find
    call _test_immediate_flag
    ret

defword "test-immediate-flag" ;; but this, renamed as immediate?
_test_immediate_flag:
    POP bx
    mov al, [bx-1]
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

defword "immediate"
    call _latest_entry
    call _flip_immediate_flag
    ret

defword "flip-immediate-flag"
_flip_immediate_flag:
    POP bx
    ;; size/flag byte -1 from xt
    mov al, [bx-1]
    xor al, 0x80
    mov [bx-1], al
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Literals

defword "lit" ; TODO: have a byte-literal version
_lit:
    pop bx
    mov ax, [bx]
    PUSH ax
    add bx, 2
    jmp bx

defwordimm "literal"
_literal:
    POP ax
    push ax ; save lit value
    call _lit
    dw _lit
    call _write_abs_call
    pop ax ; restore lit value
    PUSH ax
    call _comma
    ret

defword "non-immediate-literal" ; TODO: imprve this
    jmp _literal

defwordimm "[char]"
    call _word
    POP bx
    mov ah, 0
    mov al, [bx]
    PUSH ax
    call _literal
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; compile,

defword "ret,"
_write_ret:
    call _lit
    dw 0xc3 ; x86 encoding for "ret"
    call _write_byte
    ret

;;; compile call to execution token on top of stack
defword "compile," ; ( absolute-address-to-call -- )
_write_abs_call:
    call _abs_to_rel
    call _write_rel_call
    ret

_write_rel_call:
    call _write_rel_call_byte
    call _comma
    ret

_write_rel_call_byte:
    call _lit
    dw 0xe8 ; x86 encoding for "call"; uses relative addressing
    call _write_byte
    ret

_abs_to_rel: ; ( addr-abs -> addr-rel )
    POP ax
    sub ax, [here] ; make it relative
    sub ax, 3      ; to the end of the 3 byte instruction
    PUSH ax
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; (New) dict/XT (grabbed!)

defword "xt->name" ; ( xt -- string )
_xt_name: ;; TODO: use this in dictfind
    POP bx
    mov ch, 0
    mov cl, [bx-1] ; size byte -1 from xt
    and cl, 0x7f
    sub bx, 4 ; (1) null, (2) link pointer, (1) size byte
    sub bx, cx
    PUSH bx
    ret

defword "latest-entry" ; ( -- xt ) ; ( TODO: rename latest-xt )
_latest_entry:
    mov bx, [dictionary]
    add bx, 3
    PUSH bx
    ret

;;defword "find" ; ( string -- 0|xt ) -- This is non standard!
_find:
    POP dx
    call internal_dictfind ;; INLINE
    PUSH bx
    ret

;; ;;defword "safe-find"
;; _safe_find: ; ( string -> xt )
;;     call _dup
;;     call _find
;;     POP bx
;;     PUSH bx
;;     cmp bx, 0
;;     jz _warn_missing
;;     call _swap
;;     call _drop
;;     ret

_safe_find: ; ( string -> xt|0 )
    jmp _find

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Dictionary entries & find


defword "strlen" ; ( name-addr -- n )
_strlen:
    POP di
    call internal_strlen ;; INLINE
    PUSH ax
    ret

defword "create-entry" ; ( name-addr -- )
_create_entry:
    call _dup           ; ( a a )
    call _strlen        ; ( a n )
    call _swap          ; ( n a )
    call _over          ; ( n a n )
    call _write_string  ; ( n )
    call _write_link    ; ( n )
    call _write_byte
    ret

_write_link:
    mov ax, [dictionary]
    mov bx, [here]
    mov [dictionary], bx
    PUSH ax
    call _comma ; link
    ret

;;; Write string to [here]
_write_string:
    POP cx ; length
    POP di ; string
.loop:
    cmp cx, 0
    jz .done
    mov ax, [di]
    call internal_write_byte
    inc di
    dec cx
    jmp .loop
.done:
    mov ax, 0
    call internal_write_byte ; null
    ret

_warn_missing:
    call _drop
    print "**(Kernel) No such word: "
    POP di
    call internal_print_string
    nl
    call _crash_only_during_startup
    mov ax, _missing
    PUSH ax
    ret

;;; not in dictionary
defword "missing"
_missing:
    print "**Missing**"
    nl
    ret

defword "word" ; ( " blank-deliminted-word " -- string-addr ) ; TODO: earlier
_word:
    call internal_read_word ;; TODO inline
    mov ax, buffer
    PUSH ax ;; transient buffer; for _find/create
    ret

defword "char"
    call _word
    POP bx
    mov ah, 0
    mov al, [bx]
    PUSH ax
    ret

defword "constant" ;; TODO: is this relocatable?
    call _word
    call _create_entry
    call _lit
    dw _lit
    call _write_abs_call
    call _comma
    call _lit
    dw _exit
    call _write_abs_call
    ret

defword "type"
    POP di
    call internal_print_string
    ret

defword "s="
_string_eq:
    POP si
    POP di
.loop:
    mov al, [si]
    mov bl, [di]
    cmp al, bl
    jnz .diff ; found a differing char, so exit false
    ;; current chars match
    cmp al, 0
    jz .same ; one char is zero (so both must be), so we reached the string ends
    inc si
    inc di
    jmp .loop
.diff:
    call _lit
    dw 0
    ret
.same:
    call _lit
    dw 1
    ret

defword ":"
    jmp colon_intepreter

defword "number?" ; ( string -- number 1 | string 0 )
    call _dup
    POP dx
    call try_parse_as_number
    jnz .nan
    PUSH ax
    call _swap
    call _drop
    mov ax, 1
    PUSH ax
    ret
.nan:
    mov ax, 0
    PUSH ax
    ret

defword "shutdown"
shutdown:
    mov ax, 0x5307
    mov bx, 0x0001
    mov cx, 0x0003
    int 0x15
.loop:
    jmp .loop

defword "reboot"
reboot:
    int 0x19
.loop:
    jmp .loop

dictionary: dw lastlink

%assign X ($-$$)
;%warning X "- After Prim Words"

buffer: times 64 db 0 ;; TODO: kill; just use here+N

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Embedded string data

builtin: dw builtin_data
builtin_data:
    incbin "f/syntax.f"
    incbin "f/interpreter.f"
    incbin "f/predefined.f"
    incbin "f/regression.f"
    incbin "f/buffer.f"
    incbin "f/tools.f"
    incbin "f/examples.f"
    incbin "f/start.f"
    incbin "f/play.f"
    db 0

%assign X ($-$$)
;%warning X "- After Embedded"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Size check...

%assign R ($-$$)  ;; Space required for above code
%assign S 30      ;; Number of sectors the bootloader loads
%assign A (S*512) ;; Therefore: Maximum space allowed
;;;%warning "Kernel size" required=R, allowed=A (#sectors=S)
%if R>A
%error "Kernel too big!" required=R, allowed=A (#sectors=S)
%endif

here_start: ; persistent heap
