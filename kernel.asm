
    %include "layout.asm"

    bits 16
    org kernel_load_address

    jmp start

%macro print 1
    push di
    jmp %%after
%%message: db %1, 0
%%after:
    mov di, %%message
    call internal_print_string
    pop di
%endmacro

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Dictionary entry
;;; Header layout:
;;; (1) name (null terminated string)
;;; (2) link-word (pointer to previous XT or 0)
;;; (3) name-length/flags byte : length (not including null), max 63
;;; Compiled code follow directly. Links and XT point here.

no_flags equ 0
immediate_flag equ 0x40
hidden_flag equ 0x80

%define lastxt 0

%macro defwordWithFlags 2
%%name: db %2, 0 ; null
%%link: dw lastxt
db ((%%link - %%name - 1) | %1) ; dont include null in count; or-in flags
%%xt:
%define lastxt %%xt
%endmacro

%macro defword 1
defwordWithFlags (no_flags), %1
%endmacro

%macro defwordHidden 1
defwordWithFlags (hidden_flag), %1
%endmacro

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Termination

defword "reset"
_reset:
    int 0x19
.loop:
    jmp .loop

defword "bye"
_bye:
    mov ax, 0x5307
    mov bx, 0x0001
    mov cx, 0x0003
    int 0x15
.loop:
    jmp .loop

defword "crash"
_crash:
    print "We have crashed. (any key will quit)"
    call _cr
.loop:
    call read_char_interactive ; wait for a key to be pressed, then quit system
    jmp _bye

is_startup_complete: dw 0
defword "startup-is-complete"
    mov byte [is_startup_complete], 1
    ret

defword "crash-only-during-startup"
_crash_only_during_startup:
    cmp byte [is_startup_complete], 0
    jz _crash
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Parameter stack (register: bp)

param_stack_base equ 0xf800  ; allows 2k for call stack

init_param_stack:
    mov bp, param_stack_base
    ret

%macro pspush 1
    sub bp, 2
    mov [bp], %1
%endmacro

defwordHidden "underflow?"
check_ps_underflow:
    cmp bp, param_stack_base
    jb .ok
    sub bp, 2
    mov word [bp], 0
    print "stack underflow."
    call _cr
    call _crash_only_during_startup
.ok:
    ret

%macro pspop 1
    call check_ps_underflow
    mov %1, [bp]
    add bp, 2
%endmacro

defword "sp" ; ( -- addr )
    mov ax, bp
    pspush ax
    ret

defword "sp0" ; ( -- addr )
    mov ax, param_stack_base
    pspush ax
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Stack manipulation

defword "dup"
_dup:
    pspop ax
    pspush ax
    pspush ax
    ret

defword "swap"
_swap:
    pspop bx
    pspop ax
    pspush bx
    pspush ax
    ret

defword "drop"
_drop:
    pspop ax
    ret

defword "over"
_over:
    pspop ax
    pspop bx
    pspush bx
    pspush ax
    pspush bx
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Return stack; hardware stack (call,ret,push,pop)

defword ">r"
    pspop ax
    pop bx
    push ax
    jmp bx

defword "r>"
    pop bx
    pop ax
    pspush ax
    jmp bx

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Special numbers

defword "0"
    call _lit
    dw 0
    ret

defword "1"
    call _lit
    dw 1
    ret

defword "bl" ; ascii code for space
    call _lit
    dw 32
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Numeric operations; TODO: M*, general shifts, bitwise-ops

defword "xor"
    pspop bx
    pspop ax
    xor ax, bx
    pspush ax
    ret

defword "/2"
    pspop ax
    shr ax, 1
    pspush ax
    ret

defword "+"
    pspop bx
    pspop ax
    add ax, bx
    pspush ax
    ret

defword "-"
_minus:
    pspop bx
    pspop ax
    sub ax, bx
    pspush ax
    ret

defword "*"
    pspop bx
    pspop ax
    mul bx ; ax = ax*bx
    pspush ax
    ret

defword "/mod"
    pspop bx
    pspop ax
    mov dx, 0
    div bx ; dx:ax / bx. quotiant->ax, remainder->dx
    pspush dx
    pspush ax
    ret

defword "<"
    pspop bx
    pspop ax
    cmp ax, bx
    mov ax, 0xffff ; true
    jl isLess
    mov ax, 0 ; false
isLess:
    pspush ax
    ret

defword "="
    pspop bx
    pspop ax
    cmp ax, bx
    mov ax, 0xffff ; true
    jz isEq
    mov ax, 0 ; false
isEq:
    pspush ax
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Fetch and store

defword "@"
_fetch:
    pspop bx
    mov ax, [bx]
    pspush ax
    ret

defword "!"
    pspop bx
    pspop ax
    mov [bx], ax
    ret

defword "c@"
_c_fetch:
    pspop bx
    mov ah, 0
    mov al, [bx]
    pspush ax
    ret

defword "c!"
    pspop bx
    pspop ax
    mov [bx], al
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Heap [here]

here: dw here_start

defword "here-pointer"
    mov bx, here
    pspush bx
    ret

defword "," ; write a 16-bit word to [here]
_comma:
    pspop ax
    mov bx, [here]
    mov [bx], ax
    add word [here], 2
    ret

defword "c," ; write byte to [here]
_c_comma:
    pspop al
    mov bx, [here]
    mov [bx], al
    inc word [here]
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Threading model and control flow

defword "lit" ; embed literal in threaded instruction stream
_lit:
    pop bx
    mov ax, [bx]
    pspush ax
    add bx, 2
    jmp bx

defword "execute"
_execute:
    pspop bx
    jmp bx

_exit:
    pop bx ; and ignore
    ret

defword "0branch" ; or else looks "see" displays wrong
_0branch: ; relative
    pop bx
    pspop cx
    cmp cx, 0
    jz .no
    add bx, 2 ; skip over target pointer, and continue
    jmp bx
.no:
    add bx, [bx] ; add relative offset (will be backpatched in by "then/else")
    jmp bx ; branch to target


defword "branchR" ; used by else & string compilation
_branchR:
    pop bx
    add bx, [bx] ; add relative offset
    jmp bx ; branch to target


defword "branchA" ; used by tail -- TODO: avoid
_branchA:
    pop bx
    mov bx, [bx]
    jmp bx

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Compilation

defword "ret," ; TODO: add "jump," and use for "tail"
_write_ret:
    call _lit
    dw 0xc3 ; x86 encoding for "ret"
    call _c_comma
    ret

defword "compile," ; ( absolute-address-to-call -- )
_compile_comma:
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
    call _c_comma
    ret

_abs_to_rel: ; ( addr-abs -> addr-rel )
    pspop ax
    sub ax, [here] ; make it relative
    sub ax, 3      ; to the end of the 3 byte instruction
    pspush ax
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Dictionary: traversal + name/flag access

defword "xt->name" ; ( xt -- string )
_xt_name:
    pspop bx
    mov ch, 0
    mov cl, [bx-1] ; size byte -1 from xt
    and cl, ~(immediate_flag | hidden_flag)
    sub bx, 4 ; (1) null, (2) link pointer, (1) size byte
    sub bx, cx
    pspush bx
    ret

defword "xt->next" ; ( 0|xt1 -- 0|xt2 )
_xt_next:
    call _dup
    call _if
    jz .ret
    call _lit
    dw 3
    call _minus
    call _fetch
.ret:
    ret

defword "immediate?" ; ( xt -- bool )
_immediate_query:
    pspop bx
    mov al, [bx-1]
    and al, immediate_flag
    jnz .yes
    jmp .no
.yes:
    mov ax, 0xffff ; true
    pspush ax
    ret
.no:
    mov ax, 0 ; false
    pspush ax
    ret

defword "hidden?" ; ( xt -- bool )
_hidden_query:
    pspop bx
    mov al, [bx-1]
    and al, hidden_flag
    jnz .yes
    jmp .no
.yes:
    mov ax, 0xffff ; true
    pspush ax
    ret
.no:
    mov ax, 0 ; false
    pspush ax
    ret

defword "immediate^"
_immediate_flip:
    pspop bx
    ;; size/flag byte -1 from xt
    mov al, [bx-1]
    xor al, immediate_flag
    mov [bx-1], al
    ret

defword "hidden^"
_hidden_flip:
    pspop bx
    ;; size/flag byte -1 from xt
    mov al, [bx-1]
    xor al, hidden_flag
    mov [bx-1], al
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; New dictionary entries

_write_link:
    mov ax, [dictionary]
    mov bx, [here]
    add bx, 3
    mov [dictionary], bx
    pspush ax
    call _comma ; link
    ret

defword "latest" ; ( -- xt )
_latest:
    mov bx, [dictionary]
    pspush bx
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Input

defword "key"
_key:
    jmp [key_indirect]

defword "set-key" ; ( xt -- )
    pspop ax
    mov [key_indirect], ax
    ret

defword "get-key" ; ( -- xt )
    mov ax, [key_indirect]
    pspush ax
    ret

key_indirect: dw _key0

_key0:
    call _read_char
    call _echo_when_enabled
    ret

_echo_when_enabled:
    call _echo_enabled
    call _fetch
    call _if
    jnz _echo
    ret

_echo:
    call _dup
    call _emit
    ret

_read_char:
    call [read_char_indirection]
    mov ah, 0
    pspush ax
    ret

read_char_indirection: dw read_char_0  ; out: -> AL

read_char_0: ; first read from embedded string
    mov bx, [builtin]
    mov al, [bx]
    cmp al, 0
    jz .become_interactive
    inc word [builtin]
    ret
.become_interactive:
    mov word [read_char_indirection], read_char_interactive
read_char_interactive:
    mov ah, 0
    int 0x16
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Output

echo_enabled: dw 0

defword "echo-enabled" ; ( -- addr )
_echo_enabled:
    mov bx, echo_enabled
    pspush bx
    ret

defword "echo-off" ;; TODO: To Forth
    mov byte [echo_enabled], 0
    ret

defword "echo-on"
    mov byte [echo_enabled], 1
    ret

defword "emit" ; ( char -- ) ; emit ascii char
_emit:
    pspop ax
    cmp ax, 13
    jz _cr
    cmp ax, 10
    jz _cr
    jmp raw_output_char

defword "cr"
_cr:
    mov al,  10
    call raw_output_char
    mov al,  13
    call raw_output_char
    ret

raw_output_char: ; in: AL=char,
    mov ah, 0x0e ; Function: Teletype output
    mov bh, 0
    int 0x10
    ret

defword "cls" ; clear screen
_cls:
    push ax
    mov ax, 0x0003 ; AH=0 AL=3 video mode 80x25
    int 0x10
    pop ax
    ret

defword "type" ;; TODO: move to forth
_type:
    pspop di
    call internal_print_string
    ret

internal_print_string: ; in: DI=string; print null-terminated string.
    push ax
    push di
.loop:
    mov al, [di]
    cmp al, 0 ; null?
    je .done
    call raw_output_char
    inc di
    jmp .loop
.done:
    pop di
    pop ax
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Start (word-find-execute-loop)

warm_addr equ 0x8000
warm_mark equ 0x2a2a ; "**"

start:
    cmp word [warm_addr], warm_mark
    jz .warm
.cold:
    call _cls
    mov word [warm_addr], warm_mark
.warm: ;; TODO: try preserve defined words on warm reset. by not resetiing latest and here
    call init_param_stack
    push _bye
.loop:
    call _transient_word
    call _dup
    call _find
    call _dup
    call _if
    jz .missing
    call _swap
    call _drop
    call _execute
    jmp .loop
.missing:
    call _drop
    call _lit
    dw '#'  ;; kernel is reporting the error
    call _emit
    call _type
    call _lit
    dw '?' ;; standard ? error
    call _emit
    call _cr
    call _crash_only_during_startup
    jmp .loop

_if:
    pspop ax
    cmp ax, 0
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

%assign X ($-$$)
;%warning X "- After Sorted"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; word (GOAL: not in Asm)

defword "transient-word" ; ( "word " -- here )
_transient_word:
    call internal_read_word
    mov ax, [here]
    pspush ax
    ret

internal_read_word: ; using "key" into buffer memory
    mov di, [here]
.skip:
    call .key
    pspop ax
    cmp al, 0x21
    jb .skip ; skip leading white-space
.loop:
    cmp al, 0x21
    jb .done ; stop at white-space
    mov [di], al
    inc di
    call .key
    pspop ax
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; find (GOAL: not in Asm)

defword "find" ; ( s -- xt' )
_find:
    call _latest ; ( s xt )
.loop:
    call _dup
    call _if ; ( s xt )
    jz .missing
    call _dup
    call _hidden_query
    call _if
    jnz .next
    call _over
    call _over ; ( s xt s xt )
    call _xt_name ; ( s xt s s' )
    call _s_equals
    call _if ; ( s xt )
    jz .next
    call _swap
    call _drop ; ( xt' ) Found it !
    ret
.next:
    call _xt_next ; ( s xt )
    jmp .loop
.missing: ; ( s 0 )
    call _drop
    call _drop
    call _lit
    dw 0
    ret

defword "find!"
_find_or_crash:
    call _dup
    call _find
    call _dup
    call _if
    jz .missing
    call _swap
    call _drop
    call _exit
    ret
.missing:
    call _drop
    print "kernel.find! '"
    call _type
    print "' ?"
    call _cr
    call _crash_only_during_startup
    ret

defword "s=" ;; TODO: recode in Forth
_s_equals:
    pspop si
    pspop di
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

defword "'"
    call _transient_word
    call _find_or_crash
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; TODO: move to non transient word...

defword "entry:" ;; TODO: inline at callers
    call _word_comma
    call _entry_comma
    ret

defword "entry,"
_entry_comma:
    call _write_link    ; ( n )
    call _c_comma
    ret

defword "word," ; ( "name" -- n ) ; NON-transient ","s word to here; leaves size on stackx
_word_comma:
    call _transient_word
    call _dup           ; ( a a )
    call _strlen        ; ( a n )
    call _swap          ; ( n a )
    call _over          ; ( n a n )
    call _cover_string  ; ( n )
    ret

;;defword "strlen" ; ( name-addr -- n ) ; length of a null-terminated string
_strlen:
    pspop di
    call internal_strlen ;; INLINE
    pspush ax
    ret

internal_strlen: ; in DI=string; out AX=length
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

_cover_string:
    pspop cx ; length
    pspop di ; string, ignored -- assumed to be at [here]
    add [here], cx
    call _lit
    dw 0
    call _c_comma
    ret

dictionary: dw lastxt
builtin: dw embedded_load_address
here_start:

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Check Size

%assign R ($ - $$) ; Space required so far in this section
%assign N kernel_size_in_sectors
%assign A (N * sector_size)
;%warning "Kernel size" required=R, allowed=A (#sectors=N)
%if R>A
%error "Kernel too big!" required=R, allowed=A (#sectors=N)
%endif

    times (A - R) db 0xba ;; because embedded string data follows directory

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Embedded string data. Loaded at 0x8000

builtin_data:
    incbin "_build/forth.f"
    db 0

%assign R ($ - $$) ; Space required so far in this section
%assign N kernel_size_in_sectors + embedded_size_in_sectors
%assign A (N * sector_size)
;%warning "Embedded data size" required=R, allowed=A (#sectors=N)
%if R>A
%error "Embedded data too big!" required=R, allowed=A (#sectors=N)
%endif
