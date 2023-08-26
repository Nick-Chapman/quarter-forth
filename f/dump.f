
( Tools for exploring mem and defs )

: mem ( report bytes available )
sp here -
s" Bytes available: " type
. cr
;

( Dump colon definitions )

: e8 14 16 * 8 + ;
: is-call e8 = ;

: @rel->abs
dup @ + 2 +
;

: dump-call
( s" CALL " type )
dup 1 + @rel->abs xt->name type space
3 +
;

: dump1  c@ .h ;

: dump-next ( a -- a' )
dup c@ is-call if dump-call exit then
dup 0 + dump1
1 +
;

: dump
dump-next
dump-next
dump-next
dump-next
dump-next
dump-next
dump-next
dump-next
dump-next
dump-next
dump-next
dump-next
dump-next
dump-next
dump-next
dump-next
dump-next
dump-next
dump-next
drop
cr
;
