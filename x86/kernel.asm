
    %include "x86/layout.asm"

    bits 16
    org kernel_load_address

    jmp start

echo_enabled: dw 0 ;; Set to 1 to debug!

param_stack_base equ 0

start:
    mov ax, 1000h
    mov ss, ax
    mov sp, 0
    mov bp, param_stack_base

    call _cls
    call setup_dispatch_table

    push _bye
.loop:
    call _key
    call _dispatch
    call _dup
    call _if
    jz .ignore
    call _execute
    jmp .loop
.ignore:
    call _drop
    jmp .loop

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
;;; Initialize dispatch table

%macro set 2
    ;;mov word [tab + 2* %1], %2
    mov di, %1
    mov bx, %2
    call set_tab_entry_checked
%endmacro

_nop: ret

setup_dispatch_table:
    set 10 , _nop
    set 13 , _nop
    set ' ', _nop
    set '!', _store
    set '*', _multiply
    set '+', _add
    set ',', _comma
    set '-', _minus
    set '.', _emit
    set '0', _zero
    set '1', _one
    set ':', _set_tab_entry
    set ';', _write_ret
    set '<', _less_than
    set '=', _equals
    set '>', _compile_comma
    set '?', _dispatch
    set '@', _fetch
    set 'A', _crash_only_during_startup
    set 'B', _0branch
    set 'C', _c_fetch
    set 'D', _dup
    set 'E', _entry_comma
    set 'G', _xt_next
    set 'H', _here_pointer
    set 'I', _immediate_query
    set 'J', _jump
    set 'L', _lit
    set 'M', _cr
    set 'N', _xt_name
    set 'O', _over
    set 'P', _drop
    set 'V', _execute
    set 'W', _swap
    set 'X', _exit
    set 'Y', _hidden_query
    set 'Z', _latest
    set '^', _key
    set '`', _c_comma
    ret

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
;;; Parameter stack (register: bp)

%macro pspush 1
    sub bp, 2
    mov [ds:bp], %1
%endmacro

defwordHidden "underflow?"
check_ps_underflow:
    cmp bp, 0
    jnz .ok
    sub bp, 2
    mov word [ds:bp], 0
    print "stack underflow."
    call _cr
    call _crash_only_during_startup
.ok:
    ret

%macro pspop 1
    call check_ps_underflow
    mov %1, [ds:bp]
    add bp, 2
%endmacro

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; dispatch table (for KDX-loop)

dispatch_table: times 128 dw 0 ; indexed by char: 0..127

_set_tab_entry:
    call _key
    call _here
    pspop bx
    pspop di
    jmp set_tab_entry_checked

set_tab_entry_checked: ; in: di(char), bx(XT)
    mov ax, di
    and di, 0x7f ; clamp to ascii <128
    shl di, 1
    cmp word [dispatch_table + di], 0
    jnz .duplicate
    mov word [dispatch_table + di], bx
    ret
.duplicate:
    print "dispatch table entry set already for: '"
    call raw_output_char
    print "'"
    call _cr
    call _crash_only_during_startup
    ret

_dispatch_core:
    pspop di
    shl di, 1
    mov bx, [dispatch_table + di]
    pspush bx
    ret

defword "dispatch"
_dispatch:
    call _dup
    call _dispatch_core
    call _dup
    call _if
    jz .missing
    call _swap
    call _drop
    ret
.missing:
    call _drop
    call _cr
    print "dispatch,missing: '"
    call _emit
    print "'"
    call _cr
    call _crash_only_during_startup
    ret

_if:
    pspop ax
    cmp ax, 0
    ret

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

defword "sp" ; ( -- addr )
    mov ax, bp
    pspush ax
    ret

defword "sp0" ; ( -- addr )
    mov ax, param_stack_base
    pspush ax
    ret

defword "rsp" ; ( -- addr )
    mov ax, sp
    pspush ax
    ret

defword "rsp0" ; ( -- addr )
    mov ax, 0
    pspush ax
    ret

defword "as-num" ; ( x -- num ) ;; NOP for sake of Typechecking
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Stack manipulation

defword "dup"
_dup:
    mov ax, [ds:bp]
    mov [ds:bp-2], ax
    sub bp, 2
    ret

defword "swap"
_swap:
    mov ax, [ds:bp]
    mov bx, [ds:bp+2]
    mov [ds:bp], bx
    mov [ds:bp+2], ax
    ret

defword "drop"
_drop:
    call check_ps_underflow
    add bp, 2
    ret

defword "over"
_over:
    mov ax, [ds:bp+2]
    mov [ds:bp-2], ax
    sub bp, 2
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Return stack; hardware stack (call,ret,push,pop)

defword ">r"
    pspop ax
    pop bx
    push ax
    jmp bx

defword "r>"
_from_rs:
    pop bx
    pop ax
    pspush ax
    jmp bx

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Special numbers

defword "0"
_zero:
    call _lit
    dw 0
    ret

defword "1"
_one:
    call _lit
    dw 1
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Numeric operations; TODO: M*, general shifts, bitwise-ops

defword "xor"
_xor:
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
_add:
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
_multiply:
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
_less_than:
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
_equals:
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
_store:
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
_here_pointer:
    mov bx, here
    pspush bx
    ret

_here:
    call _here_pointer
    call _fetch
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

defword "execute" ; ( xt -- )
_execute:
    pspop bx
    jmp bx

defword "jump" ; ( xt -- )
_jump:
    pop ax
    pspop bx
    jmp bx

defword "exit"
_exit:
    pop ax
    ret

defword "0branch"
_0branch:
    pop bx
    pspop cx
    cmp cx, 0
    jz .no
    add bx, 2 ; skip over target pointer, and continue
    jmp bx
.no:
    add bx, [bx] ; add relative offset (will be backpatched in by "then/else")
    jmp bx


defword "branch" ; used by else & string compilation
    pop bx
    add bx, [bx] ; add relative offset
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

defword "entry," ; ( str -- )
_entry_comma:
    call _here ; ( a a')
    call _swap
    call _minus ; ( n-string-with-null )
    call _one
    call _minus ; ( n )
    call _write_link ; ( n ) -- unchanged
    call _c_comma
    ret

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
    call ensure_here_stays_behind_embedded_pointer
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

ensure_here_stays_behind_embedded_pointer:
    mov ax, [builtin]
    mov bx, [here]
    cmp ax, bx
    jna .bad
    ret
.bad:
    print "Here pointer has caught up with embedded string pointer"
    call _cr
    jmp _crash

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Output

defword "echo-enabled" ; ( -- addr )
_echo_enabled:
    mov bx, echo_enabled
    pspush bx
    ret

defword "echo-off"
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

defword "time" ; ( -- u u ) ;; wait/sync to the next 1/16s
_time:
    ;; save current time in bx
    mov ah, 0
    int 0x1A
    mov bx, dx
.loop:
    hlt ; until the next interrupt
    mov ah, 0
    int 0x1A
    ;; but that might not be a time tick, so loop until time has moved forward
    cmp dx,bx
    jz .loop
    ;; push both time words on the stack
    pspush cx
    pspush dx
    ret

 defword "KEY" ; ( -- u )
    mov ah, 0 ; block for key
    int 0x16
    pspush ax
    ret

defword "key?" ; ( -- u )
key_q:
    mov ah, 1 ; key pressed?
    int 0x16
    pspush ax
.loop:
    mov ah, 1 ; still pressed?
    int 0x16
    jz .done
    mov ah, 0 ; clear
    int 0x16
    jmp .loop
.done:
    ret

defword "set-cursor-shape" ; ( u -- )
    mov ah, 0x1
    pspop cx
    int 0x10
    ret

defword "set-cursor-position" ; ( row/col -- )
    mov ah, 0x2
    pspop dx ; row/col
    mov bh, 0 ; page
    int 0x10
    ret

defword "read-char-col" ; ( -- char col )
    mov ah, 0x8
    mov bh, 0 ; page
    int 0x10
    ;; ah: col, al: char
    mov bl, al
    mov bh, 0
    pspush bx ; char
    mov al, ah
    mov ah, 0
    pspush ax ; col
    ret

defword "write-char-col" ; ( char col -- )
    mov ah, 0x9
    pspop bl ; bg;fg col
    pspop al
    mov bh, 0 ; page
    mov cx, 1 ; #time to print
    int 0x10
    ret

dictionary: dw lastxt
builtin: dw embedded_load_address
here_start:

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Check Size

;; Size allocated in layout.asm:
%assign As kernel_size_in_sectors       ; in sectors
%assign Ab (As * sector_size)           ; in bytes

;; Size we actually require:
%assign Rb ($ - $$)                     ; in bytes
%assign Rs (1 + ((Rb-1)/sector_size))   ; in sectors

%if Rb>Ab
%error Kernel sectors allocated: As, required: Rs
%endif

    times (Ab - Rb) db 0xba ;; because embedded string data follows directory

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Embedded string data. Loaded at 0x8000

builtin_data:
    incbin FORTH
    db 0

;; Size allocated in layout.asm:
%assign As embedded_size_in_sectors
%assign Ab (As * sector_size)

;; Size we actually require:
%assign Rb ($ - builtin_data)           ; in bytes
%assign Rs (1 + ((Rb-1)/sector_size))   ; in sectors

%if Rb>Ab
%error Forth sectors allocated: As, required: Rs
%endif
