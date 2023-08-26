
( Tools for exploring mem and defs )

: mem ( report bytes available )
mes-bytes-available
sp here - . cr
;

( Dump colon definitions )

: e8 14 16 * 8 + ;
: is-call e8 = ;

: e-call
[char] C emit
[char] A emit
[char] L emit
[char] L emit
space ;

: xt->entry 3 - ;

: print-name-of-xt
xt->entry entry->name type
;

: @rel->abs
dup @ + 2 +
;

: dump-call
( e-call )
dup 1 + @rel->abs print-name-of-xt space
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
