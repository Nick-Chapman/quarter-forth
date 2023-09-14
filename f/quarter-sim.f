.." Loading quarter-sim ( " latest

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
dup get-dt ( xt' c xt ) if ." set-dt '" emit ." ' -- already set!" cr crash exit then
dt-cell ! ;

: dispatch ( c -- xt )
dup get-dt dup if ( c x ) swap drop exit then
drop ." dispatch: '" emit ." ' ?" cr crash
;

: kdx-loop
key dup [char] Q = if drop exit then
dispatch execute tail kdx-loop
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

hide 10
hide 2
hide 256
hide blank
hide dispatch
hide dt
hide dt-cell
hide get-dt
hide nop
hide set
hide set-dt
hide set-here

words-since char ) emit cr
