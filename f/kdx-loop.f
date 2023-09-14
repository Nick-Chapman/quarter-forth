
: nop ;
: blank ( n -- ) dup if 0 , 1 - tail blank then drop ;
: jump ( xt -- ) r> drop execute ;

1 1 +
constant 2

2 dup * dup * dup *
constant 256

2 1 + dup * 1 +
constant 10

here constant dt 256 blank ( dispatch table )

: dt-cell ( c -- addr ) 2 * dt + ;
: get-dt ( c -- xt ) dt-cell @ ;
: set-dt ( xt' c -- )
( dup get-dt if ." set-dt '" emit ." ' -- already set!" cr crash exit then )
dt-cell ! ;

: NOPE:dispatch ( c -- xt ) ( TODO: remove me! )
dup get-dt ( c xt|0 )
( dup 0 = if drop ." dispatch: '" emit ." ' ?" cr crash exit then )
dup 0 = if drop emit [char] ? emit cr crash exit then
swap drop exit
;

: kdx-loop
key dispatch execute tail kdx-loop
;

: set ( "c" "word" -- ) key ' swap set-dt ;
: set-here  here key set-dt ;

' nop 10 set-dt
' nop bl set-dt

set ^ key       ( 1/4 version of word )
set ? dispatch  ( 1/4 version of find )
set . emit
set * crash-only-during-startup

( compiling into the dictionry )
set , ,
set \ c,
set > compile,
set ; ret,
set : set-here

set 0 0
set 1 1
set - -
set + +
set = =
set < <
set ! !
set @ @

set B 0branch
set C c@
set D dup
set E entry,  ( str -- )
set G xt->next
set H here-pointer
set I immediate
set J jump      ( to execution token on stack )
set L literal
set M cr
set N xt->name
set O over
set P drop
set V execute
set W swap
set X exit
set Y hidden?
set Z latest

( lowercase )

set l lit ( better code? )
set b bl
set x xor

kdx-loop
