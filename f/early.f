
( Stuff we need defined to code interpreter in forth )

: here      here-pointer @ ;

( Control flow )

: if        ['] 0branch compile, here 0 ,   ; immediate
: then      here swap !                     ; immediate

( Bools )

: false     0 ;
: true      65535 ;
: invert    true swap if drop false then ;

( Misc )

: entry->xt 3 + ;

( : dup-if-not-zero dup if dup then ; ) ( dont need this )
