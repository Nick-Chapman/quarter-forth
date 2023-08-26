
: here      here-pointer @ ;

: if        ['] 0branch compile, here 0 ,   ; immediate
: then      here swap !                     ; immediate

: (
key [char] ) = if exit
then br (
; immediate

(
Now we have 'paren' comments!
Above we define here/if/then, and use to define comment handling.
This file contains stuff we need to code the interpreter in forth.
)

( Bools )

: false     0 ;
: true      65535 ;
: invert    true swap if drop false then ;

( Misc )

: entry->xt 3 + ;

( : dup-if-not-zero dup if dup then ; ) ( dont need this )
